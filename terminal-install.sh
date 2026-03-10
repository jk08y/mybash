#!/usr/bin/env bash

# terminal-install.sh
# Professional Terminal Enhancement Installer
# This script installs required packages and sets up customizable configurations.

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

# Ensure script is NOT run as root, as dotfiles must belong to the user
if [ "$EUID" -eq 0 ]; then
    die "This script must NOT be run as root. It will ask for sudo password when necessary."
fi

# Determine terminal environment
USER_HOME="$HOME"
OS_RELEASE="/etc/os-release"

check_os() {
    if [ -f "$OS_RELEASE" ]; then
        . "$OS_RELEASE"
        if [[ "$ID" != "ubuntu" && "$ID" != "debian" && "$ID_LIKE" != *"debian"* && "$ID_LIKE" != *"ubuntu"* ]]; then
            log_warning "This script is optimized for Ubuntu/Debian based systems. Some features might not work as expected."
        fi
    else
        log_warning "Cannot determine OS. Proceeding with caution."
    fi
}

# Check and Install Prerequisites
check_prerequisites() {
    log_info "Checking system prerequisites..."
    
    local REQUIRED_PACKAGES=(
        "git" "curl" "wget" "tmux" "zsh" 
        "fzf" "ripgrep" "bat" "fd-find" "neofetch"
    )
    
    local missing_packages=()
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing_packages+=("$pkg")
        fi
    done

    if [ ${#missing_packages[@]} -gt 0 ]; then
        log_info "Installing missing packages: ${missing_packages[*]}"
        sudo apt-get update || die "Failed to update package lists."
        sudo apt-get install -y "${missing_packages[@]}" || die "Failed to install required packages."
        log_success "Packages installed successfully."
    else
        log_success "All prerequisite packages are already installed."
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || die "Failed to install Oh My Zsh."
        log_success "Oh My Zsh installed successfully."
    else
        log_info "Oh My Zsh is already installed. Skipping."
    fi
}

# Install Powerlevel10k Theme
install_powerlevel10k() {
    local POWERLEVEL_DIR="${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ ! -d "$POWERLEVEL_DIR" ]; then
        log_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWERLEVEL_DIR" || die "Failed to clone Powerlevel10k."
        log_success "Powerlevel10k theme installed."
    else
        log_info "Powerlevel10k is already installed. Skipping."
    fi
}

# Backup and Install Configurations
install_configs() {
    log_info "Setting up configurations..."
    
    # Create backup directory timestamped for uninstallation reference
    local TIMESTAMP
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    local BACKUP_DIR="$USER_HOME/.terminal-config-backup-$TIMESTAMP"
    
    mkdir -p "$BACKUP_DIR" || die "Failed to create backup directory."
    
    # Backup existing configs safely
    [ -f "$USER_HOME/.bashrc" ] && cp -a "$USER_HOME/.bashrc" "$BACKUP_DIR/.bashrc.backup"
    [ -f "$USER_HOME/.bash_aliases" ] && cp -a "$USER_HOME/.bash_aliases" "$BACKUP_DIR/.bash_aliases.backup"
    [ -f "$USER_HOME/.tmux.conf" ] && cp -a "$USER_HOME/.tmux.conf" "$BACKUP_DIR/.tmux.conf.backup"
    [ -f "$USER_HOME/.zshrc" ] && cp -a "$USER_HOME/.zshrc" "$BACKUP_DIR/.zshrc.backup"
    
    log_info "Previous configurations backed up to $BACKUP_DIR"
    
    # Install new configurations - ensure they exist in repository
    if [ -f "configs/bashrc-custom" ]; then
        cp -f configs/bashrc-custom "$USER_HOME/.bashrc"
    else
        log_warning "configs/bashrc-custom not found. Skipping .bashrc installation."
    fi

    if [ -f "configs/bash-aliases-custom" ]; then
        cp -f configs/bash-aliases-custom "$USER_HOME/.bash_aliases"
    else
        log_warning "configs/bash-aliases-custom not found. Skipping .bash_aliases installation."
    fi

    if [ -f "configs/tmux-config" ]; then
        cp -f configs/tmux-config "$USER_HOME/.tmux.conf"
    else
        log_warning "configs/tmux-config not found. Skipping .tmux.conf installation."
    fi
    
    log_success "Configurations installed successfully."
    
    # Save the backup directory path for uninstaller to find
    echo "$BACKUP_DIR" > "$USER_HOME/.terminal-config-latest-backup"
}

# Install Utility Scripts
install_scripts() {
    log_info "Installing utility scripts..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$USER_HOME/bin"
    
    # Copy scripts and make them executable
    if ls scripts/*.sh 1> /dev/null 2>&1; then
        cp -f scripts/*.sh "$USER_HOME/bin/"
        chmod +x "$USER_HOME/bin"/*.sh
        log_success "Utility scripts installed."
    else
        log_warning "No .sh scripts found in scripts/ directory."
    fi
    
    # Add bin to PATH in .zshrc and .bashrc if not already there
    for rc in "$USER_HOME/.bashrc" "$USER_HOME/.zshrc"; do
        if [ -f "$rc" ]; then
            if ! grep -q "$USER_HOME/bin" "$rc"; then
                echo -e '\nexport PATH="$HOME/bin:$PATH"\n' >> "$rc"
            fi
        fi
    done
}

change_shell() {
    local target_shell
    target_shell=$(command -v zsh)
    
    if [ "$SHELL" != "$target_shell" ]; then
        log_info "Changing default shell to Zsh..."
        if sudo chsh -s "$target_shell" "$USER"; then
            log_success "Default shell changed to Zsh."
        else
            log_warning "Failed to change shell automatically. You may need to run 'chsh -s $(command -v zsh)' manually."
        fi
    else
        log_info "Zsh is already the default shell."
    fi
}

main() {
    clear
    log_info "Starting Terminal Enhancement Installer"
    echo "=================================================="
    
    check_os
    
    check_prerequisites
    install_oh_my_zsh
    install_powerlevel10k
    install_configs
    install_scripts
    change_shell
    
    echo "=================================================="
    log_success "Terminal enhancements installation is complete!"
    log_info "Please restart your terminal or log out and log back in for changes to take full effect."
}

# Execute main process
main "$@"
