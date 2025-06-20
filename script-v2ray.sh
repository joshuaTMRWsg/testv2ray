#!/bin/bash

set -e

UUID="0cc977b0-3266-4434-9588-b8c3bb609daa"
PORT=10086

# Install dependencies
apt update && apt install -y curl unzip uuid-runtime

# Install V2Ray
bash <(curl -s -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

# Create V2Ray config with TCP
cat <<EOF > /usr/local/etc/v2ray/config.json
{
  "inbounds": [{
    "port": $PORT,
    "listen": "0.0.0.0",
    "protocol": "vmess",
    "settings": {
      "clients": [{
        "id": "$UUID",
        "alterId": 0
      }]
    },
    "streamSettings": {
      "network": "tcp"
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
EOF

# Start and enable V2Ray
systemctl daemon-reexec
systemctl restart v2ray
systemctl enable v2ray

# Allow port in UFW
if command -v ufw >/dev/null 2>&1; then
  ufw allow $PORT/tcp
  ufw reload
fi

# Show connection info
IP=$(curl -s ifconfig.me)
echo ""
echo "✅ V2Ray (TCP) installed and running"
echo "📡 Address: $IP"
echo "📦 Port: $PORT"
echo "🔐 UUID: $UUID"
echo "🌐 Network: tcp"
echo "🛡️ TLS: false"
