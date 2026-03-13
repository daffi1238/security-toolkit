#!/usr/bin/env bash
# ── naabu  (Go binary) ──────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/projectdiscovery/naabu
set -euo pipefail

TOOL_NAME="naabu"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

apt-get install -y --no-install-recommends libpcap-dev 2>/dev/null || true
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
cp "$(go env GOPATH)/bin/naabu" "${BIN_DIR}/naabu"

echo "[✓] ${TOOL_NAME} ready  →  naabu -host example.com -top-ports 1000"
