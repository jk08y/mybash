#!/bin/bash
# System Information and Monitoring Tool
# Optimized for performance and readability

# Color Codes (Using more efficient declaration)
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging function for consistent output
log_section() {
    printf "${BLUE}===== %s =====${NC}\n" "$1"
}

# System Information Function
system_info() {
    log_section "SYSTEM INFORMATION"
    
    # Hardware Information (Using more efficient commands)
    printf "${GREEN}[*] Hardware Details:${NC}\n"
    printf "Hostname: %s\n" "$(hostname -f)"
    printf "Kernel: %s\n" "$(uname -r)"
    printf "Architecture: %s\n" "$(uname -m)"
    
    # CPU Information (More robust extraction)
    printf "\n${GREEN}[*] CPU Information:${NC}\n"
    local cpu_model cpu_cores
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
    cpu_cores=$(nproc)
    printf "Model: %s\n" "$cpu_model"
    printf "Cores: %s\n" "$cpu_cores"
    
    # Memory Information
    printf "\n${GREEN}[*] Memory Details:${NC}\n"
    free -h
    
    # Disk Usage
    printf "\n${GREEN}[*] Disk Usage:${NC}\n"
    df -h
}

# System Performance Monitor status
performance_monitor() {
    log_section "SYSTEM PERFORMANCE"
    
    # CPU Usage (More accurate calculation)
    printf "${GREEN}[*] CPU Usage:${NC}\n"
    mpstat 1 1 | awk '$3 ~ /[0-9.]+/ {print 100 - $3 "%"}'
    
    # Memory Usage
    printf "\n${GREEN}[*] Memory Usage:${NC}\n"
    free | awk 'NR==2{printf "Total: %s, Used: %s (%.2f%%)", $2, $3, $3*100/$2}'
    
    # Top Processes (Added more details)
    printf "\n${GREEN}[*] Top 5 Processes by CPU Usage:${NC}\n"
    ps aux | sort -nrk 3,3 | head -n 5 | awk '{printf "PID: %s, CPU: %s, Memory: %s, Command: %s\n", $2, $3, $4, $11}'
}

# Network Information
network_info() {
    log_section "NETWORK INFORMATION"
    
    # Public IP (Added timeout and fallback)
    printf "${GREEN}[*] Public IP:${NC}\n"
    timeout 5 curl -s ifconfig.me || timeout 5 curl -s ipecho.net/plain || echo "Unable to retrieve public IP"
    
    # Network Interfaces (More detailed)
    printf "\n${GREEN}[*] Network Interfaces:${NC}\n"
    ip -br addr show
    
    # DNS Servers
    printf "\n${GREEN}[*] DNS Servers:${NC}\n"
    grep -v '^#' /etc/resolv.conf | grep nameserver
    
    # Network Connectivity Test
    printf "\n${GREEN}[*] Network Connectivity:${NC}\n"
    timeout 3 ping -c 4 8.8.8.8 || echo "Network connectivity test failed"
}

# Error handling
error_exit() {
    printf "${YELLOW}ERROR: %s${NC}\n" "$1" >&2
    exit 1
}

# Main Script Logic
main() {
    # Check for required commands
    for cmd in hostname uname nproc free df ps ip curl; do
        command -v "$cmd" >/dev/null 2>&1 || error_exit "Required command '$cmd' not found"
    done

    # Parse arguments
    case "${1:-help}" in
        "info")
            system_info
            ;;
        "performance")
            performance_monitor
            ;;
        "network")
            network_info
            ;;
        "help")
            printf "Usage: $0 {info|performance|network|help}\n"
            ;;
        *)
            error_exit "Invalid argument. Use {info|performance|network|help}"
            ;;
    esac
}

# Execute main function
main "$@"
