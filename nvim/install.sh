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

# Plugins (lazy.nvim), treesitter parsers, and Mason LSP servers install themselves
# the first time you launch `nvim` — that's how LazyVim bootstraps. We deliberately do
# NOT run a headless "+Lazy! sync" here: this install.sh runs before the config is
# stowed and it nuked lazy.nvim first, so the sync hit an empty config and failed with
# "E492: Not an editor command: Lazy! sync". Just install the tree-sitter CLI above and
# let nvim bootstrap on first open.
