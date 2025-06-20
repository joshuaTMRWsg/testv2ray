#!/bin/bash

set -e

UUID="0cc977b0-3266-4434-9588-b8c3bb609daa"
PORT=10086
WS_PATH="/v2ray"

apt update && apt install -y curl unzip uuid-runtime

bash <(curl -s -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

cat <<EOF > /usr/local/etc/v2ray/config.json
{
  "inbounds": [{
    "port": $PORT,
    "protocol": "vmess",
    "settings": {
      "clients": [{
        "id": "$UUID",
        "alterId": 0
      }]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "$WS_PATH"
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
EOF

systemctl daemon-reexec
systemctl restart v2ray
systemctl enable v2ray

IP=$(curl -s ifconfig.me)
echo ""
echo "✅ V2Ray installed and running."
echo "🔐 UUID: $UUID"
echo "🌐 Address: $IP"
echo "📦 Port: $PORT"
echo "🛣️ Path: $WS_PATH"
echo "🔗 TLS: false"
echo "📡 Network: websocket"
