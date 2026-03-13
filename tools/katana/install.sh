#!/usr/bin/env bash
# ── katana  (Go binary) ─────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/projectdiscovery/katana
set -euo pipefail

TOOL_NAME="katana"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/projectdiscovery/katana/cmd/katana@latest
cp "$(go env GOPATH)/bin/katana" "${BIN_DIR}/katana"

echo "[✓] ${TOOL_NAME} ready  →  katana -u https://example.com -depth 3"
