#!/bin/bash
# 3proxy Elite Anonymous Proxy - Advanced Menu System
# Ubuntu 20.04+ Compatible - Self-Installing Version
# Author: muzaffer72
# Version: 2.4

set -e

# Check for install parameter
if [[ "$1" == "--install" ]]; then
    install_system
    exit 0
fi

# Configuration
VERSION="2.6"
SCRIPT_DIR="/opt/3proxy"
CONFIG_DIR="/etc/3proxy"
LOG_DIR="/var/log/3proxy"
DATA_DIR="/var/lib/3proxy"
TEMP_DIR="/tmp/3proxy"
PROXY_LIST_FILE="${DATA_DIR}/proxylistesi.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Installation Functions
install_system() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    ${GREEN}3PROXY ELITE MANAGER${BLUE}                         ║${NC}"
    echo -e "${BLUE}║                      ${YELLOW}System Installer${BLUE}                         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo

    # Check root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR] Bu script root olarak çalıştırılmalıdır: sudo $0 --install${NC}"
        exit 1
    fi

    # Check system
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Bu script Ubuntu 20.04+ için optimize edilmiştir${NC}"
        read -p "Devam etmek istiyor musunuz? [y/N]: " continue_install
        if [[ ! "$continue_install" =~ ^[Yy] ]]; then
            exit 0
        fi
    fi

    echo -e "${GREEN}[$(date +'%H:%M:%S')] 3proxy Elite Manager yükleniyor...${NC}"

    # Create installation directory
    install_dir="/opt/3proxy-elite"
    mkdir -p "$install_dir"
    
    # Copy current script to installation directory
    cp "$0" "$install_dir/3proxy_menu.sh"
    chmod +x "$install_dir/3proxy_menu.sh"

    # Create global commands with proper permissions
    ln -sf "$install_dir/3proxy_menu.sh" /usr/local/bin/3proxy-manager
    ln -sf "$install_dir/3proxy_menu.sh" /usr/local/bin/menu
    ln -sf "$install_dir/3proxy_menu.sh" /usr/local/bin/3proxy
    ln -sf "$install_dir/3proxy_menu.sh" /usr/local/bin/proxy-menu
    
    # Ensure symlinks are executable
    chmod +x /usr/local/bin/menu 2>/dev/null || true
    chmod +x /usr/local/bin/3proxy 2>/dev/null || true
    chmod +x /usr/local/bin/proxy-menu 2>/dev/null || true
    chmod +x /usr/local/bin/3proxy-manager 2>/dev/null || true

    echo -e "${GREEN}✅ 3proxy Elite Manager başarıyla yüklendi!${NC}"
    echo
    echo -e "${CYAN}🔗 Test global komutları:${NC}"
    echo -e "   ${WHITE}which menu${NC} - Komut konumunu kontrol et"
    echo -e "   ${WHITE}ls -la /usr/local/bin/menu${NC} - Dosya izinlerini kontrol et"
    echo
    echo -e "${GREEN}🚀 Global Komutlar:${NC}"
    echo -e "   ${BLUE}sudo menu${NC}               # Kısa komut (herhangi bir yerden)"
    echo -e "   ${BLUE}sudo 3proxy${NC}             # Ana komut"
    echo -e "   ${BLUE}sudo proxy-menu${NC}         # Alternatif komut"
    echo -e "   ${BLUE}sudo 3proxy-manager${NC}     # Tam komut"
    echo
    echo -e "${YELLOW}📋 Özellikler:${NC}"
    echo -e "   ✅ Ubuntu 20.04+ uyumluluğu"
    echo -e "   ✅ Sınırsız proxy oluşturma"
    echo -e "   ✅ 4 farklı proxy modu"
    echo -e "   ✅ Elite anonymous proxy"
    echo -e "   ✅ ZIP şifreleme"
    echo -e "   ✅ Otomatik güncelleme"
    echo
    read -p "Şimdi ana menüyü başlatmak istiyor musunuz? [y/N]: " start_now

    if [[ "$start_now" =~ ^[Yy] ]]; then
        exec "$install_dir/3proxy_menu.sh"
    else
        echo -e "${GREEN}Menü başlatmak için herhangi bir yerden: ${BLUE}sudo menu${NC}"
    fi
}

# Functions
print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    ${WHITE}3PROXY ELITE MANAGER v${VERSION}${CYAN}                    ║${NC}"
    echo -e "${CYAN}║                    ${YELLOW}Ubuntu 20.04+ Compatible${CYAN}                     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

log() { 
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_DIR}/menu.log" 2>/dev/null || true
}

error() { 
    echo -e "${RED}[ERROR] $1${NC}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "${LOG_DIR}/menu.log" 2>/dev/null || true
    read -p "Press Enter to continue..."
}

warning() { 
    echo -e "${YELLOW}[WARNING] $1${NC}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1" >> "${LOG_DIR}/menu.log" 2>/dev/null || true
}

info() { 
    echo -e "${BLUE}[INFO] $1${NC}"
}

success() { 
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Proxy validation functions
test_proxy() {
    local proxy_line="$1"
    local expected_ip="$2"
    
    # Parse different proxy formats (support subnet notation)
    local ip port username password
    
    if [[ "$proxy_line" =~ ^([^:]+):([^@]+)@([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
        # Format: USER:PASS@IP/SUBNET:PORT or USER:PASS@IP:PORT
        username="${BASH_REMATCH[1]}"
        password="${BASH_REMATCH[2]}"
        ip="${BASH_REMATCH[3]}"  # IP without subnet
        port="${BASH_REMATCH[5]}"
    elif [[ "$proxy_line" =~ ^([^:/]+)(/[0-9]+)?:([0-9]+):([^:]+):(.+)$ ]]; then
        # Format: IP/SUBNET:PORT:USER:PASS or IP:PORT:USER:PASS (legacy)
        ip="${BASH_REMATCH[1]}"  # IP without subnet
        port="${BASH_REMATCH[3]}"
        username="${BASH_REMATCH[4]}"
        password="${BASH_REMATCH[5]}"
    elif [[ "$proxy_line" =~ ^([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
        # Format: IP/SUBNET:PORT or IP:PORT (public proxy)
        ip="${BASH_REMATCH[1]}"  # IP without subnet
        port="${BASH_REMATCH[3]}"
        username=""
        password=""
    else
        echo "Invalid proxy format: $proxy_line" >&2
        return 1
    fi
    
    # Validate basic format
    if [[ -z "$ip" ]] || [[ -z "$port" ]]; then
        echo "Invalid proxy format: $proxy_line" >&2
        return 1
    fi
    
    # Test HTTP proxy with more robust error handling
    local test_result
    local curl_exit_code
    
    if [[ -n "$username" ]] && [[ -n "$password" ]]; then
        # Authenticated proxy
        test_result=$(timeout 15 curl -s --connect-timeout 10 --max-time 15 \
                     --proxy "$username:$password@$ip:$port" \
                     --user-agent "Mozilla/5.0 (compatible; ProxyTest/1.0)" \
                     http://httpbin.org/ip 2>/dev/null)
        curl_exit_code=$?
    else
        # Public proxy (no authentication)
        test_result=$(timeout 15 curl -s --connect-timeout 10 --max-time 15 \
                     --proxy "$ip:$port" \
                     --user-agent "Mozilla/5.0 (compatible; ProxyTest/1.0)" \
                     http://httpbin.org/ip 2>/dev/null)
        curl_exit_code=$?
    fi
    
    # Handle different curl exit codes
    case $curl_exit_code in
        0)
            # Success - check response
            if [[ -n "$test_result" ]]; then
                # Extract origin IP from JSON response
                local origin_ip=$(echo "$test_result" | grep -o '"origin": "[^"]*"' | cut -d'"' -f4 | cut -d',' -f1)
                
                if [[ -n "$origin_ip" ]]; then
                    if [[ "$origin_ip" == "$expected_ip" ]]; then
                        return 0  # Success
                    else
                        echo "IP Mismatch: Expected $expected_ip, Got $origin_ip" >&2
                        return 1  # IP mismatch
                    fi
                else
                    echo "Invalid JSON response" >&2
                    return 1
                fi
            else
                echo "Empty response" >&2
                return 1
            fi
            ;;
        28|7)
            # Timeout or connection failed
            return 2
            ;;
        *)
            echo "Curl failed with code $curl_exit_code" >&2
            return 1
            ;;
    esac
}

test_proxy_speed() {
    local proxy_line="$1"
    local expected_ip="$2"
    
    # Parse different proxy formats (support subnet notation)
    local ip port username password
    
    if [[ "$proxy_line" =~ ^([^:]+):([^@]+)@([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
        # Format: USER:PASS@IP/SUBNET:PORT or USER:PASS@IP:PORT
        username="${BASH_REMATCH[1]}"
        password="${BASH_REMATCH[2]}"
        ip="${BASH_REMATCH[3]}"  # IP without subnet
        port="${BASH_REMATCH[5]}"
    elif [[ "$proxy_line" =~ ^([^:/]+)(/[0-9]+)?:([0-9]+):([^:]+):(.+)$ ]]; then
        # Format: IP/SUBNET:PORT:USER:PASS or IP:PORT:USER:PASS (legacy)
        ip="${BASH_REMATCH[1]}"  # IP without subnet
        port="${BASH_REMATCH[3]}"
        username="${BASH_REMATCH[4]}"
        password="${BASH_REMATCH[5]}"
    elif [[ "$proxy_line" =~ ^([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
        # Format: IP/SUBNET:PORT or IP:PORT (public proxy)
        ip="${BASH_REMATCH[1]}"  # IP without subnet
        port="${BASH_REMATCH[3]}"
        username=""
        password=""
    else
        echo "0|FORMAT_ERROR"
        return 1
    fi
    
    # Test with passo.com.tr for speed
    local start_time=$(date +%s%3N)
    local test_result
    
    if [[ -n "$username" ]] && [[ -n "$password" ]]; then
        # Authenticated proxy
        test_result=$(timeout 15 curl -s -w "%{http_code}|%{time_total}" --proxy "$username:$password@$ip:$port" https://passo.com.tr 2>/dev/null)
    else
        # Public proxy (no authentication)
        test_result=$(timeout 15 curl -s -w "%{http_code}|%{time_total}" --proxy "$ip:$port" https://passo.com.tr 2>/dev/null)
    fi
    
    local end_time=$(date +%s%3N)
    local total_time=$((end_time - start_time))
    
    if [[ $? -eq 0 ]] && [[ -n "$test_result" ]]; then
        local http_code=$(echo "$test_result" | tail -1 | cut -d'|' -f1)
        local curl_time=$(echo "$test_result" | tail -1 | cut -d'|' -f2)
        
        # Convert curl time to milliseconds
        local ms_time=$(echo "scale=0; $curl_time * 1000" | bc -l 2>/dev/null || echo "$total_time")
        
        if [[ "$http_code" -eq 200 ]] || [[ "$http_code" -eq 301 ]] || [[ "$http_code" -eq 302 ]]; then
            echo "$ms_time|ÇALIŞIYOR"
            return 0
        else
            echo "$total_time|HTTP_ERROR_$http_code"
            return 1
        fi
    else
        echo "$total_time|TIMEOUT"
        return 2
    fi
}

validate_proxy_list() {
    local proxy_file="$1"
    local show_details="${2:-true}"
    
    if [[ ! -f "$proxy_file" ]]; then
        error "Proxy dosyası bulunamadı: $proxy_file"
        return 1
    fi
    
    # Check if file is readable and not empty
    if [[ ! -r "$proxy_file" ]]; then
        error "Proxy dosyası okunamıyor: $proxy_file"
        return 1
    fi
    
    if [[ ! -s "$proxy_file" ]]; then
        error "Proxy dosyası boş: $proxy_file"
        return 1
    fi
    
    local total_proxies=$(wc -l < "$proxy_file")
    local tested_count=0
    local success_count=0
    local failed_count=0
    local timeout_count=0
    
    if [[ "$show_details" == "true" ]]; then
        print_header
        echo -e "${CYAN}🔍 PROXY DOĞRULAMA SİSTEMİ${NC}"
        echo "=================================="
        echo -e "${WHITE}Proxy Dosyası: ${BLUE}$proxy_file${NC}"
        echo -e "${WHITE}Toplam Proxy: ${YELLOW}$total_proxies${NC}"
        echo -e "${WHITE}Test URL: ${BLUE}http://httpbin.org/ip${NC}"
        echo
        
        # Show first few proxies for debugging
        echo -e "${GRAY}İlk 3 proxy örneği:${NC}"
        head -3 "$proxy_file" | nl
        echo
        
        echo -e "${YELLOW}Proxy'ler test ediliyor...${NC}"
        echo
        printf "%-4s %-15s %-6s %-8s %-15s\n" "NO" "IP" "PORT" "DURUM" "SONUÇ"
        echo "=================================================="
    fi
    
    while IFS= read -r proxy_line; do
        # Skip empty lines and comments
        if [[ -z "$proxy_line" ]] || [[ "$proxy_line" =~ ^#.* ]] || [[ "$proxy_line" =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        
        ((tested_count++))
        
        # Parse different proxy formats (support subnet notation)
        local expected_ip port username password
        
        if [[ "$proxy_line" =~ ^([^:]+):([^@]+)@([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
            # Format: USER:PASS@IP/SUBNET:PORT or USER:PASS@IP:PORT
            username="${BASH_REMATCH[1]}"
            password="${BASH_REMATCH[2]}"
            expected_ip="${BASH_REMATCH[3]}"  # IP without subnet
            port="${BASH_REMATCH[5]}"
        elif [[ "$proxy_line" =~ ^([^:/]+)(/[0-9]+)?:([0-9]+):([^:]+):(.+)$ ]]; then
            # Format: IP/SUBNET:PORT:USER:PASS or IP:PORT:USER:PASS (legacy)
            expected_ip="${BASH_REMATCH[1]}"  # IP without subnet
            port="${BASH_REMATCH[3]}"
            username="${BASH_REMATCH[4]}"
            password="${BASH_REMATCH[5]}"
        elif [[ "$proxy_line" =~ ^([^:/]+)(/[0-9]+)?:([0-9]+)$ ]]; then
            # Format: IP/SUBNET:PORT or IP:PORT (public proxy)
            expected_ip="${BASH_REMATCH[1]}"  # IP without subnet
            port="${BASH_REMATCH[3]}"
            username=""
            password=""
        else
            if [[ "$show_details" == "true" ]]; then
                printf "%-4s %-15s %-6s FAILED   ${RED}❌ FORMAT HATASI${NC}\n" "$tested_count." "PARSE_ERROR" "N/A"
                echo -e "${GRAY}         └─ Desteklenmeyen format: $proxy_line${NC}"
            fi
            ((failed_count++))
            continue
        fi
        
        if [[ "$show_details" == "true" ]]; then
            printf "%-4s %-15s %-6s " "$tested_count." "$expected_ip" "$port"
        fi
        
        # Test the proxy with timeout
        if test_result=$(test_proxy "$proxy_line" "$expected_ip" 2>&1); then
            ((success_count++))
            if [[ "$show_details" == "true" ]]; then
                echo -e "TESTING  ${GREEN}✅ BAŞARILI${NC}"
            fi
        elif [[ $? -eq 2 ]]; then
            ((timeout_count++))
            if [[ "$show_details" == "true" ]]; then
                echo -e "TIMEOUT  ${YELLOW}⏱️  ZAMAN AŞIMI${NC}"
            fi
        else
            ((failed_count++))
            if [[ "$show_details" == "true" ]]; then
                echo -e "FAILED   ${RED}❌ HATA${NC}"
                [[ -n "$test_result" ]] && echo -e "${GRAY}         └─ $test_result${NC}"
            fi
        fi
        
        # Progress indicator
        if [[ "$show_details" == "true" ]] && (( tested_count % 5 == 0 )); then
            echo -e "${BLUE}         [İlerleme: $tested_count/$total_proxies - Başarı: $success_count]${NC}"
        fi
        
        # Small delay to prevent overwhelming
        sleep 0.1
        
    done < "$proxy_file"
    
    if [[ "$show_details" == "true" ]]; then
        echo
        echo -e "${CYAN}📊 TEST SONUÇLARI${NC}"
        echo "===================="
        echo -e "${GREEN}✅ Başarılı: $success_count${NC}"
        echo -e "${RED}❌ Başarısız: $failed_count${NC}"
        echo -e "${YELLOW}⏱️  Timeout: $timeout_count${NC}"
        echo -e "${WHITE}📈 Başarı Oranı: $(( success_count * 100 / tested_count ))%${NC}"
        echo
        
        if [[ $success_count -gt 0 ]]; then
            success "Proxy doğrulama tamamlandı! $success_count/$tested_count proxy çalışıyor."
        else
            error "Hiçbir proxy çalışmıyor! Konfigürasyonu kontrol edin."
        fi
        
        read -p "Devam etmek için Enter'a basın..."
    fi
    
    # Return success rate as percentage
    echo $(( success_count * 100 / tested_count ))
}

test_proxy_speeds() {
    local proxy_file="$1"
    
    if [[ ! -f "$proxy_file" ]]; then
        error "Proxy dosyası bulunamadı: $proxy_file"
        return 1
    fi
    
    if [[ ! -r "$proxy_file" ]]; then
        error "Proxy dosyası okunamıyor: $proxy_file"
        return 1
    fi
    
    if [[ ! -s "$proxy_file" ]]; then
        error "Proxy dosyası boş: $proxy_file"
        return 1
    fi
    
    # Check if bc is installed for calculations
    if ! command -v bc >/dev/null; then
        log "bc yükleniyor..."
        apt update -qq && apt install -y bc
    fi
    
    local total_proxies=$(wc -l < "$proxy_file")
    local tested_count=0
    local working_count=0
    local timeout_count=0
    local error_count=0
    
    print_header
    echo -e "${CYAN}🚀 PROXY HIZ TESTİ - PASSO.COM.TR${NC}"
    echo "=============================================="
    echo -e "${WHITE}Proxy Dosyası: ${BLUE}$proxy_file${NC}"
    echo -e "${WHITE}Toplam Proxy: ${YELLOW}$total_proxies${NC}"
    echo -e "${WHITE}Test Sitesi: ${BLUE}https://passo.com.tr${NC}"
    echo
    
    # Show first few proxies for debugging
    echo -e "${GRAY}İlk 3 proxy örneği:${NC}"
    head -3 "$proxy_file" | nl
    echo
    
    echo -e "${YELLOW}Proxy'ler test ediliyor...${NC}"
    echo
    printf "%-4s %-15s %-6s %-8s %-15s\n" "NO" "IP" "PORT" "HIZ(ms)" "DURUM"
    echo "------------------------------------------------------------"
    
    while IFS= read -r proxy_line; do
        if [[ -z "$proxy_line" ]] || [[ "$proxy_line" =~ ^#.* ]]; then
            continue
        fi
        
        ((tested_count++))
        
        # Parse different proxy formats to extract IP and port for display
        local expected_ip port
        
        if [[ "$proxy_line" =~ ^([^:]+):([^@]+)@([^:]+):([0-9]+)$ ]]; then
            # Format: USER:PASS@IP:PORT
            expected_ip="${BASH_REMATCH[3]}"
            port="${BASH_REMATCH[4]}"
        elif [[ "$proxy_line" =~ ^([^:]+):([0-9]+):([^:]+):(.+)$ ]]; then
            # Format: IP:PORT:USER:PASS (legacy)
            expected_ip="${BASH_REMATCH[1]}"
            port="${BASH_REMATCH[2]}"
        elif [[ "$proxy_line" =~ ^([^:]+):([0-9]+)$ ]]; then
            # Format: IP:PORT (public proxy)
            expected_ip="${BASH_REMATCH[1]}"
            port="${BASH_REMATCH[2]}"
        else
            expected_ip="UNKNOWN"
            port="N/A"
        fi
        
        printf "%-4s %-15s %-6s " "$tested_count." "$expected_ip" "$port"
        
        if speed_result=$(test_proxy_speed "$proxy_line" "$expected_ip" 2>&1); then
            local ms_time=$(echo "$speed_result" | cut -d'|' -f1)
            local status=$(echo "$speed_result" | cut -d'|' -f2)
            
            if [[ "$status" == "ÇALIŞIYOR" ]]; then
                ((working_count++))
                if [[ $ms_time -lt 1000 ]]; then
                    printf "${GREEN}%-8s ${GREEN}%-15s${NC}\n" "${ms_time}ms" "$status"
                elif [[ $ms_time -lt 3000 ]]; then
                    printf "${YELLOW}%-8s ${YELLOW}%-15s${NC}\n" "${ms_time}ms" "$status"
                else
                    printf "${RED}%-8s ${YELLOW}%-15s${NC}\n" "${ms_time}ms" "$status"
                fi
            else
                ((error_count++))
                printf "${RED}%-8s ${RED}%-15s${NC}\n" "${ms_time}ms" "$status"
            fi
        else
            local result_code=$?
            if [[ $result_code -eq 2 ]]; then
                ((timeout_count++))
                printf "${RED}%-8s ${RED}%-15s${NC}\n" "TIMEOUT" "BAĞLANAMADI"
            else
                ((error_count++))
                printf "${RED}%-8s ${RED}%-15s${NC}\n" "ERROR" "BAŞARISIZ"
            fi
        fi
        
        # Progress indicator every 10 tests
        if (( tested_count % 10 == 0 )); then
            echo -e "${BLUE}[İlerleme: $tested_count/$total_proxies]${NC}"
        fi
        
    done < "$proxy_file"
    
    echo
    echo "=============================================="
    echo -e "${CYAN}📊 HIZ TESTİ SONUÇLARI${NC}"
    echo "=============================================="
    echo -e "${GREEN}✅ Çalışan: $working_count${NC}"
    echo -e "${RED}❌ Hatalı: $error_count${NC}"
    echo -e "${YELLOW}⏱️  Timeout: $timeout_count${NC}"
    echo -e "${WHITE}📈 Başarı Oranı: $(( working_count * 100 / tested_count ))%${NC}"
    
    if [[ $working_count -gt 0 ]]; then
        echo -e "${WHITE}🏆 En İyi Performans: ${GREEN}< 1000ms${NC}"
        echo -e "${WHITE}⚡ Orta Performans: ${YELLOW}1000-3000ms${NC}"
        echo -e "${WHITE}🐌 Yavaş Performans: ${RED}> 3000ms${NC}"
    fi
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

# Check prerequisites
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Bu script root olarak çalıştırılmalıdır: sudo $0"
        exit 1
    fi
}

check_system() {
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        warning "Bu script Ubuntu 20.04+ için optimize edilmiştir"
    fi
    
    # Create necessary directories
    mkdir -p "${SCRIPT_DIR}" "${CONFIG_DIR}" "${LOG_DIR}" "${DATA_DIR}" "${TEMP_DIR}"
    
    # Initialize log file
    touch "${LOG_DIR}/menu.log"
    chmod 644 "${LOG_DIR}/menu.log"
}

install_dependencies() {
    log "Gerekli paketler yükleniyor..."
    apt update -qq
    apt install -y wget curl gcc make build-essential procps net-tools zip unzip bc jq python3 python3-yaml ufw iptables-persistent || {
        error "Paket yüklemesi başarısız"
        return 1
    }
    success "Bağımlılıklar başarıyla yüklendi"
}

download_3proxy() {
    log "3proxy kaynak kodu indiriliyor..."
    cd "${TEMP_DIR}"
    
    # Clean any existing directory
    if [ -d "3proxy-0.9.3" ]; then
        rm -rf "3proxy-0.9.3"
    fi
    
    # Download 3proxy source
    wget -q "https://github.com/3proxy/3proxy/archive/0.9.3.tar.gz" || {
        error "3proxy indirilemiyor"
        return 1
    }
    
    # Extract source
    tar -xzf "0.9.3.tar.gz" || {
        error "3proxy arşivi açılmıyor"
        return 1
    }
    
    cd "3proxy-0.9.3" || {
        error "3proxy dizini bulunamadı"
        return 1
    }
    
    # Enable anonymous proxy support
    echo '#define ANONYMOUS 1' >> src/proxy.h
    
    # Compile with error handling
    if make -f Makefile.Linux; then
        success "3proxy başarıyla derlendi"
    else
        error "Derleme başarısız - Makefile.Linux bulunamadı veya compile hatası"
        return 1
    fi
}

install_3proxy() {
    print_header
    echo -e "${WHITE}3PROXY KURULUM BAŞLADI${NC}"
    echo "================================"
    echo
    
    check_system
    
    # Check if proxy list exists, if not create it
    if [[ ! -f "$PROXY_LIST_FILE" ]]; then
        if ! setup_proxy_list; then
            error "Proxy listesi oluşturulamadı, kurulum iptal edildi"
            return 1
        fi
    else
        success "Mevcut proxy listesi kullanılacak: $PROXY_LIST_FILE"
        log "Proxy sayısı: $(wc -l < "$PROXY_LIST_FILE")"
    fi
    
    # Validate and configure netplan
    if ! configure_netplan; then
        warning "Netplan konfigürasyonu tamamlanamadı, manuel kontrol gerekli"
    fi
    
    install_dependencies
    download_3proxy
    
    log "3proxy kuruluyor..."
    
    # Create directories with proper structure
    mkdir -p /usr/local/3proxy/{bin,conf,logs,count}
    mkdir -p "${CONFIG_DIR}" /var/run/3proxy
    
    # Ensure we're in the correct directory
    if [[ ! -d "${TEMP_DIR}/3proxy-0.9.3/bin" ]]; then
        error "3proxy binary dizini bulunamadı: ${TEMP_DIR}/3proxy-0.9.3/bin"
        return 1
    fi
    
    # Copy binaries with verification
    cd "${TEMP_DIR}/3proxy-0.9.3" || {
        error "3proxy kaynak dizinine girilemiyor"
        return 1
    }
    
    if [[ -f "bin/3proxy" ]]; then
        cp bin/* /usr/local/3proxy/bin/ || {
            error "Binary dosyalar kopyalanmadı"
            return 1
        }
        
        # Create symlink to system binary path
        ln -sf /usr/local/3proxy/bin/3proxy /usr/local/bin/3proxy
        success "3proxy binary kuruldu"
    else
        error "3proxy binary bulunamadı - derleme başarısız olabilir"
        return 1
    fi
    
    # Create user
    if ! id proxy >/dev/null 2>&1; then
        useradd -r -s /bin/false proxy || {
            error "Proxy kullanıcısı oluşturulamadı"
            return 1
        }
    fi
    
    # Create systemd service
    create_systemd_service
    
    # Set permissions
    chown -R proxy:proxy /usr/local/3proxy /var/run/3proxy
    
    # Create global menu commands
    current_script_path=$(realpath "$0")
    
    # Ensure script is executable
    chmod +x "$current_script_path"
    
    # Create symlinks with proper permissions
    ln -sf "$current_script_path" /usr/local/bin/menu 2>/dev/null || true
    ln -sf "$current_script_path" /usr/local/bin/3proxy 2>/dev/null || true  
    ln -sf "$current_script_path" /usr/local/bin/proxy-menu 2>/dev/null || true
    ln -sf "$current_script_path" /usr/local/bin/3proxy-manager 2>/dev/null || true
    
    # Make symlinks executable
    chmod +x /usr/local/bin/menu 2>/dev/null || true
    chmod +x /usr/local/bin/3proxy 2>/dev/null || true
    chmod +x /usr/local/bin/proxy-menu 2>/dev/null || true
    chmod +x /usr/local/bin/3proxy-manager 2>/dev/null || true
    
    success "3proxy başarıyla kuruldu"
    echo -e "${CYAN}💡 Global komutlar oluşturuldu:${NC}"
    echo -e "   ${BLUE}menu${NC} - Herhangi bir yerden menüyü aç"
    echo -e "   ${BLUE}3proxy${NC} - Ana komut"
    echo -e "   ${BLUE}proxy-menu${NC} - Alternatif komut"
    echo -e "   ${BLUE}3proxy-manager${NC} - Manager komutu"
    echo
    read -p "Press Enter to continue..."
}

create_systemd_service() {
    cat > /etc/systemd/system/3proxy.service << 'EOF'
[Unit]
Description=3proxy Elite Anonymous Proxy Server
After=network.target

[Service]
Type=forking
User=root
ExecStart=/usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/var/run/3proxy/3proxy.pid
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable 3proxy
}

setup_proxy_list() {
    print_header
    echo -e "${WHITE}PROXY LİSTESİ OLUŞTURMA${NC}"
    echo "================================"
    echo
    
    echo -e "${CYAN}Bu script çalışması için IP adresi listesine ihtiyaç duyar.${NC}"
    echo -e "${YELLOW}Her proxy için bir IPv4 adresi gereklidir.${NC}"
    echo
    echo "Lütfen IP adreslerini aşağıya giriniz:"
    echo "- Her satırda bir IP adresi olmalı"
    echo "- IP'leri subnet ile birlikte girebilirsiniz (önerilen)"
    echo "- Örnek: 192.168.1.100/24 veya 45.90.98.32/23"
    echo "- Subnet belirtmezseniz otomatik tespit edilmeye çalışılır ama hatalı tespit olursa internet kopmları yaşanabilir"
    echo "- Bitirmek için boş satır bırakın ve Enter'a basın"
    echo
    
    # Create temporary file for IPs
    temp_ip_file="${TEMP_DIR}/temp_ips.txt"
    > "$temp_ip_file"
    
    echo -e "${GREEN}IP adreslerini girmeye başlayın:${NC}"
    
    while true; do
        read -p "IP adresi (boş bırakıp Enter = bitir): " ip_input
        
        # If empty, break
        if [[ -z "$ip_input" ]]; then
            break
        fi
        
        # Validate IP format (with or without subnet)
        if [[ "$ip_input" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(/[0-9]{1,2})?$ ]]; then
            # Extract IP and subnet parts
            local ip_part="${ip_input%/*}"
            local subnet_part=""
            
            if [[ "$ip_input" == *"/"* ]]; then
                subnet_part="/${ip_input#*/}"
                # Validate subnet range (8-30 for IPv4)
                local subnet_num="${subnet_part#/}"
                if [ "$subnet_num" -lt 8 ] || [ "$subnet_num" -gt 30 ]; then
                    echo -e "${RED}  ❌ Geçersiz subnet: $subnet_part (8-30 arası olmalı)${NC}"
                    continue
                fi
            fi
            
            # Check each octet of IP
            valid_ip=true
            IFS='.' read -ra ADDR <<< "$ip_part"
            for octet in "${ADDR[@]}"; do
                if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
                    valid_ip=false
                    break
                fi
            done
            
            if [ "$valid_ip" = true ]; then
                # Store IP with subnet if provided, otherwise store just IP
                echo "$ip_input" >> "$temp_ip_file"
                if [[ -n "$subnet_part" ]]; then
                    echo -e "${GREEN}  ✅ $ip_part$subnet_part eklendi${NC}"
                else
                    echo -e "${GREEN}  ✅ $ip_part eklendi (subnet otomatik tespit edilecek)${NC}"
                fi
            else
                echo -e "${RED}  ❌ Geçersiz IP adresi: $ip_part${NC}"
            fi
        else
            echo -e "${RED}  ❌ Geçersiz format: $ip_input${NC}"
            echo "  Örnekler: 192.168.1.100, 192.168.1.100/24, 45.90.98.32/23"
        fi
    done
    
    # Check if any IPs were entered
    if [[ ! -s "$temp_ip_file" ]]; then
        error "Hiç geçerli IP adresi girilmedi"
        return 1
    fi
    
    # Show entered IPs
    ip_count=$(wc -l < "$temp_ip_file")
    echo
    echo -e "${WHITE}Girilen IP Adresleri ($ip_count adet):${NC}"
    echo "================================"
    nl "$temp_ip_file"
    echo
    
    read -p "Bu IP listesini onaylıyor musunuz? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy] ]]; then
        info "IP listesi oluşturma iptal edildi"
        return 1
    fi
    
    # Save to permanent file
    cp "$temp_ip_file" "$PROXY_LIST_FILE"
    chmod 644 "$PROXY_LIST_FILE"
    
    success "Proxy listesi oluşturuldu: $PROXY_LIST_FILE"
    success "Toplam IP sayısı: $ip_count"
    
    return 0
}

configure_netplan() {
    log "Netplan konfigürasyonu kontrol ediliyor..."
    
    if [[ ! -d "/etc/netplan" ]]; then
        warning "Netplan dizini bulunamadı, IP kontrolleri atlanıyor"
        return 1
    fi
    
    if [[ ! -f "$PROXY_LIST_FILE" ]]; then
        warning "Proxy listesi bulunamadı, netplan kontrolleri atlanıyor"
        return 1
    fi
    
    # Find netplan YAML files
    yaml_files=($(find /etc/netplan -name "*.yaml" -o -name "*.yml" 2>/dev/null))
    
    if [ ${#yaml_files[@]} -eq 0 ]; then
        warning "Netplan YAML dosyası bulunamadı"
        return 1
    fi
    
    log "Bulunan netplan dosyaları: ${#yaml_files[@]} adet"
    
    # Read proxy IPs
    mapfile -t proxy_ips < "$PROXY_LIST_FILE"
    missing_ips=()
    
    # Check each proxy IP in netplan files
    for ip_entry in "${proxy_ips[@]}"; do
        ip_entry=$(echo "$ip_entry" | tr -d '\r\n ')
        
        # Extract IP part (remove subnet if present)
        local ip_only="${ip_entry%/*}"
        local provided_subnet=""
        
        if [[ "$ip_entry" == *"/"* ]]; then
            provided_subnet="/${ip_entry#*/}"
        fi
        
        found=false
        
        for yaml_file in "${yaml_files[@]}"; do
            if grep -q "$ip_only" "$yaml_file" 2>/dev/null; then
                found=true
                break
            fi
        done
        
        if [ "$found" = false ]; then
            # Store both IP and its subnet info
            if [[ -n "$provided_subnet" ]]; then
                missing_ips+=("$ip_entry")  # Keep IP with subnet
            else
                missing_ips+=("$ip_only")   # Just IP, subnet will be detected
            fi
        fi
    done
    
    if [ ${#missing_ips[@]} -eq 0 ]; then
        success "Tüm proxy IP'leri netplan'da mevcut"
        return 0
    fi
    
    warning "Netplan'da eksik IP'ler bulundu: ${#missing_ips[@]} adet"
    
    echo
    echo -e "${YELLOW}Eksik IP Adresleri:${NC}"
    for ip in "${missing_ips[@]}"; do
        local display_ip="$ip"
        if [[ "$ip" != *"/"* ]]; then
            local detected_subnet=$(detect_subnet_for_ip "$ip")
            display_ip="$ip$detected_subnet"
        fi
        echo -e "${RED}  ❌ $display_ip${NC}"
    done
    echo
    
    read -p "Bu IP'leri otomatik eklemek istiyor musunuz? [y/N]: " auto_add
    if [[ ! "$auto_add" =~ ^[Yy] ]]; then
        echo -e "${CYAN}Manuel ekleme rehberi gösteriliyor...${NC}"
        show_manual_netplan_guide "${missing_ips[@]}"
        return 1
    fi
    
    # Simple automatic addition
    primary_yaml="${yaml_files[0]}"
    backup_file="${primary_yaml}.backup.$(date +%s)"
    
    log "Yedek oluşturuluyor: $backup_file"
    cp "$primary_yaml" "$backup_file"
    
    # Clean up wrongly placed IPs first (lines starting with 6 spaces + -)  
    log "Yanlış yere eklenmiş IP'ler temizleniyor..."
    sed -i '/^      - [0-9]/d' "$primary_yaml"
    log "  ✅ Dosya sonundaki IP'ler temizlendi"
    
    # Add IPs to addresses section correctly
    for ip in "${missing_ips[@]}"; do
        local final_ip="$ip"
        if [[ "$ip" != *"/"* ]]; then
            detected_subnet=$(detect_subnet_for_ip "$ip")
            final_ip="$ip$detected_subnet"
        fi
        
        # Find addresses: line and add IP with correct indentation
        if grep -q "addresses:" "$primary_yaml"; then
            # Get the line number of addresses:
            local addr_line=$(grep -n "addresses:" "$primary_yaml" | head -1 | cut -d: -f1)
            local next_line=$((addr_line + 1))
            
            # Check if there are existing IPs to match indentation
            local existing_indent=""
            if sed -n "${next_line}p" "$primary_yaml" | grep -q "^[[:space:]]*-"; then
                # Get indentation from existing IP
                existing_indent=$(sed -n "${next_line}p" "$primary_yaml" | sed 's/-.*//')
            else
                # Default indentation (12 spaces for addresses list)
                existing_indent="            "
            fi
            
            # Add IP with correct indentation using sed
            sed -i "${addr_line}a\\${existing_indent}- ${final_ip}" "$primary_yaml"
            log "  ✅ $final_ip eklendi (addresses listesine)"
        else
            error "  ❌ addresses: bölümü bulunamadı: $final_ip"
        fi
    done
    
    
    
    # Quick validation and apply
    log "Netplan test ediliyor..."
    if timeout 10 netplan apply 2>/dev/null; then
        success "IP'ler başarıyla eklendi"
        return 0
    else
        error "Netplan hatası - yedekten geri yükleniyor"
        cp "$backup_file" "$primary_yaml"
        netplan apply 2>/dev/null
        return 1
    fi
}

# Calculate optimal port range based on available IPs
calculate_port_range() {
    local total_ips="$1"
    local proxies_per_ip="${2:-3}"  # Default 3 proxies per IP
    local start_port="${3:-10000}"  # Default start port
    
    if [[ -z "$total_ips" || "$total_ips" -eq 0 ]]; then
        echo "0:0"
        return 1
    fi
    
    local max_proxies=$((total_ips * proxies_per_ip))
    local end_port=$((start_port + max_proxies - 1))
    
    # Ensure we don't exceed 65535 port limit
    if [ "$end_port" -gt 65535 ]; then
        end_port=65535
        max_proxies=$((end_port - start_port + 1))
        warning "Port limiti aşıldı, maksimum $max_proxies proxy oluşturulabilir"
    fi
    
    echo "$start_port:$end_port"
    return 0
}

# Auto-calculate port settings for proxy modes
get_proxy_port_info() {
    local total_ips="$1"
    
    echo -e "${CYAN}🔌 Port Dağılımı:${NC}"
    echo -e "${WHITE}• Ana sunucu IP: 3128 portu (sabit)${NC}"
    
    if [[ "$total_ips" -gt 1 ]]; then
        local other_ips=$((total_ips - 1))
        echo -e "${WHITE}• Diğer $other_ips IP: Sıralı portlar${NC}"
        echo -e "${WHITE}• Her IP için 3 ardışık port${NC}"
        echo -e "${WHITE}• Örnek: IP1(10000,10001,10002), IP2(10003,10004,10005)...${NC}"
    fi
    echo
}

show_manual_netplan_guide() {
    local missing_ips=("$@")
    
    print_header
    echo -e "${CYAN}📋 MANUEL NETPLAN GÜNCELLEMESİ KILAVUZU${NC}"
    echo "==========================================="
    echo
    
    # Find primary netplan file
    local yaml_files=($(find /etc/netplan -name "*.yaml" -o -name "*.yml" 2>/dev/null))
    local primary_yaml="${yaml_files[0]}"
    
    if [[ -n "$primary_yaml" ]]; then
        echo -e "${WHITE}📁 Düzenlenecek Dosya:${NC} $primary_yaml"
        echo
        echo -e "${YELLOW}🔧 Adımlar:${NC}"
        echo -e "${WHITE}1.${NC} Dosyayı düzenle: ${BLUE}sudo nano $primary_yaml${NC}"
        echo -e "${WHITE}2.${NC} 'addresses:' bölümünü bul"
        echo -e "${WHITE}3.${NC} Aşağıdaki IP'leri listeye ekle:"
        echo
        
        echo -e "${GREEN}📝 Eklenecek IP Adresleri:${NC}"
        echo -e "${BLUE}    addresses:${NC}"
        
        # Show existing addresses first
        if grep -A 20 "addresses:" "$primary_yaml" 2>/dev/null | grep -E "^[[:space:]]*-" | head -3; then
            echo -e "${GRAY}    # (mevcut adresler yukarıda)${NC}"
        fi
        
        # Show new addresses to add
        for ip_entry in "${missing_ips[@]}"; do
            local final_ip="$ip_entry"
            if [[ "$ip_entry" != *"/"* ]]; then
                detected_subnet=$(detect_subnet_for_ip "$ip_entry")
                final_ip="$ip_entry$detected_subnet"
            fi
            echo -e "${YELLOW}      - $final_ip${NC}"
        done
        
        echo
        echo -e "${WHITE}4.${NC} Dosyayı kaydet: ${BLUE}Ctrl+X, Y, Enter${NC}"
        echo -e "${WHITE}5.${NC} Netplan'ı uygula: ${BLUE}sudo netplan apply${NC}"
        echo
        
        echo -e "${RED}⚠️  DİKKAT:${NC}"
        echo -e "${WHITE}• Girinti (indentation) çok önemli!${NC}"
        echo -e "${WHITE}• Mevcut IP'lerle aynı hizada olmalı${NC}"
        echo -e "${WHITE}• YAML syntax'ını bozmayın${NC}"
        
    else
        error "Netplan dosyası bulunamadı!"
    fi
    
    echo
    read -p "Devam etmek için Enter'a basın..."
}

delete_proxy_list() {
    print_header
    echo -e "${WHITE}PROXY LİSTESİNİ SİL${NC}"
    echo "================================"
    echo
    
    if [[ ! -f "$PROXY_LIST_FILE" ]]; then
        info "Proxy listesi zaten mevcut değil"
        read -p "Press Enter to continue..."
        return 0
    fi
    
    # Show current list
    ip_count=$(wc -l < "$PROXY_LIST_FILE")
    echo -e "${WHITE}Mevcut Proxy Listesi ($ip_count IP):${NC}"
    echo "================================"
    nl "$PROXY_LIST_FILE" | head -20
    
    if [ "$ip_count" -gt 20 ]; then
        echo -e "${CYAN}... ve $(($ip_count - 20)) IP daha${NC}"
    fi
    
    echo
    echo -e "${RED}⚠️  UYARI: Bu işlem proxy listesini tamamen silecektir!${NC}"
    echo -e "${YELLOW}Proxy'ler çalışmaya devam edecek ancak yeni proxy oluşturulamayacak.${NC}"
    echo
    
    read -p "Proxy listesini silmek istediğinizden emin misiniz? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy] ]]; then
        info "İşlem iptal edildi"
        read -p "Press Enter to continue..."
        return 0
    fi
    
    # Create backup before deletion
    backup_file="${DATA_DIR}/proxylistesi_backup_$(date +%s).txt"
    cp "$PROXY_LIST_FILE" "$backup_file"
    
    # Delete the list
    rm -f "$PROXY_LIST_FILE"
    
    success "Proxy listesi silindi"
    success "Yedek dosyası: $backup_file"
    
    read -p "Press Enter to continue..."
}

detect_subnet_for_ip() {
    local target_ip="$1"
    local subnet="/24"  # default
    
    # Check existing netplan files for subnet information
    if [[ -d "/etc/netplan" ]]; then
        for yaml_file in /etc/netplan/*.yaml /etc/netplan/*.yml; do
            [[ -f "$yaml_file" ]] || continue
            
            # Look for IP with subnet in the file
            while IFS= read -r line; do
                if [[ "$line" =~ -[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/([0-9]+) ]]; then
                    local found_ip="${BASH_REMATCH[1]}"
                    local found_subnet="/${BASH_REMATCH[2]}"
                    
                    # If we find the exact IP, use its subnet
                    if [[ "$found_ip" == "$target_ip" ]]; then
                        subnet="$found_subnet"
                        break 2
                    fi
                    
                    # If IPs are in same network, use the same subnet
                    if network_contains_ip "$found_ip$found_subnet" "$target_ip"; then
                        subnet="$found_subnet"
                        break 2
                    fi
                fi
            done < "$yaml_file"
        done
    fi
    
    # Also check current network interfaces
    if [[ "$subnet" == "/24" ]]; then
        local iface_subnet=$(ip route | grep "$target_ip" | head -1 | grep -o '/[0-9]*' || echo "")
        if [[ -n "$iface_subnet" ]]; then
            subnet="$iface_subnet"
        fi
    fi
    
    echo "$subnet"
}

network_contains_ip() {
    local network="$1"  # e.g., "192.168.1.1/24"
    local test_ip="$2"  # e.g., "192.168.1.100"
    
    # Extract network IP and CIDR
    local net_ip="${network%/*}"
    local cidr="${network#*/}"
    
    # Simple check for common subnets
    case "$cidr" in
        "24")
            [[ "${test_ip%.*}" == "${net_ip%.*}" ]] && return 0
            ;;
        "23")
            local net_third="${net_ip%.*}"; net_third="${net_third##*.}"
            local test_third="${test_ip%.*}"; test_third="${test_third##*.}"
            local net_base="${net_ip%.*.*}"
            local test_base="${test_ip%.*.*}"
            
            if [[ "$net_base" == "$test_base" ]]; then
                # For /23, check if IPs are in the same pair (e.g., 32-33, 34-35)
                local net_pair=$((net_third / 2))
                local test_pair=$((test_third / 2))
                [[ "$net_pair" == "$test_pair" ]] && return 0
            fi
            ;;
        "22")
            local net_third="${net_ip%.*}"; net_third="${net_third##*.}"
            local test_third="${test_ip%.*}"; test_third="${test_third##*.}"
            local net_base="${net_ip%.*.*}"
            local test_base="${test_ip%.*.*}"
            
            if [[ "$net_base" == "$test_base" ]]; then
                # For /22, check if IPs are in the same group of 4
                local net_group=$((net_third / 4))
                local test_group=$((test_third / 4))
                [[ "$net_group" == "$test_group" ]] && return 0
            fi
            ;;
    esac
    
    return 1
}

open_firewall_ports() {
    local start_port="$1"
    local end_port="$2"
    local protocol="$3"  # "tcp" or "udp"
    
    log "Firewall portları açılıyor: $start_port-$end_port/$protocol"
    
    # Check if UFW is active
    local ufw_status=$(ufw status 2>/dev/null | head -1 || echo "inactive")
    
    if [[ "$ufw_status" =~ "Status: active" ]]; then
        log "UFW aktif - portlar UFW ile açılıyor..."
        
        # Open port range with UFW
        if [ "$start_port" -eq "$end_port" ]; then
            ufw allow "$start_port/$protocol" >/dev/null 2>&1
            log "  ✅ Port $start_port/$protocol açıldı"
        else
            ufw allow "$start_port:$end_port/$protocol" >/dev/null 2>&1
            log "  ✅ Port aralığı $start_port:$end_port/$protocol açıldı"
        fi
    else
        log "UFW aktif değil - iptables ile portlar açılıyor..."
        
        # Open ports with iptables
        local port="$start_port"
        while [ "$port" -le "$end_port" ]; do
            iptables -A INPUT -p "$protocol" --dport "$port" -j ACCEPT >/dev/null 2>&1
            port=$((port + 1))
        done
        
        # Save iptables rules
        if command -v iptables-save >/dev/null; then
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
        fi
        
        log "  ✅ Port aralığı $start_port-$end_port/$protocol iptables ile açıldı"
    fi
    
    success "Firewall portları başarıyla açıldı"
}

extract_clean_ips() {
    local proxy_list_file="$1"
    
    # Read IPs
    mapfile -t ips < "$proxy_list_file"
    local total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        echo "0"
        return 1
    fi
    
    # Clean and extract IP addresses (remove subnets for proxy config)
    # Make it global for other functions to use
    clean_ips=()
    for ip_entry in "${ips[@]}"; do
        ip_entry=$(echo "$ip_entry" | tr -d '\r\n ')
        # Extract just the IP part (before /)
        clean_ip="${ip_entry%/*}"
        clean_ips+=("$clean_ip")
    done
    
    echo "${#clean_ips[@]}"
    return 0
}

generate_config_header() {
    local config_file="$1"
    cat > "$config_file" << EOF
#!/usr/local/bin/3proxy
# 3proxy Elite Anonymous Configuration
# Generated: $(date)
# Mode: $PROXY_MODE

daemon
pidfile /var/run/3proxy/3proxy.pid
chroot /usr/local/3proxy proxy proxy
log /logs/3proxy-%y%m%d.log D
rotate 30
maxconn 1000
nscache 65536
nserver 8.8.8.8
nserver 8.8.4.4
timeouts 1 5 30 60 180 1800 15 60

EOF
}

create_proxy_random() {
    print_header
    echo -e "${WHITE}RASTGElE MOD PROXY OLUŞTURMA${NC}"
    echo "================================"
    echo
    
    # Check if proxy list exists
    if [[ ! -f "$PROXY_LIST_FILE" ]]; then
        warning "Proxy listesi bulunamadı!"
        read -p "Şimdi proxy listesi oluşturmak istiyor musunuz? [y/N]: " create_list
        if [[ "$create_list" =~ ^[Yy] ]]; then
            if ! setup_proxy_list; then
                error "Proxy listesi oluşturulamadı"
                return 1
            fi
        else
            error "Proxy oluşturmak için IP listesi gereklidir"
            return 1
        fi
    fi
    
    # Show current proxy list info
    ip_count=$(wc -l < "$PROXY_LIST_FILE")
    echo -e "${CYAN}Mevcut IP Listesi: $ip_count adet IP${NC}"
    echo "Dosya: $PROXY_LIST_FILE"
    echo
    
    # Auto-calculate recommended port range
    port_range=$(calculate_port_range "$ip_count" 3 10000)
    recommended_start=$(echo "$port_range" | cut -d':' -f1)
    recommended_end=$(echo "$port_range" | cut -d':' -f2)
    
    echo -e "${GREEN}📊 Önerilen Port Aralığı:${NC}"
    echo -e "${WHITE}• Ana IP (3128 portu sabit)${NC}"
    echo -e "${WHITE}• Diğer IP'ler: $recommended_start-$recommended_end${NC}"
    echo -e "${WHITE}• Maksimum: $((recommended_end - recommended_start + 1)) proxy${NC}"
    echo
    
    read -p "Başlangıç portu [$recommended_start]: " start_port
    read -p "Bitiş portu [$recommended_end]: " end_port
    read -p "HTTP (h) veya SOCKS5 (s) [h/s]: " proxy_type
    
    # Use recommended values if empty
    [[ -z "$start_port" ]] && start_port=$recommended_start
    [[ -z "$end_port" ]] && end_port=$recommended_end
    
    if [[ ! "$start_port" =~ ^[0-9]+$ ]] || [[ ! "$end_port" =~ ^[0-9]+$ ]]; then
        error "Geçersiz port numarası"
        return 1
    fi
    
    if [ "$start_port" -ge "$end_port" ]; then
        error "Başlangıç portu bitiş portundan küçük olmalı"
        return 1
    fi
    
    # Read IPs and clean subnet information for proxy usage (Random mode)
    mapfile -t ips < "$PROXY_LIST_FILE"
    total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        error "IP listesi boş"
        return 1
    fi
    
    # Clean IPs - remove subnet information for proxy configuration
    declare -a clean_ips
    for i in "${!ips[@]}"; do
        # Remove subnet part (/24, /23, etc.) - keep only IP address
        clean_ip=$(echo "${ips[$i]}" | cut -d'/' -f1 | tr -d '\r\n ')
        clean_ips[$i]="$clean_ip"
    done
    
    log "Toplam IP sayısı: $total_ips"
    log "Port aralığı: $start_port-$end_port"
    log "IP'ler subnet bilgisi temizlenerek proxy konfigürasyonunda kullanılacak"
    
    # Generate config
    config_file="${CONFIG_DIR}/3proxy.cfg"
    PROXY_MODE="Random"
    generate_config_header "$config_file"
    
    # Create users file
    users_file="/usr/local/3proxy/conf/passwd"
    > "$users_file"
    
    # Create proxy list file
    proxy_list_file="${DATA_DIR}/proxy_list_random_$(date +%s).txt"
    > "$proxy_list_file"
    
    echo "users \$/conf/passwd" >> "$config_file"
    echo "auth strong" >> "$config_file"
    echo "" >> "$config_file"
    
    # Create proxies with automatic port assignment per IP
    # Each IP starts from port 3128 and increments +1 for each additional proxy on that IP
    local ip_port_map=()
    
    # Initialize starting ports for each IP (3128)
    for (( i=0; i<total_ips; i++ )); do
        ip_port_map[i]=3128
    done
    
    port="$start_port"
    ip_index=0
    
    while [ "$port" -le "$end_port" ]; do
        # Generate random credentials
        username="user$(shuf -i 1000-9999 -n 1)"
        password="$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-12)"
        
        # Get IP (round-robin)
        current_ip="${clean_ips[$ip_index]}"
        current_ip=$(echo "$current_ip" | tr -d '\r\n ')
        
        # Get the current port for this IP and increment it for next use
        current_port=${ip_port_map[$ip_index]}
        ip_port_map[$ip_index]=$((current_port + 1))
        
        # Add user
        echo "${username}:CL:${password}" >> "$users_file"
        
        # Add proxy config
        if [[ "$proxy_type" == "s" ]]; then
            echo "auth strong" >> "$config_file"
            echo "allow $username" >> "$config_file"
            echo "socks -i$current_ip -p$current_port" >> "$config_file"
            echo "flush" >> "$config_file"
            echo "" >> "$config_file"
            # Format: USER:PASS@IP:PORT
            echo "$username:$password@$current_ip:$current_port" >> "$proxy_list_file"
        else
            echo "auth strong" >> "$config_file"
            echo "allow $username" >> "$config_file"
            echo "proxy -a1 -n -i$current_ip -p$current_port" >> "$config_file"
            echo "flush" >> "$config_file"
            echo "" >> "$config_file"
            # Format: USER:PASS@IP:PORT
            echo "$username:$password@$current_ip:$current_port" >> "$proxy_list_file"
        fi
        
        port=$((port + 1))
        ip_index=$(((ip_index + 1) % total_ips))
    done
    
    # Set permissions
    chmod 600 "$users_file"
    chown proxy:proxy "$users_file"
    
    # Open firewall ports with dynamic port calculation for random proxy
    # Calculate real port range based on 3128 start + proxy count per IP
    local total_proxy_count=$((end_port - start_port + 1))
    local ports_per_ip=$((total_proxy_count / total_ips))
    if [[ $((total_proxy_count % total_ips)) -gt 0 ]]; then
        ports_per_ip=$((ports_per_ip + 1))
    fi
    local actual_end_port=$((3128 + ports_per_ip - 1))
    
    # Open firewall for the actual port range used (3128 to calculated end)
    open_firewall_ports "3128" "$actual_end_port" "tcp"
    
    # Create zip file
    create_proxy_zip "$proxy_list_file" "random"
    
    success "Rastgele mod proxy'ler oluşturuldu"
    success "Toplam proxy sayısı: $((end_port - start_port + 1))"
    success "Proxy listesi: $proxy_list_file"
    
    read -p "Proxy'leri başlatmak istiyor musunuz? [y/n]: " start_now
    if [[ "$start_now" =~ ^[Yy] ]]; then
        systemctl restart 3proxy
        if systemctl is-active --quiet 3proxy; then
            success "Proxy'ler başarıyla başlatıldı"
            
            # Ask for proxy validation
            echo
            read -p "Proxy'leri test etmek istiyor musunuz? [y/n]: " test_now
            if [[ "$test_now" =~ ^[Yy] ]]; then
                echo -e "${YELLOW}🔍 Proxy doğrulaması başlatılıyor...${NC}"
                sleep 2
                validate_proxy_list "$proxy_list_file"
            fi
        else
            error "Proxy başlatma başarısız"
        fi
    fi
    
    read -p "Press Enter to continue..."
}

create_proxy_fixed() {
    print_header
    echo -e "${WHITE}SABİT MOD PROXY OLUŞTURMA${NC}"
    echo "================================"
    echo
    
    # Check if proxy list exists
    if [[ ! -f "$PROXY_LIST_FILE" ]]; then
        warning "Proxy listesi bulunamadı!"
        read -p "Şimdi proxy listesi oluşturmak istiyor musunuz? [y/N]: " create_list
        if [[ "$create_list" =~ ^[Yy] ]]; then
            if ! setup_proxy_list; then
                error "Proxy listesi oluşturulamadı"
                return 1
            fi
        else
            error "Proxy oluşturmak için IP listesi gereklidir"
            return 1
        fi
    fi
    
    # Show current proxy list info
    ip_count=$(wc -l < "$PROXY_LIST_FILE")
    echo -e "${CYAN}Mevcut IP Listesi: $ip_count adet IP${NC}"
    echo "Dosya: $PROXY_LIST_FILE"
    echo
    
    # Auto-calculate recommended port range
    port_range=$(calculate_port_range "$ip_count" 3 10000)
    recommended_start=$(echo "$port_range" | cut -d':' -f1)
    recommended_end=$(echo "$port_range" | cut -d':' -f2)
    
    echo -e "${GREEN}📊 Önerilen Port Aralığı:${NC}"
    echo -e "${WHITE}• Ana IP (3128 portu sabit)${NC}"
    echo -e "${WHITE}• Diğer IP'ler: $recommended_start-$recommended_end${NC}"
    echo -e "${WHITE}• Maksimum: $((recommended_end - recommended_start + 1)) proxy${NC}"
    echo
    
    read -p "Başlangıç portu [$recommended_start]: " start_port
    read -p "Bitiş portu [$recommended_end]: " end_port
    read -p "Kullanıcı adı: " fixed_user
    read -p "Şifre: " fixed_pass
    
    # Use recommended values if empty
    [[ -z "$start_port" ]] && start_port=$recommended_start
    [[ -z "$end_port" ]] && end_port=$recommended_end
    read -p "HTTP (h) veya SOCKS5 (s) [h/s]: " proxy_type
    
    if [[ ! "$start_port" =~ ^[0-9]+$ ]] || [[ ! "$end_port" =~ ^[0-9]+$ ]]; then
        error "Geçersiz port numarası"
        return 1
    fi
    
    if [ "$start_port" -ge "$end_port" ]; then
        error "Başlangıç portu bitiş portundan küçük olmalı"
        return 1
    fi
    
    if [[ -z "$fixed_user" ]] || [[ -z "$fixed_pass" ]]; then
        error "Kullanıcı adı ve şifre boş olamaz"
        return 1
    fi
    
    # Read IPs and clean subnet information for proxy usage (Fixed mode)
    mapfile -t ips < "$PROXY_LIST_FILE"
    total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        error "IP listesi boş"
        return 1
    fi
    
    # Clean IPs - remove subnet information for proxy configuration
    declare -a clean_ips
    for i in "${!ips[@]}"; do
        # Remove subnet part (/24, /23, etc.) - keep only IP address
        clean_ip=$(echo "${ips[$i]}" | cut -d'/' -f1 | tr -d '\r\n ')
        clean_ips[$i]="$clean_ip"
    done
    
    log "Toplam IP sayısı: $total_ips"
    log "FIXED MOD: Her IP için 1 proxy oluşturulacak (Sequential port assignment)"
    log "IP'ler subnet bilgisi temizlenerek proxy konfigürasyonunda kullanılacak"
    
    # FIXED MODE: 1 IP = 1 Proxy, Sequential ports starting from 3128
    # Ignore user port range, use IP count for sequential assignment
    local fixed_start_port=3128
    local total_proxies_fixed=$total_ips  # Only as many proxies as IPs
    
    log "Fixed mode port ataması: $fixed_start_port'den başlayarak $total_proxies_fixed proxy"
    
    # Generate config
    config_file="${CONFIG_DIR}/3proxy.cfg"
    PROXY_MODE="Fixed"
    generate_config_header "$config_file"
    
    # Create users file
    users_file="/usr/local/3proxy/conf/passwd"
    echo "${fixed_user}:CL:${fixed_pass}" > "$users_file"
    
    # Create proxy list file
    proxy_list_file="${DATA_DIR}/proxy_list_fixed_$(date +%s).txt"
    > "$proxy_list_file"
    
    echo "users \$/conf/passwd" >> "$config_file"
    echo "auth strong" >> "$config_file"
    echo "" >> "$config_file"
    
    # Fixed mode: Each IP gets exactly one proxy with sequential port (3128, 3129, 3130, ...)
    for (( i=0; i<total_ips; i++ )); do
        # Get cleaned IP (without subnet)
        current_ip="${clean_ips[$i]}"
        current_ip=$(echo "$current_ip" | tr -d '\r\n ')
        
        # Assign sequential port starting from 3128
        assigned_port=$((fixed_start_port + i))
        
        # Add proxy config
        if [[ "$proxy_type" == "s" ]]; then
            echo "auth strong" >> "$config_file"
            echo "allow $fixed_user" >> "$config_file"
            echo "socks -i$current_ip -p$assigned_port" >> "$config_file"
            echo "flush" >> "$config_file"
            echo "" >> "$config_file"
            # Format: USER:PASS@IP:PORT (clean format without subnet)
            echo "$fixed_user:$fixed_pass@$current_ip:$assigned_port" >> "$proxy_list_file"
        else
            echo "auth strong" >> "$config_file"
            echo "allow $fixed_user" >> "$config_file"
            echo "proxy -a1 -n -i$current_ip -p$assigned_port" >> "$config_file"
            echo "flush" >> "$config_file"
            echo "" >> "$config_file"
            # Format: USER:PASS@IP:PORT (clean format without subnet)
            echo "$fixed_user:$fixed_pass@$current_ip:$assigned_port" >> "$proxy_list_file"
        fi
        
        log "IP $((i+1))/$total_ips: $current_ip → Port $assigned_port"
    done
    
    # Set permissions
    chmod 600 "$users_file"
    chown proxy:proxy "$users_file"
    
    # Open firewall ports for Fixed mode (sequential port assignment: 3128 to 3128+IP_count-1)
    local actual_end_port=$((fixed_start_port + total_ips - 1))
    
    # Open firewall for the actual port range used
    open_firewall_ports "$fixed_start_port" "$actual_end_port" "tcp"
    
    # Create zip file
    create_proxy_zip "$proxy_list_file" "fixed"
    
    success "FIXED MODE: 1 IP = 1 Proxy (Sequential Port Assignment)"
    success "Toplam proxy sayısı: $total_ips"
    success "Port aralığı: $fixed_start_port-$actual_end_port"
    success "Mapping: IP1→3128, IP2→3129, IP3→3130, ..."
    success "Proxy listesi: $proxy_list_file"
    
    read -p "Proxy'leri başlatmak istiyor musunuz? [y/n]: " start_now
    if [[ "$start_now" =~ ^[Yy] ]]; then
        systemctl restart 3proxy
        if systemctl is-active --quiet 3proxy; then
            success "Proxy'ler başarıyla başlatıldı"
            
            # Ask for proxy validation
            echo
            read -p "Proxy'leri test etmek istiyor musunuz? [y/n]: " test_now
            if [[ "$test_now" =~ ^[Yy] ]]; then
                echo -e "${YELLOW}🔍 Proxy doğrulaması başlatılıyor...${NC}"
                sleep 2
                validate_proxy_list "$proxy_list_file"
            fi
        else
            error "Proxy başlatma başarısız"
        fi
    fi
    
    read -p "Press Enter to continue..."
}

create_proxy_public() {
    print_header
    echo -e "${WHITE}PUBLIC MOD PROXY OLUŞTURMA${NC}"
    echo "================================"
    echo
    
    # Check if proxy list exists
    if [[ ! -f "$PROXY_LIST_FILE" ]]; then
        warning "Proxy listesi bulunamadı!"
        read -p "Şimdi proxy listesi oluşturmak istiyor musunuz? [y/N]: " create_list
        if [[ "$create_list" =~ ^[Yy] ]]; then
            if ! setup_proxy_list; then
                error "Proxy listesi oluşturulamadı"
                return 1
            fi
        else
            error "Proxy oluşturmak için IP listesi gereklidir"
            return 1
        fi
    fi
    
    # Show current proxy list info
    ip_count=$(wc -l < "$PROXY_LIST_FILE")
    echo -e "${CYAN}Mevcut IP Listesi: $ip_count adet IP${NC}"
    echo "Dosya: $PROXY_LIST_FILE"
    echo
    
    # Auto-calculate recommended port range
    port_range=$(calculate_port_range "$ip_count" 3 10000)
    recommended_start=$(echo "$port_range" | cut -d':' -f1)
    recommended_end=$(echo "$port_range" | cut -d':' -f2)
    
    echo -e "${GREEN}📊 Önerilen Port Aralığı:${NC}"
    echo -e "${WHITE}• Ana IP (3128 portu sabit)${NC}"
    echo -e "${WHITE}• Diğer IP'ler: $recommended_start-$recommended_end${NC}"
    echo -e "${WHITE}• Maksimum: $((recommended_end - recommended_start + 1)) proxy${NC}"
    echo
    
    read -p "Başlangıç portu [$recommended_start]: " start_port
    read -p "Bitiş portu [$recommended_end]: " end_port
    read -p "HTTP (h) veya SOCKS5 (s) [h/s]: " proxy_type
    
    # Use recommended values if empty
    [[ -z "$start_port" ]] && start_port=$recommended_start
    [[ -z "$end_port" ]] && end_port=$recommended_end
    
    if [[ ! "$start_port" =~ ^[0-9]+$ ]] || [[ ! "$end_port" =~ ^[0-9]+$ ]]; then
        error "Geçersiz port numarası"
        return 1
    fi
    
    if [ "$start_port" -ge "$end_port" ]; then
        error "Başlangıç portu bitiş portundan küçük olmalı"
        return 1
    fi
    
    # Read IPs and clean subnet information for proxy usage (Public mode)
    mapfile -t ips < "$PROXY_LIST_FILE"
    total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        error "IP listesi boş"
        return 1
    fi
    
    # Clean IPs - remove subnet information for proxy configuration
    declare -a clean_ips
    for i in "${!ips[@]}"; do
        # Remove subnet part (/24, /23, etc.) - keep only IP address
        clean_ip=$(echo "${ips[$i]}" | cut -d'/' -f1 | tr -d '\r\n ')
        clean_ips[$i]="$clean_ip"
    done
    
    log "Toplam IP sayısı: $total_ips"
    log "Port aralığı: $start_port-$end_port"
    log "IP'ler subnet bilgisi temizlenerek proxy konfigürasyonunda kullanılacak"
    log "Port aralığı: $start_port-$end_port"
    
    # Generate config
    config_file="${CONFIG_DIR}/3proxy.cfg"
    PROXY_MODE="Public"
    generate_config_header "$config_file"
    
    # Create proxy list file
    proxy_list_file="${DATA_DIR}/proxy_list_public_$(date +%s).txt"
    > "$proxy_list_file"
    
    echo "# No authentication required" >> "$config_file"
    echo "allow *" >> "$config_file"
    echo "" >> "$config_file"
    
    # Create proxies with automatic port assignment per IP
    # Each IP starts from port 3128 and increments +1 for each additional proxy on that IP
    local ip_port_map=()
    
    # Initialize starting ports for each IP (3128)
    for (( i=0; i<total_ips; i++ )); do
        ip_port_map[i]=3128
    done
    
    port="$start_port"
    ip_index=0
    
    while [ "$port" -le "$end_port" ]; do
        # Get IP (round-robin) - use cleaned IP without subnet for Public mode
        current_ip="${clean_ips[$ip_index]}"
        current_ip=$(echo "$current_ip" | tr -d '\r\n ')
        
        # Get the current port for this IP and increment it for next use
        current_port=${ip_port_map[$ip_index]}
        ip_port_map[$ip_index]=$((current_port + 1))
        
        # Add proxy config
        if [[ "$proxy_type" == "s" ]]; then
            echo "socks -i$current_ip -p$current_port" >> "$config_file"
            # Public proxy format (no authentication): IP:PORT
            echo "$current_ip:$current_port" >> "$proxy_list_file"
        else
            echo "proxy -a1 -n -i$current_ip -p$current_port" >> "$config_file"
            # Public proxy format (no authentication): IP:PORT
            echo "$current_ip:$current_port" >> "$proxy_list_file"
        fi
        
        port=$((port + 1))
        ip_index=$(((ip_index + 1) % total_ips))
    done
    
    # Open firewall ports with dynamic port calculation for public proxy
    # Calculate real port range based on 3128 start + proxy count per IP
    local total_proxy_count=$((end_port - start_port + 1))
    local ports_per_ip=$((total_proxy_count / total_ips))
    if [[ $((total_proxy_count % total_ips)) -gt 0 ]]; then
        ports_per_ip=$((ports_per_ip + 1))
    fi
    local actual_end_port=$((3128 + ports_per_ip - 1))
    
    # Open firewall for the actual port range used (3128 to calculated end)
    open_firewall_ports "3128" "$actual_end_port" "tcp"
    
    # Create zip file
    create_proxy_zip "$proxy_list_file" "public"
    
    success "Public mod proxy'ler oluşturuldu"
    success "Toplam proxy sayısı: $((end_port - start_port + 1))"
    success "Proxy listesi: $proxy_list_file"
    
    read -p "Proxy'leri başlatmak istiyor musunuz? [y/n]: " start_now
    if [[ "$start_now" =~ ^[Yy] ]]; then
        systemctl restart 3proxy
        if systemctl is-active --quiet 3proxy; then
            success "Proxy'ler başarıyla başlatıldı"
            
            # Ask for proxy validation
            echo
            read -p "Proxy'leri test etmek istiyor musunuz? [y/n]: " test_now
            if [[ "$test_now" =~ ^[Yy] ]]; then
                echo -e "${YELLOW}🔍 Proxy doğrulaması başlatılıyor...${NC}"
                sleep 2
                # For public proxies, modify format for testing (no auth)
                temp_test_file="${TEMP_DIR}/public_proxy_test.txt"
                sed 's/::/:/g' "$proxy_list_file" > "$temp_test_file"
                validate_proxy_list "$temp_test_file"
                rm -f "$temp_test_file" 2>/dev/null
            fi
        else
            error "Proxy başlatma başarısız"
        fi
    fi
    
    read -p "Press Enter to continue..."
}

create_proxy_maximum() {
    print_header
    echo -e "${WHITE}MAKSİMUM PROXY MODU${NC}"
    echo "================================"
    echo
    
    # Check if proxy list exists
    if [[ ! -f "$PROXY_LIST_FILE" ]]; then
        warning "Proxy listesi bulunamadı!"
        read -p "Şimdi proxy listesi oluşturmak istiyor musunuz? [y/N]: " create_list
        if [[ "$create_list" =~ ^[Yy] ]]; then
            if ! setup_proxy_list; then
                error "Proxy listesi oluşturulamadı"
                return 1
            fi
        else
            error "Proxy oluşturmak için IP listesi gereklidir"
            return 1
        fi
    fi
    
    # Show current proxy list info
    ip_count=$(wc -l < "$PROXY_LIST_FILE")
    echo -e "${CYAN}Mevcut IP Listesi: $ip_count adet IP${NC}"
    echo "Dosya: $PROXY_LIST_FILE"
    echo
    
    read -p "HTTP (h) veya SOCKS5 (s) [h/s]: " proxy_type
    read -p "Rastgele (r), Sabit (f), Public (p) mod [r/f/p]: " auth_mode
    
    # Read IPs and clean subnet information for proxy usage (Maximum mode)
    mapfile -t ips < "$PROXY_LIST_FILE"
    total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        error "IP listesi boş"
        return 1
    fi
    
    # Clean IPs - remove subnet information for proxy configuration
    declare -a clean_ips
    for i in "${!ips[@]}"; do
        # Remove subnet part (/24, /23, etc.) - keep only IP address
        clean_ip=$(echo "${ips[$i]}" | cut -d'/' -f1 | tr -d '\r\n ')
        clean_ips[$i]="$clean_ip"
    done
    
    # Auto-calculate optimal port range
    port_range=$(calculate_port_range "$total_ips" 3 10000)
    start_port=$(echo "$port_range" | cut -d':' -f1)
    end_port=$(echo "$port_range" | cut -d':' -f2)
    
    if [[ "$start_port" == "0" ]]; then
        error "Port hesaplama hatası"
        return 1
    fi
    
    max_proxies=$((end_port - start_port + 1))
    
    log "Toplam IP sayısı: $total_ips"
    log "Otomatik hesaplanan port aralığı: $start_port-$end_port"
    log "Maksimum proxy sayısı: $max_proxies (IP başına 3 proxy)"
    
    # Show port distribution info
    get_proxy_port_info "$total_ips"
    
    echo -e "${GREEN}📊 Otomatik Port Hesaplama:${NC}"
    echo -e "${WHITE}• Ana sunucu IP: 3128 portu${NC}"
    echo -e "${WHITE}• Diğer IP'ler: $start_port-$end_port portları${NC}"
    echo -e "${WHITE}• Her IP için 3 sıralı port${NC}"
    echo -e "${WHITE}• Toplam: $max_proxies proxy${NC}"
    
    if [[ "$auth_mode" == "f" ]]; then
        read -p "Kullanıcı adı: " fixed_user
        read -p "Şifre: " fixed_pass
        
        if [[ -z "$fixed_user" ]] || [[ -z "$fixed_pass" ]]; then
            error "Kullanıcı adı ve şifre boş olamaz"
            return 1
        fi
    fi
    
    # Generate config
    config_file="${CONFIG_DIR}/3proxy.cfg"
    PROXY_MODE="Maximum"
    generate_config_header "$config_file"
    
    # Create proxy list file
    proxy_list_file="${DATA_DIR}/proxy_list_maximum_$(date +%s).txt"
    > "$proxy_list_file"
    
    if [[ "$auth_mode" == "p" ]]; then
        echo "# No authentication required" >> "$config_file"
        echo "allow *" >> "$config_file"
        echo "" >> "$config_file"
    else
        # Create users file
        users_file="/usr/local/3proxy/conf/passwd"
        > "$users_file"
        
        echo "users \$/conf/passwd" >> "$config_file"
        echo "auth strong" >> "$config_file"
        echo "" >> "$config_file"
    fi
    
    # Create proxies with automatic port assignment per IP
    # Each IP starts from port 3128 and increments +1 for each additional proxy on that IP
    local ip_port_map=()
    
    # Initialize starting ports for each IP (3128)
    for (( i=0; i<total_ips; i++ )); do
        ip_port_map[i]=3128
    done
    
    port="$start_port"
    ip_index=0
    proxy_per_ip=0
    
    while [ "$port" -le "$end_port" ]; do
        # Get IP (3 proxies per IP) - use cleaned IP without subnet for Maximum mode
        current_ip="${clean_ips[$ip_index]}"
        current_ip=$(echo "$current_ip" | tr -d '\r\n ')
        
        # Get the current port for this IP and increment it for next use
        current_port=${ip_port_map[$ip_index]}
        ip_port_map[$ip_index]=$((current_port + 1))
        
        if [[ "$auth_mode" == "r" ]]; then
            # Random credentials
            username="user$(shuf -i 1000-9999 -n 1)"
            password="$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-12)"
            echo "${username}:CL:${password}" >> "$users_file"
            # Format: USER:PASS@IP:PORT
            echo "$username:$password@$current_ip:$current_port" >> "$proxy_list_file"
            
            echo "auth strong" >> "$config_file"
            echo "allow $username" >> "$config_file"
        elif [[ "$auth_mode" == "f" ]]; then
            # Fixed credentials
            if [ "$proxy_per_ip" -eq 0 ]; then
                echo "${fixed_user}:CL:${fixed_pass}" >> "$users_file"
            fi
            # Format: USER:PASS@IP:PORT
            echo "$fixed_user:$fixed_pass@$current_ip:$current_port" >> "$proxy_list_file"
            
            echo "auth strong" >> "$config_file"
            echo "allow $fixed_user" >> "$config_file"
        else
            # Public proxy format (no authentication): IP:PORT
            echo "$current_ip:$current_port" >> "$proxy_list_file"
        fi
        
        # Add proxy config
        if [[ "$proxy_type" == "s" ]]; then
            echo "socks -i$current_ip -p$current_port" >> "$config_file"
        else
            echo "proxy -a1 -n -i$current_ip -p$current_port" >> "$config_file"
        fi
        
        if [[ "$auth_mode" != "p" ]]; then
            echo "flush" >> "$config_file"
        fi
        echo "" >> "$config_file"
        
        port=$((port + 1))
        proxy_per_ip=$((proxy_per_ip + 1))
        
        if [ "$proxy_per_ip" -eq 3 ]; then
            proxy_per_ip=0
            ip_index=$((ip_index + 1))
        fi
    done
    
    if [[ "$auth_mode" != "p" ]]; then
        chmod 600 "$users_file"
        chown proxy:proxy "$users_file"
    fi
    
    # Open firewall ports with dynamic port calculation for maximum proxy
    # Calculate real port range based on 3128 start + proxy count per IP (3 per IP max)
    local actual_end_port=$((3128 + 2))  # Maximum 3 proxies per IP: 3128, 3129, 3130
    
    # Open firewall for the actual port range used (3128 to 3130)
    open_firewall_ports "3128" "$actual_end_port" "tcp"
    
    # Create zip file
    create_proxy_zip "$proxy_list_file" "maximum"
    
    success "Maksimum mod proxy'ler oluşturuldu"
    success "Toplam proxy sayısı: $max_proxies"
    success "Proxy listesi: $proxy_list_file"
    
    read -p "Proxy'leri başlatmak istiyor musunuz? [y/n]: " start_now
    if [[ "$start_now" =~ ^[Yy] ]]; then
        systemctl restart 3proxy
        if systemctl is-active --quiet 3proxy; then
            success "Proxy'ler başarıyla başlatıldı"
            
            # Ask for proxy validation
            echo
            read -p "Proxy'leri test etmek istiyor musunuz? [y/n]: " test_now
            if [[ "$test_now" =~ ^[Yy] ]]; then
                echo -e "${YELLOW}🔍 Proxy doğrulaması başlatılıyor...${NC}"
                sleep 2
                validate_proxy_list "$proxy_list_file"
            fi
        else
            error "Proxy başlatma başarısız"
        fi
    fi
    
    read -p "Press Enter to continue..."
}

create_proxy_zip() {
    local proxy_file="$1"
    local mode="$2"
    local zip_password="$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)"
    local zip_file="${DATA_DIR}/proxies_${mode}_$(date +%s).zip"
    
    log "Proxy listesi zip dosyasına dönüştürülüyor..."
    
    # Create zip with password
    zip -j -P "$zip_password" "$zip_file" "$proxy_file" >/dev/null 2>&1
    
    if [ -f "$zip_file" ]; then
        success "Zip dosyası oluşturuldu: $zip_file"
        success "Zip şifresi: $zip_password"
        
        # Create download info file
        info_file="${zip_file%.zip}.info"
        cat > "$info_file" << EOF
Proxy Zip Bilgileri
==================
Dosya: $zip_file
Şifre: $zip_password
Oluşturulma: $(date)
Mod: $mode
Toplam Proxy: $(wc -l < "$proxy_file")
EOF
        
        log "Bilgi dosyası: $info_file"
    else
        error "Zip dosyası oluşturulamadı"
    fi
}

start_proxies() {
    print_header
    echo -e "${WHITE}PROXY'LERİ BAŞLAT${NC}"
    echo "================================"
    echo
    
    if ! systemctl is-enabled --quiet 3proxy; then
        log "3proxy servisi etkinleştiriliyor..."
        systemctl enable 3proxy
    fi
    
    log "3proxy servisi başlatılıyor..."
    systemctl start 3proxy
    
    sleep 3
    
    if systemctl is-active --quiet 3proxy; then
        success "Proxy'ler başarıyla başlatıldı"
        echo
        
        # Show proxy configuration with IPs and ports
        log "Aktif Proxy Konfigürasyonu:"
        if [[ -f "${CONFIG_DIR}/3proxy.cfg" ]]; then
            echo
            echo -e "${CYAN}📋 IP:PORT Listesi:${NC}"
            echo "================================"
            
            # Extract proxy configurations from config file
            grep -E "^(proxy|socks)" "${CONFIG_DIR}/3proxy.cfg" 2>/dev/null | while read -r line; do
                if [[ "$line" =~ ^(proxy|socks) ]]; then
                    # Parse: proxy -a1 -n -i192.168.1.10 -p3128 or socks -i192.168.1.10 -p1080
                    local type=$(echo "$line" | awk '{print $1}')
                    local ip=$(echo "$line" | sed 's/.*-i\([0-9.]*\).*/\1/')
                    local port=$(echo "$line" | sed 's/.*-p\([0-9]*\).*/\1/')
                    
                    if [[ -n "$ip" ]] && [[ -n "$port" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        echo -e "${YELLOW}${type^^}:${NC} ${WHITE}$ip:$port${NC}"
                    fi
                fi
            done
            
            # Count total configured proxies
            local total_proxies=$(grep -c -E "^(proxy|socks)" "${CONFIG_DIR}/3proxy.cfg" 2>/dev/null || echo "0")
            echo
            echo -e "${GREEN}✅ Toplam $total_proxies proxy yapılandırıldı${NC}"
            echo
        fi
        
        # Show listening ports from system
        log "Sistem Port Durumu:"
        echo -e "${GRAY}(IPv6 portları tüm IP'lerde dinleniyor)${NC}"
        netstat -tlnp | grep 3proxy | head -15 | while read -r line; do
            local port=$(echo "$line" | awk '{print $4}' | grep -o ':[0-9]*$' | cut -d':' -f2)
            echo -e "${BLUE}Port $port:${NC} ${GREEN}✅ Aktif${NC}"
        done
    else
        error "Proxy başlatma başarısız"
        echo
        
        log "Servis durumu:"
        systemctl status 3proxy --no-pager
        echo
        
        log "Konfigürasyon dosyası kontrolü:"
        if [[ -f "${CONFIG_DIR}/3proxy.cfg" ]]; then
            echo -e "${GREEN}✅ Konfigürasyon dosyası mevcut${NC}"
            log "Son 10 satır:"
            tail -10 "${CONFIG_DIR}/3proxy.cfg"
        else
            echo -e "${RED}❌ Konfigürasyon dosyası bulunamadı: ${CONFIG_DIR}/3proxy.cfg${NC}"
        fi
        echo
        
        log "Son 20 log satırı:"
        journalctl -u 3proxy -n 20 --no-pager
    fi
    
    echo
    read -p "Press Enter to continue..."
}

stop_proxies() {
    print_header
    echo -e "${WHITE}PROXY'LERİ DURDUR${NC}"
    echo "================================"
    echo
    
    log "3proxy servisi durduruluyor..."
    systemctl stop 3proxy
    
    sleep 2
    
    if ! systemctl is-active --quiet 3proxy; then
        success "Proxy'ler başarıyla durduruldu"
    else
        warning "Proxy'ler tam olarak durdurulamadı"
        
        log "Zorla kapatılıyor..."
        pkill -f 3proxy || true
        sleep 1
        
        if ! pgrep -f 3proxy >/dev/null; then
            success "Proxy'ler zorla durduruldu"
        else
            error "Proxy'ler durdurulamadı"
        fi
    fi
    
    read -p "Press Enter to continue..."
}

restart_proxies() {
    print_header
    echo -e "${WHITE}PROXY'LERİ YENİDEN BAŞLAT${NC}"
    echo "================================"
    echo
    
    log "3proxy servisi yeniden başlatılıyor..."
    systemctl restart 3proxy
    
    sleep 3
    
    if systemctl is-active --quiet 3proxy; then
        success "Proxy'ler başarıyla yeniden başlatıldı"
        
        log "Aktif portlar:"
        netstat -tlnp | grep 3proxy | head -10
    else
        error "Proxy yeniden başlatma başarısız"
        systemctl status 3proxy --no-pager
    fi
    
    read -p "Press Enter to continue..."
}

stop_port_range() {
    print_header
    echo -e "${WHITE}PORT ARALIĞI DURDUR${NC}"
    echo "================================"
    echo
    
    read -p "Başlangıç portu: " start_port
    read -p "Bitiş portu: " end_port
    
    if [[ ! "$start_port" =~ ^[0-9]+$ ]] || [[ ! "$end_port" =~ ^[0-9]+$ ]]; then
        error "Geçersiz port numarası"
        return 1
    fi
    
    if [ "$start_port" -ge "$end_port" ]; then
        error "Başlangıç portu bitiş portundan küçük olmalı"
        return 1
    fi
    
    log "Port aralığı $start_port-$end_port durduruluyor..."
    
    stopped_count=0
    port="$start_port"
    
    while [ "$port" -le "$end_port" ]; do
        # Find process using port
        pid=$(lsof -ti:$port 2>/dev/null || true)
        if [ -n "$pid" ]; then
            if kill "$pid" 2>/dev/null; then
                ((stopped_count++))
                log "Port $port durduruldu (PID: $pid)"
            else
                warning "Port $port durdurulamadı (PID: $pid)"
            fi
        fi
        port=$((port + 1))
    done
    
    if [ "$stopped_count" -gt 0 ]; then
        success "$stopped_count port başarıyla durduruldu"
    else
        info "Belirtilen aralıkta aktif port bulunamadı"
    fi
    
    read -p "Press Enter to continue..."
}

remove_ip() {
    print_header
    echo -e "${WHITE}SUNUCUDAN IP SİL${NC}"
    echo "================================"
    echo
    
    # Show current IPs
    log "Mevcut IP adresleri:"
    ip addr show | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1 | nl
    echo
    
    read -p "Silinecek IP adresini girin: " remove_ip
    
    if [[ ! "$remove_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Geçersiz IP adresi formatı"
        return 1
    fi
    
    # Check if IP exists
    if ! ip addr show | grep -q "$remove_ip"; then
        error "IP adresi sunucuda bulunamadı: $remove_ip"
        return 1
    fi
    
    log "IP adresi siliniyor: $remove_ip"
    
    # Find interface
    interface=$(ip addr show | grep -B2 "$remove_ip" | grep -E '^[0-9]+:' | cut -d':' -f2 | tr -d ' ')
    
    if [ -z "$interface" ]; then
        error "Interface bulunamadı"
        return 1
    fi
    
    # Remove IP
    if ip addr del "$remove_ip/24" dev "$interface" 2>/dev/null; then
        success "IP adresi başarıyla silindi: $remove_ip"
        
        log "Proxy konfigürasyonu güncelleniyor..."
        
        # Stop proxies using this IP
        if systemctl is-active --quiet 3proxy; then
            log "Etkilenen proxy'ler yeniden başlatılıyor..."
            systemctl restart 3proxy
            
            if systemctl is-active --quiet 3proxy; then
                success "Proxy'ler güncellendi"
            else
                warning "Proxy yeniden başlatma başarısız"
            fi
        fi
    else
        error "IP adresi silinemedi"
    fi
    
    read -p "Press Enter to continue..."
}

check_updates() {
    print_header
    echo -e "${WHITE}GÜNCELLEMELERI KONTROL ET${NC}"
    echo "================================"
    echo
    
    log "GitHub'dan son sürüm kontrol ediliyor..."
    
    # Get latest release from GitHub
    latest_version=$(curl -s "https://api.github.com/repos/muzaffer72/3proxy-otomatik/releases/latest" | jq -r '.tag_name' 2>/dev/null || echo "unknown")
    
    if [ "$latest_version" = "unknown" ] || [ -z "$latest_version" ]; then
        warning "Güncellemeleri kontrol edilemiyor"
    else
        log "Mevcut sürüm: v$VERSION"
        log "Son sürüm: $latest_version"
        
        if [ "v$VERSION" != "$latest_version" ]; then
            echo -e "${YELLOW}Yeni güncellemeler mevcut!${NC}"
            read -p "Güncelleme yapmak istiyor musunuz? [y/n]: " update_choice
            
            if [[ "$update_choice" =~ ^[Yy] ]]; then
                log "Güncelleme indiriliyor..."
                cd "${TEMP_DIR}"
                
                if wget -q "https://github.com/muzaffer72/3proxy-otomatik/archive/refs/heads/master.zip"; then
                    unzip -q master.zip
                    
                    if [ -f "3proxy-otomatik-master/3proxy_menu.sh" ]; then
                        cp "3proxy-otomatik-master/3proxy_menu.sh" /usr/local/bin/menu
                        chmod +x /usr/local/bin/menu
                        success "Güncelleme tamamlandı! Scripti yeniden başlatın."
                        exit 0
                    else
                        error "Güncelleme dosyası bulunamadı"
                    fi
                else
                    error "Güncelleme indirilemedi"
                fi
            fi
        else
            success "En son sürümü kullanıyorsunuz!"
        fi
    fi
    
    read -p "Press Enter to continue..."
}

show_proxy_status() {
    print_header
    echo -e "${WHITE}PROXY DURUMU${NC}"
    echo "================================"
    echo
    
    # Service status
    if systemctl is-active --quiet 3proxy; then
        echo -e "${GREEN}✅ 3proxy servisi: ÇALIŞIYOR${NC}"
    else
        echo -e "${RED}❌ 3proxy servisi: DURMUŞ${NC}"
    fi
    
    # Process status
    proxy_processes=$(pgrep -f 3proxy | wc -l)
    echo -e "${CYAN}📊 Aktif process sayısı: $proxy_processes${NC}"
    
    # Active ports
    active_ports=$(netstat -tlnp 2>/dev/null | grep 3proxy | wc -l)
    echo -e "${CYAN}🔌 Aktif port sayısı: $active_ports${NC}"
    
    echo
    echo -e "${WHITE}📋 Aktif Proxy Listesi:${NC}"
    echo "==============================="
    
    if [[ -f "${CONFIG_DIR}/3proxy.cfg" ]]; then
        echo -e "${CYAN}Konfigüre Edilmiş Proxy'ler:${NC}"
        
        # Parse proxy configurations and show with status
        local proxy_count=0
        grep -E "^(proxy|socks)" "${CONFIG_DIR}/3proxy.cfg" 2>/dev/null | while read -r line; do
            if [[ "$line" =~ ^(proxy|socks) ]]; then
                ((proxy_count++))
                local type=$(echo "$line" | awk '{print $1}')
                local ip=$(echo "$line" | sed 's/.*-i\([0-9.]*\).*/\1/')
                local port=$(echo "$line" | sed 's/.*-p\([0-9]*\).*/\1/')
                
                if [[ -n "$ip" ]] && [[ -n "$port" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    # Check if port is actually listening
                    if netstat -tln 2>/dev/null | grep -q ":$port "; then
                        echo -e "${GREEN}  ✅ ${type^^}: ${WHITE}$ip:$port${NC} ${GREEN}(Aktif)${NC}"
                    else
                        echo -e "${RED}  ❌ ${type^^}: ${WHITE}$ip:$port${NC} ${RED}(Pasif)${NC}"
                    fi
                fi
            fi
        done
        
        # If no specific proxy configs found, show general port info
        if ! grep -E "^(proxy|socks)" "${CONFIG_DIR}/3proxy.cfg" >/dev/null 2>&1; then
            echo -e "${YELLOW}Genel port dinleme modu aktif:${NC}"
            netstat -tlnp 2>/dev/null | grep 3proxy | head -10 | while read -r line; do
                local port=$(echo "$line" | awk '{print $4}' | cut -d':' -f2)
                echo -e "${GREEN}  ✅ Port: ${WHITE}$port${NC} ${GREEN}(Tüm IP'lerde dinleniyor)${NC}"
            done
        fi
    else
        echo -e "${RED}❌ Konfigürasyon dosyası bulunamadı${NC}"
    fi
    
    echo
    echo -e "${WHITE}Sistem Portları:${NC}"
    echo -e "${GRAY}(Sistemde dinlenen 3proxy portları)${NC}"
    netstat -tlnp 2>/dev/null | grep 3proxy | head -15 | while read -r line; do
        local full_port=$(echo "$line" | awk '{print $4}')
        local port=$(echo "$full_port" | grep -o '[0-9]*$')
        local pid=$(echo "$line" | awk '{print $7}' | cut -d'/' -f1)
        echo -e "${BLUE}  🔌 $full_port${NC} ${GREEN}(PID: $pid)${NC}"
    done
    
    echo
    echo -e "${WHITE}Sistem Bilgileri:${NC}"
    echo -e "${CYAN}  Çalışma süresi: $(uptime -p)${NC}"
    echo -e "${CYAN}  Bellek kullanımı: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')${NC}"
    echo -e "${CYAN}  Disk kullanımı: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')${NC}"
    
    # Configuration files
    echo
    echo -e "${WHITE}Konfigürasyon Dosyaları:${NC}"
    if [ -f "${CONFIG_DIR}/3proxy.cfg" ]; then
        echo -e "${GREEN}  ✅ Ana config: ${CONFIG_DIR}/3proxy.cfg${NC}"
        local config_lines=$(wc -l < "${CONFIG_DIR}/3proxy.cfg")
        echo -e "${CYAN}     Toplam satır: $config_lines${NC}"
    else
        echo -e "${RED}  ❌ Ana config bulunamadı${NC}"
    fi
    
    if [ -f "/usr/local/3proxy/conf/passwd" ]; then
        user_count=$(wc -l < /usr/local/3proxy/conf/passwd)
        echo -e "${GREEN}  ✅ Kullanıcılar: $user_count tanımlı${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Kullanıcı dosyası bulunamadı${NC}"
    fi
    
    # Proxy list status
    if [ -f "$PROXY_LIST_FILE" ]; then
        proxy_ip_count=$(wc -l < "$PROXY_LIST_FILE")
        echo -e "${GREEN}  ✅ Proxy IP Listesi: $proxy_ip_count IP${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Proxy IP listesi bulunamadı${NC}"
    fi
    
    # Proxy lists
    echo
    echo -e "${WHITE}Proxy Listeleri:${NC}"
    if ls "${DATA_DIR}"/proxy_list_*.txt >/dev/null 2>&1; then
        for file in "${DATA_DIR}"/proxy_list_*.txt; do
            basename_file=$(basename "$file")
            proxy_count=$(wc -l < "$file")
            echo -e "${CYAN}  📄 $basename_file: $proxy_count proxy${NC}"
        done
    else
        echo -e "${YELLOW}  ⚠️  Proxy listesi bulunamadı${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

view_logs() {
    print_header
    echo -e "${WHITE}LOG GÖRÜNTÜLEME${NC}"
    echo "================================"
    echo
    
    echo "Hangi logu görüntülemek istiyorsunuz?"
    echo "1. 3proxy servisi logları"
    echo "2. Menu logları"
    echo "3. Sistem logları (son 50 satır)"
    echo "4. Canlı log takibi"
    echo
    read -p "Seçiminiz [1-4]: " log_choice
    
    case $log_choice in
        1)
            echo -e "${WHITE}3proxy Servis Logları:${NC}"
            echo "================================"
            journalctl -u 3proxy -n 50 --no-pager
            ;;
        2)
            if [ -f "${LOG_DIR}/menu.log" ]; then
                echo -e "${WHITE}Menu Logları:${NC}"
                echo "================================"
                tail -50 "${LOG_DIR}/menu.log"
            else
                info "Menu log dosyası bulunamadı"
            fi
            ;;
        3)
            echo -e "${WHITE}Sistem Logları:${NC}"
            echo "================================"
            tail -50 /var/log/syslog | grep -E "(3proxy|proxy)" || echo "3proxy ile ilgili log bulunamadı"
            ;;
        4)
            echo -e "${WHITE}Canlı Log Takibi (Çıkmak için Ctrl+C):${NC}"
            echo "================================"
            journalctl -u 3proxy -f
            ;;
        *)
            error "Geçersiz seçim"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

manage_configs() {
    print_header
    echo -e "${WHITE}KONFİGÜRASYON YÖNETİMİ${NC}"
    echo "================================"
    echo
    
    echo "1. Aktif konfigürasyonu görüntüle"
    echo "2. Konfigürasyonu yedekle"
    echo "3. Yedekten konfigürasyonu geri yükle"
    echo "4. Konfigürasyon dosyasını düzenle"
    echo "5. Konfigürasyonu test et"
    echo
    read -p "Seçiminiz [1-5]: " config_choice
    
    case $config_choice in
        1)
            if [ -f "${CONFIG_DIR}/3proxy.cfg" ]; then
                echo -e "${WHITE}Aktif Konfigürasyon:${NC}"
                echo "================================"
                cat "${CONFIG_DIR}/3proxy.cfg"
            else
                error "Konfigürasyon dosyası bulunamadı"
            fi
            ;;
        2)
            backup_file="${DATA_DIR}/3proxy_backup_$(date +%s).cfg"
            if cp "${CONFIG_DIR}/3proxy.cfg" "$backup_file" 2>/dev/null; then
                success "Konfigürasyon yedeklendi: $backup_file"
            else
                error "Yedekleme başarısız"
            fi
            ;;
        3)
            echo -e "${WHITE}Mevcut Yedekler:${NC}"
            ls -la "${DATA_DIR}"/3proxy_backup_*.cfg 2>/dev/null | nl || {
                error "Yedek bulunamadı"
                return 1
            }
            read -p "Geri yüklenecek yedek dosyasının tam yolunu girin: " restore_file
            if [ -f "$restore_file" ]; then
                if cp "$restore_file" "${CONFIG_DIR}/3proxy.cfg"; then
                    success "Konfigürasyon geri yüklendi"
                    log "Değişikliklerin etkin olması için servisi yeniden başlatın"
                else
                    error "Geri yükleme başarısız"
                fi
            else
                error "Yedek dosyası bulunamadı"
            fi
            ;;
        4)
            if command -v nano >/dev/null; then
                nano "${CONFIG_DIR}/3proxy.cfg"
            elif command -v vi >/dev/null; then
                vi "${CONFIG_DIR}/3proxy.cfg"
            else
                error "Metin editörü bulunamadı"
            fi
            ;;
        5)
            log "Konfigürasyon test ediliyor..."
            if /usr/local/bin/3proxy "${CONFIG_DIR}/3proxy.cfg" -t 2>/dev/null; then
                success "Konfigürasyon test başarılı"
            else
                error "Konfigürasyon test başarısız"
                log "Hata detayları:"
                /usr/local/bin/3proxy "${CONFIG_DIR}/3proxy.cfg" -t
            fi
            ;;
        *)
            error "Geçersiz seçim"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

reinstall_server() {
    print_header
    echo -e "${RED}🔄 SUNUCU YENİDEN KURULUM${NC}"
    echo "============================================"
    echo
    echo -e "${YELLOW}⚠️  UYARI: Bu işlem sunucuyu tamamen yeniden kuracaktır!${NC}"
    echo -e "${RED}⚠️  TÜM VERİLER SİLİNECEKTİR!${NC}"
    echo
    echo -e "${WHITE}Yeniden Kurulum Bilgileri:${NC}"
    echo -e "• İşletim Sistemi: ${GREEN}Ubuntu 20.04${NC}"
    echo -e "• Kurulum Script: ${BLUE}bin456789/reinstall${NC}"
    echo -e "• Sunucu yeniden başlatılacak${NC}"
    echo
    
    read -p "Bu işlemi gerçekten yapmak istiyor musunuz? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy] ]]; then
        info "İşlem iptal edildi"
        return 0
    fi
    
    echo
    echo -e "${CYAN}🔐 Root şifresi belirleme${NC}"
    echo "================================"
    echo -e "${WHITE}Yeni sunucu için root şifresi girin:${NC}"
    
    while true; do
        read -s -p "Root şifresi: " user_password
        echo
        if [[ ${#user_password} -lt 6 ]]; then
            error "Şifre en az 6 karakter olmalıdır"
            continue
        fi
        
        read -s -p "Şifreyi tekrar girin: " user_password2
        echo
        
        if [[ "$user_password" != "$user_password2" ]]; then
            error "Şifreler eşleşmiyor"
            continue
        fi
        
        break
    done
    
    success "Şifre belirlendi"
    echo
    
    echo -e "${YELLOW}⚠️  SON UYARI: 10 saniye içinde sunucu yeniden kurulumu başlayacak!${NC}"
    echo -e "${RED}Bu işlem GERİ ALINAMAZ!${NC}"
    echo
    
    for i in {10..1}; do
        echo -ne "\rGeri sayım: ${RED}$i${NC} saniye... (Durdurmak için Ctrl+C)"
        sleep 1
    done
    echo
    echo
    
    log "Sunucu yeniden kurulum başlatılıyor..."
    echo -e "${CYAN}📥 Kurulum script'i indiriliyor...${NC}"
    
    # Download reinstall script
    if command -v wget >/dev/null; then
        wget -O /tmp/reinstall.sh https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
    elif command -v curl >/dev/null; then
        curl -sL https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh -o /tmp/reinstall.sh
    else
        error "wget veya curl bulunamadı"
        return 1
    fi
    
    if [[ ! -f "/tmp/reinstall.sh" ]]; then
        error "Kurulum script'i indirilemedi"
        return 1
    fi
    
    chmod +x /tmp/reinstall.sh
    
    echo -e "${GREEN}✅ Script indirildi${NC}"
    echo -e "${YELLOW}🚀 Ubuntu 20.04 kurulumu başlatılıyor...${NC}"
    echo
    echo -e "${RED}SUNUCU ŞİMDİ YENİDEN BAŞLATILACAK!${NC}"
    echo
    
    # Run reinstall command
    log "Reinstall komutu çalıştırılıyor: bash /tmp/reinstall.sh ubuntu 20.04 --passwd ****"
    bash /tmp/reinstall.sh ubuntu 20.04 --passwd "$user_password" && reboot
}

uninstall_3proxy() {
    print_header
    echo -e "${RED}3PROXY KALDIRMA${NC}"
    echo "================================"
    echo
    
    echo -e "${RED}⚠️  UYARI: Bu işlem tüm 3proxy kurulumunu ve verilerini silecektir!${NC}"
    echo
    read -p "Kaldırma işlemini onaylıyor musunuz? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy] ]]; then
        info "İşlem iptal edildi"
        return 0
    fi
    
    log "3proxy kaldırılıyor..."
    
    # Stop service
    systemctl stop 3proxy 2>/dev/null || true
    systemctl disable 3proxy 2>/dev/null || true
    
    # Remove systemd service
    rm -f /etc/systemd/system/3proxy.service
    systemctl daemon-reload
    
    # Remove files
    rm -rf /usr/local/3proxy
    rm -rf "${CONFIG_DIR}"
    rm -rf "${LOG_DIR}"
    rm -rf "${DATA_DIR}"
    rm -rf "${SCRIPT_DIR}"
    
    # Remove global commands
    rm -f /usr/local/bin/3proxy
    rm -f /usr/local/bin/menu
    rm -f /usr/local/bin/proxy-menu
    rm -f /usr/local/bin/3proxy-manager
    
    # Remove user
    userdel proxy 2>/dev/null || true
    
    # Kill any remaining processes
    pkill -f 3proxy 2>/dev/null || true
    
    success "3proxy başarıyla kaldırıldı"
    
    read -p "Press Enter to continue..."
    exit 0
}

check_firewall_status() {
    print_header
    echo -e "${WHITE}FIREWALL DURUMU${NC}"
    echo "================================"
    echo
    
    # Check UFW status
    log "UFW durumu kontrol ediliyor..."
    local ufw_status=$(ufw status 2>/dev/null || echo "UFW bulunamadı")
    
    if [[ "$ufw_status" =~ "Status: active" ]]; then
        echo -e "${GREEN}✅ UFW: Aktif${NC}"
        echo
        echo -e "${WHITE}UFW Kuralları:${NC}"
        ufw status numbered | grep -E "(ALLOW|DENY)" | head -20
    elif [[ "$ufw_status" =~ "Status: inactive" ]]; then
        echo -e "${YELLOW}⚠️  UFW: Pasif${NC}"
    else
        echo -e "${RED}❌ UFW: Bulunamadı${NC}"
    fi
    
    echo
    
    # Check iptables
    log "iptables durumu kontrol ediliyor..."
    if command -v iptables >/dev/null; then
        echo -e "${WHITE}iptables INPUT Kuralları:${NC}"
        iptables -L INPUT -n | grep -E "(ACCEPT|DROP|REJECT)" | grep -E "tcp|udp" | head -10 || echo "Özel kural bulunamadı"
    else
        echo -e "${RED}❌ iptables bulunamadı${NC}"
    fi
    
    echo
    
    # Show listening ports
    echo -e "${WHITE}Dinlenen Portlar:${NC}"
    netstat -tlnp 2>/dev/null | grep -E ":([0-9]+)" | head -15 || \
    ss -tlnp 2>/dev/null | grep -E ":([0-9]+)" | head -15 || \
    echo "Port bilgisi alınamadı"
    
    read -p "Press Enter to continue..."
}

open_specific_ports() {
    print_header
    echo -e "${WHITE}BELİRLİ PORTLARI AÇ${NC}"
    echo "================================"
    echo
    
    read -p "Başlangıç portu: " start_port
    read -p "Bitiş portu (tek port için aynı değer): " end_port
    read -p "Protokol [tcp/udp/both]: " protocol_choice
    
    if [[ ! "$start_port" =~ ^[0-9]+$ ]] || [[ ! "$end_port" =~ ^[0-9]+$ ]]; then
        error "Geçersiz port numarası"
        return 1
    fi
    
    if [ "$start_port" -gt "$end_port" ]; then
        error "Başlangıç portu bitiş portundan küçük veya eşit olmalı"
        return 1
    fi
    
    case "$protocol_choice" in
        "tcp"|"TCP")
            open_firewall_ports "$start_port" "$end_port" "tcp"
            ;;
        "udp"|"UDP")
            open_firewall_ports "$start_port" "$end_port" "udp"
            ;;
        "both"|"BOTH"|"her ikisi")
            open_firewall_ports "$start_port" "$end_port" "tcp"
            open_firewall_ports "$start_port" "$end_port" "udp"
            ;;
        *)
            error "Geçersiz protokol seçimi"
            return 1
            ;;
    esac
    
    success "Portlar başarıyla açıldı"
    read -p "Press Enter to continue..."
}

# Main menu
show_main_menu() {
    print_header
    echo -e "${WHITE}ANA MENU${NC}"
    echo "================================"
    echo
    
    # Show proxy list status
    if [[ -f "$PROXY_LIST_FILE" ]]; then
        ip_count=$(wc -l < "$PROXY_LIST_FILE")
        echo -e "${GREEN}📋 Proxy Listesi: $ip_count IP mevcut${NC}"
    else
        echo -e "${YELLOW}📋 Proxy Listesi: Henüz oluşturulmamış${NC}"
    fi
    
    # Show firewall status
    local ufw_status=$(ufw status 2>/dev/null | head -1 | grep -o "Status: [a-z]*" || echo "UFW: Unknown")
    if [[ "$ufw_status" =~ "active" ]]; then
        echo -e "${GREEN}🔥 Firewall: UFW Aktif${NC}"
    elif [[ "$ufw_status" =~ "inactive" ]]; then
        echo -e "${YELLOW}🔥 Firewall: UFW Pasif${NC}"
    else
        echo -e "${CYAN}🔥 Firewall: iptables Modu${NC}"
    fi
    echo
    
    echo -e "${CYAN} 1.${NC} İlk Kurulum (3proxy ve bağımlılıklar)"
    echo -e "${CYAN} 2.${NC} Proxy Listesi Oluştur/Düzenle"
    echo -e "${CYAN} 3.${NC} Proxy Listesini Sil"
    echo -e "${CYAN} 4.${NC} Rastgele Mod Proxy Oluştur"
    echo -e "${CYAN} 5.${NC} Sabit Mod Proxy Oluştur"
    echo -e "${CYAN} 6.${NC} Public Mod Proxy Oluştur"
    echo -e "${CYAN} 7.${NC} Maksimum Proxy Modu"
    echo -e "${CYAN} 8.${NC} Proxy'leri Başlat"
    echo -e "${CYAN} 9.${NC} Proxy'leri Durdur"
    echo -e "${CYAN}10.${NC} Proxy'leri Yeniden Başlat"
    echo -e "${CYAN}11.${NC} Port Aralığını Durdur"
    echo -e "${CYAN}12.${NC} Sunucudan IP Sil"
    echo -e "${CYAN}13.${NC} Proxy Durumu Görüntüle"
    echo -e "${CYAN}14.${NC} Firewall Durumu Kontrol Et"    
    echo -e "${CYAN}15.${NC} Belirli Portları Aç"           
    echo -e "${CYAN}16.${NC} Güncellemeleri Kontrol Et"
    echo -e "${CYAN}17.${NC} Log Görüntüle"
    echo -e "${CYAN}18.${NC} Konfigürasyon Yönetimi"
    echo -e "${CYAN}19.${NC} Proxy'leri Doğrula"
    echo -e "${CYAN}20.${NC} Proxy Hız Testi (passo.com.tr)"
    echo -e "${CYAN}21.${NC} Sunucu Yeniden Kur"
    echo -e "${CYAN}22.${NC} 3proxy Kaldır"
    echo -e "${CYAN} 0.${NC} Çıkış"
    echo
    echo -e "${WHITE}Ubuntu 20.04+ | v$VERSION | $(date)${NC}"
    echo
}

# Main loop
main() {
    check_root
    check_system
    
    while true; do
        show_main_menu
        read -p "Seçiminiz [0-22]: " choice
        
        case $choice in
            1) install_3proxy ;;
            2) setup_proxy_list ;;
            3) delete_proxy_list ;;
            4) create_proxy_random ;;
            5) create_proxy_fixed ;;
            6) create_proxy_public ;;
            7) create_proxy_maximum ;;
            8) start_proxies ;;
            9) stop_proxies ;;
            10) restart_proxies ;;
            11) stop_port_range ;;
            12) remove_ip ;;
            13) show_proxy_status ;;
            14) check_firewall_status ;;
            15) open_specific_ports ;;
            16) check_updates ;;
            17) view_logs ;;
            18) manage_configs ;;
            19) validate_proxy_list "$PROXY_LIST_FILE" ;;
            20) test_proxy_speeds "$PROXY_LIST_FILE" ;;
            21) reinstall_server ;;
            22) uninstall_3proxy ;;
            0) 
                print_header
                echo -e "${GREEN}3proxy Elite Manager'dan çıkılıyor...${NC}"
                echo -e "${WHITE}İyi günler!${NC}"
                exit 0
                ;;
            *)
                error "Geçersiz seçim: $choice"
                ;;
        esac
    done
}

# Start the script
main "$@"
