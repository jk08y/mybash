# terminal-uninstall.sh updated
#!/bin/bash

# Ultimate Terminal Enhancement Uninstallation Script

# Color Codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging Functions
log_success() {
    echo -e "${GREEN}[✓ SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠ WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗ ERROR]${NC} $1"
}

# Restore Original Configurations
restore_configs() {
    echo "Restoring original configurations..."
    
    # Restore bashrc
    if [ -f "$HOME/.bashrc.orig" ]; then
        mv "$HOME/.bashrc.orig" "$HOME/.bashrc"
        log_success "Original .bashrc restored"
    fi
    
    # Restore bash_aliases
    if [ -f "$HOME/.bash_aliases.orig" ]; then
        mv "$HOME/.bash_aliases.orig" "$HOME/.bash_aliases"
        log_success "Original .bash_aliases restored"
    fi
    
    # Restore tmux.conf
    if [ -f "$HOME/.tmux.conf.orig" ]; then
        mv "$HOME/.tmux.conf.orig" "$HOME/.tmux.conf"
        log_success "Original .tmux.conf restored"
    fi
}

# Remove Installed Packages
remove_packages() {
    echo "Removing installed packages..."
    
    # List of packages to remove
    PACKAGES_TO_REMOVE=(
        "zsh" "oh-my-zsh" "tmux" 
        "fzf" "ripgrep" "bat" "fd-find" "neofetch"
    )
    
    for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
        apt-get remove -y "$pkg"
    done
    
    log_success "Packages removed"
}

# Remove Utility Scripts
remove_scripts() {
    echo "Removing utility scripts..."
    
    # Remove scripts from bin
    rm -rf "$HOME/bin/system-info-tool.sh"
    rm -rf "$HOME/bin/network-utilities.sh"
    
    log_success "Utility scripts removed"
}

# Cleanup Oh My Zsh and Powerlevel10k
cleanup_zsh() {
    echo "Cleaning up Zsh configurations..."
    
    # Remove Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        rm -rf "$HOME/.oh-my-zsh"
        log_success "Oh My Zsh removed"
    fi
    
    # Remove Powerlevel10k
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
        log_success "Powerlevel10k theme removed"
    fi
    
    # Reset shell to default
    chsh -s "$(which bash)"
}

# Main Uninstallation Function
main() {
    clear
    echo "🔄 Ultimate Terminal Enhancement Uninstaller 🔄"
    echo "=============================================="
    
    # Confirm uninstallation
    read -p "Are you sure you want to uninstall? (y/N): " confirm
    if [[ "$confirm" != [yY] && "$confirm" != [yY][eE][sS] ]]; then
        echo "Uninstallation cancelled."
        exit 0
    fi
    
    # Run uninstallation steps
    restore_configs
    remove_packages
    remove_scripts
    cleanup_zsh
    
    echo ""
    log_success "Terminal enhancement completely uninstalled!"
    echo "Your original terminal configuration has been restored."
}

# Run the main uninstallation
main
