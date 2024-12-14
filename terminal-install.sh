#!/bin/bash

# Ultimate Terminal Enhancement Installation Script

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
   echo "This script must be run with sudo" 
   echo "Usage: sudo ./terminal-install.sh"
   exit 1
fi

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

# Prerequisite Check
check_prerequisites() {
    echo "Checking system prerequisites..."
    
    # List of required packages
    REQUIRED_PACKAGES=(
        "git" "curl" "wget" "tmux" "zsh" 
        "fzf" "ripgrep" "bat" "fd-find" "neofetch"
    )
    
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            log_warning "Installing $pkg..."
            apt-get install -y "$pkg" || log_error "Failed to install $pkg"
        else
            log_success "$pkg is already installed"
        fi
    done
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed successfully"
    else
        log_warning "Oh My Zsh is already installed"
    fi
}

# Install Powerlevel10k Theme
install_powerlevel10k() {
    POWERLEVEL_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ ! -d "$POWERLEVEL_DIR" ]; then
        echo "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWERLEVEL_DIR"
        log_success "Powerlevel10k theme installed"
    else
        log_warning "Powerlevel10k is already installed"
    fi
}

# Backup and Install Configurations
install_configs() {
    echo "Setting up configurations..."
    
    # Create backup directory
    BACKUP_DIR="$HOME/.terminal-config-backup-$(date +%Y%m%d%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing configs
    cp -n "$HOME/.bashrc" "$BACKUP_DIR/.bashrc.backup" 2>/dev/null
    cp -n "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.backup" 2>/dev/null
    
    # Install new configurations
    cp configs/bashrc-custom.bashrc "$HOME/.bashrc"
    cp configs/bash-aliases-custom.sh "$HOME/.bash_aliases"
    cp configs/tmux-config.conf "$HOME/.tmux.conf"
    
    log_success "Configurations installed successfully"
}

# Install Utility Scripts
install_scripts() {
    echo "Installing utility scripts..."
    
    # Create bin directory if not exists
    mkdir -p "$HOME/bin"
    
    # Copy scripts and make executable
    cp scripts/*.sh "$HOME/bin/"
    chmod +x "$HOME/bin"/*.sh
    
    # Add bin to PATH if not already there
    if ! grep -q "$HOME/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    
    log_success "Utility scripts installed"
}

# Main Installation Function
main() {
    clear
    echo "🚀 Ultimate Terminal Enhancement Installer 🚀"
    echo "============================================"
    
    # Update package lists
    apt-get update
    
    # Run installation steps
    check_prerequisites
    install_oh_my_zsh
    install_powerlevel10k
    install_configs
    install_scripts
    
    # Change default shell to Zsh
    chsh -s "$(which zsh)"
    
    echo ""
    log_success "Terminal enhancement complete! Please restart your terminal."
    echo "Backup of original configs stored in: $BACKUP_DIR"
}

# Run the main installation
main
