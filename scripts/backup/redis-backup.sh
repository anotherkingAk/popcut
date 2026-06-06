#!/usr/bin/env bash
# =============================================================================
# Redis Backup Script — PopCut
# =============================================================================
#
# Usage:
#   ./redis-backup.sh [--dry-run]
#
# Environment variables:
#   REDIS_HOST      — Redis host (default: localhost)
#   REDIS_PORT      — Redis port (default: 6379)
#   REDIS_PASSWORD  — Redis password (optional)
#   REDIS_DATA_DIR  — Redis data directory containing dump.rdb (default: /data/redis)
#   S3_ENDPOINT     — S3-compatible endpoint URL (default: http://localhost:9000)
#   S3_BUCKET       — S3 bucket name (default: popcut-backups)
#   S3_ACCESS_KEY   — S3 access key (default: popcut)
#   S3_SECRET_KEY   — S3 secret key (default: popcut123)
#   S3_REGION       — S3 region (default: us-east-1)
#   BACKUP_DIR      — Local staging directory (default: /tmp/popcut-backups/redis)
#   RETENTION_DAILY   — Number of daily backups to keep (default: 7)
#   RETENTION_WEEKLY  — Number of weekly backups to keep (default: 4)
#   RETENTION_MONTHLY — Number of monthly backups to keep (default: 12)
#   EMAIL_TO        — Notification email on failure (optional)
#   LOG_DIR         — Log directory (default: /var/log/popcut/backups)
#
# Requirements:
#   - redis-cli (Redis 6+)
#   - aws-cli v2
#   - gzip
# =============================================================================

set -euo pipefail

# --- Config ----------------------------------------------------------------
REDIS_HOST="${REDIS_HOST:-localhost}"
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_PASSWORD="${REDIS_PASSWORD:-}"
REDIS_DATA_DIR="${REDIS_DATA_DIR:-/data/redis}"

S3_ENDPOINT="${S3_ENDPOINT:-http://localhost:9000}"
S3_BUCKET="${S3_BUCKET:-popcut-backups}"
S3_ACCESS_KEY="${S3_ACCESS_KEY:-popcut}"
S3_SECRET_KEY="${S3_SECRET_KEY:-popcut123}"
S3_REGION="${S3_REGION:-us-east-1}"

BACKUP_DIR="${BACKUP_DIR:-/tmp/popcut-backups/redis}"
RETENTION_DAILY="${RETENTION_DAILY:-7}"
RETENTION_WEEKLY="${RETENTION_WEEKLY:-4}"
RETENTION_MONTHLY="${RETENTION_MONTHLY:-12}"
LOG_DIR="${LOG_DIR:-/var/log/popcut/backups}"
EMAIL_TO="${EMAIL_TO:-}"

DRY_RUN="${DRY_RUN:-false}"
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DATE_PART="$(date +%Y/%m/%d)"
DAY_OF_WEEK="$(date +%u)"
DAY_OF_MONTH="$(date +%d)"

export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY"
export AWS_DEFAULT_REGION="$S3_REGION"

# --- Logging ---------------------------------------------------------------
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/redis-backup-$TIMESTAMP.log"

log() {
    local level="$1"
    shift
    local message="[$TIMESTAMP] [$level] $*"
    echo "$message" | tee -a "$LOG_FILE"
}

info()  { log "INFO"  "$@"; }
warn()  { log "WARN"  "$@"; }
error() { log "ERROR" "$@"; }

# --- Cleanup ---------------------------------------------------------------
cleanup() {
    if [[ -d "$BACKUP_DIR/$TIMESTAMP" ]]; then
        rm -rf "$BACKUP_DIR/$TIMESTAMP"
    fi
}
trap cleanup EXIT

# --- Prerequisites ---------------------------------------------------------
check_prereqs() {
    local missing=false
    for cmd in redis-cli aws gzip; do
        if ! command -v "$cmd" &>/dev/null; then
            error "Required command not found: $cmd"
            missing=true
        fi
    done
    if [[ "$missing" == true ]]; then
        error "Missing prerequisites. Aborting."
        exit 1
    fi
    info "All prerequisites met"
}

# --- Build redis-cli args --------------------------------------------------
redis_args() {
    local args=("-h" "$REDIS_HOST" "-p" "$REDIS_PORT")
    if [[ -n "$REDIS_PASSWORD" ]]; then
        args+=("-a" "$REDIS_PASSWORD" "--no-auth-warning")
    fi
    echo "${args[@]}"
}

# --- Backup -----------------------------------------------------------------
perform_backup() {
    info "Starting Redis backup (host: $REDIS_HOST:$REDIS_PORT)"

    local staging_dir="$BACKUP_DIR/$TIMESTAMP"
    mkdir -p "$staging_dir"

    # 1. Trigger BGSAVE
    info "Triggering BGSAVE ..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would execute: redis-cli $(redis_args) BGSAVE"
    else
        local bgsave_result
        bgsave_result="$(redis-cli $(redis_args) BGSAVE 2>>"$LOG_FILE")"
        info "BGSAVE result: $bgsave_result"

        # Wait for background save to complete
        local timeout=60
        local elapsed=0
        while true; do
            local save_status
            save_status="$(redis-cli $(redis_args) INFO persistence 2>>"$LOG_FILE" | grep 'rdb_bgsave_in_progress' | cut -d: -f2 | tr -d '\r')"
            if [[ "$save_status" == "0" ]]; then
                info "BGSAVE completed"
                break
            fi
            if [[ "$elapsed" -ge "$timeout" ]]; then
                error "Timeout waiting for BGSAVE to complete"
                return 1
            fi
            sleep 2
            elapsed=$((elapsed + 2))
        done
    fi

    # 2. Locate dump.rdb (try common paths)
    local dump_rdb=""
    for candidate in "$REDIS_DATA_DIR/dump.rdb" "/var/lib/redis/dump.rdb" "/data/dump.rdb" "/var/lib/redis/6379/dump.rdb"; do
        if [[ -f "$candidate" ]]; then
            dump_rdb="$candidate"
            break
        fi
    done

    if [[ -z "$dump_rdb" ]]; then
        # Fallback: ask Redis for the dir
        if [[ "$DRY_RUN" == false ]]; then
            local redis_dir
            redis_dir="$(redis-cli $(redis_args) CONFIG GET dir 2>>"$LOG_FILE" | tail -1 | tr -d '\r')"
            dump_rdb="${redis_dir}/dump.rdb"
            if [[ ! -f "$dump_rdb" ]]; then
                error "Cannot locate dump.rdb. Tried: $REDIS_DATA_DIR/dump.rdb, $dump_rdb"
                return 1
            fi
        else
            dump_rdb="$REDIS_DATA_DIR/dump.rdb"
        fi
    fi

    info "Found dump.rdb at: $dump_rdb"

    # 3. Copy and compress
    local dest_file="$staging_dir/dump.rdb"
    local compressed_file="$dest_file.gz"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would copy $dump_rdb → $dest_file"
        info "[DRY-RUN] Would compress: gzip $dest_file"
    else
        cp "$dump_rdb" "$dest_file"
        info "Copied dump.rdb to staging"

        # Verify the copy
        if [[ ! -s "$dest_file" ]]; then
            error "Copied dump.rdb is empty or missing"
            return 1
        fi

        gzip "$dest_file"
        info "Compression completed: $compressed_file"
    fi

    # Checksum
    local checksum=""
    if [[ "$DRY_RUN" == false ]]; then
        checksum="$(sha256sum "$compressed_file" | cut -d' ' -f1)"
        info "Checksum (SHA256): $checksum"
    fi

    # 4. Upload
    local s3_path="redis/$DATE_PART/redis-dump-$TIMESTAMP.rdb.gz"
    info "Uploading to s3://$S3_BUCKET/$s3_path ..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would upload: $compressed_file → s3://$S3_BUCKET/$s3_path"
    else
        aws s3 cp "$compressed_file" "s3://$S3_BUCKET/$s3_path" \
            --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1
        info "Upload completed"
    fi

    if [[ "$DRY_RUN" == false ]]; then
        apply_retention
    else
        info "[DRY-RUN] Would apply retention policies"
    fi

    info "Redis backup completed successfully"
    return 0
}

# --- Retention --------------------------------------------------------------
apply_retention() {
    info "Applying retention policies..."

    aws s3 ls "s3://$S3_BUCKET/redis/" --endpoint-url "$S3_ENDPOINT" --recursive 2>>"$LOG_FILE" \
        | sort -k1,2 \
        | head -n -"$RETENTION_DAILY" \
        | while read -r line; do
            key="$(echo "$line" | awk '{print $4}')"
            if [[ -n "$key" && "$key" != "redis/" ]]; then
                info "Removing old daily backup: $key"
                aws s3 rm "s3://$S3_BUCKET/$key" --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1
            fi
          done || true

    if [[ "$DAY_OF_WEEK" == "1" ]]; then
        aws s3 ls "s3://$S3_BUCKET/redis/" --endpoint-url "$S3_ENDPOINT" --recursive 2>>"$LOG_FILE" \
            | sort -k1,2 \
            | head -n -"$RETENTION_WEEKLY" \
            | while read -r line; do
                key="$(echo "$line" | awk '{print $4}')"
                if [[ -n "$key" && "$key" != "redis/" ]]; then
                    info "Removing old weekly backup: $key"
                    aws s3 rm "s3://$S3_BUCKET/$key" --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1
                fi
              done || true
    fi

    if [[ "$DAY_OF_MONTH" == "01" ]]; then
        aws s3 ls "s3://$S3_BUCKET/redis/" --endpoint-url "$S3_ENDPOINT" --recursive 2>>"$LOG_FILE" \
            | sort -k1,2 \
            | head -n -"$RETENTION_MONTHLY" \
            | while read -r line; do
                key="$(echo "$line" | awk '{print $4}')"
                if [[ -n "$key" && "$key" != "redis/" ]]; then
                    info "Removing old monthly backup: $key"
                    aws s3 rm "s3://$S3_BUCKET/$key" --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1
                fi
              done || true
    fi
}

# --- Notification -----------------------------------------------------------
notify_failure() {
    local subject="[FAILED] Redis Backup — $TIMESTAMP"
    local body="Redis backup failed at $TIMESTAMP.\n\nLog: $LOG_FILE\nHost: $REDIS_HOST:$REDIS_PORT"

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
        info "Failure notification sent to $EMAIL_TO"
    fi
}

# --- Main -------------------------------------------------------------------
main() {
    echo "======================================================================"
    echo "  PopCut Redis Backup"
    echo "  Timestamp: $TIMESTAMP"
    echo "======================================================================"

    if [[ "$DRY_RUN" == true ]]; then
        echo "  ** DRY-RUN MODE **"
        echo "======================================================================"
    fi

    check_prereqs

    if ! perform_backup; then
        error "Backup failed"
        notify_failure
        exit 1
    fi

    info "All operations complete. Log: $LOG_FILE"
    echo "======================================================================"
}

main
