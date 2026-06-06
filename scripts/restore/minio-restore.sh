#!/usr/bin/env bash
# =============================================================================
# MinIO / S3-Compatible Storage Restore Script — PopCut
# =============================================================================
#
# Usage:
#   ./minio-restore.sh                          # Interactive: list & select
#   ./minio-restore.sh --latest                 # Restore latest backup
#   ./minio-restore.sh --date 2024-01-15        # Restore from specific date
#   ./minio-restore.sh --list                   # List available backups
#
# This restores by syncing from the backup bucket back to the source bucket.
#
# Environment variables:
#   SOURCE_ENDPOINT  — Source S3 endpoint (default: http://localhost:9000)
#   SOURCE_BUCKET    — Source bucket to restore into (default: popcut)
#   SOURCE_ACCESS_KEY — Source access key (default: popcut)
#   SOURCE_SECRET_KEY — Source secret key (default: popcut123)
#   SOURCE_REGION    — Source region (default: us-east-1)
#
#   DEST_ENDPOINT    — Same as SOURCE_ENDPOINT during restore (source is the target)
#   BACKUP_ENDPOINT  — Backup S3 endpoint (default: http://localhost:9000)
#   BACKUP_BUCKET    — Backup bucket (default: popcut-backups)
#   BACKUP_ACCESS_KEY — Backup access key (default: popcut)
#   BACKUP_SECRET_KEY — Backup secret key (default: popcut123)
#   BACKUP_REGION    — Backup region (default: us-east-1)
#
#   RESTORE_DIR      — Local staging (default: /tmp/popcut-restore/minio)
#   LOG_DIR          — Log directory (default: /var/log/popcut/backups)
#   CONFIRM_DANGER   — Must be set to "yes" to proceed (safety flag)
# =============================================================================

set -euo pipefail

# --- Config ----------------------------------------------------------------
SOURCE_ENDPOINT="${SOURCE_ENDPOINT:-http://localhost:9000}"
SOURCE_BUCKET="${SOURCE_BUCKET:-popcut}"
SOURCE_ACCESS_KEY="${SOURCE_ACCESS_KEY:-popcut}"
SOURCE_SECRET_KEY="${SOURCE_SECRET_KEY:-popcut123}"
SOURCE_REGION="${SOURCE_REGION:-us-east-1}"

BACKUP_ENDPOINT="${BACKUP_ENDPOINT:-http://localhost:9000}"
BACKUP_BUCKET="${BACKUP_BUCKET:-popcut-backups}"
BACKUP_ACCESS_KEY="${BACKUP_ACCESS_KEY:-popcut}"
BACKUP_SECRET_KEY="${BACKUP_SECRET_KEY:-popcut123}"
BACKUP_REGION="${BACKUP_REGION:-us-east-1}"

RESTORE_DIR="${RESTORE_DIR:-/tmp/popcut-restore/minio}"
LOG_DIR="${LOG_DIR:-/var/log/popcut/backups}"
CONFIRM_DANGER="${CONFIRM_DANGER:-no}"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# --- Logging ---------------------------------------------------------------
mkdir -p "$LOG_DIR" "$RESTORE_DIR"
LOG_FILE="$LOG_DIR/minio-restore-$TIMESTAMP.log"

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
    for cmd in aws; do
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
    info "Listing available MinIO backups in s3://$BACKUP_BUCKET/minio/"

    export AWS_ACCESS_KEY_ID="$BACKUP_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$BACKUP_SECRET_KEY"
    export AWS_DEFAULT_REGION="$BACKUP_REGION"

    local backups
    backups="$(aws s3 ls "s3://$BACKUP_BUCKET/minio/" --endpoint-url "$BACKUP_ENDPOINT" --recursive 2>>"$LOG_FILE" \
        | sort -k1,2 -r)"

    if [[ -z "$backups" ]]; then
        info "No MinIO backups found in s3://$BACKUP_BUCKET/minio/"
        return 1
    fi

    echo ""
    echo "Available MinIO backup dates:"
    echo "============================="
    echo "$backups" | awk '{print $1, $2}' | sort -u -r | while read -r d t; do
        echo "  $d $t"
    done
    echo "============================="

    echo "$backups"
    return 0
}

# --- Restore ---------------------------------------------------------------
perform_restore() {
    local restore_prefix="$1"

    export AWS_ACCESS_KEY_ID="$BACKUP_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$BACKUP_SECRET_KEY"
    export AWS_DEFAULT_REGION="$BACKUP_REGION"

    info "Restoring from s3://$BACKUP_BUCKET/$restore_prefix → s3://$SOURCE_BUCKET/"

    # Check if restore prefix exists
    local object_count
    object_count="$(aws s3 ls "s3://$BACKUP_BUCKET/$restore_prefix" --endpoint-url "$BACKUP_ENDPOINT" --recursive 2>>"$LOG_FILE" | wc -l | tr -d ' ')"
    info "Backup prefix contains $object_count objects"

    if [[ "$object_count" -eq 0 ]]; then
        error "No objects found at s3://$BACKUP_BUCKET/$restore_prefix"
        return 1
    fi

    # Safety confirmation
    if [[ "$CONFIRM_DANGER" != "yes" ]]; then
        echo ""
        echo "!!! DANGER: This will overwrite objects in s3://$SOURCE_BUCKET/ !!!"
        echo "!!! Set CONFIRM_DANGER=yes to proceed                          !!!"
        echo ""
        error "Aborting: CONFIRM_DANGER is not set to 'yes'"
        exit 1
    fi

    echo ""
    echo "WARNING: You are about to restore $object_count objects to s3://$SOURCE_BUCKET/"
    echo "This will OVERWRITE existing data."
    echo ""
    read -r -p "Type 'yes' to confirm: " confirm
    if [[ "$confirm" != "yes" ]]; then
        info "Restore cancelled by user"
        exit 0
    fi

    info "Starting sync restore ..."

    export AWS_ACCESS_KEY_ID="$BACKUP_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$BACKUP_SECRET_KEY"
    export AWS_DEFAULT_REGION="$BACKUP_REGION"

    aws s3 sync "s3://$BACKUP_BUCKET/$restore_prefix" "s3://$SOURCE_BUCKET/" \
        --endpoint-url "$BACKUP_ENDPOINT" \
        --no-progress \
        >>"$LOG_FILE" 2>&1

    info "Sync restore completed"

    # Verify
    info "Verifying restore ..."
    local restored_count
    restored_count="$(aws s3 ls "s3://$SOURCE_BUCKET/" --endpoint-url "$SOURCE_ENDPOINT" --recursive 2>>"$LOG_FILE" | wc -l | tr -d ' ')"
    info "Source bucket now contains $restored_count objects"
}

# --- Interactive select ----------------------------------------------------
interactive_select() {
    export AWS_ACCESS_KEY_ID="$BACKUP_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$BACKUP_SECRET_KEY"
    export AWS_DEFAULT_REGION="$BACKUP_REGION"

    local backup_dates
    backup_dates="$(aws s3 ls "s3://$BACKUP_BUCKET/minio/" --endpoint-url "$BACKUP_ENDPOINT" 2>>"$LOG_FILE" | awk '{print $2}' | sed 's|/$||' | sort -r)"

    if [[ -z "$backup_dates" ]]; then
        error "No backup dates found in s3://$BACKUP_BUCKET/minio/"
        exit 1
    fi

    echo ""
    echo "Available MinIO backup dates:"
    local -a date_array
    mapfile -t date_array <<< "$backup_dates"
    local i=1
    for d in "${date_array[@]}"; do
        date_path="${d//\//-}"  # Replace / with - for display
        echo "  [$i] $date_path ($d)"
        i=$((i + 1))
    done
    echo ""
    read -r -p "Select backup date (number): " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt "${#date_array[@]}" ]]; then
        error "Invalid selection"
        exit 1
    fi

    echo "minio/${date_array[$((selection - 1))]}/"
}

# --- Main -------------------------------------------------------------------
main() {
    local restore_prefix=""

    echo "======================================================================"
    echo "  PopCut MinIO Restore"
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
            local backup_date
            export AWS_ACCESS_KEY_ID="$BACKUP_ACCESS_KEY"
            export AWS_SECRET_ACCESS_KEY="$BACKUP_SECRET_KEY"
            export AWS_DEFAULT_REGION="$BACKUP_REGION"

            backup_date="$(aws s3 ls "s3://$BACKUP_BUCKET/minio/" --endpoint-url "$BACKUP_ENDPOINT" 2>>"$LOG_FILE" | awk '{print $2}' | sed 's|/$||' | sort -r | head -1)"
            if [[ -z "$backup_date" ]]; then
                error "No backups found"
                exit 1
            fi
            restore_prefix="minio/$backup_date/"
            info "Latest backup: $restore_prefix"
            ;;
        --date)
            if [[ -z "${2:-}" ]]; then
                error "Usage: $0 --date YYYY-MM-DD"
                exit 1
            fi
            local target_date="$2"
            local date_path="${target_date//-/\/}"  # Convert YYYY-MM-DD to YYYY/MM/DD
            restore_prefix="minio/$date_path/"
            info "Selected backup: $restore_prefix"
            ;;
        *)
            restore_prefix="$(interactive_select)"
            ;;
    esac

    if [[ -z "$restore_prefix" ]]; then
        error "No backup selected"
        exit 1
    fi

    perform_restore "$restore_prefix"

    info "Restore completed successfully"
    echo "======================================================================"
}

main "$@"
