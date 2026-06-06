#!/usr/bin/env bash
# =============================================================================
# PostgreSQL Restore Script — PopCut
# =============================================================================
#
# Usage:
#   ./postgres-restore.sh                        # Interactive: list & select
#   ./postgres-restore.sh --latest               # Restore latest backup
#   ./postgres-restore.sh --date 2024-01-15      # Restore from specific date
#   ./postgres-restore.sh --file s3://path/to/backup.dump.gz  # Restore specific file
#   ./postgres-restore.sh --list                 # List available backups
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
#   RESTORE_DIR   — Local staging directory (default: /tmp/popcut-restore/postgres)
#   LOG_DIR       — Log directory (default: /var/log/popcut/backups)
#   DROP_EXISTING — Drop existing database before restore (default: false)
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

RESTORE_DIR="${RESTORE_DIR:-/tmp/popcut-restore/postgres}"
LOG_DIR="${LOG_DIR:-/var/log/popcut/backups}"
DROP_EXISTING="${DROP_EXISTING:-false}"

export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY"
export AWS_DEFAULT_REGION="$S3_REGION"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# --- Logging ---------------------------------------------------------------
mkdir -p "$LOG_DIR" "$RESTORE_DIR"
LOG_FILE="$LOG_DIR/postgres-restore-$TIMESTAMP.log"

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
    if [[ -d "$RESTORE_DIR/$TIMESTAMP" ]]; then
        rm -rf "$RESTORE_DIR/$TIMESTAMP"
    fi
}
trap cleanup EXIT

# --- Prerequisites ---------------------------------------------------------
check_prereqs() {
    local missing=false
    for cmd in pg_restore pg_isready aws gunzip psql; do
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

# --- List backups ----------------------------------------------------------
list_backups() {
    info "Listing available PostgreSQL backups in s3://$S3_BUCKET/postgres/"

    local backups
    backups="$(aws s3 ls "s3://$S3_BUCKET/postgres/" --endpoint-url "$S3_ENDPOINT" --recursive 2>>"$LOG_FILE" \
        | grep '\.dump\.gz$' \
        | sort -k1,2 -r)"

    if [[ -z "$backups" ]]; then
        info "No backups found in s3://$S3_BUCKET/postgres/"
        return 1
    fi

    echo ""
    echo "Available PostgreSQL backups:"
    echo "============================="
    echo "$backups" | awk '{printf "  %s %s %s  %s\n", $1, $2, $4, $3}'
    echo "============================="

    echo "$backups" | awk '{print $4}'
    return 0
}

# --- Download backup -------------------------------------------------------
download_backup() {
    local s3_key="$1"
    local staging_dir="$RESTORE_DIR/$TIMESTAMP"
    mkdir -p "$staging_dir"

    local filename
    filename="$(basename "$s3_key")"
    local local_file="$staging_dir/$filename"

    info "Downloading s3://$S3_BUCKET/$s3_key ..."
    aws s3 cp "s3://$S3_BUCKET/$s3_key" "$local_file" \
        --endpoint-url "$S3_ENDPOINT" >>"$LOG_FILE" 2>&1

    if [[ ! -f "$local_file" ]]; then
        error "Download failed: $local_file not found"
        exit 1
    fi

    local remote_checksum
    remote_checksum="$(sha256sum "$local_file" | cut -d' ' -f1)"
    info "Downloaded: $local_file (SHA256: $remote_checksum)"

    # Decompress
    info "Decompressing ..."
    gunzip "$local_file"
    local uncompressed="${local_file%.gz}"
    if [[ ! -f "$uncompressed" ]]; then
        error "Decompression failed"
        exit 1
    fi
    info "Decompressed to: $uncompressed"

    echo "$uncompressed"
}

# --- Drop and recreate database --------------------------------------------
prepare_database() {
    export PGPASSWORD="$DB_PASSWORD"

    if [[ "$DROP_EXISTING" != "true" ]]; then
        info "DROP_EXISTING=false — will restore on top of existing data"
        return
    fi

    info "Dropping existing database $DB_NAME ..."
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres \
        -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$DB_NAME';" \
        >>"$LOG_FILE" 2>&1 || true

    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres \
        -c "DROP DATABASE IF EXISTS $DB_NAME;" \
        >>"$LOG_FILE" 2>&1

    info "Creating database $DB_NAME ..."
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres \
        -c "CREATE DATABASE $DB_NAME;" \
        >>"$LOG_FILE" 2>&1

    info "Database prepared"
}

# --- Restore ---------------------------------------------------------------
perform_restore() {
    local dump_file="$1"

    info "Starting restore of $dump_file to $DB_HOST:$DB_PORT/$DB_NAME ..."

    export PGPASSWORD="$DB_PASSWORD"

    pg_restore -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" \
        -d "$DB_NAME" \
        --no-owner \
        --no-acl \
        --verbose \
        "$dump_file" 2>&1 | tee -a "$LOG_FILE"

    info "pg_restore completed"
}

# --- Validate --------------------------------------------------------------
validate_restore() {
    info "Validating restore with test query ..."

    export PGPASSWORD="$DB_PASSWORD"

    local table_count
    table_count="$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" 2>>"$LOG_FILE" | tr -d ' ')"

    if [[ -z "$table_count" || "$table_count" -eq 0 ]]; then
        error "Validation failed: no tables found in $DB_NAME"
        return 1
    fi

    info "Validation passed: $table_count tables found in $DB_NAME"

    # Get database size
    local db_size
    db_size="$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        -t -c "SELECT pg_size_pretty(pg_database_size('$DB_NAME'));" 2>>"$LOG_FILE" | tr -d ' ')"

    info "Database size: $db_size"
    return 0
}

# --- Interactive select ----------------------------------------------------
interactive_select() {
    local backups
    backups="$(list_backups)"
    if [[ -z "$backups" || $? -ne 0 ]]; then
        exit 1
    fi

    local -a backup_array
    mapfile -t backup_array <<< "$backups"

    echo ""
    echo "Select a backup to restore (enter number):"
    local i=1
    for backup in "${backup_array[@]}"; do
        echo "  [$i] $backup"
        i=$((i + 1))
    done
    echo ""
    read -r selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt "${#backup_array[@]}" ]]; then
        error "Invalid selection"
        exit 1
    fi

    echo "${backup_array[$((selection - 1))]}"
}

# --- Main -------------------------------------------------------------------
main() {
    local mode="${1:-interactive}"
    local s3_key=""

    echo "======================================================================"
    echo "  PopCut PostgreSQL Restore"
    echo "  Timestamp: $TIMESTAMP"
    echo "======================================================================"

    check_prereqs

    # Parse arguments
    case "${1:-}" in
        --list)
            list_backups
            exit 0
            ;;
        --latest)
            info "Selecting latest backup ..."
            local backups
            backups="$(list_backups)"
            if [[ -z "$backups" ]]; then
                error "No backups available"
                exit 1
            fi
            s3_key="$(echo "$backups" | head -1)"
            ;;
        --date)
            if [[ -z "${2:-}" ]]; then
                error "Usage: $0 --date YYYY-MM-DD"
                exit 1
            fi
            local target_date="$2"
            info "Selecting backup from date: $target_date"
            local backups
            backups="$(list_backups)"
            s3_key="$(echo "$backups" | grep "$target_date" | head -1)"
            if [[ -z "$s3_key" ]]; then
                error "No backup found for date: $target_date"
                exit 1
            fi
            ;;
        --file)
            if [[ -z "${2:-}" ]]; then
                error "Usage: $0 --file s3://path/to/backup.dump.gz"
                exit 1
            fi
            s3_key="${2#s3://$S3_BUCKET/}"
            info "Using specified backup: $s3_key"
            ;;
        *)
            s3_key="$(interactive_select)"
            ;;
    esac

    if [[ -z "$s3_key" ]]; then
        error "No backup selected"
        exit 1
    fi

    info "Selected backup: $s3_key"

    local dump_file
    dump_file="$(download_backup "$s3_key")"

    prepare_database

    if ! perform_restore "$dump_file"; then
        error "Restore failed"
        exit 1
    fi

    if ! validate_restore; then
        error "Restore validation failed"
        exit 1
    fi

    info "Restore completed successfully"
    echo "======================================================================"
}

main "$@"
