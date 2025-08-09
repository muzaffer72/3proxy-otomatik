# 3proxy Elite Anonymous Proxy Installer

简单有效的3proxy精英级高匿名代理一键安装脚本。

## 特性

- ✅ **精英级高匿名代理** - 使用`-a1 -n`参数确保无VIA和X-Forwarded头部
- ✅ **一键安装** - 自动检测环境、编译、安装、配置
- ✅ **固定认证** - 用户名: neonlink, 密码: meshnova
- ✅ **多协议支持** - HTTP(3128)、SOCKS5(1080)、Web管理(8080)
- ✅ **跨平台兼容** - 支持Ubuntu、CentOS、Alpine等

## 使用方法

```bash
# 下载并执行
curl -sL https://raw.githubusercontent.com/Deroino/3proxy-installer/master/install_3proxy.sh | sudo bash

# 或者手动下载
wget https://raw.githubusercontent.com/Deroino/3proxy-installer/master/install_3proxy.sh
chmod +x install_3proxy.sh
sudo ./install_3proxy.sh
```

## 代理配置

安装完成后可使用以下配置：

- **HTTP代理**: `YOUR_SERVER_IP:3128`
- **SOCKS5代理**: `YOUR_SERVER_IP:1080` 
- **Web管理界面**: `YOUR_SERVER_IP:8080`

**认证信息**:
- 用户名: `neonlink`
- 密码: `meshnova`

## 使用示例

```bash
# HTTP代理测试
curl -x neonlink:meshnova@YOUR_SERVER_IP:3128 http://httpbin.org/ip

# SOCKS5代理测试
curl --socks5 neonlink:meshnova@YOUR_SERVER_IP:1080 http://httpbin.org/ip

# 匿名性测试
curl -x neonlink:meshnova@YOUR_SERVER_IP:3128 http://httpbin.org/headers
```

## 管理命令

```bash
# 服务控制
systemctl start 3proxy
systemctl stop 3proxy
systemctl restart 3proxy
systemctl status 3proxy

# 配置文件
/etc/3proxy/3proxy.cfg                  # 主配置
/usr/local/3proxy/conf/3proxy.cfg       # 详细配置
/usr/local/3proxy/conf/passwd           # 用户认证
```

## 高匿名特性

- ✅ 启用`-a1`参数（随机化客户端信息）
- ✅ 启用`-n`参数（无日志记录客户端IP）
- ✅ 无HTTP_VIA头部
- ✅ 无HTTP_X_FORWARDED_FOR头部
- ✅ 精英级高匿名代理