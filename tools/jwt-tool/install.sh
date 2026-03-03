#!/usr/bin/env bash
# ── jwt_tool  (Python 3.12) ─────────────────────────────────────────────────
set -euo pipefail

TOOL_NAME="jwt-tool"
PYTHON_VERSION="3.12"
REPO="https://github.com/ticarpi/jwt_tool.git"
INSTALL_DIR="/opt/toolkit/tools/${TOOL_NAME}/src"
VENV_DIR="/opt/toolkit/venvs/${TOOL_NAME}"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Python ${PYTHON_VERSION})..."

uv python install "${PYTHON_VERSION}"
git clone --depth 1 "${REPO}" "${INSTALL_DIR}"
uv venv --python "${PYTHON_VERSION}" "${VENV_DIR}"
uv pip install --python "${VENV_DIR}/bin/python" -r "${INSTALL_DIR}/requirements.txt"

# Wrapper script
printf '#!/usr/bin/env bash
exec /opt/toolkit/venvs/jwt-tool/bin/python /opt/toolkit/tools/jwt-tool/src/jwt_tool.py "$@"
' > "${BIN_DIR}/jwt-tool"
chmod +x "${BIN_DIR}/jwt-tool"

echo "[✓] ${TOOL_NAME} ready  →  jwt-tool <token>"
