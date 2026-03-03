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

# ── 1. System dependencies ──────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        dnsutils \
        git \
        jq \
        libffi-dev \
        libssl-dev \
        nmap \
        unzip \
        wget \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# ── 2. uv  (Python version manager + virtualenv + pip replacement) ──────────
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
ENV UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_TOOL_DIR=/opt/toolkit/venvs \
    UV_TOOL_BIN_DIR=/opt/toolkit/bin

# ── 3. Go runtime ───────────────────────────────────────────────────────────
ARG GO_VERSION=1.23.4
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    | tar -C /usr/local -xz
ENV GOPATH=/root/go \
    PATH="/usr/local/go/bin:/root/go/bin:${PATH}"

# ── 4. Node.js via fnm (version manager) ────────────────────────────────────
ARG NODE_VERSION=22
RUN curl -fsSL https://fnm.vercel.app/install \
    | bash -s -- --install-dir /usr/local/bin --skip-shell \
    && eval "$(fnm env --shell bash)" \
    && fnm install ${NODE_VERSION} \
    && fnm default ${NODE_VERSION}
ENV FNM_DIR="/root/.local/share/fnm" \
    PATH="/root/.local/share/fnm/aliases/default/bin:${PATH}"

# ── 5. Toolkit layout ───────────────────────────────────────────────────────
RUN mkdir -p /opt/toolkit/tools \
             /opt/toolkit/bin  \
             /opt/toolkit/venvs \
             /opt/toolkit/scripts
ENV PATH="/opt/toolkit/bin:${PATH}"
WORKDIR /opt/toolkit

# ── 6. Copy tool manifests & install scripts ────────────────────────────────
COPY tools/   /opt/toolkit/tools/
COPY scripts/ /opt/toolkit/scripts/
RUN chmod +x /opt/toolkit/scripts/*.sh

# ── 7. Run modular installers ───────────────────────────────────────────────
RUN /opt/toolkit/scripts/install-all.sh

# ── 8. Shell UX ─────────────────────────────────────────────────────────────
COPY scripts/bashrc.sh /root/.bashrc_toolkit
RUN echo '. /root/.bashrc_toolkit' >> /root/.bashrc

# ── 9. Volumes for persistence ──────────────────────────────────────────────
VOLUME ["/workspace"]

WORKDIR /workspace
ENTRYPOINT ["/bin/bash"]
