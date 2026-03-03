#!/usr/bin/env bash
###############################################################################
# Orchestrator: finds and runs every tools/*/install.sh
###############################################################################
set -euo pipefail

TOOLS_DIR="/opt/toolkit/tools"
FAILED=()

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  Security Toolkit - Installing tools..."
echo "══════════════════════════════════════════════════════════════"
echo ""

for installer in "${TOOLS_DIR}"/*/install.sh; do
    tool_name=$(basename "$(dirname "${installer}")")
    # Skip templates
    [[ "${tool_name}" == _* ]] && continue
    echo "────────────────────────────────────────────────────────────"
    echo "  ▶ ${tool_name}"
    echo "────────────────────────────────────────────────────────────"
    if bash "${installer}"; then
        echo ""
    else
        echo "[✗] FAILED: ${tool_name}"
        FAILED+=("${tool_name}")
        echo ""
    fi
done

echo "══════════════════════════════════════════════════════════════"
if [ ${#FAILED[@]} -eq 0 ]; then
    echo "  ✓ All tools installed successfully"
else
    echo "  ⚠ Failed: ${FAILED[*]}"
fi
echo "══════════════════════════════════════════════════════════════"
echo ""
