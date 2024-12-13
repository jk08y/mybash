# network-utilities.sh
#!/bin/bash

# Network Utilities Script

# Color Codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Internet Connectivity Check
check_connectivity() {
    echo -e "${YELLOW}Checking Internet Connectivity...${NC}"
    
    # Multiple DNS servers for robust check
    SERVERS=("8.8.8.8" "1.1.1.1" "9.9.9.9")
    
    for server in "${SERVERS[@]}"; do
        if ping -c 4 "$server" &> /dev/null; then
            echo -e "${GREEN}✓ Internet Connection Successful via $server${NC}"
            return 0
        fi
    done
    
    echo -e "${RED}✗ No Internet Connection${NC}"
    return 1
}

# Port Scanning Utility
port_scan() {
    local HOST=$1
    local START_PORT=${2:-1}
    local END_PORT=${3:-1024}
    
    echo -e "${YELLOW}Scanning ports for $HOST from $START_PORT to $END_PORT...${NC}"
    
    for ((port=START_PORT; port<=END_PORT; port++)); do
        timeout 1 bash -c "echo >/dev/tcp/$HOST/$port" 2>/dev/null && 
            echo -e "${GREEN}Port $port is open${NC}"
    done
}

# Network Speed Test
network_speedtest() {
    echo -e "${YELLOW}Running Network Speed Test...${NC}"
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}curl is not installed. Please install it.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Download Speed:${NC}"
    curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
}

# Public IP and Geolocation
ip_info() {
    echo -e "${YELLOW}Retrieving IP Information...${NC}"
    
    # Public IP
    PUBLIC_IP=$(curl -s ifconfig.me)
    echo -e "${GREEN}Public IP:${NC} $PUBLIC_IP"
    
    # Geolocation (using ipinfo.io)
    echo -e "${GREEN}IP Geolocation:${NC}"
    curl -s "https://ipinfo.io/$PUBLIC_IP/json"
}

# Main Script Logic
case "$1" in
    "connectivity")
        check_connectivity
        ;;
    "portscan")
        if [ $# -lt 2 ]; then
            echo "Usage: $0 portscan <host> [start_port] [end_port]"
            exit 1
        fi
        port_scan "$2" "$3" "$4"
        ;;
    "speedtest")
        network_speedtest
        ;;
    "ipinfo")
        ip_info
        ;;
    *)
        echo "Usage: $0 {connectivity|portscan|speedtest|ipinfo}"
        exit 1
        ;;
esac