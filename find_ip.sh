#!/bin/bash

# Check if IP address is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

IP_ADDRESS=$1

# Perform port scan
echo "Scanning open ports on IP: $IP_ADDRESS..."
OPEN_PORTS=$(nmap -p- --open -Pn "$IP_ADDRESS" | grep 'open' | awk '{print $1}' | sed 's/\/tcp//')

if [ -z "$OPEN_PORTS" ]; then
    echo "No open ports found on $IP_ADDRESS."
    exit 0
fi

echo "Open ports detected: $OPEN_PORTS"
echo "Performing detailed checks on each port..."

for PORT in $OPEN_PORTS; do
    echo "Testing port $PORT..."

    # Basic connection test
    nc -z -w 2 "$IP_ADDRESS" "$PORT" && echo "Connection succeeded!" || echo "Connection failed."

    # Protocol-specific tests
    case "$PORT" in
    22)
        echo "Testing SSH..."
        ssh -o ConnectTimeout=3 -o BatchMode=yes "$IP_ADDRESS" exit &>/dev/null && \
        echo "SSH service is responding." || echo "SSH service not responding."
        ;;
    80|8080)
        echo "Testing HTTP..."
        curl -s -I --max-time 3 "http://$IP_ADDRESS:$PORT" | head -n 1 || echo "No HTTP response."
        ;;
    443)
        echo "Testing HTTPS..."
        curl -s -I --max-time 3 "https://$IP_ADDRESS:$PORT" | head -n 1 || echo "No HTTPS response."
        ;;
    5667)
        echo "Testing for Nagios NRPE (common for port 5667)..."
        echo -e "\n" | nc -w 3 "$IP_ADDRESS" "$PORT" | head -n 5 || echo "No NRPE response."
        ;;
    *)
        echo "Generic test for port $PORT..."
        echo -e '\n' | timeout 3 telnet "$IP_ADDRESS" "$PORT" 2>/dev/null | head -n 5 || echo "No response from port $PORT."
        ;;
    esac
done
