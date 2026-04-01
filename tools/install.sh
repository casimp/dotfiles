#!/usr/bin/env bash
# Base packages and tools that don't have their own topic

sudo apt update -qq
xargs sudo apt install -y -qq < "$DOTFILES_DIR/packages.txt"

# Neovim (GitHub release — apt version is too old for LazyVim)
if ! command -v nvim &>/dev/null || ! nvim --version | head -1 | grep -qP 'v0\.(1[0-9]|[2-9]\d)|v[1-9]'; then
    curl -sLo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    sudo rm -rf /opt/nvim
    sudo tar xzf /tmp/nvim.tar.gz -C /opt
    sudo mv /opt/nvim-linux-x86_64 /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm -f /tmp/nvim.tar.gz
fi

# eza
if ! command -v eza &>/dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo apt update -qq && sudo apt install -y -qq eza
fi

# zoxide
command -v zoxide &>/dev/null || curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# lazygit
if ! command -v lazygit &>/dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -sLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm -f /tmp/lazygit /tmp/lazygit.tar.gz
fi

# Nerd Font (JetBrains Mono — needed for terminal/nvim icons)
if ! fc-list | grep -qi "JetBrainsMono.*Nerd"; then
    curl -sLo /tmp/nerd-font.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    mkdir -p ~/.local/share/fonts
    unzip -o /tmp/nerd-font.zip -d ~/.local/share/fonts/JetBrainsMono
    fc-cache -f
    rm -f /tmp/nerd-font.zip
fi

# Rust toolchain (needed to compile tree-sitter-cli from source on Ubuntu 22.04)
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
fi

# bitwarden
command -v bw &>/dev/null || sudo snap install bw
