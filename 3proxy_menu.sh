#!/bin/bash
# 3proxy Elite Anonymous Proxy - Advanced Menu System
# Ubuntu 20.04+ Compatible - Self-Installing Version
# Author: muzaffer72
# Version: 2.3

set -e

# Check for install parameter
if [[ "$1" == "--install" ]]; then
    install_system
    exit 0
fi

# Configuration
VERSION="2.3"
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

    # Create global command
    ln -sf "$install_dir/3proxy_menu.sh" /usr/local/bin/3proxy-manager

    echo -e "${GREEN}✅ 3proxy Elite Manager başarıyla yüklendi!${NC}"
    echo
    echo -e "${GREEN}🚀 Kullanım:${NC}"
    echo -e "   ${BLUE}sudo 3proxy-manager${NC}     # Ana menüyü başlat"
    echo -e "   ${BLUE}sudo $install_dir/3proxy_menu.sh${NC}  # Doğrudan çalıştır"
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
        echo -e "${GREEN}Menü başlatmak için: ${BLUE}sudo 3proxy-manager${NC}"
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
    
    # Parse proxy format: ip:port:username:password or ip:port (for public)
    local ip=$(echo "$proxy_line" | cut -d':' -f1)
    local port=$(echo "$proxy_line" | cut -d':' -f2)
    local username=$(echo "$proxy_line" | cut -d':' -f3)
    local password=$(echo "$proxy_line" | cut -d':' -f4)
    
    # Test HTTP proxy
    local test_result
    if [[ -n "$username" ]] && [[ -n "$password" ]] && [[ "$username" != "$password" ]]; then
        # Authenticated proxy
        test_result=$(timeout 10 curl -s --proxy "$username:$password@$ip:$port" http://httpbin.org/ip 2>/dev/null)
    else
        # Public proxy (no authentication)
        test_result=$(timeout 10 curl -s --proxy "$ip:$port" http://httpbin.org/ip 2>/dev/null)
    fi
    
    if [[ $? -eq 0 ]] && [[ -n "$test_result" ]]; then
        # Extract origin IP from JSON response
        local origin_ip=$(echo "$test_result" | grep -o '"origin": "[^"]*"' | cut -d'"' -f4)
        
        if [[ "$origin_ip" == "$expected_ip" ]]; then
            return 0  # Success
        else
            echo "IP Mismatch: Expected $expected_ip, Got $origin_ip" >&2
            return 1  # IP mismatch
        fi
    else
        echo "Connection failed or timeout" >&2
        return 2  # Connection failed
    fi
}

test_proxy_speed() {
    local proxy_line="$1"
    local expected_ip="$2"
    
    # Parse proxy format: ip:port:username:password or ip:port (for public)
    local ip=$(echo "$proxy_line" | cut -d':' -f1)
    local port=$(echo "$proxy_line" | cut -d':' -f2)
    local username=$(echo "$proxy_line" | cut -d':' -f3)
    local password=$(echo "$proxy_line" | cut -d':' -f4)
    
    # Test with passo.com.tr for speed
    local start_time=$(date +%s%3N)
    local test_result
    
    if [[ -n "$username" ]] && [[ -n "$password" ]] && [[ "$username" != "$password" ]]; then
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
    
    local total_proxies=$(wc -l < "$proxy_file")
    local tested_count=0
    local success_count=0
    local failed_count=0
    local timeout_count=0
    
    if [[ "$show_details" == "true" ]]; then
        print_header
        echo -e "${CYAN}🔍 PROXY DOĞRULAMA SİSTEMİ${NC}"
        echo "=================================="
        echo -e "${WHITE}Toplam Proxy: ${YELLOW}$total_proxies${NC}"
        echo -e "${WHITE}Test URL: ${BLUE}http://httpbin.org/ip${NC}"
        echo
        echo -e "${YELLOW}Proxy'ler test ediliyor...${NC}"
        echo
    fi
    
    while IFS= read -r proxy_line; do
        if [[ -z "$proxy_line" ]] || [[ "$proxy_line" =~ ^#.* ]]; then
            continue
        fi
        
        ((tested_count++))
        local expected_ip=$(echo "$proxy_line" | cut -d':' -f1)
        
        if [[ "$show_details" == "true" ]]; then
            printf "%-3s %-15s %-6s " "$tested_count." "$expected_ip" "$(echo "$proxy_line" | cut -d':' -f2)"
        fi
        
        if test_result=$(test_proxy "$proxy_line" "$expected_ip" 2>&1); then
            ((success_count++))
            if [[ "$show_details" == "true" ]]; then
                echo -e "${GREEN}✅ BAŞARILI${NC}"
            fi
        elif [[ $? -eq 2 ]]; then
            ((timeout_count++))
            if [[ "$show_details" == "true" ]]; then
                echo -e "${RED}❌ TIMEOUT${NC}"
            fi
        else
            ((failed_count++))
            if [[ "$show_details" == "true" ]]; then
                echo -e "${RED}❌ HATA: $test_result${NC}"
            fi
        fi
        
        # Progress indicator
        if [[ "$show_details" == "true" ]] && (( tested_count % 10 == 0 )); then
            echo -e "${BLUE}[İlerleme: $tested_count/$total_proxies]${NC}"
        fi
        
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
    echo -e "${WHITE}Toplam Proxy: ${YELLOW}$total_proxies${NC}"
    echo -e "${WHITE}Test Sitesi: ${BLUE}https://passo.com.tr${NC}"
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
        local expected_ip=$(echo "$proxy_line" | cut -d':' -f1)
        local port=$(echo "$proxy_line" | cut -d':' -f2)
        
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
    
    if [ -d "3proxy-0.9.3" ]; then
        rm -rf "3proxy-0.9.3"
    fi
    
    wget -q "https://github.com/3proxy/3proxy/archive/0.9.3.tar.gz" || {
        error "3proxy indirilemiyor"
        return 1
    }
    
    tar -xzf "0.9.3.tar.gz"
    cd "3proxy-0.9.3"
    
    # Enable anonymous proxy support
    echo '#define ANONYMOUS 1' >> src/proxy.h
    
    # Compile
    make -f Makefile.Linux || {
        error "Derleme başarısız"
        return 1
    }
    
    success "3proxy başarıyla derlendi"
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
    
    # Create directories
    mkdir -p /usr/local/3proxy/{bin,conf,logs,count}
    mkdir -p "${CONFIG_DIR}" /var/run/3proxy
    
    # Copy binaries
    cd "${TEMP_DIR}/3proxy-0.9.3"
    cp bin/* /usr/local/3proxy/bin/
    ln -sf /usr/local/3proxy/bin/3proxy /usr/local/bin/3proxy
    
    # Create user
    id proxy >/dev/null 2>&1 || useradd -r -s /bin/false proxy
    
    # Create systemd service
    create_systemd_service
    
    # Set permissions
    chown -R proxy:proxy /usr/local/3proxy /var/run/3proxy
    
    success "3proxy başarıyla kuruldu"
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
        echo -e "${RED}  ❌ $ip${NC}"
    done
    echo
    
    read -p "Eksik IP'leri netplan'a eklemek istiyor musunuz? [y/N]: " add_ips
    if [[ ! "$add_ips" =~ ^[Yy] ]]; then
        warning "Netplan güncellemesi atlandı"
        return 1
    fi
    
    # Find primary netplan file (first one)
    primary_yaml="${yaml_files[0]}"
    log "Ana netplan dosyası: $primary_yaml"
    
    # Backup original
    backup_file="${primary_yaml}.backup.$(date +%s)"
    cp "$primary_yaml" "$backup_file"
    log "Yedek oluşturuldu: $backup_file"
    
    # Add missing IPs to addresses section
    log "Eksik IP'ler ekleniyor..."
    
    # Create temporary file with updated config
    temp_yaml="${TEMP_DIR}/netplan_temp.yaml"
    cp "$primary_yaml" "$temp_yaml"
    
    # Add each missing IP to addresses section
    for ip_entry in "${missing_ips[@]}"; do
        local ip_to_add=""
        
        if [[ "$ip_entry" == *"/"* ]]; then
            # IP already has subnet, use as-is
            ip_to_add="$ip_entry"
            log "  ✅ $ip_to_add eklendi (kullanıcı tarafından belirtilen subnet)"
        else
            # IP without subnet, detect it
            detected_subnet=$(detect_subnet_for_ip "$ip_entry")
            ip_to_add="$ip_entry$detected_subnet"
            log "  ✅ $ip_to_add eklendi (otomatik tespit edilen subnet)"
        fi
        
        # Find the line with 'addresses:' and add IPs after existing ones
        if grep -q "addresses:" "$temp_yaml"; then
            sed -i "/addresses:/a\\                - $ip_to_add" "$temp_yaml"
        else
            warning "  ❌ addresses section bulunamadı: $ip_to_add"
        fi
    done
    
    # Validate YAML syntax
    if python3 -c "import yaml; yaml.safe_load(open('$temp_yaml'))" 2>/dev/null; then
        # Apply the changes
        cp "$temp_yaml" "$primary_yaml"
        success "Netplan konfigürasyonu güncellendi"
        
        # Apply netplan
        log "Netplan uygulanıyor..."
        if netplan apply 2>/dev/null; then
            success "Netplan başarıyla uygulandı"
        else
            error "Netplan uygulanamadı, yedekten geri yükleniyor..."
            cp "$backup_file" "$primary_yaml"
            netplan apply
            return 1
        fi
    else
        error "YAML syntax hatası, değişiklikler uygulanamadı"
        return 1
    fi
    
    return 0
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
    
    read -p "Başlangıç portu: " start_port
    read -p "Bitiş portu: " end_port
    read -p "HTTP (h) veya SOCKS5 (s) [h/s]: " proxy_type
    
    if [[ ! "$start_port" =~ ^[0-9]+$ ]] || [[ ! "$end_port" =~ ^[0-9]+$ ]]; then
        error "Geçersiz port numarası"
        return 1
    fi
    
    if [ "$start_port" -ge "$end_port" ]; then
        error "Başlangıç portu bitiş portundan küçük olmalı"
        return 1
    fi
    
    # Read IPs
    mapfile -t ips < "$PROXY_LIST_FILE"
    total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        error "IP listesi boş"
        return 1
    fi
    
    log "Toplam IP sayısı: $total_ips"
    log "Port aralığı: $start_port-$end_port"
    
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
    
    port="$start_port"
    ip_index=0
    
    while [ "$port" -le "$end_port" ]; do
        # Generate random credentials
        username="user$(shuf -i 1000-9999 -n 1)"
        password="$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-12)"
        
        # Get IP (round-robin)
        current_ip="${clean_ips[$ip_index]}"
        current_ip=$(echo "$current_ip" | tr -d '\r\n ')
        
        # Add user
        echo "${username}:CL:${password}" >> "$users_file"
        
        # Add proxy config
        if [[ "$proxy_type" == "s" ]]; then
            echo "auth strong" >> "$config_file"
            echo "allow $username" >> "$config_file"
            echo "socks -i$current_ip -p$port" >> "$config_file"
            echo "flush" >> "$config_file"
            echo "" >> "$config_file"
            echo "$current_ip:$port:$username:$password" >> "$proxy_list_file"
        else
            echo "auth strong" >> "$config_file"
            echo "allow $username" >> "$config_file"
            echo "proxy -a1 -n -i$current_ip -p$port" >> "$config_file"
            echo "flush" >> "$config_file"
            echo "" >> "$config_file"
            echo "$current_ip:$port:$username:$password" >> "$proxy_list_file"
        fi
        
        port=$((port + 1))
        ip_index=$(((ip_index + 1) % total_ips))
    done
    
    # Set permissions
    chmod 600 "$users_file"
    chown proxy:proxy "$users_file"
    
    # Open firewall ports
    open_firewall_ports "$start_port" "$end_port" "tcp"
    
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
    
    read -p "Başlangıç portu: " start_port
    read -p "Bitiş portu: " end_port
    read -p "Kullanıcı adı: " fixed_user
    read -p "Şifre: " fixed_pass
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
    
    # Read IPs
    mapfile -t ips < "$PROXY_LIST_FILE"
    total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        error "IP listesi boş"
        return 1
    fi
    
    log "Toplam IP sayısı: $total_ips"
    log "Port aralığı: $start_port-$end_port"
    
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
    
    port="$start_port"
    ip_index=0
    
    while [ "$port" -le "$end_port" ]; do
        # Get IP (round-robin)
        current_ip="${ips[$ip_index]}"
        current_ip=$(echo "$current_ip" | tr -d '\r\n ')
        
        # Add proxy config
        if [[ "$proxy_type" == "s" ]]; then
            echo "auth strong" >> "$config_file"
            echo "allow $fixed_user" >> "$config_file"
            echo "socks -i$current_ip -p$port" >> "$config_file"
            echo "flush" >> "$config_file"
            echo "" >> "$config_file"
            echo "$current_ip:$port:$fixed_user:$fixed_pass" >> "$proxy_list_file"
        else
            echo "auth strong" >> "$config_file"
            echo "allow $fixed_user" >> "$config_file"
            echo "proxy -a1 -n -i$current_ip -p$port" >> "$config_file"
            echo "flush" >> "$config_file"
            echo "" >> "$config_file"
            echo "$current_ip:$port:$fixed_user:$fixed_pass" >> "$proxy_list_file"
        fi
        
        port=$((port + 1))
        ip_index=$(((ip_index + 1) % total_ips))
    done
    
    # Set permissions
    chmod 600 "$users_file"
    chown proxy:proxy "$users_file"
    
    # Open firewall ports
    open_firewall_ports "$start_port" "$end_port" "tcp"
    
    # Create zip file
    create_proxy_zip "$proxy_list_file" "fixed"
    
    success "Sabit mod proxy'ler oluşturuldu"
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
    
    read -p "Başlangıç portu: " start_port
    read -p "Bitiş portu: " end_port
    read -p "HTTP (h) veya SOCKS5 (s) [h/s]: " proxy_type
    
    if [[ ! "$start_port" =~ ^[0-9]+$ ]] || [[ ! "$end_port" =~ ^[0-9]+$ ]]; then
        error "Geçersiz port numarası"
        return 1
    fi
    
    if [ "$start_port" -ge "$end_port" ]; then
        error "Başlangıç portu bitiş portundan küçük olmalı"
        return 1
    fi
    
    # Read IPs
    mapfile -t ips < "$PROXY_LIST_FILE"
    total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        error "IP listesi boş"
        return 1
    fi
    
    log "Toplam IP sayısı: $total_ips"
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
    
    port="$start_port"
    ip_index=0
    
    while [ "$port" -le "$end_port" ]; do
        # Get IP (round-robin)
        current_ip="${ips[$ip_index]}"
        current_ip=$(echo "$current_ip" | tr -d '\r\n ')
        
        # Add proxy config
        if [[ "$proxy_type" == "s" ]]; then
            echo "socks -i$current_ip -p$port" >> "$config_file"
            echo "$current_ip:$port" >> "$proxy_list_file"
        else
            echo "proxy -a1 -n -i$current_ip -p$port" >> "$config_file"
            echo "$current_ip:$port" >> "$proxy_list_file"
        fi
        
        port=$((port + 1))
        ip_index=$(((ip_index + 1) % total_ips))
    done
    
    # Open firewall ports
    open_firewall_ports "$start_port" "$end_port" "tcp"
    
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
    
    # Read IPs
    mapfile -t ips < "$PROXY_LIST_FILE"
    total_ips=${#ips[@]}
    
    if [ "$total_ips" -eq 0 ]; then
        error "IP listesi boş"
        return 1
    fi
    
    # Calculate maximum proxies (3 per IP)
    max_proxies=$((total_ips * 3))
    start_port=10000
    end_port=$((start_port + max_proxies - 1))
    
    log "Toplam IP sayısı: $total_ips"
    log "Maksimum proxy sayısı: $max_proxies"
    log "Port aralığı: $start_port-$end_port"
    
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
    
    port="$start_port"
    ip_index=0
    proxy_per_ip=0
    
    while [ "$port" -le "$end_port" ]; do
        # Get IP (3 proxies per IP)
        current_ip="${ips[$ip_index]}"
        current_ip=$(echo "$current_ip" | tr -d '\r\n ')
        
        if [[ "$auth_mode" == "r" ]]; then
            # Random credentials
            username="user$(shuf -i 1000-9999 -n 1)"
            password="$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-12)"
            echo "${username}:CL:${password}" >> "$users_file"
            echo "$current_ip:$port:$username:$password" >> "$proxy_list_file"
            
            echo "auth strong" >> "$config_file"
            echo "allow $username" >> "$config_file"
        elif [[ "$auth_mode" == "f" ]]; then
            # Fixed credentials
            if [ "$proxy_per_ip" -eq 0 ]; then
                echo "${fixed_user}:CL:${fixed_pass}" >> "$users_file"
            fi
            echo "$current_ip:$port:$fixed_user:$fixed_pass" >> "$proxy_list_file"
            
            echo "auth strong" >> "$config_file"
            echo "allow $fixed_user" >> "$config_file"
        else
            # Public
            echo "$current_ip:$port" >> "$proxy_list_file"
        fi
        
        # Add proxy config
        if [[ "$proxy_type" == "s" ]]; then
            echo "socks -i$current_ip -p$port" >> "$config_file"
        else
            echo "proxy -a1 -n -i$current_ip -p$port" >> "$config_file"
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
    
    # Open firewall ports
    open_firewall_ports "$start_port" "$end_port" "tcp"
    
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
        
        # Show listening ports
        log "Aktif portlar:"
        netstat -tlnp | grep 3proxy | head -10
    else
        error "Proxy başlatma başarısız"
        
        log "Servis durumu:"
        systemctl status 3proxy --no-pager
        
        log "Son 20 log satırı:"
        journalctl -u 3proxy -n 20 --no-pager
    fi
    
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
                        cp "3proxy-otomatik-master/3proxy_menu.sh" /usr/local/bin/3proxy-menu
                        chmod +x /usr/local/bin/3proxy-menu
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
    echo -e "${WHITE}Aktif Portlar:${NC}"
    netstat -tlnp 2>/dev/null | grep 3proxy | head -20 | while read line; do
        port=$(echo "$line" | awk '{print $4}' | cut -d':' -f2)
        echo -e "${GREEN}  Port: $port${NC}"
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
    rm -f /usr/local/bin/3proxy
    rm -f /usr/local/bin/3proxy-menu
    
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
