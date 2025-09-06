#!/bin/bash
# Fixed Mode Test Script

# Simulate IP list
cat > test_ips.txt << 'EOF'
176.100.36.39/24
176.100.36.44/24
45.90.98.32/23
45.90.98.33/23
45.90.98.34/23
45.90.98.35/23
45.13.225.70/24
45.86.155.69/24
185.14.92.130/24
176.100.39.59/24
EOF

echo "=== FIXED MODE TEST ==="
echo "IP sayısı: $(wc -l < test_ips.txt)"
echo

# Simulate Fixed mode logic
fixed_start_port=3128
ip_count=$(wc -l < test_ips.txt)

echo "Expected proxy output with 1:1 IP-to-proxy mapping:"
echo "Port range: $fixed_start_port - $((fixed_start_port + ip_count - 1))"
echo

# Read and process IPs
i=0
while IFS= read -r ip_line; do
    # Clean IP (remove subnet)
    clean_ip=$(echo "$ip_line" | cut -d'/' -f1)
    assigned_port=$((fixed_start_port + i))
    echo "onvaonet:onvaonet@$clean_ip:$assigned_port"
    ((i++))
done < test_ips.txt

echo
echo "Total proxies: $ip_count"
echo "Port range: $fixed_start_port-$((fixed_start_port + ip_count - 1))"

rm test_ips.txt
