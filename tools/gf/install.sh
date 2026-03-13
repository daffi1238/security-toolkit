#!/usr/bin/env bash
# ── gf  (Go binary) + patterns ──────────────────────────────────────────────
# Runtime: go | Source: https://github.com/tomnomnom/gf
# Grep patterns para filtrar URLs por tipo de vulnerabilidad
set -euo pipefail

TOOL_NAME="gf"
BIN_DIR="/opt/toolkit/bin"
PATTERNS_DIR="/root/.gf"

echo "[+] Installing ${TOOL_NAME} (Go)..."

go install -v github.com/tomnomnom/gf@latest
cp "$(go env GOPATH)/bin/gf" "${BIN_DIR}/gf"

# Install common patterns
mkdir -p "${PATTERNS_DIR}"

echo "[+] Cloning gf-patterns..."
git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns.git /tmp/gf-patterns
cp /tmp/gf-patterns/*.json "${PATTERNS_DIR}/" 2>/dev/null || true
rm -rf /tmp/gf-patterns

# Extra patterns from tomnomnom examples
cat > "${PATTERNS_DIR}/debug_logic.json" <<'EOF'
{
  "flags": "-iE",
  "patterns": [
    "debug=",
    "test=",
    "admin=",
    "dev=",
    "enable=",
    "disable=",
    "hidden="
  ]
}
EOF

echo "[✓] ${TOOL_NAME} ready  →  cat urls.txt | gf xss"
echo "    Patterns: $(ls ${PATTERNS_DIR}/*.json 2>/dev/null | wc -l) installed in ${PATTERNS_DIR}"
