#!/usr/bin/env bash
# ── arjun  (Python 3.11) ────────────────────────────────────────────────────
# Runtime: python | Source: https://github.com/s0md3v/Arjun
# HTTP parameter discovery
set -euo pipefail

TOOL_NAME="arjun"
PYTHON_VERSION="3.11"
VENV_DIR="/opt/toolkit/venvs/${TOOL_NAME}"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Python ${PYTHON_VERSION})..."

uv python install "${PYTHON_VERSION}"
uv venv --python "${PYTHON_VERSION}" "${VENV_DIR}"
uv pip install --python "${VENV_DIR}/bin/python" arjun

printf '#!/usr/bin/env bash\nexec %s -m arjun "$@"\n' \
    "${VENV_DIR}/bin/python" \
    > "${BIN_DIR}/${TOOL_NAME}"
chmod +x "${BIN_DIR}/${TOOL_NAME}"

echo "[✓] ${TOOL_NAME} ready  →  arjun -u https://example.com/endpoint"
