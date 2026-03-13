# Bug Bounty Methodology

> Metodología personal — combina recon a gran escala con auditoría detallada por objetivo.
> Actualizado: 2026-03-13

---

## Filosofía

1. **Recon primero, atacar después.** No lances exploits sin entender la superficie.
2. **Amplitud + profundidad.** Cubrir todo el scope superficialmente primero, luego foco en lo más interesante.
3. **Manual > automatizado para alta severidad.** Nuclei encuentra misconfigs; los bugs críticos los encuentras tú.
4. **Documenta todo.** Capturas, requests/responses, notas de razonamiento.

---

## Flujo General

```
TARGET DEFINED
     │
     ▼
[1] RECON PASIVO          → No tocas el target
     │
     ▼
[2] RECON ACTIVO          → Primera interacción
     │
     ▼
[3] MAPEO DE SUPERFICIE   → Entiendes la app
     │
     ▼
[4] AUDITORÍA MANUAL      → Buscas vulns reales
     │
     ▼
[5] AUTOMATIZACIÓN        → Nuclei, dalfox, sqlmap en candidatos
     │
     ▼
[6] VERIFICACIÓN          → Confirmas y documentas
     │
     ▼
[7] REPORTE               → Escribes el informe
```

---

## FASE 1: Recon Pasivo

**Objetivo:** Máxima información sin tocar el target.

### Subdomains
```bash
subfinder -d target.com -silent -all
# crt.sh: https://crt.sh/?q=%.target.com&output=json
# dnsdumpster, rapiddns, hackertarget
```

### OSINT
- **Google Dorks:**
  ```
  site:target.com filetype:pdf
  site:target.com inurl:admin
  site:target.com ext:env OR ext:log OR ext:sql
  site:target.com "internal use only"
  site:*.target.com -www
  ```
- **GitHub:**
  ```
  target.com password
  target.com api_key
  org:targetorg filename:.env
  ```
- **Shodan/Censys:** `org:"Target Corp"` — IPs, certificados, puertos
- **FOFA:** alternativa gratuita para Asia/Europa
- **LinkedIn:** tecnologías en job postings → stack tech
- **Wayback Machine:** URLs históricas, parámetros deprecated

### ASN & IP Ranges
```bash
# Buscar en whois/BGP
whois -h whois.radb.net '!gAS12345'
# Herramientas: amass intel, bgp.he.net
```

---

## FASE 2: Recon Activo

**Objetivo:** Confirmar lo que existe y ampliar superficie.

```bash
# DNS bruteforce
alterx -d target.com | dnsx -r resolvers.txt

# Port scan (rápido primero)
naabu -l resolved_subs.txt -top-ports 1000

# HTTP probing
httpx -l resolved.txt -sc -title -tech-detect -json

# URL collection
gau --subs target.com | uro > urls_dedup.txt
waybackurls target.com >> urls_dedup.txt
katana -u https://target.com -depth 3 -js-crawl
```

### Qué buscar en httpx output:
- Subdominios con tecnologías antiguas (Struts, Spring Boot actuator, etc.)
- Paneles de admin (Jenkins, Kibana, Grafana, Jira)
- Errores verbose con stack traces
- Subdominios con IPs internas → posible takeover o SSRF

---

## FASE 3: Mapeo de Superficie

**Para cada aplicación web interesante:**

### 3.1 Fingerprinting
- Tecnologías (Wappalyzer, whatweb, httpx -tech-detect)
- Versiones → buscar CVEs en nvd.nist.gov / exploit-db
- WAF detection: `wafw00f https://target.com`

### 3.2 Estructura de la Aplicación
- Autenticación: ¿OAuth? ¿SSO? ¿Magic links?
- Roles: ¿multi-tenant? ¿usuario/admin/superadmin?
- APIs: REST/GraphQL/SOAP — buscar `/api/`, `/graphql`, `/swagger.json`
- Funciones críticas: pagos, subida de archivos, exportación de datos

### 3.3 Análisis de JS
```bash
# Extraer endpoints de JS
grep -rhoE "(\/api\/[a-zA-Z0-9_\-\/]+)" *.js

# Buscar secrets
grep -rhoE "(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][^'\"]{8,}['\"]" *.js

# Linkfinder
python3 linkfinder.py -i https://target.com/app.js -o cli
```

---

## FASE 4: Auditoría Manual

### Prioridad de Vulnerabilidades (ROI vs esfuerzo)

| Vuln | P99 Impacto | Dificultad | Donde buscar |
|------|-------------|------------|--------------|
| IDOR/BOLA | Crítica | Baja | Todos los IDs en requests |
| SSRF | Crítica | Media | URL params, webhooks, imports |
| SQLi | Crítica | Media-Alta | Todos los params |
| RCE via upload | Crítica | Alta | File upload, templates |
| Auth bypass | Crítica | Variable | Login, JWT, OAuth |
| XSS stored | Alta | Baja-Media | Inputs almacenados |
| CORS misconfig | Alta | Baja | Headers en todas las responses |
| Business logic | Alta | Alta | Flujos de negocio complejos |
| Subdomain takeover | Media-Alta | Baja | CNAME a servicios muertos |

### 4.1 IDOR — Checklist
```
1. Identifica todos los IDs en: URL path, params, headers, body, cookies
2. Crea 2 cuentas (victim + attacker)
3. Sustituye IDs de victim con cuenta attacker:
   - GET /api/users/{victim_id}
   - GET /api/orders/{victim_order_id}
   - POST /api/messages con to_user: victim_id
4. Prueba IDs numéricos, GUIDs, hashes MD5/SHA
5. Prueba HTTP verb tampering (POST → GET → PUT → DELETE)
6. Prueba state-based IDOR (draft → published, pending → approved)
```

### 4.2 SSRF — Checklist
```
1. Identifica vectores:
   - Parámetros URL: ?url=, ?redirect=, ?webhook=, ?callback=
   - Headers: X-Forwarded-For, Referer
   - Funciones: importar desde URL, webhooks, preview de links
   - File upload con URL remota
   - PDF/Image render

2. Payloads básicos:
   - http://COLLAB_URL  → OOB detection
   - http://169.254.169.254/latest/meta-data/  → AWS IMDSv1
   - http://metadata.google.internal/  → GCP
   - http://localhost/  → internal services

3. Bypass de filtros:
   - http://COLLAB_URL@169.254.169.254/
   - http://169.254.169.254#COLLAB_URL
   - http://[::ffff:169.254.169.254]
   - DNS rebinding
   - Short URLs (t.co, etc.)
   - Decimal IP: http://2130706433 == 127.0.0.1
```

### 4.3 XSS — Checklist
```
1. Identifica todos los reflection points (inputs, URL params, headers)
2. Detecta encoding/sanitización: <script>alert(1)</script>
3. Payloads contextuales:
   - HTML context:     <img src=x onerror=alert(1)>
   - Attr context:     " onmouseover=alert(1) "
   - JS context:       ';alert(1)//
   - Template:         {{7*7}} ${7*7} #{7*7}
4. DOM XSS: revisar uso de innerHTML, document.write, location.href
5. Stored XSS: cualquier input que se muestre a otro usuario
```

### 4.4 Business Logic
```
1. Precio manipulation:
   - Cambiar precio en request (si se envía del client)
   - Precio negativo
   - Cantidad 0 o negativa
   - Cupones: reuse, stacking ilimitado

2. Race conditions:
   - Doble gasto, doble like, doble claim
   - Herramienta: Burp Turbo Intruder (parallelism)

3. Workflow bypass:
   - Saltar pasos en flujos multi-step
   - Manipular state params
   - Replay de requests de fases anteriores

4. Mass assignment:
   - Añadir campos extra al body: "is_admin": true, "role": "admin"
```

---

## FASE 5: Automatización Dirigida

Solo después de identificar candidatos manualmente.

```bash
# SQLi en candidatos específicos
sqlmap -u "https://target.com/search?q=test" --batch --level 3

# XSS automatizado
cat gf_xss.txt | dalfox pipe --silence

# Nuclei en scope completo
nuclei -l live_hosts.txt -severity critical,high -rl 50

# Subdomain takeover
cat all_subs.txt | httpx -cname -silent | grep -E "CNAME.*github|CNAME.*azure|CNAME.*s3"
subjack -w all_subs.txt -t 100 -timeout 30 -ssl
```

---

## FASE 6: Verificación

Antes de reportar, confirma:
- [ ] ¿El bug es reproducible?
- [ ] ¿Estás dentro del scope?
- [ ] ¿Hay impacto real? (no solo teórico)
- [ ] ¿Es un duplicado? (busca en disclosures públicos)
- [ ] ¿Afecta a datos reales o entorno de prueba?

---

## FASE 7: Reporte

### Estructura de un buen reporte

```markdown
## Título
[Vuln Type] — [Feature/Endpoint] — [Impacto resumen]
Ejemplo: "IDOR en /api/v2/users/{id} permite acceso a datos de cualquier usuario"

## Severidad
CVSS v3: 8.1 (High)

## Descripción
[2-3 párrafos explicando el problema y por qué existe]

## Impacto
[Qué puede hacer un atacante real. Sé concreto.]

## Pasos para Reproducir
1. Crear cuenta como user A
2. Navegar a /profile
3. Capturar request GET /api/users/12345
4. Cambiar 12345 por 99999 (cuenta de user B)
5. Observar que se devuelven datos del user B

## Prueba de Concepto
[Request/Response o video — SIEMPRE incluir]

## Remediación
[Recomendación concreta — no genérica]

## Referencias
[CVE, OWASP, CWE si aplica]
```

### Tips para reportes
- **Sé concreto en el impacto** — no "podría comprometer datos" sino "permite leer emails, nombre y teléfono de cualquier usuario"
- **Incluye siempre PoC** — sin PoC = triager no puede reproducir = cierre
- **No exageres la severidad** — los triagers te reconocen y eso cuenta
- **Un bug por reporte** — no mezcles issues, dificulta el triage
- **Video para bugs complejos** — auth bypass, race conditions, multi-step

---

## Herramientas de Referencia Rápida

```bash
# Recon
subfinder -d target.com -silent -all -o subs.txt
httpx -l subs.txt -sc -title -tech-detect -json -o http.json
gau --subs target.com | uro | tee urls.txt
nuclei -l urls.txt -severity critical,high

# Fuzzing
ffuf -u https://target.com/FUZZ -w wordlist.txt -mc 200,301,302,403
ffuf -u https://target.com/api/v1/users/FUZZ -w ids.txt -mc 200

# Specific
sqlmap -u "url" --dbs --batch
dalfox url "https://target.com/search?q=FUZZ"
arjun -u https://target.com/api/endpoint

# OOB
interactsh-client -v  # genera URL para SSRF/XXE/SSTI callbacks
```

---

## Recursos

- https://portswigger.net/web-security — labs gratuitos para practicar
- https://hackerone.com/hacktivity — disclosures públicos para aprender
- https://pentester.land/list-of-bug-bounty-writeups/ — writeups categorizados
- https://github.com/swisskyrepo/PayloadsAllTheThings — payloads
- https://book.hacktricks.xyz — técnicas detalladas
