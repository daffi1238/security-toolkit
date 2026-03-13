#!/usr/bin/env bash
# ============================================================
# recon.sh — Reconocimiento automatizado para Bug Bounty
# Uso: recon.sh -d target.com [-o output_dir] [-q]
# Ejecutar dentro del container: docker compose run --rm toolkit
# ============================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[+]${NC} $(date '+%H:%M:%S') $*"; }
info() { echo -e "${BLUE}[*]${NC} $(date '+%H:%M:%S') $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $(date '+%H:%M:%S') $*"; }

TOOLKIT_BIN="/opt/toolkit/bin"
export PATH="$TOOLKIT_BIN:$PATH"

WL_DIR="/opt/toolkit/wordlists"
RESOLVERS="$WL_DIR/resolvers.txt"
THREADS=50
RATE_LIMIT=150

TARGET=""
OUT_DIR=""
QUICK=false

usage() {
    echo "Usage: $0 -d <domain> [-o <output_dir>] [-q (quick mode)]"
    exit 1
}

while getopts "d:o:qh" opt; do
    case $opt in
        d) TARGET="$OPTARG" ;;
        o) OUT_DIR="$OPTARG" ;;
        q) QUICK=true ;;
        h|*) usage ;;
    esac
done

[ -z "$TARGET" ] && usage

DATE=$(date '+%Y%m%d_%H%M')
OUT_DIR="${OUT_DIR:-/workspace/$TARGET/$DATE}"
mkdir -p "$OUT_DIR"/{subdomains,ports,http,urls,vulns,js}

LOGFILE="$OUT_DIR/recon.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo -e "\n${GREEN}============================================"
echo "  RECON: $TARGET"
echo "  Output: $OUT_DIR"
echo -e "============================================${NC}\n"

# ─── 1. Subdomains ────────────────────────────────────────────
info "STEP 1 — Subdomain Enumeration"

# Passive: subfinder
subfinder -d "$TARGET" -silent -all -recursive \
    -o "$OUT_DIR/subdomains/subfinder.txt" 2>/dev/null || true

# Passive + Active: amass (skip en quick mode)
if ! $QUICK; then
    amass enum -passive -d "$TARGET" \
        -o "$OUT_DIR/subdomains/amass.txt" 2>/dev/null || true
fi

# Certificate Transparency: crt.sh
curl -s "https://crt.sh/?q=%25.$TARGET&output=json" 2>/dev/null | \
    jq -r '.[].name_value' 2>/dev/null | \
    sed 's/\*\.//g' | sort -u \
    > "$OUT_DIR/subdomains/crtsh.txt" || true

# DNS bruteforce: alterx + dnsx
if [ -f "$RESOLVERS" ]; then
    echo "$TARGET" | alterx -silent 2>/dev/null | \
        dnsx -silent -r "$RESOLVERS" 2>/dev/null \
        > "$OUT_DIR/subdomains/alterx_dns.txt" || true
fi

# Merge + resolve
cat "$OUT_DIR/subdomains/"*.txt 2>/dev/null | sort -u \
    > "$OUT_DIR/subdomains/all_subs.txt"

dnsx -l "$OUT_DIR/subdomains/all_subs.txt" \
    -silent ${RESOLVERS:+-r "$RESOLVERS"} \
    -o "$OUT_DIR/subdomains/resolved.txt" 2>/dev/null || \
    cp "$OUT_DIR/subdomains/all_subs.txt" "$OUT_DIR/subdomains/resolved.txt"

ok "Subdomains found: $(wc -l < "$OUT_DIR/subdomains/resolved.txt")"

# ─── 2. Port Scanning ─────────────────────────────────────────
info "STEP 2 — Port Scanning"

naabu -l "$OUT_DIR/subdomains/resolved.txt" \
    -top-ports 1000 -silent -rate "$RATE_LIMIT" \
    -o "$OUT_DIR/ports/naabu_top1000.txt" 2>/dev/null || true

if [ -s "$OUT_DIR/ports/naabu_top1000.txt" ]; then
    cut -d: -f1 "$OUT_DIR/ports/naabu_top1000.txt" | sort -u \
        > "$OUT_DIR/ports/hosts.txt"
    nmap -sV -sC --open -iL "$OUT_DIR/ports/hosts.txt" \
        -oA "$OUT_DIR/ports/nmap_svc" --min-rate 1000 2>/dev/null || true
fi

# ─── 3. HTTP Probing ──────────────────────────────────────────
info "STEP 3 — HTTP Probing"

httpx -l "$OUT_DIR/subdomains/resolved.txt" \
    -silent -status-code -title -tech-detect -content-length \
    -follow-redirects -rate-limit "$RATE_LIMIT" -threads "$THREADS" \
    -json -o "$OUT_DIR/http/httpx_full.json" \
    -o "$OUT_DIR/http/live_hosts.txt" 2>/dev/null || true

jq -r '.url' "$OUT_DIR/http/httpx_full.json" 2>/dev/null | sort -u \
    > "$OUT_DIR/http/urls.txt" || \
    cp "$OUT_DIR/http/live_hosts.txt" "$OUT_DIR/http/urls.txt" 2>/dev/null || true

ok "Live hosts: $(wc -l < "$OUT_DIR/http/urls.txt" 2>/dev/null || echo 0)"

# ─── 4. URL Collection ────────────────────────────────────────
info "STEP 4 — URL Collection"

gau --threads 5 --subs "$TARGET" 2>/dev/null | sort -u \
    > "$OUT_DIR/urls/gau.txt" || true

echo "$TARGET" | waybackurls 2>/dev/null | sort -u \
    > "$OUT_DIR/urls/wayback.txt" || true

if ! $QUICK && [ -s "$OUT_DIR/http/urls.txt" ]; then
    katana -list "$OUT_DIR/http/urls.txt" \
        -silent -depth 3 -js-crawl -concurrency "$THREADS" \
        -o "$OUT_DIR/urls/katana.txt" 2>/dev/null || true
fi

cat "$OUT_DIR/urls/"*.txt 2>/dev/null | sort -u > "$OUT_DIR/urls/all_urls.txt"
uro -i "$OUT_DIR/urls/all_urls.txt" -o "$OUT_DIR/urls/all_urls_uro.txt" 2>/dev/null || \
    cp "$OUT_DIR/urls/all_urls.txt" "$OUT_DIR/urls/all_urls_uro.txt"

ok "URLs collected: $(wc -l < "$OUT_DIR/urls/all_urls.txt" 2>/dev/null || echo 0)"

# ─── 5. JS Analysis ───────────────────────────────────────────
info "STEP 5 — JS Analysis"

grep -E "\.js(\?|$)" "$OUT_DIR/urls/all_urls.txt" 2>/dev/null | sort -u \
    > "$OUT_DIR/js/js_urls.txt" || true

if [ -s "$OUT_DIR/js/js_urls.txt" ]; then
    mkdir -p "$OUT_DIR/js/files"
    while IFS= read -r url; do
        fname=$(echo "$url" | md5sum | cut -d' ' -f1)
        curl -s -L --max-time 10 "$url" -o "$OUT_DIR/js/files/${fname}.js" 2>/dev/null || true
    done < "$OUT_DIR/js/js_urls.txt"

    grep -rhoE "(\/[a-zA-Z0-9_\-\/\.]{4,})" "$OUT_DIR/js/files/" 2>/dev/null | \
        sort -u > "$OUT_DIR/js/endpoints.txt" || true

    grep -rhoE "(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][^'\"]{8,}['\"]" \
        "$OUT_DIR/js/files/" 2>/dev/null > "$OUT_DIR/js/potential_secrets.txt" || true
fi

# ─── 6. GF Pattern Matching ───────────────────────────────────
info "STEP 6 — GF Pattern Matching"

if [ -s "$OUT_DIR/urls/all_urls_uro.txt" ]; then
    for pattern in xss sqli ssrf redirect lfi rce idor debug_logic; do
        gf "$pattern" < "$OUT_DIR/urls/all_urls_uro.txt" \
            > "$OUT_DIR/urls/gf_${pattern}.txt" 2>/dev/null || true
        count=$(wc -l < "$OUT_DIR/urls/gf_${pattern}.txt" 2>/dev/null || echo 0)
        [ "$count" -gt 0 ] && ok "  gf $pattern: $count URLs"
    done
fi

# ─── 7. Nuclei ────────────────────────────────────────────────
info "STEP 7 — Nuclei"

if [ -s "$OUT_DIR/http/urls.txt" ]; then
    nuclei -l "$OUT_DIR/http/urls.txt" \
        -severity critical,high \
        -silent -rate-limit "$RATE_LIMIT" -concurrency "$THREADS" \
        -json -o "$OUT_DIR/vulns/nuclei_critical_high.json" 2>/dev/null || true

    nuclei -l "$OUT_DIR/http/urls.txt" \
        -tags exposure,misconfig,default-login \
        -silent -rate-limit "$RATE_LIMIT" \
        -json -o "$OUT_DIR/vulns/nuclei_exposures.json" 2>/dev/null || true
fi

# ─── Summary ──────────────────────────────────────────────────
echo -e "\n${GREEN}============================================"
echo "  SUMMARY — $TARGET  ($(date '+%Y-%m-%d %H:%M'))"
echo "============================================${NC}"
printf "  %-30s %s\n" "Subdomains (resolved):" "$(wc -l < "$OUT_DIR/subdomains/resolved.txt" 2>/dev/null || echo 0)"
printf "  %-30s %s\n" "Live HTTP hosts:"       "$(wc -l < "$OUT_DIR/http/urls.txt" 2>/dev/null || echo 0)"
printf "  %-30s %s\n" "URLs collected:"        "$(wc -l < "$OUT_DIR/urls/all_urls.txt" 2>/dev/null || echo 0)"
printf "  %-30s %s\n" "JS endpoints:"          "$(wc -l < "$OUT_DIR/js/endpoints.txt" 2>/dev/null || echo 0)"
printf "  %-30s %s\n" "Potential secrets:"     "$(wc -l < "$OUT_DIR/js/potential_secrets.txt" 2>/dev/null || echo 0)"
echo ""
echo "  Output: $OUT_DIR"
echo ""
[ -s "$OUT_DIR/js/potential_secrets.txt" ] && \
    warn "POTENTIAL SECRETS — review $OUT_DIR/js/potential_secrets.txt"
