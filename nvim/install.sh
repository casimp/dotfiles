#!/usr/bin/env bash
# Install LSP servers
npm list -g pyright &>/dev/null || sudo npm i -g pyright
npm list -g typescript-language-server &>/dev/null || sudo npm i -g typescript typescript-language-server

# tree-sitter CLI (needed by nvim-treesitter to compile parsers)
if ! command -v tree-sitter &>/dev/null || [[ "$(tree-sitter --version | grep -oP '\d+\.\d+')" < "0.26" ]]; then
    curl -sLo /tmp/tree-sitter-cli.zip "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-cli-linux-x86.zip"
    unzip -o /tmp/tree-sitter-cli.zip -d /tmp
    sudo install /tmp/tree-sitter /usr/local/bin
    rm -f /tmp/tree-sitter /tmp/tree-sitter-cli.zip
fi

# Clear stale parsers and plugin cache, then sync
rm -rf ~/.local/share/nvim/site/parser
rm -rf ~/.local/share/nvim/lazy
# CPATH: tree-sitter CLI doesn't search Ubuntu's multiarch include path
CPATH=/usr/include/x86_64-linux-gnu nvim --headless "+Lazy! sync" +qa
