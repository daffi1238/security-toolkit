#!/usr/bin/env bash
# ── dnsvalidator  (Python 3.12) ─────────────────────────────────────────────
# Runtime: python | Source: https://github.com/vortexau/dnsvalidator
set -euo pipefail

TOOL_NAME="dnsvalidator"
PYTHON_VERSION="3.12"
REPO="https://github.com/vortexau/dnsvalidator.git"
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

# 4. Install package
uv pip install --python "${VENV_DIR}/bin/python" "${INSTALL_DIR}"

# 5. Wrapper
printf '#!/usr/bin/env bash\nexec %s -m dnsvalidator "$@"\n' \
    "${VENV_DIR}/bin/python" \
    > "${BIN_DIR}/${TOOL_NAME}"
chmod +x "${BIN_DIR}/${TOOL_NAME}"

echo "[✓] ${TOOL_NAME} ready  →  dnsvalidator -h"
