#!/usr/bin/env bash
# ============================================================
# download.sh — Descarga wordlists en ./wordlists/
# Ejecutar desde el HOST (no el container), una sola vez
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WL_DIR="$SCRIPT_DIR"

ok()   { echo "[+] $*"; }
warn() { echo "[!] $*"; }

# SecLists (~500MB)
if [ ! -d "$WL_DIR/SecLists" ]; then
    ok "Cloning SecLists..."
    git clone --depth=1 https://github.com/danielmiessler/SecLists.git "$WL_DIR/SecLists"
else
    warn "SecLists already exists — skipping"
fi

# onelistforallmicro — balanced dirscan list
if [ ! -f "$WL_DIR/onelistforallmicro.txt" ]; then
    ok "Downloading onelistforallmicro.txt..."
    curl -fsSL "https://raw.githubusercontent.com/six2dez/OneListForAll/main/onelistforallmicro.txt" \
        -o "$WL_DIR/onelistforallmicro.txt"
fi

# DNS resolvers
if [ ! -f "$WL_DIR/resolvers.txt" ]; then
    ok "Downloading resolvers.txt..."
    curl -fsSL "https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt" \
        -o "$WL_DIR/resolvers.txt"
fi

# JWT common secrets (para jwt-tool)
if [ ! -f "$WL_DIR/jwt-common.txt" ]; then
    ok "Downloading jwt-common.txt..."
    curl -fsSL "https://raw.githubusercontent.com/wallarm/jwt-secrets/master/jwt.secrets.list" \
        -o "$WL_DIR/jwt-common.txt"
fi

ok "Wordlists ready in $WL_DIR"
du -sh "$WL_DIR"/* 2>/dev/null | sort -h
