#!/usr/bin/env bash
set -euo pipefail

# Run this script in native Termux, not inside proot.
DOMAIN_MAIN="${GRV_MAIN_DOMAIN:-grvffws.dpdns.org}"
DOMAIN_JSORG="${GRV_JSORG_DOMAIN:-grv-panel.js.org}"
MAIN_PORT="${GRV_MAIN_PORT:-5000}"
JSORG_PORT="${GRV_JSORG_PORT:-8090}"
TUNNEL_NAME="${CLOUDFLARED_TUNNEL_NAME:?請設定 CLOUDFLARED_TUNNEL_NAME}"
TOKEN="${CLOUDFLARED_TUNNEL_TOKEN:-}"
CREDENTIALS_FILE="${CLOUDFLARED_CREDENTIALS_FILE:-}"
CA_FILE="${TLS_CA_FILE:-$HOME/GRV-panel/certs/grvffws.dpdns.org/ca.pem}"
CONFIG_FILE="${CLOUDFLARED_CONFIG:-$HOME/.cloudflared/grv-grv-panel.yml}"

command -v cloudflared >/dev/null 2>&1 || { echo '找不到原生 Termux cloudflared' >&2; exit 1; }
[ -n "$TOKEN" ] || [ -n "$CREDENTIALS_FILE" ] || { echo '請設定 CLOUDFLARED_TUNNEL_TOKEN 或 CLOUDFLARED_CREDENTIALS_FILE' >&2; exit 1; }
[ -n "$TOKEN" ] || [ -r "$CREDENTIALS_FILE" ] || { echo "找不到 Tunnel credentials: $CREDENTIALS_FILE" >&2; exit 1; }
[ -r "$CA_FILE" ] || { echo "找不到 proot Node origin CA: $CA_FILE" >&2; exit 1; }

# Validate the private Node origin certificate from native Termux.
CERT_FILE="${TLS_CERT_FILE:-$HOME/GRV-panel/certs/grvffws.dpdns.org/fullchain.pem}"
[ -r "$CERT_FILE" ] || { echo "找不到 Node origin certificate: $CERT_FILE" >&2; exit 1; }
openssl verify -CAfile "$CA_FILE" "$CERT_FILE" >/dev/null || { echo 'Node origin CA 與 certificate 不匹配' >&2; exit 1; }

mkdir -p "$(dirname "$CONFIG_FILE")"
umask 077
cat > "$CONFIG_FILE" <<EOF
protocol: http2
no-autoupdate: true
connectTimeout: 10s
keepAliveConnections: 8
keepAliveTimeout: 30s
ingress:
  - hostname: $DOMAIN_MAIN
    service: https://127.0.0.1:$MAIN_PORT
    originRequest:
      originServerName: $DOMAIN_MAIN
      caPool: $CA_FILE
      httpHostHeader: $DOMAIN_MAIN
  - hostname: $DOMAIN_JSORG
    service: http://127.0.0.1:$JSORG_PORT
  - service: http_status:404
EOF

if [ -n "$CREDENTIALS_FILE" ]; then
  printf 'tunnel: %s\ncredentials-file: %s\n' "$TUNNEL_NAME" "$CREDENTIALS_FILE" >> "$CONFIG_FILE"
fi
chmod 600 "$CONFIG_FILE"
printf '[GRV] %s -> https://127.0.0.1:%s\n' "$DOMAIN_MAIN" "$MAIN_PORT"
printf '[JS.ORG] %s -> http://127.0.0.1:%s\n' "$DOMAIN_JSORG" "$JSORG_PORT"
if [ -n "$TOKEN" ]; then
  exec cloudflared tunnel --config "$CONFIG_FILE" run --token "$TOKEN"
else
  exec cloudflared tunnel --config "$CONFIG_FILE" run "$TUNNEL_NAME"
fi
