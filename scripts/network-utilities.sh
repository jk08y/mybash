#!/usr/bin/env bash
# network-utilities.sh
# Network Utilities Script for mybash

set -euo pipefail

# Color Codes
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging Functions
log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

# Internet Connectivity Check
check_connectivity() {
    log_info "Checking Internet Connectivity..."
    
    # Multiple DNS servers for robust check
    local SERVERS=("8.8.8.8" "1.1.1.1" "9.9.9.9")
    
    for server in "${SERVERS[@]}"; do
        if ping -c 4 "$server" &> /dev/null; then
            log_success "Internet Connection Successful via $server"
            return 0
        fi
    done
    
    log_error "No Internet Connection detected."
    return 1
}

# Port Scanning Utility
port_scan() {
    local HOST=$1
    local START_PORT=${2:-1}
    local END_PORT=${3:-1024}
    
    log_info "Scanning ports for $HOST from $START_PORT to $END_PORT..."
    
    for ((port=START_PORT; port<=END_PORT; port++)); do
        timeout 1 bash -c "echo >/dev/tcp/$HOST/$port" 2>/dev/null && 
            log_success "Port $port is open"
    done
}

# Network Speed Test Test 
network_speedtest() {
    log_info "Running Network Speed Test..."
    
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed. Please install it."
        return 1
    fi
    if ! command -v python3 &> /dev/null; then
        log_error "python3 is not installed. Please install it."
        return 1
    fi
    
    log_info "Download Speed Test Results:"
    if ! curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 - ; then
        log_error "Speed test failed to run."
        return 1
    fi
}

# Public IP and Geolocation
ip_info() {
    log_info "Retrieving IP Information..."
    
    local PUBLIC_IP
    if PUBLIC_IP=$(curl -s ifconfig.me); then
        log_success "Public IP: $PUBLIC_IP"
        log_info "IP Geolocation:"
        curl -s "https://ipinfo.io/$PUBLIC_IP/json" || log_error "Failed to retrieve geolocation data."
        echo "" # new line for clean output
    else
        log_error "Failed to retrieve Public IP."
        return 1
    fi
}

# Main Script Logic
main() {
    case "${1:-help}" in
        "connectivity")
            check_connectivity
            ;;
        "portscan")
            if [ $# -lt 2 ]; then
                log_error "Usage: $0 portscan <host> [start_port] [end_port]"
                exit 1
            fi
            port_scan "$2" "${3:-1}" "${4:-1024}"
            ;;
        "speedtest")
            network_speedtest
            ;;
        "ipinfo")
            ip_info
            ;;
        "help"|*)
            echo "Network Utilities Script"
            echo "Usage: $0 {connectivity|portscan|speedtest|ipinfo}"
            echo ""
            echo "Options:"
            echo "  connectivity    Check external internet connectivity."
            echo "  portscan        Scan ports on a target address."
            echo "  speedtest       Run a basic download/upload speed test."
            echo "  ipinfo          Get public IP address and geolocation information."
            exit 1
            ;;
    esac
}

main "$@"