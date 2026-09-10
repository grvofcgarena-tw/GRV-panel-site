#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOMAIN="${TUNNEL_DOMAIN:-grv-panel.js.org}"
PORT="${GRV_JSORG_PORT:-8090}"
TUNNEL_NAME="${CLOUDFLARED_TUNNEL_NAME:?請設定 CLOUDFLARED_TUNNEL_NAME}"
TOKEN="${CLOUDFLARED_TUNNEL_TOKEN:-}"
CREDENTIALS_FILE="${CLOUDFLARED_CREDENTIALS_FILE:-}"
CONFIG_FILE="${CLOUDFLARED_CONFIG:-$HOME/.cloudflared/grv-jsorg.yml}"

command -v cloudflared >/dev/null 2>&1 || { echo '找不到原生 Termux cloudflared' >&2; exit 1; }

if [ -z "$TOKEN" ] && [ -z "$CREDENTIALS_FILE" ]; then
  echo '請設定 CLOUDFLARED_TUNNEL_TOKEN 或 CLOUDFLARED_CREDENTIALS_FILE' >&2
  exit 1
fi
if [ -n "$CREDENTIALS_FILE" ] && [ ! -r "$CREDENTIALS_FILE" ]; then
  echo "找不到 Tunnel credentials: $CREDENTIALS_FILE" >&2
  exit 1
fi

mkdir -p "$(dirname "$CONFIG_FILE")"
umask 077
cat > "$CONFIG_FILE" <<EOF
protocol: http2
no-autoupdate: true
connectTimeout: 10s
keepAliveConnections: 8
keepAliveTimeout: 30s
ingress:
  - hostname: $DOMAIN
    service: http://127.0.0.1:$PORT
  - service: http_status:404
EOF

if [ -n "$CREDENTIALS_FILE" ]; then
  printf 'tunnel: %s\ncredentials-file: %s\n' "$TUNNEL_NAME" "$CREDENTIALS_FILE" >> "$CONFIG_FILE"
fi
chmod 600 "$CONFIG_FILE"

printf '[GRV-js.org] Tunnel：%s\n' "$DOMAIN"
printf '[GRV-js.org] Origin：http://127.0.0.1:%s\n' "$PORT"
if [ -n "$TOKEN" ]; then
  exec cloudflared tunnel --config "$CONFIG_FILE" run --token "$TOKEN"
else
  exec cloudflared tunnel --config "$CONFIG_FILE" run "$TUNNEL_NAME"
fi
