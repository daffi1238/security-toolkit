#!/usr/bin/env bash
# ── ffuf  (Go binary) ─────────────────────────────────────────────────────────
set -euo pipefail

TOOL_NAME="ffuf"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/ffuf/ffuf/v2@latest
cp "$(go env GOPATH)/bin/ffuf" "${BIN_DIR}/ffuf"

echo "[✓] ${TOOL_NAME} ready  →  ffuf -h"
