#!/usr/bin/env bash
# install.sh - Bootstrap a new machine with dotfiles
#
# Usage:
#   git clone https://github.com/YOUR_USER/dotfiles ~/software/personal/dotfiles
#   cd ~/software/personal/dotfiles
#   ./install.sh

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { echo -e "\n\033[0;34m[info]\033[0m  $*"; }
ok()    { echo -e "\033[0;32m[ok]\033[0m    $*"; }
warn()  { echo -e "\033[0;33m[warn]\033[0m  $*"; }
error() { echo -e "\033[0;31m[error]\033[0m $*" >&2; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Check we're on a Debian/Ubuntu system
# ---------------------------------------------------------------------------
if ! command -v apt &>/dev/null; then
    error "This script currently supports Debian/Ubuntu only (apt not found)."
    exit 1
fi

# ---------------------------------------------------------------------------
# 1. Install apt packages
# ---------------------------------------------------------------------------
info "Installing apt packages..."
sudo apt update -qq
xargs sudo apt install -y -qq < "$DOTFILES_DIR/packages.txt"
ok "apt packages installed"

# ---------------------------------------------------------------------------
# 2. Install tools not in apt (or too old in apt)
# ---------------------------------------------------------------------------

# Starship prompt
if ! command -v starship &>/dev/null; then
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    ok "starship installed"
else
    ok "starship already installed"
fi

# eza (modern ls)
if ! command -v eza &>/dev/null; then
    info "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo apt update -qq
    sudo apt install -y -qq eza
    ok "eza installed"
else
    ok "eza already installed"
fi

# zoxide (smart cd)
if ! command -v zoxide &>/dev/null; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    ok "zoxide installed"
else
    ok "zoxide already installed"
fi

# lazygit
if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -sLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm -f /tmp/lazygit /tmp/lazygit.tar.gz
    ok "lazygit installed"
else
    ok "lazygit already installed"
fi

# delta (git pager)
if ! command -v delta &>/dev/null; then
    info "Installing delta..."
    DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -sLo /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
    sudo dpkg -i /tmp/delta.deb
    rm -f /tmp/delta.deb
    ok "delta installed"
else
    ok "delta already installed"
fi

# Bitwarden CLI
if ! command -v bw &>/dev/null; then
    info "Installing Bitwarden CLI..."
    if command -v snap &>/dev/null; then
        sudo snap install bw
    elif command -v npm &>/dev/null; then
        npm install -g @bitwarden/cli
    else
        warn "Could not install Bitwarden CLI (no snap or npm). Install manually."
    fi
    ok "Bitwarden CLI installed"
else
    ok "Bitwarden CLI already installed"
fi

# navi (interactive cheatsheets)
if ! command -v navi &>/dev/null; then
    info "Installing navi..."
    BIN_DIR="$HOME/.local/bin" bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)
    ok "navi installed"
else
    ok "navi already installed"
fi

# Import community cheat sheets
if [ ! -d "$HOME/.local/share/navi/cheats/denisidoro__cheats" ]; then
    info "Importing navi community cheat sheets..."
    navi repo add https://github.com/denisidoro/cheats 2>/dev/null || true
    ok "community cheat sheets imported"
else
    ok "community cheat sheets already present"
fi

# ---------------------------------------------------------------------------
# 3. Install TPM (Tmux Plugin Manager)
# ---------------------------------------------------------------------------
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    ok "TPM installed"
else
    ok "TPM already installed"
fi

# ---------------------------------------------------------------------------
# 4. Claude Code setup (MCP servers + gstack skills)
# ---------------------------------------------------------------------------
if command -v claude &>/dev/null; then
    info "Configuring Claude Code MCP servers..."

    # GitLab (OAuth -- will prompt in browser on first use)
    claude mcp add --transport http --scope user GitLab https://gitlab.com/api/v4/mcp 2>/dev/null && ok "GitLab MCP added" || ok "GitLab MCP already configured"

    # GitHub (needs GITHUB_TOKEN in ~/.bash_local)
    claude mcp add --scope user github -- npx -y @anthropic-ai/github-mcp-server 2>/dev/null && ok "GitHub MCP added" || ok "GitHub MCP already configured"

    # Context7 (up-to-date library docs)
    claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest 2>/dev/null && ok "Context7 MCP added" || ok "Context7 MCP already configured"

    # Playwright (browser automation)
    claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest 2>/dev/null && ok "Playwright MCP added" || ok "Playwright MCP already configured"

    # DynamoDB (read-only by default)
    claude mcp add --scope user dynamodb -- npx -y @awslabs/dynamodb-mcp-server 2>/dev/null && ok "DynamoDB MCP added" || ok "DynamoDB MCP already configured"

    # Install Playwright browser deps for Linux
    npx -y playwright install-deps 2>/dev/null || true

    # Install gstack skills
    if [ ! -d "$HOME/.claude/skills/gstack" ]; then
        info "Installing gstack skills..."
        git clone https://github.com/garrytan/gstack.git "$HOME/.claude/skills/gstack"
        cd "$HOME/.claude/skills/gstack" && ./setup 2>/dev/null || true
        cd "$DOTFILES_DIR"
        ok "gstack installed"
    else
        ok "gstack already installed"
    fi
else
    warn "Claude Code not installed -- skipping MCP and skills setup"
    warn "Install Claude Code first, then re-run install.sh"
fi

# ---------------------------------------------------------------------------
# 5. Create directory structure
# ---------------------------------------------------------------------------
info "Creating directory structure..."
mkdir -p ~/software/personal
mkdir -p ~/bin
mkdir -p ~/.local/share
ok "directories created"

# ---------------------------------------------------------------------------
# 6. Stow all packages
# ---------------------------------------------------------------------------
info "Stowing dotfiles packages..."
cd "$DOTFILES_DIR"
for dir in */; do
    if [ -d "$dir" ]; then
        pkg="${dir%/}"
        stow -R "$pkg" 2>&1 | grep -v "BUG" || true
        ok "stowed $pkg"
    fi
done

# ---------------------------------------------------------------------------
# 7. Copy .example files if .local versions don't exist
# ---------------------------------------------------------------------------
info "Setting up local config files..."
if [ ! -f "$HOME/.bash_local" ]; then
    cp "$DOTFILES_DIR/bash/.bash_local.example" "$HOME/.bash_local"
    chmod 600 "$HOME/.bash_local"
    ok "created ~/.bash_local from template"
else
    ok "~/.bash_local already exists"
fi

# ---------------------------------------------------------------------------
# 8. Enable auto-sync timer
# ---------------------------------------------------------------------------
info "Enabling dotfiles auto-sync timer..."
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-sync.timer
ok "auto-sync timer enabled (every 30 minutes)"

# ---------------------------------------------------------------------------
# 9. Done!
# ---------------------------------------------------------------------------
echo ""
echo "==========================================="
echo "  Dotfiles installation complete!"
echo "==========================================="
echo ""
echo "  Next steps:"
echo "  1. Restart your shell (or run: source ~/.bashrc)"
echo "  2. In tmux, press Ctrl+a then I to install tmux plugins"
echo "  3. Run 'dotfiles-secrets-sync' to pull secrets from Bitwarden"
echo "  4. Run 'ssh-keygen -t ed25519' to create SSH keys for this machine"
echo "  5. Edit ~/.bash_local for any machine-specific config"
echo ""
echo "  Cheat sheets:"
echo "  - Ctrl+a Ctrl+g  Open navi cheat sheet popup (in tmux)"
echo "  - navi            Open navi from terminal"
echo ""
