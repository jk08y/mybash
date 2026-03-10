#!/usr/bin/env bash

# quick-backup-script.sh
# Backup utility for configuration files and home directories

set -euo pipefail

# Color Codes
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Backup Configuration
BACKUP_DIR="$HOME/Backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Logging Functions
log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
log_warning() { printf "${YELLOW}[WARNING]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

# Create Backup Directory
create_backup_dir() {
    if ! mkdir -p "$BACKUP_DIR"; then
        log_error "Failed to create backup directory at $BACKUP_DIR"
        exit 1
    fi
}

# File/Directory Backup
backup_item() {
    local source=$1
    local name
    name=$(basename "$source")
    
    # Expand source path using eval (safe here given pre-defined list but better to hardcode path)
    if [[ ! "$source" =~ ^/ ]]; then
        source="$HOME/$source"
    fi
    
    # Check if source exists
    if [ ! -e "$source" ]; then
        log_warning "Source $source does not exist. Skipping."
        return 1
    fi
    
    # Create backup archive
    local backup_file="$BACKUP_DIR/${name}_${TIMESTAMP}.tar.gz"
    if tar -czf "$backup_file" -C "$(dirname "$source")" "$(basename "$source")"; then
        log_success "Backed up $source to $backup_file"
    else
        log_error "Failed to backup $source"
        return 1
    fi
}

# Config Files Backup
backup_configs() {
    local config_files=(
        "$HOME/.bashrc"
        "$HOME/.bash_aliases"
        "$HOME/.tmux.conf"
        "$HOME/.zshrc"
    )
    
    log_info "Backing up configuration files..."
    
    for config in "${config_files[@]}"; do
        if [ -f "$config" ]; then
            backup_item "$config" || true
        fi
    done
}

# Home Directory Selective Backup
backup_home_dirs() {
    local home_dirs=(
        "$HOME/Documents"
        "$HOME/Projects"
        "$HOME/.ssh"
    )
    
    log_info "Backing up selected home directories..."
    
    for dir in "${home_dirs[@]}"; do
        if [ -d "$dir" ]; then
            backup_item "$dir" || true
        fi
    done
}

# System Information Snapshot
backup_system_info() {
    local system_info_file="$BACKUP_DIR/system_info_${TIMESTAMP}.txt"
    
    log_info "Creating system information snapshot..."
    
    {
        echo "System Backup Snapshot"
        echo "----------------------"
        echo "Date: $(date)"
        echo "Hostname: $(hostname)"
        echo "OS: $(uname -a)"
        echo "Disk Usage:"
        df -h
        echo "Installed Packages (Debian/Ubuntu):"
        if command -v dpkg >/dev/null 2>&1; then
            dpkg -l
        else
            echo "dpkg not found, skipping packages."
        fi
    } > "$system_info_file"
    
    log_success "System information snapshot saved to $system_info_file"
}

# Cleanup Old Backups
cleanup_old_backups() {
    local days_to_keep=30
    
    log_info "Cleaning up backups older than $days_to_keep days..."
    find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +$days_to_keep -delete
    find "$BACKUP_DIR" -type f -name "system_info_*.txt" -mtime +$days_to_keep -delete
    log_success "Cleanup complete."
}

# Main Backup Sequence
full_backup() {
    clear
    log_info "Starting Quick Backup Utility"
    echo "========================================="
    
    create_backup_dir
    backup_configs
    backup_home_dirs
    backup_system_info
    cleanup_old_backups
    
    echo "========================================="
    log_success "Backup sequence completed!"
}

main() {
    case "${1:-}" in
        "configs")
            create_backup_dir
            backup_configs
            ;;
        "home")
            create_backup_dir
            backup_home_dirs
            ;;
        "full")
            full_backup
            ;;
        *)
            echo "Quick Backup Utility"
            echo "Usage: $0 {configs|home|full}"
            echo ""
            echo "Commands:"
            echo "  configs     Backup standard terminal configuration files (.bashrc, .zshrc, etc.)"
            echo "  home        Backup predefined home directories (Documents, Projects, .ssh)"
            echo "  full        Perform a full sequence backup and cleanup old backups"
            exit 1
            ;;
    esac
}

main "$@"
