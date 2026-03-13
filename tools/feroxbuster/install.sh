#!/usr/bin/env bash
# ── feroxbuster  (Rust binary) ──────────────────────────────────────────────
# Runtime: prebuilt binary | Source: https://github.com/epi052/feroxbuster
# Dirscan recursivo de alto rendimiento
set -euo pipefail

TOOL_NAME="feroxbuster"
BIN_DIR="/opt/toolkit/bin"
INSTALL_URL="https://github.com/epi052/feroxbuster/releases/latest/download/x86_64-linux-feroxbuster.zip"

echo "[+] Installing ${TOOL_NAME} (prebuilt binary)..."

TMP_DIR=$(mktemp -d)
curl -fsSL "${INSTALL_URL}" -o "${TMP_DIR}/feroxbuster.zip"
unzip -q "${TMP_DIR}/feroxbuster.zip" -d "${TMP_DIR}"
chmod +x "${TMP_DIR}/feroxbuster"
cp "${TMP_DIR}/feroxbuster" "${BIN_DIR}/feroxbuster"
rm -rf "${TMP_DIR}"

echo "[✓] ${TOOL_NAME} ready  →  feroxbuster -u https://example.com -w wordlist.txt"
