#!/usr/bin/env bash
# ── waybackurls  (Go binary) ────────────────────────────────────────────────
set -euo pipefail

TOOL_NAME="waybackurls"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install github.com/tomnomnom/waybackurls@latest
cp "$(go env GOPATH)/bin/waybackurls" "${BIN_DIR}/waybackurls"

echo "[✓] ${TOOL_NAME} ready  →  echo example.com | waybackurls"
