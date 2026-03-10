#!/usr/bin/env bash

# terminal-uninstall.sh
# Professional Terminal Enhancement Uninstaller
# Safely removes terminal enhancements and restores latest backup.

set -euo pipefail

# Color Codes
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging Functions
log_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

log_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

die() {
    log_error "$1"
    exit 1
}

if [ "$EUID" -eq 0 ]; then
    die "This script must NOT be run as root. It modifies user-specific configurations."
fi

USER_HOME="$HOME"

# Restore Original Configurations
restore_configs() {
    log_info "Looking for configuration backups..."
    
    local BACKUP_REF_FILE="$USER_HOME/.terminal-config-latest-backup"
    
    if [ -f "$BACKUP_REF_FILE" ]; then
        local BACKUP_DIR
        BACKUP_DIR=$(cat "$BACKUP_REF_FILE")
        
        if [ -d "$BACKUP_DIR" ]; then
            log_info "Found backup directory: $BACKUP_DIR"
            log_info "Restoring original configurations..."

            [ -f "$BACKUP_DIR/.bashrc.backup" ] && cp -f "$BACKUP_DIR/.bashrc.backup" "$USER_HOME/.bashrc" && log_success "Restored .bashrc"
            [ -f "$BACKUP_DIR/.bash_aliases.backup" ] && cp -f "$BACKUP_DIR/.bash_aliases.backup" "$USER_HOME/.bash_aliases" && log_success "Restored .bash_aliases"
            [ -f "$BACKUP_DIR/.tmux.conf.backup" ] && cp -f "$BACKUP_DIR/.tmux.conf.backup" "$USER_HOME/.tmux.conf" && log_success "Restored .tmux.conf"
            [ -f "$BACKUP_DIR/.zshrc.backup" ] && cp -f "$BACKUP_DIR/.zshrc.backup" "$USER_HOME/.zshrc" && log_success "Restored .zshrc"

            # Optionally clean up the reference file
            rm -f "$BACKUP_REF_FILE"
        else
            log_warning "Backup directory ($BACKUP_DIR) listed in reference file does not exist. Cannot restore configurations."
        fi
    else
        log_warning "No valid backup reference file found at $BACKUP_REF_FILE. Cannot restore configurations automatically."
    fi
}

# Remove Utility Scripts
remove_scripts() {
    log_info "Removing installed utility scripts..."
    
    local SCRIPTS=(
        "network-utilities.sh"
        "quick-backup-script.sh"
        "system-info-tool.sh"
    )
    
    local script_removed=false
    for script in "${SCRIPTS[@]}"; do
        if [ -f "$USER_HOME/bin/$script" ]; then
            rm -f "$USER_HOME/bin/$script"
            log_success "Removed $script"
            script_removed=true
        fi
    done
    
    if [ "$script_removed" = false ]; then
        log_info "No utility scripts found in $USER_HOME/bin to remote."
    fi
}

# Cleanup Oh My Zsh and Powerlevel10k
cleanup_zsh() {
    log_info "Cleaning up Zsh custom configurations..."
    
    local ZSH_DIR="$USER_HOME/.oh-my-zsh"
    local CUSTOM_DIR="${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}"
    local P10K_DIR="$CUSTOM_DIR/themes/powerlevel10k"
    local PLUGINS_DIR="$CUSTOM_DIR/plugins"
    
    if [ -d "$P10K_DIR" ]; then
        rm -rf "$P10K_DIR"
        log_success "Powerlevel10k theme removed."
    fi

    if [ -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
        rm -rf "$PLUGINS_DIR/zsh-autosuggestions"
        log_success "zsh-autosuggestions plugin removed."
    fi

    if [ -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        rm -rf "$PLUGINS_DIR/zsh-syntax-highlighting"
        log_success "zsh-syntax-highlighting plugin removed."
    fi
    
    if [ -d "$ZSH_DIR" ]; then
        log_warning "Oh My Zsh directory ($ZSH_DIR) still exists."
        log_info "To completely remove Oh My Zsh, you can run 'uninstall_oh_my_zsh' if you are still logged into a Zsh standard session,"
        log_info "or manually remove it by running: rm -rf ~/.oh-my-zsh"
    fi
}

change_shell_to_bash() {
    local target_shell
    target_shell=$(command -v bash)
    
    if [ "$SHELL" != "$target_shell" ]; then
        log_info "Changing default shell back to Bash..."
        if sudo chsh -s "$target_shell" "$USER"; then
            log_success "Default shell changed to Bash."
        else
            log_warning "Failed to change shell automatically. You may need to run 'chsh -s $(command -v bash)' manually."
        fi
    else
        log_info "Bash is already the default shell."
    fi
}

main() {
    clear
    log_info "Starting Terminal Enhancement Uninstaller"
    echo "=================================================="
    
    # Confirm uninstallation
    read -rp "Are you sure you want to uninstall user configurations and scripts? (y/N): " confirm
    if [[ "$confirm" != [yY] && "$confirm" != [yY][eE][sS] ]]; then
        log_info "Uninstallation cancelled."
        exit 0
    fi
    
    log_info "Note: Installed system packages (like git, curl, zsh) are NOT removed to prevent breaking other programs."
    
    restore_configs
    remove_scripts
    cleanup_zsh
    change_shell_to_bash
    
    echo "=================================================="
    log_success "Terminal enhancements configurations uninstalled successfully."
    log_info "Please restart your terminal or log out and log back in for changes to take full effect."
}

# Run the main uninstallation
main "$@"
