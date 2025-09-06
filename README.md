Gönderdiğiniz metin, "3proxy Elite Anonymous Proxy Installer" adlı bir betiğin Çince hazırlanmış dokümantasyonudur. Bu betik, yüksek anonimliğe sahip bir proxy sunucusunu tek komutla kurmayı amaçlıyor.

İşte metnin Türkçe çevirisi:

-----

### **3proxy Elit Anonim Proxy Kurulum Betiği**

Basit ve etkili, elit seviye yüksek anonimliğe sahip bir 3proxy kurulum betiği.

#### **Özellikler**

  * ✅ **Elit Seviye Yüksek Anonimlik** - `-a1` ve `-n` parametrelerini kullanarak **VIA** ve **X-Forwarded** başlıklarının gönderilmemesini sağlar.
  * ✅ **Tek Tıkla Kurulum** - Ortamı otomatik olarak algılar, derler, kurar ve yapılandırır.
  * ✅ **Sabit Kimlik Doğrulama** - Kullanıcı adı: `neonlink`, şifre: `meshnova`.
  * ✅ **Çoklu Protokol Desteği** - HTTP (3128), SOCKS5 (1080) ve Web Yönetim (8080) portlarını destekler.
  * ✅ **Platformlar Arası Uyumluluk** - Ubuntu, CentOS, Alpine gibi işletim sistemlerini destekler.

#### **Kullanım Yöntemleri**

```bash
# İndir ve Çalıştır
curl -sL https://raw.githubusercontent.com/muzaffer72/3proxy-otomatik/master/install_3proxy.sh | sudo bash

# Veya Manuel İndir
wget https://raw.githubusercontent.com/muzaffer72/3proxy-otomatik/master/install_3proxy.sh
chmod +x install_3proxy.sh
sudo ./install_3proxy.sh
```

#### **Proxy Yapılandırması**

Kurulum tamamlandıktan sonra aşağıdaki ayarları kullanabilirsiniz:

  * **HTTP Proxy**: `SUNUCU_IP_ADRESINIZ:3128`
  * **SOCKS5 Proxy**: `SUNUCU_IP_ADRESINIZ:1080`
  * **Web Yönetim Arayüzü**: `SUNUCU_IP_ADRESINIZ:8080`

**Kimlik Doğrulama Bilgileri**:

  * Kullanıcı Adı: `onvaonet`
  * Şifre: `onvaonet`

#### **Kullanım Örnekleri**

```bash
# HTTP Proxy Testi
curl -x onvaonet:onvaonet@SUNUCU_IP_ADRESINIZ:3128 http://httpbin.org/ip

# SOCKS5 Proxy Testi
curl --socks5  onvaonet:onvaonet@SUNUCU_IP_ADRESINIZ:1080 http://httpbin.org/ip

# Anonimlik Testi
curl -x  onvaonet:onvaonet@SUNUCU_IP_ADRESINIZ:3128 http://httpbin.org/headers
```

#### **Yönetim Komutları**

```bash
# Servis Kontrolü
systemctl start 3proxy
systemctl stop 3proxy
systemctl restart 3proxy
systemctl status 3proxy

# Yapılandırma Dosyaları
/etc/3proxy/3proxy.cfg                  # Ana yapılandırma
/usr/local/3proxy/conf/3proxy.cfg       # Detaylı yapılandırma
/usr/local/3proxy/conf/passwd           # Kullanıcı kimlik doğrulama
```

#### **Yüksek Anonimlik Özellikleri**

  * ✅ `-a1` parametresi etkinleştirilmiştir (istemci bilgilerini rastgeleleştirir).
  * ✅ `-n` parametresi etkinleştirilmiştir (istemci IP'sinin loglanmasını engeller).
  * ✅ HTTP **VIA** başlığı yoktur.
  * ✅ HTTP **X-FORWARDED\_FOR** başlığı yoktur.
  * ✅ Elit seviye yüksek anonim proxy sağlar.
