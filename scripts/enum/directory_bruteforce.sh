#!/usr/bin/env bash
# ============================================================
# directory_bruteforce.sh — Content discovery sobre hosts vivos
# Uso: directory_bruteforce.sh -l <live_hosts.txt> [-o <dir>] [-t threads]
# ============================================================
set -euo pipefail

export PATH="/opt/toolkit/bin:$PATH"
WL_DIR="/opt/toolkit/wordlists"

HOSTS_FILE=""
OUT_DIR="./dirscan_$(date +%Y%m%d_%H%M)"
THREADS=40

while getopts "l:o:t:" opt; do
    case $opt in
        l) HOSTS_FILE="$OPTARG" ;;
        o) OUT_DIR="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
    esac
done

[ -z "$HOSTS_FILE" ] && echo "Usage: $0 -l <live_hosts.txt> [-o output_dir] [-t threads]" && exit 1
mkdir -p "$OUT_DIR"

# Wordlist priority
WL=""
for candidate in \
    "$WL_DIR/onelistforallmicro.txt" \
    "$WL_DIR/SecLists/Discovery/Web-Content/raft-medium-directories.txt" \
    "$WL_DIR/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt" \
    "$WL_DIR/SecLists/Discovery/Web-Content/common.txt"
do
    [ -f "$candidate" ] && WL="$candidate" && break
done

[ -z "$WL" ] && echo "[-] No wordlist found in $WL_DIR. Run wordlists/download.sh first." && exit 1

echo "[*] Wordlist: $WL"
echo "[*] Scanning $(wc -l < "$HOSTS_FILE") hosts..."

while IFS= read -r host; do
    [ -z "$host" ] && continue
    safe_name=$(echo "$host" | sed 's|https\?://||' | tr '/:' '__')

    if command -v feroxbuster &>/dev/null; then
        feroxbuster \
            --url "$host" --wordlist "$WL" \
            --threads "$THREADS" --depth 2 \
            --status-codes 200,201,204,301,302,307,401,403,405 \
            --output "$OUT_DIR/${safe_name}.txt" --silent --no-recursion \
            2>/dev/null || true
    else
        ffuf -u "${host}/FUZZ" -w "$WL" \
            -t "$THREADS" -mc 200,201,204,301,302,307,401,403,405 \
            -o "$OUT_DIR/${safe_name}.json" -of json -s \
            2>/dev/null || true
    fi

    echo "[+] Done: $host"
done < "$HOSTS_FILE"

echo "[+] Results in: $OUT_DIR"
