#!/bin/bash
# Minimal proxy speed test

# Test basic curl functionality
echo "=== CURL TEST ==="
echo "Testing direct connection to passo.com.tr..."
curl_result=$(timeout 5 curl -s -w "%{http_code}|%{time_total}" https://passo.com.tr 2>/dev/null)
exit_code=$?

echo "Exit code: $exit_code"
echo "Result: $curl_result"

if [[ $exit_code -eq 0 ]] && [[ -n "$curl_result" ]]; then
    http_code=$(echo "$curl_result" | tail -1 | cut -d'|' -f1)
    time_total=$(echo "$curl_result" | tail -1 | cut -d'|' -f2)
    echo "HTTP Code: $http_code"
    echo "Time: $time_total seconds"
else
    echo "Direct connection failed!"
fi

# Test proxy connection (this will likely fail, but shows the command)
echo
echo "=== PROXY TEST ==="
echo "Testing proxy connection..."
proxy_result=$(timeout 5 curl -s -w "%{http_code}|%{time_total}" --proxy "onvaonet:onvaonet@45.13.225.70:3128" https://passo.com.tr 2>/dev/null)
proxy_exit=$?

echo "Proxy exit code: $proxy_exit"
echo "Proxy result: $proxy_result"

# Test if bc is available
echo
echo "=== BC TEST ==="
if command -v bc >/dev/null; then
    echo "✅ bc is available"
    test_calc=$(echo "scale=0; 1.5 * 1000" | bc -l 2>/dev/null)
    echo "Test calculation: $test_calc"
else
    echo "❌ bc is not available"
fi
