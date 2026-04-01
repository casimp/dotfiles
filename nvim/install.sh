#!/usr/bin/env bash
# Install LSP servers
npm list -g pyright &>/dev/null || sudo npm i -g pyright
npm list -g typescript-language-server &>/dev/null || sudo npm i -g typescript typescript-language-server

# tree-sitter CLI (needed by nvim-treesitter to compile parsers)
# Built from source via cargo to avoid glibc 2.39 mismatch with prebuilt binaries on Ubuntu 22.04
source "$HOME/.cargo/env" 2>/dev/null || true
# Remove any broken system tree-sitter (e.g. from npm or prebuilt with wrong glibc)
[ -e /usr/local/bin/tree-sitter ] && sudo rm -f /usr/local/bin/tree-sitter
command -v tree-sitter &>/dev/null || cargo install tree-sitter-cli

# Clear stale parsers and plugin cache, then sync
rm -rf ~/.local/share/nvim/site/parser
rm -rf ~/.local/share/nvim/lazy
# CPATH: tree-sitter CLI doesn't search Ubuntu's multiarch include path
CPATH=/usr/include/x86_64-linux-gnu nvim --headless "+Lazy! sync" "+TSUpdate" "+sleep 30" +qa
