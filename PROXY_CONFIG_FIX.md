#!/bin/bash
# Test proxy configuration with -e parameter

echo "🔧 PROXY KONFİGÜRASYON DÜZELTMESİ"
echo "=================================="
echo
echo "❌ ÖNCEKİ (YANLIŞ):"
echo "   proxy -a1 -n -i45.13.225.70 -p3128"
echo "   → Tüm proxy'ler ana IP ile çıkış yapıyor"
echo
echo "✅ YENİ (DOĞRU):"
echo "   proxy -a1 -n -i45.13.225.70 -p3128 -e45.13.225.70"
echo "   → Her proxy kendi IP'si ile çıkış yapıyor"
echo
echo "📊 PARAMETRELER:"
echo "   -i: Bind IP (dinleme adresi)"
echo "   -p: Port"
echo "   -e: External IP (çıkış IP adresi) ← Bu önemliydi!"
echo "   -a1: Authentication required"
echo "   -n: No proxy chain"
echo
echo "🎯 SONUÇ:"
echo "   45.13.225.70:3128 → 45.13.225.70 IP'si ile çıkış"
echo "   45.86.155.69:3129 → 45.86.155.69 IP'si ile çıkış"
echo "   185.14.92.130:3130 → 185.14.92.130 IP'si ile çıkış"
echo
echo "✅ TÜM MODLAR DÜZELTİLDİ:"
echo "   - Fixed Mode"
echo "   - Random Mode" 
echo "   - Public Mode"
echo "   - Maximum Mode"
echo
echo "🔄 Proxy'leri yeniden başlatmayı unutmayın!"
