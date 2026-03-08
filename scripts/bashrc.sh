#!/usr/bin/env bash
# ── Security Toolkit shell config ────────────────────────────────────────────

export PATH="/opt/toolkit/bin:${PATH}"

# fnm (Node.js)
if command -v fnm &>/dev/null; then
    eval "$(fnm env --shell bash)"
fi

# Prompt
export PS1="\[[1;31m\][toolkit]\[[0m\] \[[1;34m\]\w\[[0m\] \$ "

# Aliases
alias tools="ls /opt/toolkit/bin/"
alias tool-info="cat /opt/toolkit/tools/*/install.sh | grep -E '^# ──'"

# Welcome
echo ""
echo -e "[1;31m  ╔══════════════════════════════════════╗"
echo -e "  ║     Security Toolkit  v1.0           ║"
echo -e "  ╚══════════════════════════════════════╝[0m"
echo ""
echo -e "  Runtimes:"
echo -e "    Python (uv) : $(uv --version 2>/dev/null || echo N/A)"
echo -e "    Go           : $(go version 2>/dev/null | awk "{print \}")"
echo -e "    Node.js      : $(node --version 2>/dev/null || echo N/A)"
echo ""
echo -e "  Tools available:"
for t in /opt/toolkit/bin/*; do
    [ -x "$t" ] && echo -e "    • $(basename $t)"
done
# System-level tools (installed via apt)
for cmd in parallel nmap; do
    command -v "$cmd" &>/dev/null && echo -e "    • $cmd (system)"
done
echo ""
echo -e "  Tip: "tools" to list | "tool-info" for details"
echo ""
