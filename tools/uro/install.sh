#!/usr/bin/env bash
# ── uro  (Python 3.11) ──────────────────────────────────────────────────────
# Runtime: python | Source: https://github.com/s0md3v/uro
# Deduplica y reduce listas de URLs manteniendo cobertura de parámetros
set -euo pipefail

TOOL_NAME="uro"
PYTHON_VERSION="3.11"
VENV_DIR="/opt/toolkit/venvs/${TOOL_NAME}"
BIN_DIR="/opt/toolkit/bin"

echo "[+] Installing ${TOOL_NAME} (Python ${PYTHON_VERSION})..."

uv python install "${PYTHON_VERSION}"
uv venv --python "${PYTHON_VERSION}" "${VENV_DIR}"
uv pip install --python "${VENV_DIR}/bin/python" uro

printf '#!/usr/bin/env bash\nexec %s -m uro "$@"\n' \
    "${VENV_DIR}/bin/python" \
    > "${BIN_DIR}/${TOOL_NAME}"
chmod +x "${BIN_DIR}/${TOOL_NAME}"

echo "[✓] ${TOOL_NAME} ready  →  cat urls.txt | uro"
