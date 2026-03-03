#!/usr/bin/env bash
# ── TOOL_NAME  (Python X.Y) ─────────────────────────────────────────────────
# Runtime: python | Source: https://github.com/...
set -euo pipefail

TOOL_NAME="CHANGE_ME"
PYTHON_VERSION="3.12"
REPO="https://github.com/OWNER/REPO.git"
INSTALL_DIR="/opt/toolkit/tools/${TOOL_NAME}/src"
VENV_DIR="/opt/toolkit/venvs/${TOOL_NAME}"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Python ${PYTHON_VERSION})..."

# 1. Ensure Python version
uv python install "${PYTHON_VERSION}"

# 2. Clone
git clone --depth 1 "${REPO}" "${INSTALL_DIR}"

# 3. Isolated venv
uv venv --python "${PYTHON_VERSION}" "${VENV_DIR}"

# 4. Dependencies
uv pip install --python "${VENV_DIR}/bin/python" -r "${INSTALL_DIR}/requirements.txt"

# 5. Wrapper  (edit the entrypoint as needed)
printf '#!/usr/bin/env bash\nexec %s %s "$@"\n' \
    "${VENV_DIR}/bin/python" "${INSTALL_DIR}/main.py" \
    > "${BIN_DIR}/${TOOL_NAME}"
chmod +x "${BIN_DIR}/${TOOL_NAME}"

echo "[✓] ${TOOL_NAME} ready"
