#!/usr/bin/env bash
# =============================================================================
# Full Backup Orchestrator — PopCut
# =============================================================================
#
# Runs postgres, redis, and minio backups sequentially, creates a unified
# manifest with checksums and timestamps, and reports overall status.
#
# Usage:
#   ./full-backup.sh [--dry-run] [--skip-postgres] [--skip-redis] [--skip-minio]
#
# Environment variables:
#   All variables from postgres-backup.sh, redis-backup.sh, minio-backup.sh
#   are respected. See those scripts for details.
#
#   BACKUP_DIR  — Root staging directory (default: /tmp/popcut-backups)
#   LOG_DIR     — Log directory (default: /var/log/popcut/backups)
#   EMAIL_TO    — Notification email on failure (optional)
#
# Requirements:
#   - postgres-backup.sh in same directory
#   - redis-backup.sh in same directory
#   - minio-backup.sh in same directory
#   - sha256sum
# =============================================================================

set -euo pipefail

# --- Config ----------------------------------------------------------------
BACKUP_DIR="${BACKUP_DIR:-/tmp/popcut-backups}"
LOG_DIR="${LOG_DIR:-/var/log/popcut/backups}"
EMAIL_TO="${EMAIL_TO:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DATE_PART="$(date +%Y/%m/%d)"

DRY_RUN=false
SKIP_POSTGRES=false
SKIP_REDIS=false
SKIP_MINIO=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)    DRY_RUN=true ;;
        --skip-postgres) SKIP_POSTGRES=true ;;
        --skip-redis)    SKIP_REDIS=true ;;
        --skip-minio)    SKIP_MINIO=true ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

export DRY_RUN
export BACKUP_DIR
export LOG_DIR

# --- Logging ---------------------------------------------------------------
mkdir -p "$LOG_DIR" "$BACKUP_DIR/manifests"
LOG_FILE="$LOG_DIR/full-backup-$TIMESTAMP.log"

log() {
    local level="$1"
    shift
    local message="[$TIMESTAMP] [$level] $*"
    echo "$message" | tee -a "$LOG_FILE"
}

info()  { log "INFO"  "$@"; }
warn()  { log "WARN"  "$@"; }
error() { log "ERROR" "$@"; }

# --- Manifest ---------------------------------------------------------------
MANIFEST_FILE="$BACKUP_DIR/manifests/manifest-$TIMESTAMP.txt"

init_manifest() {
    mkdir -p "$BACKUP_DIR/manifests"
    {
        echo "======================================================================"
        echo "  PopCut Full Backup Manifest"
        echo "======================================================================"
        echo "Started at:    $TIMESTAMP"
        echo "Date:          $(date)"
        echo "Hostname:      $(hostname)"
        echo "User:          $(whoami)"
        echo "Backup Dir:    $BACKUP_DIR"
        echo "Dry Run:       $DRY_RUN"
        echo "======================================================================"
        echo ""
    } > "$MANIFEST_FILE"
    info "Manifest initialized: $MANIFEST_FILE"
}

append_manifest() {
    local component="$1"
    local status="$2"
    local checksum="${3:-}"
    local size_bytes="${4:-}"
    local duration="${5:-}"

    {
        echo "Component:     $component"
        echo "Status:        $status"
        [[ -n "$checksum" ]]  && echo "Checksum:      $checksum"
        [[ -n "$size_bytes" ]] && echo "Size (bytes):  $size_bytes"
        [[ -n "$duration" ]]   && echo "Duration (s):  $duration"
        echo "---"
    } >> "$MANIFEST_FILE"
}

finalize_manifest() {
    local end_ts="$(date +%Y%m%d-%H%M%S)"
    {
        echo ""
        echo "======================================================================"
        echo "Completed at:  $end_ts"
        echo "======================================================================"
    } >> "$MANIFEST_FILE"

    # Upload manifest
    local s3_manifest_path="manifests/manifest-$TIMESTAMP.txt"
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would upload manifest to s3://${S3_BUCKET:-popcut-backups}/$s3_manifest_path"
    else
        aws s3 cp "$MANIFEST_FILE" "s3://${S3_BUCKET:-popcut-backups}/$s3_manifest_path" \
            --endpoint-url "${S3_ENDPOINT:-http://localhost:9000}" >>"$LOG_FILE" 2>&1 && \
            info "Manifest uploaded to S3" || \
            warn "Failed to upload manifest to S3"
    fi
}

# --- Prerequisites ---------------------------------------------------------
check_prereqs() {
    local missing=false

    if [[ ! -x "$SCRIPT_DIR/postgres-backup.sh" ]]; then
        error "Missing: $SCRIPT_DIR/postgres-backup.sh"
        missing=true
    fi
    if [[ ! -x "$SCRIPT_DIR/redis-backup.sh" ]]; then
        error "Missing: $SCRIPT_DIR/redis-backup.sh"
        missing=true
    fi
    if [[ ! -x "$SCRIPT_DIR/minio-backup.sh" ]]; then
        error "Missing: $SCRIPT_DIR/minio-backup.sh"
        missing=true
    fi
    if ! command -v sha256sum &>/dev/null; then
        error "Missing: sha256sum"
        missing=true
    fi

    if [[ "$missing" == true ]]; then
        error "Prerequisites missing. Aborting."
        exit 1
    fi
    info "All prerequisites met"
}

# --- Run a component and record status ------------------------------------
OVERALL_STATUS=0

run_component() {
    local name="$1"
    local script="$2"
    local skip_var="$3"

    if [[ "$skip_var" == true ]]; then
        info "Skipping $name (--skip-$name specified)"
        append_manifest "$name" "SKIPPED"
        return
    fi

    info "Starting $name backup ..."
    local start_ts
    start_ts="$(date +%s)"

    set +e
    bash "$script" ${DRY_RUN:+--dry-run} 2>&1 | tee -a "$LOG_FILE"
    local exit_code="${PIPESTATUS[0]}"
    set -e

    local end_ts
    end_ts="$(date +%s)"
    local duration=$((end_ts - start_ts))

    if [[ "$exit_code" -eq 0 ]]; then
        info "$name backup completed successfully (${duration}s)"
        # Grab last log entry for checksum if available
        local checksum
        checksum="$(tail -20 "$LOG_FILE" | grep -i 'checksum' | tail -1 | awk '{print $NF}')"
        append_manifest "$name" "SUCCESS" "$checksum" "" "$duration"
    else
        error "$name backup FAILED (${duration}s, exit $exit_code)"
        append_manifest "$name" "FAILED" "" "" "$duration"
        OVERALL_STATUS=1
    fi
}

# --- Notification -----------------------------------------------------------
notify() {
    local subject status_text
    if [[ "$OVERALL_STATUS" -eq 0 ]]; then
        subject="[SUCCESS] PopCut Full Backup — $TIMESTAMP"
        status_text="completed successfully"
    else
        subject="[FAILED] PopCut Full Backup — $TIMESTAMP"
        status_text="FAILED (one or more components)"
    fi

    local body="Full backup $status_text at $TIMESTAMP.\n\nLog: $LOG_FILE\nManifest: $MANIFEST_FILE"

    if [[ -n "$EMAIL_TO" ]]; then
        if command -v mail &>/dev/null; then
            echo -e "$body" | mail -s "$subject" "$EMAIL_TO"
        elif command -v sendmail &>/dev/null; then
            {
                echo "Subject: $subject"
                echo "To: $EMAIL_TO"
                echo ""
                echo -e "$body"
            } | sendmail -t
        else
            warn "No mail command. Cannot send notification."
        fi
        info "Notification sent to $EMAIL_TO"
    fi
}

# --- Main -------------------------------------------------------------------
main() {
    echo "======================================================================"
    echo "  PopCut Full Backup Orchestrator"
    echo "  Timestamp: $TIMESTAMP"
    echo "======================================================================"

    if [[ "$DRY_RUN" == true ]]; then
        echo "  ** DRY-RUN MODE **"
        echo "======================================================================"
    fi

    check_prereqs
    init_manifest

    run_component "postgres" "$SCRIPT_DIR/postgres-backup.sh" "$SKIP_POSTGRES"
    run_component "redis"    "$SCRIPT_DIR/redis-backup.sh"    "$SKIP_REDIS"
    run_component "minio"    "$SCRIPT_DIR/minio-backup.sh"    "$SKIP_MINIO"

    finalize_manifest
    notify

    if [[ "$OVERALL_STATUS" -eq 0 ]]; then
        info "Full backup completed successfully. Manifest: $MANIFEST_FILE"
        echo "======================================================================"
    else
        error "Full backup completed with errors. Check manifest: $MANIFEST_FILE"
        echo "======================================================================"
        exit 1
    fi
}

main
