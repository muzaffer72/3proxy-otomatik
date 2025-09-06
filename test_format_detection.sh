#!/bin/bash
# Test IP List vs Proxy List Detection

# Test 1: IP List format
cat > test_ip_list.txt << 'EOF'
45.13.225.70/24
45.86.155.69/24
185.14.92.130/24
EOF

# Test 2: Proxy List format  
cat > test_proxy_list.txt << 'EOF'
onvaonet:onvaonet@176.100.36.39:3128
onvaonet:onvaonet@176.100.36.44:3129  
onvaonet:onvaonet@45.90.98.32:3130
EOF

echo "=== Format Detection Test ==="

echo "Test 1 - IP List format:"
first_line=$(head -1 test_ip_list.txt)
if [[ "$first_line" =~ ^([^:/]+)(/[0-9]+)?$ ]] && [[ ! "$first_line" =~ : ]]; then
    echo "✅ IP list detected: $first_line"
else
    echo "❌ Not IP list"
fi

echo
echo "Test 2 - Proxy List format:"
first_line=$(head -1 test_proxy_list.txt)
if [[ "$first_line" =~ ^([^:/]+)(/[0-9]+)?$ ]] && [[ ! "$first_line" =~ : ]]; then
    echo "❌ Incorrectly detected as IP list"
else
    echo "✅ Proxy list detected: $first_line"
fi

# Test pattern matching
echo
echo "=== Pattern Matching Tests ==="
echo "Testing IP/24 format:"
test_line="45.13.225.70/24"
if [[ "$test_line" =~ ^([^:/]+)(/[0-9]+)?$ ]]; then
    echo "✅ IP/SUBNET pattern matched: ${BASH_REMATCH[1]} subnet: ${BASH_REMATCH[2]}"
fi

echo "Testing USER:PASS@IP:PORT format:"
test_line="onvaonet:onvaonet@176.100.36.39:3128"
if [[ "$test_line" =~ ^([^:]+):([^@]+)@([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
    echo "✅ Proxy format matched: user=${BASH_REMATCH[1]}, ip=${BASH_REMATCH[3]}, port=${BASH_REMATCH[5]}"
fi

rm test_ip_list.txt test_proxy_list.txt
