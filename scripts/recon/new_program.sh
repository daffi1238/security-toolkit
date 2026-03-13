#!/usr/bin/env bash
# ============================================================
# new_program.sh — Inicializa workspace para un nuevo programa
# Uso: new_program.sh <program_name> [platform]
# Output: /workspace/<program_name>/
# ============================================================
PROGRAM="$1"
PLATFORM="${2:-hackerone}"

[ -z "$PROGRAM" ] && echo "Usage: $0 <program_name> [platform]" && exit 1

PROG_DIR="/workspace/$PROGRAM"
mkdir -p "$PROG_DIR"/{recon,scope,notes,exploits,reports,screenshots}

cat > "$PROG_DIR/scope/scope.txt" <<EOF
# Scope — $PROGRAM ($PLATFORM)
# +*.target.com   → in scope
# -out.target.com → out of scope

# IN SCOPE

# OUT OF SCOPE
EOF

cat > "$PROG_DIR/notes/checklist.md" <<'EOF'
# Bug Bounty Checklist

## Reconocimiento
- [ ] Subdomain enumeration (subfinder, amass, crt.sh)
- [ ] DNS bruteforce (alterx + dnsx)
- [ ] Port scanning (naabu + nmap)
- [ ] HTTP probing (httpx)
- [ ] URL collection (gau, waybackurls, katana)
- [ ] JS analysis (endpoints, secrets)
- [ ] GitHub recon (dorking por org)
- [ ] Shodan / Censys

## Superficie
- [ ] Tecnologías + versiones con CVEs
- [ ] Admin panels / login pages
- [ ] API docs (swagger, graphql introspection)
- [ ] OAuth / SSO flows
- [ ] File upload endpoints
- [ ] Webhooks / callbacks
- [ ] Mobile app (si aplica)

## Vulnerabilidades
### Críticas
- [ ] IDOR / BOLA en todas las entidades
- [ ] SSRF (params, headers, webhooks, imports)
- [ ] SQLi (manual + sqlmap)
- [ ] RCE (template injection, file upload, deserialization)
- [ ] Auth bypass / JWT issues
- [ ] XXE

### Altas
- [ ] XSS stored
- [ ] CORS misconfiguration
- [ ] Business logic (precios, race conditions)
- [ ] Mass Assignment

### Misconfigs / Exposures
- [ ] Secrets en JS / repos GitHub
- [ ] Subdomain takeover
- [ ] S3 / GCS / Azure blob público
- [ ] Directory listing
- [ ] Backup files (.bak, .zip, .old)
- [ ] Debug endpoints
- [ ] Default credentials
- [ ] Security headers faltantes

## Pre-report
- [ ] Bug reproducible confirmado
- [ ] Dentro del scope
- [ ] Impacto documentado con PoC
- [ ] No es duplicado
EOF

echo "[+] Program initialized: $PROG_DIR"
echo "[+] Edit scope:     vim $PROG_DIR/scope/scope.txt"
echo "[+] Run recon:      recon.sh -d target.com"
echo "[+] Check list:     cat $PROG_DIR/notes/checklist.md"
