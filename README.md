# 3proxy Elite Manager v2.2

**Ubuntu 20.04+ İçin Gelişmiş 3proxy Yönetim Sistemi - Tek Dosya + Proxy Doğrulama**

Bu script, Ubuntu 20.04+ işletim sistemlerinde çalışan kapsamlı bir 3proxy yönetim sistemidir. Sınırsız proxy oluşturma, çoklu mod desteği ve gelişmiş yönetim özellikleri sunar. Artık tüm sistem tek dosyada!

## 🚀 Özellikler

### ✅ **Temel Özellikler**
- **Tek Dosya Çözümü** - Tüm sistem tek script'te
- **Ubuntu 20.04+ Uyumluluğu** - Tam optimizasyon
- **Self-Installing** - Otomatik kurulum sistemi
- **Sınırsız Proxy Üretimi** - Port ve IP sınırı yok
- **Çoklu IPv4 Desteği** - Her proxy için ayrı IPv4 adresi
- **Elite Anonymous Proxy** - `-a1` ve `-n` parametreleri
- **Otomatik Güncelleme Kontrolü** - GitHub entegrasyonu
- **ZIP Şifreleme** - Proxy listelerini güvenli paylaşım

### 🔧 **Proxy Modları**
1. **Rastgele Mod** - Her port için benzersiz kullanıcı adı/şifre
2. **Sabit Mod** - Tüm portlar için aynı kullanıcı adı/şifre
3. **Public Mod** - Kimlik doğrulama gerektirmez
4. **Maksimum Mod** - IP başına 3 proxy (maksimum verimlilik)

### 🌐 **Desteklenen Protokoller**
- **HTTP Proxy** - Elite Anonymous seviye
- **SOCKS5 Proxy** - Yüksek performans
- **Karma Kurulum** - Aynı anda her iki protokol

### 🛠️ **Yönetim Özellikleri**
- **Port Aralığı Yönetimi** - Belirli portları durdurma
- **IP Adresi Silme** - Tek IPv4 adresini kaldırma
- **Canlı Sistem Monitoring** - Gerçek zamanlı durum takibi
- **Log Yönetimi** - Detaylı loglama sistemi
- **Konfigürasyon Yedekleme** - Otomatik yedek alma
- **🆕 Firewall Otomasyonu** - Otomatik port açma (UFW/iptables)
- **🆕 Akıllı Subnet Tespiti** - /23, /24, /22 otomatik tespit

## 📦 Kurulum

### 🎯 **Tek Komut Kurulum (Önerilen)**
```bash
# Script'i indir ve otomatik kurulum yap
wget https://raw.githubusercontent.com/muzaffer72/3proxy-otomatik/master/3proxy_menu.sh
chmod +x 3proxy_menu.sh
sudo ./3proxy_menu.sh --install
```

### 🖥️ **Manuel Kullanım**
```bash
# Script'i indir ve direkt menüyü başlat
wget https://raw.githubusercontent.com/muzaffer72/3proxy-otomatik/master/3proxy_menu.sh
chmod +x 3proxy_menu.sh
sudo ./3proxy_menu.sh
```

### 📂 **Repository'den Kurulum**
```bash
# Repository'yi klonla
git clone https://github.com/muzaffer72/3proxy-otomatik.git
cd 3proxy-otomatik
sudo ./3proxy_menu.sh --install
```

### 🎮 **Kurulum Sonrası Kullanım**
```bash
# Global komut olarak (kurulum sonrası)
sudo 3proxy-manager

# Veya doğrudan script ile
sudo /opt/3proxy-elite/3proxy_menu.sh
```

## 🎯 Kullanım

### Ana Menü Seçenekleri

```
 1. İlk Kurulum (3proxy ve bağımlılıklar)  # YENİ: Tek tıkla sistem kurulumu
 2. Proxy Listesi Oluştur/Düzenle         # YENİ: Kopyala-yapıştır ile IP girişi
 3. Proxy Listesini Sil                   # YENİ: IP listesini silme
 4. Rastgele Mod Proxy Oluştur
 5. Sabit Mod Proxy Oluştur
 6. Public Mod Proxy Oluştur
 7. Maksimum Proxy Modu
 8. Proxy'leri Başlat
 9. Proxy'leri Durdur
10. Proxy'leri Yeniden Başlat
11. Port Aralığını Durdur
12. Sunucudan IP Sil
13. Proxy Durumu Görüntüle
14. Firewall Durumu Kontrol Et       # YENİ: UFW/iptables durumu
15. Belirli Portları Aç              # YENİ: Manuel port açma
16. Güncellemeleri Kontrol Et
17. Log Görüntüle
18. Konfigürasyon Yönetimi
19. Proxy'leri Doğrula               # YENİ: Otomatik proxy testleri
20. 3proxy Kaldır
```

### 🆕 Gelişmiş Özellikler

#### **🔥 Otomatik Firewall Yönetimi**
- **UFW Desteği** - Ubuntu Firewall otomatik konfigürasyon
- **iptables Desteği** - Düşük seviye firewall kuralları  
- **Port Açma** - Proxy portları otomatik açılır
- **Durum Kontrol** - Firewall durumu görüntüleme

#### **🔍 Proxy Doğrulama Sistemi**
- **Otomatik Test** - Her proxy oluşturma sonrası test seçeneği
- **HTTP Kontrolü** - `http://httpbin.org/ip` ile gerçek IP kontrolü
- **Detaylı Rapor** - Başarı/başarısızlık oranları ve detaylar
- **Çoklu Format** - Authenticated ve public proxy testleri
- **Timeout Koruması** - 10 saniye timeout ile hızlı tespit

#### **🎯 Akıllı Subnet Tespiti**
Netplan dosyalarından subnet bilgisini otomatik tespit eder:
- **/24** - Standart subnet (256 IP)
- **/23** - Çift subnet (512 IP) 
- **/22** - Dörtlü subnet (1024 IP)
- **Otomatik Eşleme** - Mevcut IP'lerle subnet eşleştirme

### 🆕 Yeni Özellikler

#### **Akıllı IP Yönetimi**
- **Kopyala-Yapıştır IP Girişi** - Dosya yolu yerine doğrudan IP girişi
- **Otomatik IP Listesi** - `proxylistesi.txt` otomatik oluşturulur
- **Netplan Entegrasyonu** - IP'ler otomatik olarak netplan'a eklenir
- **IP Doğrulama** - Geçersiz IP formatları otomatik reddedilir

#### **Netplan Otomatik Konfigürasyonu**
Script, girilen IP adreslerini `/etc/netplan/*.yaml` dosyalarında kontrol eder:
- Eksik IP'ler otomatik olarak eklenir
- YAML syntax korunur
- Otomatik yedekleme
- `netplan apply` ile uygulama

### IP Listesi Oluşturma

Artık IP listesi için ayrı dosya oluşturmanıza gerek yok:

```bash
1. Ana menüden "2. Proxy Listesi Oluştur/Düzenle" seçin
2. IP'lerinizi subnet ile birlikte girin (önerilen):
   IP adresi: 45.90.98.32/23
   IP adresi: 176.100.39.59/24
   IP adresi: 185.14.92.130/24
   IP adresi: (boş bırakıp Enter = bitir)
3. Liste otomatik olarak /var/lib/3proxy/proxylistesi.txt'e kaydedilir
```

### 🔧 Subnet Formatları

**Desteklenen Subnet Türleri:**
```bash
# /24 subnet (256 IP)
192.168.1.100/24    # 192.168.1.1-192.168.1.254

# /23 subnet (512 IP) 
45.90.98.32/23      # 45.90.98.0-45.90.99.255

# /22 subnet (1024 IP)
185.14.92.0/22      # 185.14.92.0-185.14.95.255

# Subnet belirtmezseniz otomatik tespit edilir
192.168.1.100       # Netplan'dan tespit edilir
```

**Avantajlar:**
- ✅ **Kesin Doğruluk** - Subnet yanlış tespiti olmaz
- ✅ **Hızlı İşlem** - Otomatik tespit algoritması çalışmaz  
- ✅ **Esneklik** - Farklı subnet'ler karışık kullanılabilir
- ✅ **Güvenlik** - Network konfigürasyonu kesin kontrolde

### 🔧 Netplan Otomatik Entegrasyonu

Script, girilen IP adreslerini netplan konfigürasyonunda kontrol eder ve eksik olanları otomatik ekler:

**Örnek Netplan Dosyası (`/etc/netplan/01-netcfg.yaml`):**
```yaml
network:
    version: 2
    ethernets:
        eth0:
            match:
                macaddress: 4a:63:06:47:31:5e
            set-name: eth0
            addresses:
                - 45.13.225.70/24
                - 45.86.155.69/24
                - 185.14.92.130/24
                - 176.100.39.59/24
                - 176.100.36.39/24
                - 176.100.36.44/24
                - 45.90.98.32/23
                - 45.90.98.33/23
            nameservers:
                addresses:
                    - 1.1.1.1
                search:
                    - example.com
            routes:
                - to: 0.0.0.0/0
                  via: 45.13.225.1
```

**Otomatik İşlemler:**
1. ✅ Mevcut netplan dosyalarını tarar
2. ✅ Girilen IP'leri kontrol eder
3. ✅ Eksik IP'leri `addresses:` bölümüne ekler
4. ✅ Otomatik yedek oluşturur
5. ✅ YAML syntax'ını doğrular
6. ✅ `netplan apply` çalıştırır

### Kullanım Örnekleri

#### Rastgele Mod Proxy Oluşturma
1. Menu'den "2" seçin
2. IP listesi dosya yolunu girin: `/path/to/ips.txt`
3. Port aralığını belirleyin: `10000-10100`
4. Protokol seçin: `h` (HTTP) veya `s` (SOCKS5)

#### Maksimum Proxy Modu
Bu mod, her IP adresi için 3 proxy oluşturur:
- 4 IP adresi = 12 proxy
- Port aralığı otomatik belirlenir (10000'den başlar)

## 📋 Proxy Formatları

### Rastgele Mod Çıktısı
```
192.168.1.100:10000:user1234:pass5678
192.168.1.101:10001:user2345:pass6789
192.168.1.102:10002:user3456:pass7890
```

### Sabit Mod Çıktısı
```
192.168.1.100:10000:myuser:mypass
192.168.1.101:10001:myuser:mypass
192.168.1.102:10002:myuser:mypass
```

### Public Mod Çıktısı
```
192.168.1.100:10000
192.168.1.101:10001
192.168.1.102:10002
```

## 🔒 Güvenlik Özellikleri

### Elite Anonymous Proxy
- ✅ HTTP `Via` header gizleme
- ✅ `X-Forwarded-For` header gizleme
- ✅ `X-Real-IP` header gizleme
- ✅ İstemci IP'si gizleme (-n parametresi)
- ✅ İstemci bilgilerini rastgeleleştirme (-a1 parametresi)

### ZIP Şifreleme
- Proxy listeleri otomatik olarak şifrelenir
- Rastgele 16 karakter şifre üretimi
- `.info` dosyası ile şifre bilgisi

## 📊 Sistem Gereksinimleri

- **İşletim Sistemi**: Ubuntu 20.04+ (önerilen)
- **RAM**: Minimum 512MB
- **Disk**: 1GB boş alan
- **Network**: IPv4 adresleri
- **Gereksinimler**: Root erişimi

## 🔧 Gelişmiş Konfigürasyon

### Bellek Optimizasyonu
Script otomatik olarak sistem belleğini algılar:
- **<512MB**: Minimal konfigürasyon
- **512MB-1GB**: Optimized konfigürasyon  
- **>1GB**: Standard konfigürasyon

### Port Yönetimi
```bash
# Belirli port aralığını durdur
# Örnek: 1000-1500 arası tüm proxy'leri durdur
Menu seçeneği: 9
```

### IP Adresi Yönetimi
```bash
# Sunucudan IPv4 adresi sil
# Otomatik olarak ilgili proxy'ler güncellenir
Menu seçeneği: 10
```

## 📈 Monitoring ve Loglar

### Sistem Durumu
- Aktif proxy sayısı
- Port kullanım durumu
- Bellek ve disk kullanımı
- Servis durumu

### Log Dosyaları
- `/var/log/3proxy/menu.log` - Menu işlemleri
- `journalctl -u 3proxy` - Servis logları
- `/tmp/3proxy.log` - Runtime logları

## 🔄 Güncellemeler

Script otomatik olarak GitHub'dan güncellemeleri kontrol eder:
```bash
# Manuel güncelleme kontrolü
Menu seçeneği: 12
```

## 📞 Destek

### Test Komutları
```bash
# HTTP Proxy Test
curl -x kullanici:sifre@IP:PORT http://httpbin.org/ip

# SOCKS5 Proxy Test  
curl --socks5 kullanici:sifre@IP:PORT http://httpbin.org/ip

# Anonymous Test
curl -x kullanici:sifre@IP:PORT http://httpbin.org/headers
```

### Servis Yönetimi
```bash
# Systemd komutları
systemctl status 3proxy
systemctl restart 3proxy
systemctl stop 3proxy

# Manuel başlatma
/usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
```

## 📁 Dosya Konumları

```
/opt/3proxy/              # Script dosyaları
/etc/3proxy/              # Konfigürasyon dosyaları
/var/log/3proxy/          # Log dosyaları
/var/lib/3proxy/          # Proxy listeleri ve yedekler
/usr/local/3proxy/        # 3proxy binary dosyaları
```

## 🏆 Avantajlar

### ✅ **Neden Bu Script?**
- **Tek Tıkla Kurulum** - Karmaşık konfigürasyon gerektirmez
- **Sınırsız Ölçeklenebilirlik** - Binlerce proxy destekler
- **Otomatik Yönetim** - Sistem kendini yönetir
- **Enterprise Seviye** - Production ortamlar için uygun
- **Açık Kaynak** - Tam şeffaflık
- **Türkçe Destek** - Tam lokalizasyon

### 🎯 **Kullanım Alanları**
- Web scraping projeleri
- SEO araçları
- Veri toplama sistemleri
- Güvenlik testleri
- Anonymity araçları
- Load balancing

---

**Versiyon**: 2.0  
**Uyumluluk**: Ubuntu 20.04+  
**Lisans**: MIT  
**Geliştirici**: muzaffer72
