#!/bin/bash
# 3proxy Elite Anonymous Proxy - One-Click Installer
# Simple and effective installation script

set -e

# Configuration
PROXY_USER="neonlink"
PROXY_PASS="meshnova"
VERSION="0.9.3"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }

# Check root
[[ $EUID -eq 0 ]] || error "Run as root: sudo $0"

log "Installing dependencies..."
if command -v apt >/dev/null; then
    apt update -qq && apt install -y wget curl gcc make build-essential procps net-tools
elif command -v yum >/dev/null; then
    yum install -y wget curl gcc make glibc-devel procps-ng net-tools
elif command -v apk >/dev/null; then
    apk update && apk add --no-cache wget curl gcc make musl-dev procps net-tools
else
    error "Unsupported package manager"
fi

log "Downloading and compiling 3proxy..."
cd /tmp
wget -q "https://github.com/3proxy/3proxy/archive/${VERSION}.tar.gz"
tar -xzf "${VERSION}.tar.gz"
cd "3proxy-${VERSION}"

# Enable anonymous proxy support
echo '#define ANONYMOUS 1' >> src/proxy.h

# Compile
make -f Makefile.Linux || make -f Makefile.unix || make

log "Installing 3proxy..."
mkdir -p /usr/local/3proxy/{bin,conf,logs,count}
mkdir -p /etc/3proxy /var/run/3proxy

cp bin/* /usr/local/3proxy/bin/
ln -sf /usr/local/3proxy/bin/3proxy /usr/local/bin/3proxy

# Create user
id proxy >/dev/null 2>&1 || useradd -r -s /bin/false proxy

log "Creating configuration..."
# Main config
cat > /etc/3proxy/3proxy.cfg << 'EOF'
#!/usr/local/bin/3proxy
daemon
pidfile /var/run/3proxy/3proxy.pid
chroot /usr/local/3proxy proxy proxy
include /conf/3proxy.cfg
EOF

# Detailed config with ELITE ANONYMOUS settings
cat > /usr/local/3proxy/conf/3proxy.cfg << 'EOF'
nscache 65536
nserver 8.8.8.8
log /logs/3proxy-%y%m%d.log D
rotate 30
users $/conf/passwd
auth strong
deny * * 127.0.0.1
allow *
proxy -a1 -n -p3128
socks -p1080
flush
allow *
admin -p8080
EOF

# User credentials
echo "${PROXY_USER}:CL:${PROXY_PASS}" > /usr/local/3proxy/conf/passwd
touch /usr/local/3proxy/conf/{counters,bandlimiters}

# Set permissions
chown -R proxy:proxy /usr/local/3proxy /var/run/3proxy
chmod 600 /usr/local/3proxy/conf/passwd

# Detect init system and start service
detect_init_system() {
    if [ -f /.dockerenv ] || [ -f /proc/1/cgroup ] && grep -q docker /proc/1/cgroup; then
        echo "container"
    elif command -v systemctl >/dev/null 2>&1 && systemctl --version >/dev/null 2>&1; then
        echo "systemd"
    elif [ -d /etc/init.d ]; then
        echo "sysv"
    else
        echo "manual"
    fi
}

INIT_SYSTEM=$(detect_init_system)
log "Detected init system: $INIT_SYSTEM"

case "$INIT_SYSTEM" in
    "systemd")
        log "Creating systemd service..."
        cat > /etc/systemd/system/3proxy.service << 'EOF'
[Unit]
Description=3proxy Elite Anonymous Proxy
After=network.target

[Service]
Type=forking
User=root
ExecStart=/usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
PIDFile=/var/run/3proxy/3proxy.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable 3proxy
        systemctl start 3proxy
        ;;
        
    "sysv")
        log "Creating SysV init script..."
        cat > /etc/init.d/3proxy << 'EOF'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          3proxy
# Required-Start:    $network $local_fs
# Required-Stop:     $network $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       3proxy proxy server
### END INIT INFO

DAEMON=/usr/local/bin/3proxy
CONFIG=/etc/3proxy/3proxy.cfg
PIDFILE=/var/run/3proxy/3proxy.pid

case "$1" in
    start)
        echo "Starting 3proxy..."
        $DAEMON $CONFIG
        ;;
    stop)
        echo "Stopping 3proxy..."
        if [ -f $PIDFILE ]; then
            kill $(cat $PIDFILE)
            rm -f $PIDFILE
        fi
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
EOF
        chmod +x /etc/init.d/3proxy
        /etc/init.d/3proxy start
        # Try to add to startup
        if command -v update-rc.d >/dev/null 2>&1; then
            update-rc.d 3proxy defaults
        elif command -v chkconfig >/dev/null 2>&1; then
            chkconfig --add 3proxy
            chkconfig 3proxy on
        fi
        ;;
        
    "container"|"manual")
        log "Container/Manual mode - Starting 3proxy directly..."
        # Create startup script
        cat > /usr/local/bin/start-3proxy.sh << 'EOF'
#!/bin/bash
# 3proxy startup script for containers
cd /usr/local/3proxy
exec /usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
EOF
        chmod +x /usr/local/bin/start-3proxy.sh
        
        # Start in background
        nohup /usr/local/bin/start-3proxy.sh > /tmp/3proxy.log 2>&1 &
        
        echo
        echo "📋 Container Management Commands:"
        echo "  Start:   nohup /usr/local/bin/start-3proxy.sh > /tmp/3proxy.log 2>&1 &"
        echo "  Stop:    pkill -f 3proxy"
        echo "  Status:  pgrep -f 3proxy"
        echo "  Logs:    tail -f /tmp/3proxy.log"
        ;;
esac

# Wait and verify
sleep 2
if pgrep -f "3proxy" >/dev/null; then
    log "✅ 3proxy Elite Anonymous Proxy installed successfully!"
    echo
    echo "🌐 Proxy Configuration:"
    echo "  HTTP:  YOUR_SERVER_IP:3128"
    echo "  SOCKS: YOUR_SERVER_IP:1080"
    echo "  Admin: YOUR_SERVER_IP:8080"
    echo
    echo "🔐 Credentials:"
    echo "  Username: ${PROXY_USER}"
    echo "  Password: ${PROXY_PASS}"
    echo
    echo "✨ Elite Features:"
    echo "  ✅ High Anonymous (-a1)"
    echo "  ✅ No HTTP_VIA header"
    echo "  ✅ No X-Forwarded headers"
    echo
    echo "📋 Usage:"
    echo "  curl -x ${PROXY_USER}:${PROXY_PASS}@YOUR_IP:3128 http://httpbin.org/ip"
else
    error "Installation failed - 3proxy not running"
fi