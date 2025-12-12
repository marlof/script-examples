#!/bin/bash

# Cache file for IP-country lookups
CACHE_FILE="${HOME}/ip_country_cache.txt"


# Combined log for DST ports and country tracking
LOG_FILE="/tmp/port_country_log.txt"

# Temp files for SRC IPs (if still needed for other use cases)
SRC_IPS_FILE="/tmp/src_ips.txt"

# Initialize the log file but not the cache (cache persists across runs)
> "$LOG_FILE"
> "$SRC_IPS_FILE"

# Function to get the first 3 octets of an IP
get_first_three_octets() {
  local ip="$1"
  echo "$ip" | cut -d '.' -f 1-3
}

# Function to check if an IP is in the local 192.168.x.x range
is_local_ip() {
  local ip="$1"
  [[ "$ip" =~ ^192\.168\..* ]]
}

# Function to look up country by the first 3 octets of IP and cache the result
lookup_country() {
  local ip="$1"
  local octets=$(get_first_three_octets "$ip")
  
  # Check if the 3-octet IP is already cached
  local country=$(grep "^$octets" "$CACHE_FILE" | cut -d ' ' -f 2 | sort -u)
  
  if [ -z "$country" ]; then
    # If not cached, use curl to get the country from ipinfo.io
    country=$(curl -s "https://ipinfo.io/$octets.0/country")
    
    # Cache the result for future use
    echo "$octets $country" >> "$CACHE_FILE"
  fi
  
  echo "$country"
}

# Process the syslog file line by line
while read -r line; do
  # Extract SRC IP and DST Port from the log line
  src_ip=$(echo "$line" | grep -oP 'SRC=\K[\d.]+')
  dst_port=$(echo "$line" | grep -oP 'DPT=\K\d+')
  
  # Exclude local IP addresses in the 192.168.x.x range
  if is_local_ip "$src_ip"; then
    continue
  fi
  
  # Look up the country of origin for the SRC IP
  country=$(lookup_country "$src_ip")
  
  # Log the DST port, country, and SRC IP
  echo "$(get_first_three_octets $src_ip) $dst_port $country" >> "$LOG_FILE"
  echo "$src_ip" >> "$SRC_IPS_FILE"
  
  # Output the result (Optional: format it as you like)
  echo "SRC IP: $src_ip, Country: $country, DST Port: $dst_port"
  
done < /var/log/syslog.log

# Find the most common DST ports
echo "Most common DST ports:"
sort "$LOG_FILE" | cut -d ' ' -f 1 | uniq -c | sort -nr | head -n 10

# Find the most common country-port pairs
echo "Most common country-port pairs:"
sort "$LOG_FILE" | uniq -c | sort -nr | head -n 10

# Find the most common source IPs
echo "Most common SRC IP addresses:"
sort "$SRC_IPS_FILE" | uniq -c | sort -nr | head -n 10
