#!/usr/bin/env bash
# ── sqlmap  (Python 3.11) ───────────────────────────────────────────────────
set -euo pipefail

TOOL_NAME="sqlmap"
PYTHON_VERSION="3.11"
REPO="https://github.com/sqlmapproject/sqlmap.git"
INSTALL_DIR="/opt/toolkit/tools/${TOOL_NAME}/src"
VENV_DIR="/opt/toolkit/venvs/${TOOL_NAME}"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Python ${PYTHON_VERSION})..."

uv python install "${PYTHON_VERSION}"
git clone --depth 1 "${REPO}" "${INSTALL_DIR}"
uv venv --python "${PYTHON_VERSION}" "${VENV_DIR}"

printf '#!/usr/bin/env bash
exec /opt/toolkit/venvs/sqlmap/bin/python /opt/toolkit/tools/sqlmap/src/sqlmap.py "$@"
' > "${BIN_DIR}/sqlmap"
chmod +x "${BIN_DIR}/sqlmap"

echo "[✓] ${TOOL_NAME} ready  →  sqlmap -h"
