#!/bin/bash
# Test proxy file selection logic

# Simulate directory structure
DATA_DIR="/var/lib/3proxy"
PROXY_LIST_FILE="/var/lib/3proxy/proxylistesi.txt"

# Create test files
mkdir -p test_data
echo "45.13.225.70/24" > test_data/proxylistesi.txt
echo "user1:pass1@45.13.225.70:3128" > test_data/proxy_list_fixed_1699123456.txt  
echo "user2:pass2@45.86.155.69:3129" > test_data/proxy_list_random_1699123457.txt

# Test file discovery
echo "=== PROXY FILE DISCOVERY TEST ==="
proxy_files=()

# Check IP list
if [[ -f "test_data/proxylistesi.txt" ]]; then
    proxy_files+=("test_data/proxylistesi.txt")
    echo "1) IP Listesi: test_data/proxylistesi.txt ($(wc -l < "test_data/proxylistesi.txt") satır)"
fi

# Check generated proxy lists  
count=1
for proxy_file in test_data/proxy_list_*.txt; do
    if [[ -f "$proxy_file" ]]; then
        ((count++))
        proxy_files+=("$proxy_file")
        echo "$count) Proxy Listesi: $(basename "$proxy_file") ($(wc -l < "$proxy_file") satır)"
    fi
done

echo
echo "Total files found: ${#proxy_files[@]}"
echo "Files: ${proxy_files[@]}"

# Test format detection
echo
echo "=== FORMAT DETECTION TEST ==="
for file in "${proxy_files[@]}"; do
    first_line=$(head -1 "$file")
    echo "File: $file"
    echo "First line: $first_line"
    
    if [[ "$first_line" =~ ^([^:/]+)(/[0-9]+)?$ ]] && [[ ! "$first_line" =~ : ]]; then
        echo "Format: IP List (not suitable for speed test)"
    else
        echo "Format: Proxy List (suitable for speed test)"
    fi
    echo "---"
done

# Cleanup
rm -rf test_data
