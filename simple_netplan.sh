#!/bin/bash
# Simple netplan update function

configure_netplan_simple() {
    echo "Basit netplan güncellemesi..."
    
    # Find primary netplan file
    primary_yaml=$(find /etc/netplan -name "*.yaml" 2>/dev/null | head -1)
    if [[ -z "$primary_yaml" ]]; then
        echo "Netplan dosyası bulunamadı"
        return 1
    fi
    
    # Backup
    backup_file="${primary_yaml}.backup.$(date +%s)"
    cp "$primary_yaml" "$backup_file"
    echo "Yedek: $backup_file"
    
    # Read missing IPs from user
    echo "Eklenecek IP'leri girin (subnet ile birlikte):"
    echo "Örnek: 192.168.1.100/24"
    echo "Bitirmek için boş satır girin"
    
    while true; do
        read -p "IP: " ip_input
        if [[ -z "$ip_input" ]]; then
            break
        fi
        
        # Add to file with simple echo
        if grep -q "addresses:" "$primary_yaml"; then
            echo "      - $ip_input" >> "$primary_yaml"
            echo "✅ $ip_input eklendi"
        else
            echo "❌ addresses bölümü bulunamadı"
        fi
    done
    
    # Test
    echo "Test ediliyor..."
    if netplan try --timeout=5; then
        echo "✅ Başarılı"
    else
        echo "❌ Hata - geri yükleniyor"
        cp "$backup_file" "$primary_yaml"
    fi
}

configure_netplan_simple
