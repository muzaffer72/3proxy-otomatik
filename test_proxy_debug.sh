#!/bin/bash
# Debug proxy speed test function

# Test data
cat > test_proxy_debug.txt << 'EOF'
onvaonet:onvaonet@45.13.225.70:3128
onvaonet:onvaonet@45.86.155.69:3129
onvaonet:onvaonet@185.14.92.130:3130
EOF

echo "=== PROXY PARSING DEBUG TEST ==="

# Test the regex patterns
while IFS= read -r proxy_line; do
    if [[ -z "$proxy_line" ]] || [[ "$proxy_line" =~ ^#.* ]]; then
        continue
    fi
    
    echo "Testing: $proxy_line"
    
    # Test pattern matching
    if [[ "$proxy_line" =~ ^([^:]+):([^@]+)@([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
        echo "✅ Pattern 1 matched: USER:PASS@IP:PORT"
        echo "   User: ${BASH_REMATCH[1]}"
        echo "   Pass: ${BASH_REMATCH[2]}"
        echo "   IP: ${BASH_REMATCH[3]}"
        echo "   Subnet: ${BASH_REMATCH[4]}"
        echo "   Port: ${BASH_REMATCH[5]}"
    elif [[ "$proxy_line" =~ ^([^:/]+)(/[0-9]+)?:([0-9]+):([^:]+):(.+)$ ]]; then
        echo "✅ Pattern 2 matched: IP:PORT:USER:PASS"
        echo "   IP: ${BASH_REMATCH[1]}"
        echo "   Port: ${BASH_REMATCH[3]}"
    elif [[ "$proxy_line" =~ ^([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
        echo "✅ Pattern 3 matched: IP:PORT"
        echo "   IP: ${BASH_REMATCH[1]}"
        echo "   Port: ${BASH_REMATCH[3]}"
    else
        echo "❌ No pattern matched!"
    fi
    echo "---"
    
done < test_proxy_debug.txt

# Test file reading
echo
echo "=== FILE READING TEST ==="
echo "Lines in file: $(wc -l < test_proxy_debug.txt)"
echo "Content:"
cat -n test_proxy_debug.txt

# Test while loop
echo
echo "=== WHILE LOOP TEST ==="
line_count=0
while IFS= read -r proxy_line; do
    ((line_count++))
    echo "Line $line_count: [$proxy_line]"
done < test_proxy_debug.txt

rm test_proxy_debug.txt
