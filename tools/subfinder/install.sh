#!/usr/bin/env bash
# ── subfinder  (Go binary) ──────────────────────────────────────────────────
set -euo pipefail

TOOL_NAME="subfinder"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
cp "$(go env GOPATH)/bin/subfinder" "${BIN_DIR}/subfinder"

echo "[✓] ${TOOL_NAME} ready  →  subfinder -h"
