#!/usr/bin/env bash
# ── step-cli  (Binary) ────────────────────────────────────────────────────────
# Runtime: prebuilt binary | Source: https://github.com/smallstep/cli
# Provides: step crypto commands for key generation, JWT signing, JWK/PEM, etc.
set -euo pipefail

TOOL_NAME="step"
VERSION="0.28.6"
BIN_DIR="/opt/toolkit/bin"
ARCH="amd64"

echo "[+] Installing ${TOOL_NAME} v${VERSION}..."

curl -fsSL "https://github.com/smallstep/cli/releases/download/v${VERSION}/step_linux_${VERSION}_${ARCH}.tar.gz" \
    | tar -xz --strip-components=2 -C /tmp "step_${VERSION}/bin/step"

mv /tmp/step "${BIN_DIR}/${TOOL_NAME}"
chmod +x "${BIN_DIR}/${TOOL_NAME}"

echo "[✓] ${TOOL_NAME} ready  →  step crypto --help"
