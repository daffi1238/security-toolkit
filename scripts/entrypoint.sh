#!/usr/bin/env bash
###############################################################################
# Runtime entrypoint - runs on every container start (fast, no rebuild needed)
# Put config tweaks, path fixes, and light setup here instead of Dockerfile
###############################################################################

# Fix jwt_tool config paths if config exists
if [ -f /root/.jwt_tool/jwtconf.ini ]; then
    sed -i 's|wordlist = .*|wordlist = /opt/toolkit/wordlists/jwt-common.txt|' \
        /root/.jwt_tool/jwtconf.ini
fi

# Symlink all jwt_tool bundled txt files so relative paths work from any dir
JWT_SRC="/opt/toolkit/tools/jwt-tool/src"
if [ -d "${JWT_SRC}" ]; then
    for f in "${JWT_SRC}"/*.txt; do
        name=$(basename "$f")
        [ ! -f "/workspace/${name}" ] && ln -sf "$f" "/workspace/${name}"
    done
fi

# Source toolkit shell config
[ -f /root/.bashrc_toolkit ] && . /root/.bashrc_toolkit

exec /bin/bash "$@"
