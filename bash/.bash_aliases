# ~/.bash_aliases - managed by dotfiles

# ---------------------------------------------------------------------------
# Modern replacements (only alias if the tool is installed)
# ---------------------------------------------------------------------------

# eza -> ls
if command -v eza &>/dev/null; then
    alias ls="eza --icons"
    alias ll="eza -la --icons --git"
    alias la="eza -a --icons"
    alias tree="eza --tree --icons"
else
    alias ll="ls -alF"
    alias la="ls -A"
fi

# bat -> cat
if command -v bat &>/dev/null; then
    alias cat="bat --paging=never --style=plain"
    alias catp="bat"  # bat with full features (paging, line numbers)
elif command -v batcat &>/dev/null; then
    alias cat="batcat --paging=never --style=plain"
    alias catp="batcat"
fi

# ripgrep -> grep
if command -v rg &>/dev/null; then
    alias grep="rg"
fi

# zoxide -> cd
if command -v zoxide &>/dev/null; then
    alias cd="z"
fi

# lazygit
if command -v lazygit &>/dev/null; then
    alias lg="lazygit"
fi

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ---------------------------------------------------------------------------
# Git shortcuts
# ---------------------------------------------------------------------------
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline -20"
alias gp="git push"
alias gpull="git pull"

# ---------------------------------------------------------------------------
# Safety
# ---------------------------------------------------------------------------
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

# ---------------------------------------------------------------------------
# Dotfiles
# ---------------------------------------------------------------------------
alias dotfiles="cd ~/software/personal/dotfiles"
alias dotfiles-edit="cd ~/software/personal/dotfiles && \${EDITOR:-vim}"
