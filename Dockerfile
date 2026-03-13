###############################################################################
# Security Toolkit - Multi-runtime workbench
# Python envs managed by uv | Go & Node.js available
# Launches into interactive bash with all tools ready
###############################################################################
FROM ubuntu:24.04

LABEL maintainer="security-toolkit"
LABEL description="Modular security toolkit with uv, Go and Node.js"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# ── 1. System dependencies (rarely changes → cached) ─────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        dnsutils \
        git \
        iputils-ping \
        iproute2 \
        net-tools \
        traceroute \
        jq \
        libffi-dev \
        libpcap-dev \
        libssl-dev \
        nmap \
        parallel \
        python3-pip \
        unzip \
        wget \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# ── 2. uv (rarely changes → cached) ──────────────────────────────────────────
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
ENV UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_TOOL_DIR=/opt/toolkit/venvs \
    UV_TOOL_BIN_DIR=/opt/toolkit/bin

# ── 3. Go runtime (rarely changes → cached) ──────────────────────────────────
ARG GO_VERSION=1.23.4
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    | tar -C /usr/local -xz
ENV GOPATH=/root/go \
    PATH="/usr/local/go/bin:/root/go/bin:${PATH}"

# ── 4. Node.js via fnm (rarely changes → cached) ─────────────────────────────
ARG NODE_VERSION=22
RUN curl -fsSL https://fnm.vercel.app/install \
    | bash -s -- --install-dir /usr/local/bin --skip-shell \
    && eval "$(fnm env --shell bash)" \
    && fnm install ${NODE_VERSION} \
    && fnm default ${NODE_VERSION}
ENV FNM_DIR="/root/.local/share/fnm" \
    PATH="/root/.local/share/fnm/aliases/default/bin:${PATH}"

# ── 5. Toolkit layout ────────────────────────────────────────────────────────
RUN mkdir -p /opt/toolkit/tools \
             /opt/toolkit/bin  \
             /opt/toolkit/venvs \
             /opt/toolkit/wordlists \
             /opt/toolkit/scripts
ENV PATH="/opt/toolkit/bin:${PATH}"
WORKDIR /opt/toolkit

# ── 6. Tool installers (only rebuilds tools when install.sh changes) ─────────
COPY tools/   /opt/toolkit/tools/
RUN chmod +x /opt/toolkit/tools/*/install.sh 2>/dev/null || true

# ── 7. Run modular installers ────────────────────────────────────────────────
COPY scripts/install-all.sh /opt/toolkit/scripts/install-all.sh
RUN chmod +x /opt/toolkit/scripts/install-all.sh && /opt/toolkit/scripts/install-all.sh

# ── 8. Config & UX (changes often → last layers, cheap to rebuild) ───────────
COPY scripts/bashrc.sh /root/.bashrc_toolkit
RUN echo '. /root/.bashrc_toolkit' >> /root/.bashrc
COPY scripts/entrypoint.sh /opt/toolkit/scripts/entrypoint.sh
RUN chmod +x /opt/toolkit/scripts/entrypoint.sh

# ── 9.1 Recon / enum / exploit scripts ───────────────────────────────────────
COPY scripts/recon/   /opt/toolkit/scripts/recon/
COPY scripts/enum/    /opt/toolkit/scripts/enum/
COPY scripts/exploit/ /opt/toolkit/scripts/exploit/
RUN find /opt/toolkit/scripts/recon /opt/toolkit/scripts/enum \
         /opt/toolkit/scripts/exploit -name "*.sh" -exec chmod +x {} \;

# ── 10. Volumes for persistence ──────────────────────────────────────────────
VOLUME ["/workspace"]

WORKDIR /workspace
ENTRYPOINT ["/opt/toolkit/scripts/entrypoint.sh"]
