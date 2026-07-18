#!/usr/bin/env bash
# Ensure fnm-managed Node is on PATH (Mason-installed servers like vtsls run on Node)
export PATH="$HOME/.local/share/fnm:$PATH"
command -v fnm &>/dev/null && eval "$(fnm env)"

# tree-sitter CLI (>=0.26.1) — REQUIRED by nvim-treesitter main branch (Neovim 0.12+).
# Prebuilt binary from GitHub releases: NOT npm (unsupported by main), NOT cargo.
if ! command -v tree-sitter &>/dev/null || ! tree-sitter --version 2>/dev/null | grep -qE '0\.(2[6-9]|[3-9][0-9])'; then
    TS_URL=$(curl -s https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest \
        | grep -Po '"browser_download_url": "\K[^"]*tree-sitter-linux-x64\.gz')
    if [ -n "$TS_URL" ]; then
        curl -sL "$TS_URL" | gunzip > "$HOME/.local/bin/tree-sitter"
        chmod +x "$HOME/.local/bin/tree-sitter"
    fi
fi

# Clear stale parsers and plugin cache, then sync.
# LazyVim + enabled lang extras install parsers (treesitter) and LSP servers (Mason).
rm -rf ~/.local/share/nvim/site/parser
rm -rf ~/.local/share/nvim/lazy
# CPATH: tree-sitter doesn't search Ubuntu's multiarch include path
CPATH=/usr/include/x86_64-linux-gnu nvim --headless "+Lazy! sync" "+sleep 30" +qa
