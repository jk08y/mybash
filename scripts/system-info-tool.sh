#!/usr/bin/env bash

# system-info-tool.sh
# System Information and Monitoring Tool

set -euo pipefail

# Color Codes
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

log_section() {
    printf "\n${BLUE}===== %s =====${NC}\n" "$1"
}

# System Information
system_info() {
    log_section "SYSTEM INFORMATION"
    
    printf "${GREEN}Hardware Details:${NC}\n"
    printf "  Hostname:     %s\n" "$(hostname -f 2>/dev/null || hostname)"
    printf "  Kernel:       %s\n" "$(uname -r)"
    printf "  Architecture: %s\n" "$(uname -m)"
    
    printf "\n${GREEN}CPU Information:${NC}\n"
    local cpu_model cpu_cores
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs || echo "Unknown CPU")
    cpu_cores=$(nproc || echo "Unknown Cores")
    printf "  Model:        %s\n" "$cpu_model"
    printf "  Cores:        %s\n" "$cpu_cores"
    
    printf "\n${GREEN}Memory Details:${NC}\n"
    free -h | awk 'NR==2{printf "  Total: %s\n  Used:  %s\n  Free:  %s\n", $2, $3, $4}'
    
    printf "\n${GREEN}Disk Usage (Root /):${NC}\n"
    df -h / | tail -n 1 | awk '{printf "  Total: %s\n  Used:  %s\n  Avail: %s\n  Usage: %s\n", $2, $3, $4, $5}'
}

# System Performance
performance_monitor() {
    log_section "SYSTEM PERFORMANCE"
    
    printf "${GREEN}CPU Load Average:${NC}\n"
    local load_avg
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    printf "  1/5/15 min:   %s\n" "$load_avg"
    
    printf "\n${GREEN}Memory Usage Details:${NC}\n"
    free -m | awk 'NR==2{printf "  Used: %.2f%%\n", $3*100/$2}'
    
    printf "\n${GREEN}Top 5 Processes by CPU (PID, %CPU, %MEM, CMD):${NC}\n"
    ps aux --sort=-%cpu | head -n 6 | tail -n 5 | awk '{printf "  %-7s %-5s %-5s %s\n", $2, $3, $4, $11}'
}

# Network Information
network_info() {
    log_section "NETWORK INFORMATION"
    
    printf "${GREEN}Public IP:${NC}\n"
    local public_ip
    if public_ip=$(timeout 3 curl -s ifconfig.me 2>/dev/null); then
        printf "  %s\n" "$public_ip"
    else
        printf "  %s\n" "Unable to retrieve (Check Connection)"
    fi
    
    printf "\n${GREEN}Network Interfaces:${NC}\n"
    # Reformat slightly for readability
    if command -v ip >/dev/null 2>&1; then
        ip -br addr show | awk '{printf "  %-15s %-15s %s\n", $1, $2, $3}'
    else
        ifconfig -a | grep -E '^[a-z]|inet ' | awk '{print "  "$0}'
    fi
    
    printf "\n${GREEN}Connectivity (Ping 8.8.8.8):${NC}\n"
    if timeout 2 ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        printf "  %s\n" "Connected"
    else
        printf "  %s\n" "Failed"
    fi
}

error_exit() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
    exit 1
}

# Main Script Logic
main() {
    # Check dependencies silently where possible
    for cmd in hostname uname nproc free df ps curl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            printf "${YELLOW}[WARNING]${NC} Required command '%s' not found. Output may be incomplete.\n" "$cmd"
        fi
    done

    case "${1:-}" in
        "info")
            system_info
            ;;
        "performance")
            performance_monitor
            ;;
        "network")
            network_info
            ;;
        "all")
            system_info
            performance_monitor
            network_info
            ;;
        *)
            echo "System Information Tool"
            echo "Usage: $0 {info|performance|network|all}"
            echo ""
            echo "Commands:"
            echo "  info          Display hardware, CPU, memory, and disk info."
            echo "  performance   Show CPU load, memory usage, and top processes."
            echo "  network       List public IP, interfaces, and connectivity."
            echo "  all           Run all checks."
            exit 1
            ;;
    esac
    echo "" # padding
}

main "$@"
