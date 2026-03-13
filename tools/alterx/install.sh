#!/usr/bin/env bash
# ── alterx  (Go binary) ─────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/projectdiscovery/alterx
set -euo pipefail

TOOL_NAME="alterx"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
cp "$(go env GOPATH)/bin/alterx" "${BIN_DIR}/alterx"

echo "[✓] ${TOOL_NAME} ready  →  echo example.com | alterx | dnsx"
