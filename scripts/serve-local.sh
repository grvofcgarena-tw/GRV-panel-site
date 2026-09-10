#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${GRV_JSORG_PORT:-8090}"
HOST="${GRV_JSORG_HOST:-127.0.0.1}"

command -v python3 >/dev/null 2>&1 || { echo '找不到 python3；請在執行環境安裝 Python 3。' >&2; exit 1; }

cd "$ROOT"
printf '[GRV-js.org] 本地靜態站：http://%s:%s\n' "$HOST" "$PORT"
printf '[GRV-js.org] 根目錄：%s\n' "$ROOT"
exec python3 -m http.server "$PORT" --bind "$HOST"
