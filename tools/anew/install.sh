#!/usr/bin/env bash
# ── anew  (Go binary) ───────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/tomnomnom/anew
# Appends unique lines to a file (deduplication in pipelines)
set -euo pipefail

TOOL_NAME="anew"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/tomnomnom/anew@latest
cp "$(go env GOPATH)/bin/anew" "${BIN_DIR}/anew"

echo "[✓] ${TOOL_NAME} ready  →  cat new.txt | anew existing.txt"
