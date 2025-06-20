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
curl -s --user 'api:333f4afa3a817c2da82e7bb631689b9a-51afd2db-136e0eee' \
  https://api.mailgun.net/v3/sandbox6e276e9bcb654ba69089c91546916586.mailgun.org/messages \
  -F from='TMRW Automated AWS <postmaster@sandbox6e276e9bcb654ba69089c91546916586.mailgun.org>' \
  -F to='joshua@tachy.com.sg' \
  -F subject='V2Ray IP changed to $IP' \
  -F text="✅ V2Ray TCP was installed.\nIP: $IP\nPort: $PORT\nUUID: $UUID"
echo ""
echo "✅ V2Ray (TCP) installed and running"
echo "📡 Address: $IP"
echo "📦 Port: $PORT"
echo "🔐 UUID: $UUID"
echo "🌐 Network: tcp"
echo "🛡️ TLS: false"
