#!/usr/bin/env bash
# ============================================================
# param_discovery.sh — Descubrimiento de parámetros HTTP ocultos
# Uso: param_discovery.sh -u <url_or_file> [-o output]
# ============================================================
set -euo pipefail

export PATH="/opt/toolkit/bin:$PATH"
WL_DIR="/opt/toolkit/wordlists"

TARGET=""
OUTPUT="params_$(date +%Y%m%d_%H%M).txt"

while getopts "u:o:" opt; do
    case $opt in
        u) TARGET="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
    esac
done

[ -z "$TARGET" ] && echo "Usage: $0 -u <url_or_file> [-o output]" && exit 1

echo "[*] Parameter Discovery — $TARGET"

# arjun
if command -v arjun &>/dev/null; then
    echo "[+] arjun..."
    if [ -f "$TARGET" ]; then
        arjun -i "$TARGET" -oT "${OUTPUT}.arjun" -t 10 2>/dev/null || true
    else
        arjun -u "$TARGET" -oT "${OUTPUT}.arjun" -t 10 2>/dev/null || true
    fi
fi

# ffuf param bruteforce
PARAM_WL="$WL_DIR/SecLists/Discovery/Web-Content/burp-parameter-names.txt"
[ ! -f "$PARAM_WL" ] && PARAM_WL="$WL_DIR/SecLists/Discovery/Web-Content/common.txt"

if command -v ffuf &>/dev/null && [ -f "$PARAM_WL" ]; then
    echo "[+] ffuf GET params..."
    url_target="$TARGET"
    [ -f "$TARGET" ] && url_target=$(head -1 "$TARGET")

    ffuf -u "${url_target}?FUZZ=test1337" \
        -w "$PARAM_WL" -fs 0 -mc all \
        -t 50 -rate 100 \
        -o "${OUTPUT}.ffuf.json" -of json -s 2>/dev/null || true
fi

echo "[+] Output: ${OUTPUT}*"
