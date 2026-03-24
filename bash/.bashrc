# ~/.bashrc - managed by dotfiles

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=50000
HISTFILESIZE=100000
shopt -s histappend

# ---------------------------------------------------------------------------
# Shell options
# ---------------------------------------------------------------------------
shopt -s checkwinsize
shopt -s globstar 2>/dev/null
shopt -s cdspell 2>/dev/null
shopt -s dirspell 2>/dev/null

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# ---------------------------------------------------------------------------
# Tool initialization
# ---------------------------------------------------------------------------

# Starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# Zoxide (smart cd)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# fzf keybindings and completion
if command -v fzf &>/dev/null; then
    if fzf --bash &>/dev/null; then
        eval "$(fzf --bash)"
    else
        [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
        [ -f /usr/share/doc/fzf/examples/completion.bash ] && source /usr/share/doc/fzf/examples/completion.bash
    fi
fi

# direnv
if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

# ---------------------------------------------------------------------------
# fzf config
# ---------------------------------------------------------------------------
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif command -v fdfind &>/dev/null; then
    export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ---------------------------------------------------------------------------
# Keyboard remaps
# ---------------------------------------------------------------------------

# Caps Lock → Ctrl (both positions act as Ctrl)
if command -v setxkbmap &>/dev/null && [ -n "$DISPLAY" ]; then
    setxkbmap -option ctrl:nocaps
fi

# ---------------------------------------------------------------------------
# Keybindings
# ---------------------------------------------------------------------------

# Ctrl+F to launch tmux-sessionizer
bind -x '"\C-f": tmux-sessionizer'

# ---------------------------------------------------------------------------
# Machine-specific / secrets (not tracked in git)
# ---------------------------------------------------------------------------
[ -f ~/.bash_local ] && source ~/.bash_local
