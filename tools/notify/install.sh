#!/usr/bin/env bash
# ── notify  (Go binary) ─────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/projectdiscovery/notify
# Envía alertas a Slack/Telegram/Discord desde pipelines
set -euo pipefail

TOOL_NAME="notify"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/projectdiscovery/notify/cmd/notify@latest
cp "$(go env GOPATH)/bin/notify" "${BIN_DIR}/notify"

echo "[✓] ${TOOL_NAME} ready  →  echo 'vuln found' | notify"
echo "    Config: ~/.config/notify/provider-config.yaml"
