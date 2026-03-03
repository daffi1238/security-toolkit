# Security Toolkit

Contenedor Docker modular con múltiples herramientas de seguridad.  
Cada herramienta corre en su propio entorno aislado (venv via **uv**, binario Go, o paquete Node).

## Uso rápido

```bash
# Construir
docker compose build

# Lanzar shell interactivo
docker compose run --rm toolkit

# Ya dentro del contenedor:
jwt-tool eyJhbGciOiJIUzI1NiJ9...
sqlmap -u "http://target/page?id=1"
nuclei -u https://target.com
tools          # listar herramientas disponibles
```

## Arquitectura

```
security-toolkit/
├── Dockerfile
├── docker-compose.yml
├── workspace/            ← montado en /workspace (tus proyectos)
├── wordlists/            ← montado en /opt/toolkit/wordlists
├── scripts/
│   ├── install-all.sh    ← orquestador (ejecuta todos los install.sh)
│   └── bashrc.sh         ← prompt y aliases
└── tools/
    ├── jwt-tool/         ← Python 3.12 (via uv)
    │   └── install.sh
    ├── sqlmap/           ← Python 3.11 (via uv)
    │   └── install.sh
    ├── nuclei/           ← Go binary
    │   └── install.sh
    ├── _template_python/ ← plantilla para nuevas tools Python
    ├── _template_go/     ← plantilla para nuevas tools Go
    └── _template_node/   ← plantilla para nuevas tools Node
```

## Añadir una nueva herramienta

### Python (cualquier versión)

```bash
cp -r tools/_template_python tools/mi-tool
# Editar tools/mi-tool/install.sh:
#   - TOOL_NAME, PYTHON_VERSION, REPO
#   - Ajustar el entrypoint del wrapper
docker compose build
```

### Go

```bash
cp -r tools/_template_go tools/mi-tool
# Editar tools/mi-tool/install.sh:
#   - TOOL_NAME, GO_PKG
docker compose build
```

### Node.js

```bash
cp -r tools/_template_node tools/mi-tool
# Editar tools/mi-tool/install.sh:
#   - TOOL_NAME, NPM_PKG
docker compose build
```

## Runtimes disponibles

| Runtime   | Manager | Versiones              |
|-----------|---------|------------------------|
| Python    | uv      | Cualquiera (por tool)  |
| Go        | nativo  | ARG en Dockerfile      |
| Node.js   | fnm     | ARG en Dockerfile      |

## Notas

- Los templates `_template_*` se ignoran automáticamente en `install-all.sh` (prefijo `_`).
- `workspace/` y `wordlists/` persisten entre sesiones.
- Para escaneos que necesiten red del host, descomenta `network_mode: host` en compose.
