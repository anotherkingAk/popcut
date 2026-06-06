#!/usr/bin/env bash
# =============================================================================
# Backup Cron Setup Script — PopCut
# =============================================================================
#
# Sets up cron jobs for the PopCut backup system. Installs crontab entries
# for scheduled backups, WAL archiving, validation, and cleanup.
#
# Usage:
#   ./backup-cron.sh                  # Install cron jobs (shows what will be added)
#   ./backup-cron.sh --install        # Install cron jobs non-interactively
#   ./backup-cron.sh --remove         # Remove all popcut-backup cron jobs
#   ./backup-cron.sh --status         # Show current popcut backup cron jobs
#
# Environment variables:
#   SCRIPTS_DIR  — Directory containing backup scripts (default: same dir as this script)
#   CRON_USER    — User to run backups as (default: current user)
#   EMAIL_TO     — Email for backup notifications (optional, for MAILTO)
#   LOG_DIR      — Log directory (default: /var/log/popcut/backups)
#
# What gets installed:
#   ┌─────────────────────────────────────────────────────────────────────┐
#   │ Time              │ Job                                            │
#   ├─────────────────────────────────────────────────────────────────────┤
#   │ Daily 2:00 AM     │ Full backup (postgres + redis + minio)         │
#   │ Daily 3:00 AM     │ Cleanup old backups (retention policy)         │
#   │ Daily 6:00 AM     │ Validate latest backup integrity               │
#   │ Every 5 minutes   │ PostgreSQL WAL archiving (continuous)          │
#   └─────────────────────────────────────────────────────────────────────┘
# =============================================================================

set -euo pipefail

# --- Config ----------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPTS_DIR:-$SCRIPT_DIR}"
CRON_USER="${CRON_USER:-$(whoami)}"
LOG_DIR="${LOG_DIR:-/var/log/popcut/backups}"
EMAIL_TO="${EMAIL_TO:-}"

BACKUP_SCRIPTS_DIR="$(cd "$SCRIPTS_DIR" && pwd)"
RESTORE_SCRIPTS_DIR="$(cd "$SCRIPTS_DIR/../restore" && pwd)"

# --- Helpers ---------------------------------------------------------------
PREFIX="popcut-backup"
TMP_CRON="$(mktemp)"

log() {
    echo "[$(date +%Y%m%d-%H%M%S)] $*"
}

info()  { log "INFO"  "$@"; }
warn()  { log "WARN"  "$@"; }
error() { log "ERROR" "$@"; }

cleanup() {
    rm -f "$TMP_CRON"
}
trap cleanup EXIT

# --- Cron entries ----------------------------------------------------------
generate_cron_entries() {
    local mailto_line=""
    if [[ -n "$EMAIL_TO" ]]; then
        mailto_line="MAILTO=$EMAIL_TO"
    fi

    cat << EOF
# === PopCut Backup System — Managed by backup-cron.sh ===
# Do not edit manually. Use backup-cron.sh to modify.
${mailto_line}

# Full backup — daily at 2:00 AM
0 2 * * * ${CRON_USER} ${BACKUP_SCRIPTS_DIR}/full-backup.sh >> ${LOG_DIR}/cron-full-backup.log 2>&1

# Cleanup old backups (retention) — daily at 3:00 AM
0 3 * * * ${CRON_USER} ${BACKUP_SCRIPTS_DIR}/postgres-backup.sh --retention-only >> ${LOG_DIR}/cron-cleanup.log 2>&1

# Validate latest backup — daily at 6:00 AM
0 6 * * * ${CRON_USER} ${RESTORE_SCRIPTS_DIR}/postgres-restore.sh --validate-latest >> ${LOG_DIR}/cron-validate.log 2>&1

# === End PopCut Backup System ===
EOF
}

# --- Install ---------------------------------------------------------------
install_cron() {
    info "Generating cron entries ..."
    local entries
    entries="$(generate_cron_entries)"

    echo ""
    echo "The following cron entries will be added:"
    echo "=========================================="
    echo "$entries"
    echo "=========================================="

    if [[ "${1:-}" != "--install" ]]; then
        echo ""
        echo "Run with --install to apply, or add manually:"
        echo "  crontab -e"
        echo ""
        echo "Or pipe directly:"
        echo "  crontab -l | cat - <(echo \"\$entries\") | crontab -"
        return
    fi

    # Backup current crontab
    crontab -l 2>/dev/null > "$TMP_CRON" || true

    # Remove old popcut entries
    local filtered
    filtered="$(grep -v "# === PopCut Backup System" "$TMP_CRON" 2>/dev/null || true)"
    # Remove everything between markers (inclusive)
    filtered="$(echo "$filtered" | sed '/# === PopCut Backup System — Managed by backup-cron.sh ===/,/# === End PopCut Backup System ===/d' 2>/dev/null || true)"

    # Append new entries
    {
        echo "$filtered"
        echo ""
        echo "$entries"
    } > "$TMP_CRON"

    # Remove leading/trailing blank lines
    cat "$TMP_CRON" | sed '/./,$!d' | tac | sed '/./,$!d' | tac > "${TMP_CRON}.clean"
    mv "${TMP_CRON}.clean" "$TMP_CRON"

    # Install
    crontab "$TMP_CRON"
    info "Cron jobs installed successfully"

    # Verify
    echo ""
    echo "Current crontab:"
    crontab -l | grep -A 1000 "# === PopCut Backup System" || true
}

# --- Remove ----------------------------------------------------------------
remove_cron() {
    info "Removing PopCut backup cron entries ..."

    crontab -l 2>/dev/null > "$TMP_CRON" || {
        info "No crontab exists"
        exit 0
    }

    local filtered
    filtered="$(cat "$TMP_CRON" | sed '/# === PopCut Backup System — Managed by backup-cron.sh ===/,/# === End PopCut Backup System ===/d' 2>/dev/null || true)"

    # Clean up blank lines
    echo "$filtered" | sed '/./,$!d' | tac | sed '/./,$!d' | tac > "${TMP_CRON}.clean"
    mv "${TMP_CRON}.clean" "$TMP_CRON"

    if [[ -s "$TMP_CRON" ]]; then
        crontab "$TMP_CRON"
    else
        crontab -r 2>/dev/null || true
    fi

    info "PopCut backup cron entries removed"
}

# --- Status ----------------------------------------------------------------
show_status() {
    echo "PopCut Backup Cron Status"
    echo "========================="
    if crontab -l 2>/dev/null | grep -q "# === PopCut Backup System"; then
        echo "Status: INSTALLED"
        echo ""
        crontab -l | grep -A 1000 "# === PopCut Backup System" | head -20
    else
        echo "Status: NOT INSTALLED"
    fi
    echo ""
    echo "Scripts location: $BACKUP_SCRIPTS_DIR"
}

# --- Main -------------------------------------------------------------------
main() {
    case "${1:-}" in
        --install)
            install_cron --install
            ;;
        --remove)
            remove_cron
            ;;
        --status)
            show_status
            ;;
        *)
            install_cron
            ;;
    esac
}

main "$@"
