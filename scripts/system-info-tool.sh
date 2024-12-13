# system-info-tool.sh
#!/bin/bash

# System Information and Monitoring Tool

# Color Codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# System Information Function
system_info() {
    echo -e "${BLUE}===== SYSTEM INFORMATION =====${NC}"
    
    # Hardware Information
    echo -e "${GREEN}[*] Hardware Details:${NC}"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    
    # CPU Information
    echo -e "\n${GREEN}[*] CPU Information:${NC}"
    CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | uniq | cut -d':' -f2)
    CPU_CORES=$(nproc)
    echo "Model: $CPU_MODEL"
    echo "Cores: $CPU_CORES"
    
    # Memory Information
    echo -e "\n${GREEN}[*] Memory Details:${NC}"
    free -h
    
    # Disk Usage
    echo -e "\n${GREEN}[*] Disk Usage:${NC}"
    df -h
}

# System Performance Monitor
performance_monitor() {
    echo -e "${BLUE}===== SYSTEM PERFORMANCE =====${NC}"
    
    # CPU Usage
    echo -e "${GREEN}[*] CPU Usage:${NC}"
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
    
    # Memory Usage
    echo -e "\n${GREEN}[*] Memory Usage:${NC}"
    free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }'
    
    # Top Processes
    echo -e "\n${GREEN}[*] Top 5 Processes by CPU Usage:${NC}"
    ps aux | sort -nrk 3,3 | head -n 5
}

# Network Information
network_info() {
    echo -e "${BLUE}===== NETWORK INFORMATION =====${NC}"
    
    # Public IP
    echo -e "${GREEN}[*] Public IP:${NC}"
    curl -s ifconfig.me
    
    # Network Interfaces
    echo -e "\n${GREEN}[*] Network Interfaces:${NC}"
    ip addr show
    
    # DNS Servers
    echo -e "\n${GREEN}[*] DNS Servers:${NC}"
    cat /etc/resolv.conf | grep nameserver
}

# Main Script Logic
case "$1" in
    "info")
        system_info
        ;;
    "performance")
        performance_monitor
        ;;
    "network")
        network_info
        ;;
    *)
        echo "Usage: $0 {info|performance|network}"
        exit 1
        ;;
esac