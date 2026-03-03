#!/usr/bin/env bash
# ── TOOL_NAME  (Node.js) ────────────────────────────────────────────────────
set -euo pipefail

TOOL_NAME="CHANGE_ME"
NPM_PKG="CHANGE_ME"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Node.js)..."

npm install -g "${NPM_PKG}"

GLOBAL_BIN="$(npm root -g)/../bin/${TOOL_NAME}"
if [ -f "${GLOBAL_BIN}" ]; then
    ln -sf "${GLOBAL_BIN}" "${BIN_DIR}/${TOOL_NAME}"
fi

echo "[✓] ${TOOL_NAME} ready"
