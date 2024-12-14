#!/bin/bash

# Quick Backup Script
# Provides flexible backup solutions for files and directories

# Color Codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Backup Configuration
BACKUP_DIR="$HOME/Backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Logging Function
log() {
    local type=$1
    local message=$2
    
    case $type in
        "success")
            echo -e "${GREEN}[✓ SUCCESS]${NC} $message"
            ;;
        "warning")
            echo -e "${YELLOW}[⚠ WARNING]${NC} $message"
            ;;
        "error")
            echo -e "${RED}[✗ ERROR]${NC} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Create Backup Directory
create_backup_dir() {
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        log "error" "Failed to create backup directory"
        exit 1
    fi
}

# File/Directory Backup
backup_item() {
    local source=$1
    local name=$(basename "$source")
    
    # Expand source path
    source=$(eval echo "$source")
    
    # Check if source exists
    if [ ! -e "$source" ]; then
        log "warning" "Source $source does not exist. Skipping."
        return 1
    fi
    
    # Create backup
    local backup_file="$BACKUP_DIR/${name}_${TIMESTAMP}.tar.gz"
    tar -czf "$backup_file" -C "$(dirname "$source")" "$(basename "$source")"
    
    if [ $? -eq 0 ]; then
        log "success" "Backed up $source to $backup_file"
    else
        log "error" "Failed to backup $source"
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
    
    log "success" "Backing up configuration files..."
    
    for config in "${config_files[@]}"; do
        if [ -f "$config" ]; then
            backup_item "$config"
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
    
    log "success" "Backing up selected home directories..."
    
    for dir in "${home_dirs[@]}"; do
        if [ -d "$dir" ]; then
            backup_item "$dir"
        fi
    done
}

# System Information Snapshot
backup_system_info() {
    local system_info_file="$BACKUP_DIR/system_info_${TIMESTAMP}.txt"
    
    echo "System Backup Snapshot" > "$system_info_file"
    echo "----------------------" >> "$system_info_file"
    
    {
        echo "Date: $(date)"
        echo "Hostname: $(hostname)"
        echo "OS: $(uname -a)"
        echo "Disk Usage:"
        df -h
        echo "Installed Packages:"
        dpkg -l
    } >> "$system_info_file"
    
    log "success" "System information snapshot saved to $system_info_file"
}

# Cleanup Old Backups
cleanup_old_backups() {
    local days_to_keep=30
    
    log "success" "Cleaning up backups older than $days_to_keep days..."
    find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +$days_to_keep -delete
    find "$BACKUP_DIR" -type f -name "system_info_*.txt" -mtime +$days_to_keep -delete
}

# Main Backup Function
main() {
    clear
    echo "🔒 Quick Backup Utility 🔒"
    echo "========================="
    
    create_backup_dir
    backup_configs
    backup_home_dirs
    backup_system_info
    cleanup_old_backups
    
    log "success" "Backup process completed successfully!"
}

# Script Usage
case "$1" in
    "configs")
        create_backup_dir
        backup_configs
        ;;
    "home")
        create_backup_dir
        backup_home_dirs
        ;;
    "full")
        main
        ;;
    *)
        echo "Usage: $0 {configs|home|full}"
        exit 1
        ;;
esac
