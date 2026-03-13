#!/usr/bin/env bash
# ── interactsh-client  (Go binary) ──────────────────────────────────────────
# Runtime: go | Source: https://github.com/projectdiscovery/interactsh
# OOB interaction server para SSRF, XXE, RCE blind
set -euo pipefail

TOOL_NAME="interactsh-client"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
cp "$(go env GOPATH)/bin/interactsh-client" "${BIN_DIR}/interactsh-client"

echo "[✓] ${TOOL_NAME} ready  →  interactsh-client -v  (genera URL OOB)"
