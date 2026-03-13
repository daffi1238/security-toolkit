# Security Toolkit

Contenedor Docker modular para Bug Bounty y pentesting web.
Cada herramienta corre en su propio entorno aislado (venv via **uv**, binario Go, o binario precompilado).

## Inicio rápido

```bash
# 1. Wordlists (solo la primera vez, desde el host)
bash wordlists/download.sh

# 2. Construir imagen
docker compose build

# 3. Shell interactivo con todo listo
docker compose run --rm toolkit

# Dentro del container:
new_program.sh target_name hackerone    # init workspace
recon.sh -d target.com                  # recon completo
recon.sh -d target.com -q              # modo rápido (sin amass/crawl)
tools                                   # listar binarios disponibles
```

## Arquitectura

```
security-toolkit/
├── Dockerfile
├── docker-compose.yml
│
├── tools/                      ← un install.sh por herramienta
│   ├── nuclei/
│   ├── subfinder/
│   ├── httpx/
│   ├── amass/
│   ├── naabu/
│   ├── katana/
│   ├── dnsx/
│   ├── alterx/
│   ├── gau/
│   ├── anew/
│   ├── dalfox/
│   ├── gf/                     ← + patterns xss, sqli, ssrf, etc.
│   ├── interactsh/
│   ├── notify/
│   ├── feroxbuster/
│   ├── ffuf/
│   ├── waybackurls/
│   ├── sqlmap/
│   ├── jwt-tool/
│   ├── arjun/
│   ├── uro/
│   ├── dnsvalidator/
│   └── step-cli/
│
├── scripts/
│   ├── install-all.sh          ← orquestador (Dockerfile)
│   ├── entrypoint.sh
│   ├── bashrc.sh
│   ├── recon/
│   │   ├── recon.sh            ← recon completo automatizado
│   │   └── new_program.sh      ← init workspace por programa
│   ├── enum/
│   │   ├── directory_bruteforce.sh
│   │   ├── param_discovery.sh
│   │   └── github_recon.sh
│   └── exploit/
│       ├── ssrf_check.sh
│       └── xss_scan.sh
│
├── methodology/
│   └── methodology.md          ← metodología completa 7 fases
│
├── templates/
│   ├── report_template.md      ← plantilla de reporte
│   └── scope_analysis.md       ← análisis de scope
│
├── wordlists/                  ← persistido como volumen
│   └── download.sh             ← descarga SecLists, resolvers, etc.
│
└── workspace/                  ← persistido como volumen
    └── <program>/              ← creado por new_program.sh
        ├── recon/
        ├── scope/
        ├── notes/
        ├── exploits/
        └── reports/
```

## Herramientas disponibles

| Herramienta | Tipo | Uso |
|-------------|------|-----|
| subfinder | Go | Subdomain discovery pasivo |
| amass | Go | Subdomain + ASN discovery |
| dnsx | Go | DNS resolution masiva |
| alterx | Go | DNS bruteforce permutaciones |
| naabu | Go | Port scanner rápido |
| httpx | Go | HTTP probing + fingerprint |
| katana | Go | Web crawler activo |
| gau | Go | URLs desde archivos web (gau) |
| waybackurls | Go | URLs desde Wayback Machine |
| nuclei | Go | Vulnerability scanner plantillas |
| ffuf | Go | Fuzzer HTTP (dirs, params) |
| feroxbuster | Rust | Dirscan recursivo rápido |
| dalfox | Go | XSS scanner |
| gf | Go | Filtro URLs por patrón de vuln |
| anew | Go | Deduplicación en pipelines |
| interactsh-client | Go | Callbacks OOB (SSRF/XXE/blind) |
| notify | Go | Alertas Slack/Telegram/Discord |
| sqlmap | Python | SQL injection |
| arjun | Python | HTTP parameter discovery |
| uro | Python | URL deduplication inteligente |
| jwt-tool | Python | JWT analysis y ataques |
| dnsvalidator | Python | Validación de resolvers DNS |
| step-cli | Go | Herramientas PKI/TLS |

## Añadir una herramienta nueva

```bash
# Go
cp -r tools/_template_go tools/mi-tool
vim tools/mi-tool/install.sh   # editar TOOL_NAME y GO_PKG
docker compose build

# Python
cp -r tools/_template_python tools/mi-tool
vim tools/mi-tool/install.sh   # editar TOOL_NAME, PYTHON_VERSION, REPO
docker compose build
```

## Flujo Bug Bounty típico

```bash
# Host: descargar wordlists (una vez)
bash wordlists/download.sh

# Host: construir / actualizar imagen
docker compose build

# Entrar al container
docker compose run --rm toolkit

# Container: inicializar programa
new_program.sh shopify hackerone

# Container: recon completo
recon.sh -d shopify.com

# Container: dirscan sobre vivos
directory_bruteforce.sh -l /workspace/shopify.com/TIMESTAMP/http/urls.txt

# Container: OOB para SSRF
interactsh-client -v &   # genera URL OOB en segundo plano
ssrf_check.sh -l /workspace/shopify.com/TIMESTAMP/urls/all_urls_uro.txt \
              -c <interactsh_url>

# Container: XSS sobre candidatos gf
xss_scan.sh -l /workspace/shopify.com/TIMESTAMP/urls/gf_xss.txt
```

## Variables de entorno opcionales

```bash
# ~/.bashrc del HOST — para pasar al container vía env_file o -e
GITHUB_TOKEN=ghp_xxx          # github_recon.sh (rate limit sin token: 10 req/min)
NOTIFY_SLACK_WEBHOOK=https://... # notificaciones
```

## Notas

- `workspace/` y `wordlists/` persisten entre sesiones via volúmenes Docker.
- Los scripts en `scripts/recon|enum|exploit/` se montan como volumen → editable sin rebuild.
- `network_mode: host` activo — el container comparte red del host (necesario para naabu, etc.).
- Templates `_template_*` en `tools/` se ignoran automáticamente en `install-all.sh`.
