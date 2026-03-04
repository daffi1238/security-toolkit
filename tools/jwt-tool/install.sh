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
uv pip install --python "${VENV_DIR}/bin/python" jwcrypto

# Wrapper script
printf '#!/usr/bin/env bash
exec /opt/toolkit/venvs/jwt-tool/bin/python /opt/toolkit/tools/jwt-tool/src/jwt_tool.py "$@"
' > "${BIN_DIR}/jwt_tool"
chmod +x "${BIN_DIR}/jwt_tool"

# Initialize jwt_tool config and place default wordlist
mkdir -p /root/.jwt_tool
"${VENV_DIR}/bin/python" "${INSTALL_DIR}/jwt_tool.py" 2>/dev/null || true
cp "${INSTALL_DIR}/jwt-common.txt" /root/.jwt_tool/jwt-common.txt
# Wordlists are mounted via docker-compose volume, not baked into image

echo "[✓] ${TOOL_NAME} ready  →  jwt_tool <token>"
