#!/usr/bin/env bash
# ============================================================
# github_recon.sh — GitHub dorking para secrets y código expuesto
# Uso: github_recon.sh -t <target> [-k <github_token>]
# ============================================================
TARGET=""
TOKEN="${GITHUB_TOKEN:-}"

while getopts "t:k:" opt; do
    case $opt in
        t) TARGET="$OPTARG" ;;
        k) TOKEN="$OPTARG" ;;
    esac
done

[ -z "$TARGET" ] && echo "Usage: $0 -t <target_company_or_domain> [-k github_token]" && exit 1
[ -z "$TOKEN" ]  && echo "[!] No GITHUB_TOKEN set — rate limiting will apply (10 req/min)"

OUT_DIR="/workspace/github_recon_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUT_DIR"

HEADERS=(-H "Accept: application/vnd.github.v3+json")
[ -n "$TOKEN" ] && HEADERS+=(-H "Authorization: token $TOKEN")

declare -a DORKS=(
    "$TARGET password"
    "$TARGET secret"
    "$TARGET api_key OR apikey"
    "$TARGET token"
    "$TARGET credentials"
    "$TARGET internal"
    "org:${TARGET} filename:.env"
    "org:${TARGET} filename:config.php"
    "org:${TARGET} filename:database.yml"
    "org:${TARGET} extension:pem"
    "org:${TARGET} password"
    "org:${TARGET} secret"
)

echo "[*] GitHub Recon — $TARGET"
echo "[*] Output: $OUT_DIR"

for dork in "${DORKS[@]}"; do
    safe_name=$(echo "$dork" | tr ' ' '_' | tr '/:' '__' | cut -c1-60)
    echo "[*] Querying: $dork"

    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$dork'))")
    curl -s "${HEADERS[@]}" \
        "https://api.github.com/search/code?q=${encoded}&per_page=100" \
        -o "$OUT_DIR/${safe_name}.json" 2>/dev/null || true

    sleep 3   # Evitar rate limit
done

echo ""
echo "[+] Resultados con hits:"
for f in "$OUT_DIR"/*.json; do
    count=$(python3 -c "import json,sys; d=json.load(open('$f')); print(d.get('total_count',0))" 2>/dev/null || echo 0)
    [ "$count" -gt 0 ] && echo "  ${count} hits — $(basename "$f" .json)"
done

echo ""
echo "[!] Revisar manualmente en https://github.com/search?type=code los dorks con hits"
echo ""
echo "Dorks adicionales para búsqueda manual:"
printf '  site:github.com "%s" extension:env\n' "$TARGET"
printf '  site:github.com "%s" filename:*.pem\n' "$TARGET"
printf '  site:github.com "org:%s" "BEGIN RSA PRIVATE KEY"\n' "$TARGET"
