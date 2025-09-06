#!/bin/bash

# Source the test_proxy_speed function (simulated)
test_proxy_speed_simple() {
    local proxy_line="$1"
    echo "Testing: $proxy_line"
    
    # Parse the proxy
    if [[ "$proxy_line" =~ ^([^:]+):([^@]+)@([^:/]+):([0-9]+)$ ]]; then
        local username="${BASH_REMATCH[1]}"
        local password="${BASH_REMATCH[2]}" 
        local ip="${BASH_REMATCH[3]}"
        local port="${BASH_REMATCH[4]}"
        
        echo "Parsed: $username:***@$ip:$port"
        
        # Simulate test (will fail but shows the process)
        local start_time=$(date +%s%3N)
        local test_result=$(timeout 3 curl -s -w "%{http_code}|%{time_total}" --proxy "$username:$password@$ip:$port" https://httpbin.org/ip 2>/dev/null)
        local curl_exit=$?
        local end_time=$(date +%s%3N)
        local total_time=$((end_time - start_time))
        
        echo "Exit: $curl_exit, Result: [$test_result], Time: ${total_time}ms"
        
        if [[ $curl_exit -eq 0 ]] && [[ -n "$test_result" ]]; then
            echo "SUCCESS"
        else
            echo "FAILED"
        fi
    else
        echo "Invalid format"
    fi
    echo "---"
}

# Test with sample proxy
test_proxy_speed_simple "onvaonet:onvaonet@45.13.225.70:3128"
test_proxy_speed_simple "testuser:testpass@1.2.3.4:8080"
