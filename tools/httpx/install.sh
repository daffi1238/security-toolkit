#!/usr/bin/env bash
# ── httpx  (Go binary) ──────────────────────────────────────────────────────
set -euo pipefail

TOOL_NAME="httpx"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
cp "$(go env GOPATH)/bin/httpx" "${BIN_DIR}/httpx"

echo "[✓] ${TOOL_NAME} ready  →  httpx -h"
