#!/usr/bin/env bash
# ── gau  (Go binary) ────────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/lc/gau
set -euo pipefail

TOOL_NAME="gau"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/lc/gau/v2/cmd/gau@latest
cp "$(go env GOPATH)/bin/gau" "${BIN_DIR}/gau"

echo "[✓] ${TOOL_NAME} ready  →  gau --subs example.com"
