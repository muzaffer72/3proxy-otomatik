#!/bin/bash

# Extract just the test_proxy function and test it
test_proxy() {
    local proxy_line="$1"
    local expected_ip="$2"
    echo "[DEBUG] test_proxy: Testing proxy line: '$proxy_line' | Expected IP: '$expected_ip'"
    
    # Basit proxy test - icanhazip.com ile test et (sadece IP döndürür)
    local test_result
    local curl_exit_code
    
    # Proxy formatı: username:password@ip:port
    test_result=$(timeout 10 curl -x "$proxy_line" -s https://icanhazip.com 2>/dev/null)
    curl_exit_code=$?
    echo "[DEBUG] test_proxy: curl exit code: $curl_exit_code"
    echo "[DEBUG] test_proxy: curl result: '$test_result'"
    
    # Curl başarılı mı?
    if [ $curl_exit_code -eq 0 ] && [ -n "$test_result" ]; then
        # icanhazip.com sadece IP döndürür, temizle
        local origin_ip=$(echo "$test_result" | tr -d '\r\n ')
        echo "[DEBUG] test_proxy: Cleaned origin IP: '$origin_ip'"
        
        # Beklenen IP ile dönen IP aynı mı?
        if [ "$origin_ip" = "$expected_ip" ]; then
            echo "[DEBUG] test_proxy: SUCCESS - IP match."
            return 0  # Başarılı
        else
            echo "[DEBUG] test_proxy: FAILED - IP Mismatch. Expected '$expected_ip', Got '$origin_ip'"
            return 1
        fi
    else
        echo "[DEBUG] test_proxy: FAILED - Connection failed or empty result."
        return 1
    fi
}

# Test function without proxy (should show your real IP)
echo "Testing icanhazip.com directly (no proxy):"
real_ip=$(curl -s https://icanhazip.com | tr -d '\r\n ')
echo "Your real IP: '$real_ip'"

# Test function with an invalid proxy (should fail)
echo -e "\nTesting with invalid proxy:"
test_proxy "user:pass@999.999.999.999:3128" "999.999.999.999"
echo "Invalid proxy test result: $?"

echo -e "\nValidation function test completed!"
