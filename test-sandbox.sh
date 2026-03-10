#!/usr/bin/env bash

# test-sandbox.sh
# Safely test the mybash installation without modifying your actual user system.

set -euo pipefail

# Color Codes
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
log_warning() { printf "${YELLOW}[WARNING]${NC} %s\n" "$1"; }

SANDBOX_DIR="/tmp/mybash-test-env"

main() {
    clear
    log_info "Welcome to the mybash Sandbox Testing Utility."
    log_info "This script will trick the installer into deploying configurations to a secure temporary directory: $SANDBOX_DIR"
    
    # Clean up previous sandbox runs if they exist
    if [ -d "$SANDBOX_DIR" ]; then
        log_warning "Removing previous sandbox environment..."
        rm -rf "$SANDBOX_DIR"
    fi
    
    mkdir -p "$SANDBOX_DIR"
    
    # Replicate default linux user files if skeleton is available
    if [ -d /etc/skel ]; then
        cp -a /etc/skel/. "$SANDBOX_DIR/" >/dev/null 2>&1 || true
    fi
    
    log_info "Executing installer inside sandbox constraints..."
    
    # Execute the installer with the hijacked HOME variable
    # We allow the script to prompt for sudo ONLY so it can verify apt packages if needed,
    # but the configurations will land perfectly safely inside $SANDBOX_DIR.
    export HOME="$SANDBOX_DIR"
    
    if ./terminal-install.sh; then
        echo ""
        log_success "Testing installation completed securely!"
        echo "=========================================================="
        echo "To browse around, test features, and take your screenshots,"
        echo "enter your testing sandbox by copying and pasting this command:"
        echo ""
        printf "  ${GREEN}HOME=\"%s\" bash${NC}\n" "$SANDBOX_DIR"
        echo ""
        echo "Or to load the Zsh powerlevel10k theme directly:"
        echo ""
        printf "  ${GREEN}HOME=\"%s\" zsh${NC}\n" "$SANDBOX_DIR"
        echo "=========================================================="
    else
        log_warning "Installation encountered issues within the sandbox."
    fi
}

main "$@"
