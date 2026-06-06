#!/usr/bin/env bash
# =============================================================================
# PostgreSQL Backup Script — PopCut
# =============================================================================
#
# Usage:
#   ./postgres-backup.sh [--dry-run]
#
# Environment variables:
#   DB_HOST       — PostgreSQL host (default: localhost)
#   DB_PORT       — PostgreSQL port (default: 5432)
#   DB_NAME       — Database name (default: popcut)
#   DB_USER       — Database user (default: popcut)
#   DB_PASSWORD   — Database password (default: popcut)
#   S3_ENDPOINT   — S3-compatible endpoint URL (default: http://localhost:9000)
#   S3_BUCKET     — S3 bucket name (default: popcut-backups)
#   S3_ACCESS_KEY — S3 access key (default: popcut)
#   S3_SECRET_KEY — S3 secret key (default: popcut123)
#   S3_REGION     — S3 region (default: us-east-1)
#   BACKUP_DIR    — Local staging directory (default: /tmp/popcut-backups/postgres)
#   RETENTION_DAILY   — Number of daily backups to keep (default: 7)
#   RETENTION_WEEKLY  — Number of weekly backups to keep (default: 4)
#   RETENTION_MONTHLY — Number of monthly backups to keep (default: 12)
#   EMAIL_TO      — Notification email on failure (optional)
#   LOG_DIR       — Log directory (default: /var/log/popcut/backups)
#
# Requirements:
#   - pg_dump (PostgreSQL client 14+)
#   - aws-cli v2 (or mc CLI for MinIO)
#   - gzip / gunzip
# =============================================================================

set -euo pipefail

# --- Config ----------------------------------------------------------------
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-popcut}"
DB_USER="${DB_USER:-popcut}"
DB_PASSWORD="${DB_PASSWORD:-popcut}"

S3_ENDPOINT="${S3_ENDPOINT:-http://localhost:9000}"
S3_BUCKET="${S3_BUCKET:-popcut-backups}"
S3_ACCESS_KEY="${S3_ACCESS_KEY:-popcut}"
S3_SECRET_KEY="${S3_SECRET_KEY:-popcut123}"
S3_REGION="${S3_REGION:-us-east-1}"

BACKUP_DIR="${BACKUP_DIR:-/tmp/popcut-backups/postgres}"
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
YEAR_MONTH="$(date +%Y/%m)"
WEEK_NUM="$(date +%V)"
DAY_OF_MONTH="$(date +%d)"
DAY_OF_WEEK="$(date +%u)"

export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY"
export AWS_DEFAULT_REGION="$S3_REGION"

# --- Logging ---------------------------------------------------------------
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/postgres-backup-$TIMESTAMP.log"

log() {
    local level="$1"
    shift
    local message="[$TIMESTAMP] [$level] $*"
    echo "$message" | tee -a "$LOG_FILE"
}

info()  { log "INFO"  "$@"; }
warn()  { log "WARN"  "$@"; }
error() { log "ERROR" "$@"; }

# --- Cleanup on exit -------------------------------------------------------
cleanup() {
    if [[ -d "$BACKUP_DIR/$TIMESTAMP" ]]; then
        rm -rf "$BACKUP_DIR/$TIMESTAMP"
    fi
}
trap cleanup EXIT

# --- Prerequisites ---------------------------------------------------------
check_prereqs() {
    local missing=false
    for cmd in pg_dump aws gzip; do
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

# --- Backup -----------------------------------------------------------------
perform_backup() {
    info "Starting PostgreSQL backup for database: $DB_NAME"

    local staging_dir="$BACKUP_DIR/$TIMESTAMP"
    mkdir -p "$staging_dir"

    local backup_file="$staging_dir/popcut-$DB_NAME-$TIMESTAMP.dump"
    local compressed_file="$backup_file.gz"

    # Ensure .pgpass for non-interactive auth
    export PGPASSWORD="$DB_PASSWORD"

    info "Running pg_dump (custom format) ..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would execute: pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -Fc --no-owner --no-acl -f $backup_file $DB_NAME"
    else
        pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" \
            -Fc --no-owner --no-acl \
            -f "$backup_file" "$DB_NAME" 2>>"$LOG_FILE"
        info "pg_dump completed successfully"
    fi

    info "Compressing backup ..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would run: gzip $backup_file"
    else
        if [[ ! -f "$backup_file" ]]; then
            error "Backup file not found: $backup_file"
            return 1
        fi
        gzip "$backup_file"
        info "Compression completed: $compressed_file"
    fi

    # Checksum
    local checksum=""
    if [[ "$DRY_RUN" == false ]]; then
        checksum="$(sha256sum "$compressed_file" | cut -d' ' -f1)"
        info "Checksum (SHA256): $checksum"
    fi

    # Upload to S3
    local s3_path="postgres/$DATE_PART/popcut-$DB_NAME-$TIMESTAMP.dump.gz"

    info "Uploading to s3://$S3_BUCKET/$s3_path ..."
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would upload: $compressed_file → s3://$S3_BUCKET/$s3_path"
    else
        aws s3 cp "$compressed_file" "s3://$S3_BUCKET/$s3_path" \
            --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1
        info "Upload completed"
    fi

    # --- Retention: determine which tier this backup belongs to ---
    # Daily: keep last N, Weekly: keep last N (Monday), Monthly: keep last N (1st day)
    if [[ "$DRY_RUN" == false ]]; then
        apply_retention
    else
        info "[DRY-RUN] Would apply retention policies"
    fi

    info "PostgreSQL backup completed successfully"
    return 0
}

# --- Retention --------------------------------------------------------------
apply_retention() {
    info "Applying retention policies..."

    # Daily retention — keep last RETENTION_DAILY dumps
    info "Daily retention: keeping last $RETENTION_DAILY"
    aws s3 ls "s3://$S3_BUCKET/postgres/" --endpoint-url "$S3_ENDPOINT" --recursive 2>>"$LOG_FILE" \
        | sort -k1,2 \
        | head -n -"$RETENTION_DAILY" \
        | while read -r line; do
            key="$(echo "$line" | awk '{print $4}')"
            if [[ -n "$key" && "$key" != "postgres/" ]]; then
                info "Removing old daily backup: $key"
                aws s3 rm "s3://$S3_BUCKET/$key" --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1
            fi
          done || true

    # Weekly retention (every Monday)
    if [[ "$DAY_OF_WEEK" == "1" ]]; then
        info "Weekly retention: keeping last $RETENTION_WEEKLY weeklies"
        aws s3 ls "s3://$S3_BUCKET/postgres/" --endpoint-url "$S3_ENDPOINT" --recursive 2>>"$LOG_FILE" \
            | grep "postgres/.*/" \
            | sort -k1,2 \
            | head -n -"$RETENTION_WEEKLY" \
            | while read -r line; do
                key="$(echo "$line" | awk '{print $4}')"
                if [[ -n "$key" && "$key" != "postgres/" ]]; then
                    info "Removing old weekly backup: $key"
                    aws s3 rm "s3://$S3_BUCKET/$key" --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1
                fi
              done || true
    fi

    # Monthly retention (1st day of month)
    if [[ "$DAY_OF_MONTH" == "01" ]]; then
        info "Monthly retention: keeping last $RETENTION_MONTHLY monthlies"
        aws s3 ls "s3://$S3_BUCKET/postgres/" --endpoint-url "$S3_ENDPOINT" --recursive 2>>"$LOG_FILE" \
            | sort -k1,2 \
            | head -n -"$RETENTION_MONTHLY" \
            | while read -r line; do
                key="$(echo "$line" | awk '{print $4}')"
                if [[ -n "$key" && "$key" != "postgres/" ]]; then
                    info "Removing old monthly backup: $key"
                    aws s3 rm "s3://$S3_BUCKET/$key" --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1
                fi
              done || true
    fi
}

# --- Notification -----------------------------------------------------------
notify_failure() {
    local subject="[FAILED] PostgreSQL Backup — $DB_NAME — $TIMESTAMP"
    local body="PostgreSQL backup failed at $TIMESTAMP.\n\nLog: $LOG_FILE\nHost: $DB_HOST\nDatabase: $DB_NAME"

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
            warn "No mail command found. Cannot send notification."
        fi
        info "Failure notification sent to $EMAIL_TO"
    fi
}

# --- Main -------------------------------------------------------------------
main() {
    echo "======================================================================"
    echo "  PopCut PostgreSQL Backup"
    echo "  Timestamp: $TIMESTAMP"
    echo "======================================================================"

    if [[ "$DRY_RUN" == true ]]; then
        echo "  ** DRY-RUN MODE **  No changes will be made."
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
