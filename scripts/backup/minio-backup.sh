#!/usr/bin/env bash
# =============================================================================
# MinIO / S3-Compatible Storage Backup Script — PopCut
# =============================================================================
#
# Usage:
#   ./minio-backup.sh [--dry-run]
#
# Environment variables:
#   SOURCE_ENDPOINT  — Source S3 endpoint (default: http://localhost:9000)
#   SOURCE_BUCKET    — Source bucket to back up (default: popcut)
#   SOURCE_ACCESS_KEY — Source access key (default: popcut)
#   SOURCE_SECRET_KEY — Source secret key (default: popcut123)
#   SOURCE_REGION    — Source region (default: us-east-1)
#
#   DEST_ENDPOINT    — Destination S3 endpoint (default: same as SOURCE)
#   DEST_BUCKET      — Destination bucket (default: popcut-backups)
#   DEST_ACCESS_KEY  — Destination access key (default: popcut)
#   DEST_SECRET_KEY  — Destination secret key (default: popcut123)
#   DEST_REGION      — Destination region (default: us-east-1)
#
#   BACKUP_DIR       — Local staging (default: /tmp/popcut-backups/minio)
#   RETENTION_DAILY  — Daily backups to keep (default: 7)
#   RETENTION_WEEKLY — Weekly backups to keep (default: 4)
#   EXCLUDE_PATTERNS — Comma-separated globs to exclude (default: "tmp/*,temp/*,*.swp")
#   EMAIL_TO         — Notification email on failure (optional)
#   LOG_DIR          — Log directory (default: /var/log/popcut/backups)
#
# Requirements:
#   - aws-cli v2
#   - gzip
# =============================================================================

set -euo pipefail

# --- Config ----------------------------------------------------------------
SOURCE_ENDPOINT="${SOURCE_ENDPOINT:-http://localhost:9000}"
SOURCE_BUCKET="${SOURCE_BUCKET:-popcut}"
SOURCE_ACCESS_KEY="${SOURCE_ACCESS_KEY:-popcut}"
SOURCE_SECRET_KEY="${SOURCE_SECRET_KEY:-popcut123}"
SOURCE_REGION="${SOURCE_REGION:-us-east-1}"

DEST_ENDPOINT="${DEST_ENDPOINT:-$SOURCE_ENDPOINT}"
DEST_BUCKET="${DEST_BUCKET:-popcut-backups}"
DEST_ACCESS_KEY="${DEST_ACCESS_KEY:-$SOURCE_ACCESS_KEY}"
DEST_SECRET_KEY="${DEST_SECRET_KEY:-$SOURCE_SECRET_KEY}"
DEST_REGION="${DEST_REGION:-$SOURCE_REGION}"

BACKUP_DIR="${BACKUP_DIR:-/tmp/popcut-backups/minio}"
RETENTION_DAILY="${RETENTION_DAILY:-7}"
RETENTION_WEEKLY="${RETENTION_WEEKLY:-4}"
EXCLUDE_PATTERNS="${EXCLUDE_PATTERNS:-tmp/*,temp/*,*.swp}"
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

# --- Logging ---------------------------------------------------------------
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/minio-backup-$TIMESTAMP.log"

log() {
    local level="$1"
    shift
    local message="[$TIMESTAMP] [$level] $*"
    echo "$message" | tee -a "$LOG_FILE"
}

info()  { log "INFO"  "$@"; }
warn()  { log "WARN"  "$@"; }
error() { log "ERROR" "$@"; }

# --- Prerequisites ---------------------------------------------------------
check_prereqs() {
    local missing=false
    for cmd in aws gzip; do
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

# --- Sync bucket to bucket ---------------------------------------------------
sync_buckets() {
    info "Starting MinIO bucket sync: $SOURCE_BUCKET → $DEST_BUCKET"

    local exclude_args=()
    IFS=',' read -ra patterns <<< "$EXCLUDE_PATTERNS"
    for pattern in "${patterns[@]}"; do
        pattern="$(echo "$pattern" | xargs)"
        if [[ -n "$pattern" ]]; then
            exclude_args+=(--exclude "$pattern")
        fi
    done

    local dest_prefix="minio/$DATE_PART/"

    info "Syncing s3://$SOURCE_BUCKET → s3://$DEST_BUCKET/$dest_prefix"
    info "Excluding patterns: ${exclude_args[*]:-none}"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would execute: aws s3 sync s3://$SOURCE_BUCKET s3://$DEST_BUCKET/$dest_prefix"
        info "[DRY-RUN] With excludes: ${exclude_args[*]:-}"
    else
        # Source credentials
        export AWS_ACCESS_KEY_ID="$SOURCE_ACCESS_KEY"
        export AWS_SECRET_ACCESS_KEY="$SOURCE_SECRET_KEY"
        export AWS_DEFAULT_REGION="$SOURCE_REGION"

        # First, list source to count objects
        local object_count
        object_count="$(aws s3 ls "s3://$SOURCE_BUCKET" --endpoint-url "$SOURCE_ENDPOINT" --recursive --summarize 2>>"$LOG_FILE" | tail -1 | awk '{print $3}')"
        info "Source bucket contains approximately $object_count objects"

        # Switch to destination credentials for the sync
        export AWS_ACCESS_KEY_ID="$DEST_ACCESS_KEY"
        export AWS_SECRET_ACCESS_KEY="$DEST_SECRET_KEY"
        export AWS_DEFAULT_REGION="$DEST_REGION"

        aws s3 sync "s3://$SOURCE_BUCKET" "s3://$DEST_BUCKET/$dest_prefix" \
            --endpoint-url "$DEST_ENDPOINT" \
            --no-progress \
            "${exclude_args[@]}" \
            >>"$LOG_FILE" 2>&1

        info "Sync completed"
    fi
}

# --- Create local manifest for checksum verification -------------------------
create_manifest() {
    local manifest_dir="$BACKUP_DIR/$TIMESTAMP"
    mkdir -p "$manifest_dir"
    local manifest_file="$manifest_dir/manifest-$TIMESTAMP.txt"

    info "Creating manifest: $manifest_file"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would create manifest at $manifest_file"
        return
    fi

    {
        echo "PopCut MinIO Backup Manifest"
        echo "============================="
        echo "Timestamp: $TIMESTAMP"
        echo "Source Bucket: $SOURCE_BUCKET"
        echo "Destination Bucket: $DEST_BUCKET"
        echo "============================="
        echo ""
        echo "Contents:"
        echo "---------"

        export AWS_ACCESS_KEY_ID="$DEST_ACCESS_KEY"
        export AWS_SECRET_ACCESS_KEY="$DEST_SECRET_KEY"
        export AWS_DEFAULT_REGION="$DEST_REGION"

        aws s3 ls "s3://$DEST_BUCKET/minio/$DATE_PART/" --endpoint-url "$DEST_ENDPOINT" --recursive \
            2>>"$LOG_FILE" | awk '{print $1, $2, $4, $3}'
    } > "$manifest_file"

    info "Manifest created"
}

# --- Retention --------------------------------------------------------------
apply_retention() {
    info "Applying retention policies..."

    export AWS_ACCESS_KEY_ID="$DEST_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$DEST_SECRET_KEY"
    export AWS_DEFAULT_REGION="$DEST_REGION"

    # Daily
    aws s3 ls "s3://$DEST_BUCKET/minio/" --endpoint-url "$DEST_ENDPOINT" --recursive 2>>"$LOG_FILE" \
        | sort -k1,2 \
        | head -n -"$RETENTION_DAILY" \
        | while read -r line; do
            key="$(echo "$line" | awk '{print $4}')"
            if [[ -n "$key" && "$key" != "minio/" ]]; then
                info "Removing old daily minio backup: $key"
                aws s3 rm "s3://$DEST_BUCKET/$key" --endpoint-url "$DEST_ENDPOINT" >>"$LOG_FILE" 2>&1
            fi
          done || true

    # Weekly (Monday)
    if [[ "$DAY_OF_WEEK" == "1" ]]; then
        aws s3 ls "s3://$DEST_BUCKET/minio/" --endpoint-url "$DEST_ENDPOINT" --recursive 2>>"$LOG_FILE" \
            | sort -k1,2 \
            | head -n -"$RETENTION_WEEKLY" \
            | while read -r line; do
                key="$(echo "$line" | awk '{print $4}')"
                if [[ -n "$key" && "$key" != "minio/" ]]; then
                    info "Removing old weekly minio backup: $key"
                    aws s3 rm "s3://$DEST_BUCKET/$key" --endpoint-url "$DEST_ENDPOINT" >>"$LOG_FILE" 2>&1
                fi
              done || true
    fi
}

# --- Notification -----------------------------------------------------------
notify_failure() {
    local subject="[FAILED] MinIO Backup — $TIMESTAMP"
    local body="MinIO backup failed at $TIMESTAMP.\n\nLog: $LOG_FILE\nSource: $SOURCE_BUCKET\nDest: $DEST_BUCKET"

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
    echo "  PopCut MinIO Backup"
    echo "  Timestamp: $TIMESTAMP"
    echo "======================================================================"

    if [[ "$DRY_RUN" == true ]]; then
        echo "  ** DRY-RUN MODE **"
        echo "======================================================================"
    fi

    check_prereqs

    if ! sync_buckets; then
        error "Backup sync failed"
        notify_failure
        exit 1
    fi

    create_manifest

    if [[ "$DRY_RUN" == false ]]; then
        apply_retention
    else
        info "[DRY-RUN] Would apply retention policies"
    fi

    info "All operations complete. Log: $LOG_FILE"
    echo "======================================================================"
}

main
