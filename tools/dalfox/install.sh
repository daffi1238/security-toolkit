#!/usr/bin/env bash
# ── dalfox  (Go binary) ─────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/hahwul/dalfox
# XSS scanner con parameter analysis
set -euo pipefail

TOOL_NAME="dalfox"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/hahwul/dalfox/v2@latest
cp "$(go env GOPATH)/bin/dalfox" "${BIN_DIR}/dalfox"

echo "[✓] ${TOOL_NAME} ready  →  dalfox url 'https://example.com/search?q=FUZZ'"
