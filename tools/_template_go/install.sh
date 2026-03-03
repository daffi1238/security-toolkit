#!/usr/bin/env bash
# ── TOOL_NAME  (Go) ─────────────────────────────────────────────────────────
# Runtime: go | Source: https://github.com/...
set -euo pipefail

TOOL_NAME="CHANGE_ME"
GO_PKG="github.com/OWNER/REPO/cmd/TOOL@latest"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v "${GO_PKG}"
cp "$(go env GOPATH)/bin/${TOOL_NAME}" "${BIN_DIR}/${TOOL_NAME}"

echo "[✓] ${TOOL_NAME} ready"
