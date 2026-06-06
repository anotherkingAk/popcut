#!/usr/bin/env bash
# =============================================================================
# Redis Restore Script — PopCut
# =============================================================================
#
# Usage:
#   ./redis-restore.sh                         # Interactive: list & select
#   ./redis-restore.sh --latest                # Restore latest backup
#   ./redis-restore.sh --date 2024-01-15       # Restore from specific date
#   ./redis-restore.sh --file s3://path/to/backup.rdb.gz  # Restore specific file
#   ./redis-restore.sh --list                  # List available backups
#
# Environment variables:
#   REDIS_HOST      — Redis host (default: localhost)
#   REDIS_PORT      — Redis port (default: 6379)
#   REDIS_PASSWORD  — Redis password (optional)
#   REDIS_DATA_DIR  — Redis data directory (default: /data/redis)
#   S3_ENDPOINT     — S3-compatible endpoint URL (default: http://localhost:9000)
#   S3_BUCKET       — S3 bucket name (default: popcut-backups)
#   S3_ACCESS_KEY   — S3 access key (default: popcut)
#   S3_SECRET_KEY   — S3 secret key (default: popcut123)
#   S3_REGION       — S3 region (default: us-east-1)
#   RESTORE_DIR     — Local staging directory (default: /tmp/popcut-restore/redis)
#   LOG_DIR         — Log directory (default: /var/log/popcut/backups)
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

RESTORE_DIR="${RESTORE_DIR:-/tmp/popcut-restore/redis}"
LOG_DIR="${LOG_DIR:-/var/log/popcut/backups}"

export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY"
export AWS_DEFAULT_REGION="$S3_REGION"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# --- Logging ---------------------------------------------------------------
mkdir -p "$LOG_DIR" "$RESTORE_DIR"
LOG_FILE="$LOG_DIR/redis-restore-$TIMESTAMP.log"

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
    for cmd in redis-cli aws gunzip; do
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

redis_args() {
    local args=("-h" "$REDIS_HOST" "-p" "$REDIS_PORT")
    if [[ -n "$REDIS_PASSWORD" ]]; then
        args+=("-a" "$REDIS_PASSWORD" "--no-auth-warning")
    fi
    echo "${args[@]}"
}

# --- List backups ----------------------------------------------------------
list_backups() {
    info "Listing available Redis backups in s3://$S3_BUCKET/redis/"

    local backups
    backups="$(aws s3 ls "s3://$S3_BUCKET/redis/" --endpoint-url "$S3_ENDPOINT" --recursive 2>>"$LOG_FILE" \
        | grep '\.rdb\.gz$' \
        | sort -k1,2 -r)"

    if [[ -z "$backups" ]]; then
        info "No Redis backups found in s3://$S3_BUCKET/redis/"
        return 1
    fi

    echo ""
    echo "Available Redis backups:"
    echo "========================"
    echo "$backups" | awk '{printf "  %s %s %s  %s\n", $1, $2, $4, $3}'
    echo "========================"

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
        error "Download failed"
        exit 1
    fi

    local checksum
    checksum="$(sha256sum "$local_file" | cut -d' ' -f1)"
    info "Downloaded: $local_file (SHA256: $checksum)"

    # Decompress
    info "Decompressing ..."
    gunzip "$local_file"
    local uncompressed="${local_file%.gz}"
    info "Decompressed to: $uncompressed"

    echo "$uncompressed"
}

# --- Get Redis config dir ---------------------------------------------------
get_redis_dir() {
    redis-cli $(redis_args) CONFIG GET dir 2>>"$LOG_FILE" | tail -1 | tr -d '\r'
}

# --- Restore ---------------------------------------------------------------
perform_restore() {
    local rdb_file="$1"

    local redis_dir
    redis_dir="$(get_redis_dir)"
    info "Redis data directory: $redis_dir"

    local dest_rdb="$redis_dir/dump.rdb"

    # Check available disk space
    local avail_kb
    avail_kb="$(df "$redis_dir" | tail -1 | awk '{print $4}')"
    local file_size_kb
    file_size_kb="$(( $(stat -f%z "$rdb_file" 2>/dev/null || stat -c%s "$rdb_file" 2>/dev/null) / 1024 ))"

    if [[ "$avail_kb" -lt "$file_size_kb" ]]; then
        error "Insufficient disk space in $redis_dir (need ${file_size_kb}KB, have ${avail_kb}KB)"
        exit 1
    fi

    # Stop Redis, replace dump.rdb, restart
    info "Stopping Redis (SHUTDOWN) ..."
    redis-cli $(redis_args) SHUTDOWN SAVE 2>>"$LOG_FILE" || true
    sleep 2

    info "Copying $rdb_file → $dest_rdb ..."
    cp "$rdb_file" "$dest_rdb"

    if [[ ! -f "$dest_rdb" ]]; then
        error "Failed to copy dump.rdb to $dest_rdb"
        exit 1
    fi

    # Fix permissions
    chown redis:redis "$dest_rdb" 2>/dev/null || true
    chmod 640 "$dest_rdb" 2>/dev/null || true

    info "Restarting Redis ..."
    if command -v systemctl &>/dev/null; then
        systemctl start redis 2>>"$LOG_FILE" || true
    elif command -v service &>/dev/null; then
        service redis start 2>>"$LOG_FILE" || true
    elif command -v redis-server &>/dev/null; then
        # Assume it's managed externally; attempt to start
        redis-server --daemonize yes 2>>"$LOG_FILE" || true
    else
        warn "Could not auto-start Redis. Please start it manually."
    fi

    # Wait for Redis to be ready
    local timeout=15
    local elapsed=0
    while true; do
        if redis-cli $(redis_args) PING 2>>"$LOG_FILE" | grep -q "PONG"; then
            info "Redis is ready"
            break
        fi
        if [[ "$elapsed" -ge "$timeout" ]]; then
            error "Timeout waiting for Redis to start"
            exit 1
        fi
        sleep 2
        elapsed=$((elapsed + 2))
    done

    info "Restore completed"
}

# --- Validate --------------------------------------------------------------
validate_restore() {
    info "Validating Redis restore ..."

    local dbsize
    dbsize="$(redis-cli $(redis_args) DBSIZE 2>>"$LOG_FILE" | tr -d '\r')"

    if [[ -z "$dbsize" ]]; then
        error "Validation failed: could not get DBSIZE"
        return 1
    fi

    info "Validation passed: Redis contains $dbsize keys"
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
    local s3_key=""

    echo "======================================================================"
    echo "  PopCut Redis Restore"
    echo "  Timestamp: $TIMESTAMP"
    echo "======================================================================"

    check_prereqs

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
                error "Usage: $0 --file s3://path/to/backup.rdb.gz"
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

    local rdb_file
    rdb_file="$(download_backup "$s3_key")"

    if ! perform_restore "$rdb_file"; then
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
