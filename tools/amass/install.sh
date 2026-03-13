#!/usr/bin/env bash
# ── amass  (Go binary) ──────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/owasp-amass/amass
set -euo pipefail

TOOL_NAME="amass"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/owasp-amass/amass/v4/...@master
cp "$(go env GOPATH)/bin/amass" "${BIN_DIR}/amass"

echo "[✓] ${TOOL_NAME} ready  →  amass enum -d example.com"
