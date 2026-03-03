#!/usr/bin/env bash
# ── nuclei  (Go binary) ─────────────────────────────────────────────────────
set -euo pipefail

TOOL_NAME="nuclei"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
cp "$(go env GOPATH)/bin/nuclei" "${BIN_DIR}/nuclei"

echo "[✓] ${TOOL_NAME} ready  →  nuclei -h"
