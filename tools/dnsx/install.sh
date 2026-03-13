#!/usr/bin/env bash
# ── dnsx  (Go binary) ───────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/projectdiscovery/dnsx
set -euo pipefail

TOOL_NAME="dnsx"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
cp "$(go env GOPATH)/bin/dnsx" "${BIN_DIR}/dnsx"

echo "[✓] ${TOOL_NAME} ready  →  echo example.com | dnsx -silent"
