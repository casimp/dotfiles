# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). One command to set up a new machine, auto-syncs every 30 minutes.

## Quick Start (New Machine)

```bash
git clone git@github.com:YOUR_USER/dotfiles.git ~/software/personal/dotfiles
cd ~/software/personal/dotfiles
script/bootstrap
```

That's it. The script installs all packages, symlinks all configs, enables auto-sync, and imports community cheat sheets.

### Post-install

```bash
source ~/.bashrc                    # load new config
tmux                                # start tmux, then Ctrl+a I to install plugins
dotfiles-secrets-sync               # pull secrets from Bitwarden
ssh-keygen -t ed25519               # generate SSH key for this machine
```

## What's Included

| Package | What it configures | Key files |
|---|---|---|
| `bash/` | Shell: history, aliases, tool init, PATH, keyboard remaps | `.bashrc`, `.bash_aliases`, `.bash_profile` |
| `git/` | Git: delta pager, aliases, auto email switching | `.gitconfig`, `.gitconfig-personal`, `.gitignore_global` |
| `tmux/` | Tmux: Ctrl+a prefix, vim nav, TPM plugins | `.tmux.conf` |
| `ghostty/` | Ghostty terminal: font, keybindings | `.config/ghostty/config` |
| `nvim/` | Neovim: LazyVim config | `.config/nvim/` |
| `scripts/` | CLI tools: sessionizer, secrets sync | `bin/tmux-sessionizer`, `bin/dotfiles-secrets-sync` |
| `navi/` | Interactive cheat sheets (tmux + tools) | `.config/navi/`, `.local/share/navi/cheats/custom/` |
| `starship/` | Cross-shell prompt | `.config/starship.toml` |
| `systemd/` | Auto-sync timer (pulls dotfiles every 30 min) | `.config/systemd/user/dotfiles-sync.*` |
| `handy/` | Handy dictation: Ctrl+Space shortcuts, wl-copy + ydotool paste | `.local/bin/handy-paste.sh`, `install.sh` |

### Installed CLI Tools

| Tool | Replaces | Alias |
|---|---|---|
| `eza` | `ls` | `ls`, `ll`, `tree` |
| `bat` | `cat` | `cat`, `catp` (with pager) |
| `ripgrep` | `grep` | `grep` |
| `zoxide` | `cd` | `cd`, `z`, `zi` |
| `fzf` | Ctrl+R history | Ctrl+R, Ctrl+T, Alt+C |
| `fd-find` | `find` | `fd` / `fdfind` |
| `lazygit` | git CLI | `lg` |
| `delta` | git diff | auto-enabled via `.gitconfig` |
| `starship` | bash prompt | auto-enabled |
| `navi` | man pages | `navi`, Ctrl+a Ctrl+g in tmux |
| `btop` | `htop` | `btop` |
| `direnv` | manual env vars | auto-loads `.envrc` per directory |
| `tldr` | `man` | `tldr <command>` |

## Key Bindings

### Keyboard Remaps (system-wide)

| Remap | Effect |
|---|---|
| Caps Lock → Ctrl | Both Caps Lock and original Ctrl act as Ctrl |

### Ghostty Terminal

| Binding | Action |
|---|---|
| `Alt+v` | Paste from clipboard |

### Handy (dictation, GNOME shortcuts)

| Binding | Action |
|---|---|
| `Ctrl+Space` | Start / stop dictation (toggle), text is pasted into the focused window |
| `Ctrl+Escape` | Cancel the current recording |

`handy/install.sh` installs Handy (latest GitHub `.deb`), `ydotool` and `wl-clipboard`, gives
`/dev/uinput` to group `input` (udev rule + `uinput` module) and adds you to that group, enables
Ubuntu's own `ydotool.service` user unit (don't add a second ydotoold - they share a socket and
collide), adds the two GNOME shortcuts, and sets Handy to paste via `~/.local/bin/handy-paste.sh`,
toggle mode, overlay and post-processing off, start at login.

On a new machine: after bootstrap, **log out and back in** (for the `input` group), open Handy once
and download the Parakeet 0.6B Q8 model, quit it, then re-run `handy/install.sh` to apply its
settings. Handy's own Transcribe shortcut is also `ctrl+space`. Paste uses Ctrl+V, so it won't
paste into terminals.

### Tmux (prefix = Ctrl+a)

| Binding | Action |
|---|---|
| `Ctrl+a f` | Fuzzy find project -> tmux session (sessionizer) |
| `Ctrl+a s` | List/switch sessions (choose-tree) |
| `Ctrl+a Ctrl+g` | Open navi cheat sheet popup |
| `Ctrl+a \|` | Split pane vertical |
| `Ctrl+a -` | Split pane horizontal |
| `Alt+h/j/k/l` | Navigate panes (no prefix needed) |
| `Ctrl+a Ctrl+h/j/k/l` | Resize panes |
| `Ctrl+a z` | Toggle pane zoom |
| `Alt+1..5` | Jump to window (no prefix needed) |
| `Ctrl+a r` | Reload tmux config |
| `Ctrl+a I` | Install TPM plugins |

### Shell

| Binding | Action |
|---|---|
| `Ctrl+f` | tmux-sessionizer (outside tmux) |
| `Ctrl+r` | Fuzzy search command history (fzf) |
| `Ctrl+t` | Fuzzy find file path (fzf) |
| `Alt+c` | Fuzzy cd into directory (fzf) |

## How It Works

### Stow

Each top-level directory is a "package". Running `stow bash` from the dotfiles root creates symlinks:

```
dotfiles/bash/.bashrc  ->  ~/.bashrc
dotfiles/bash/.bash_aliases  ->  ~/.bash_aliases
```

To apply all packages: `cd ~/software/personal/dotfiles && for d in */; do stow -R "$d"; done`

To remove a package: `stow -D bash`

### Auto-Sync

A systemd user timer pulls changes every 30 minutes and re-stows:

```bash
# Check timer status
systemctl --user status dotfiles-sync.timer

# Trigger a manual sync
systemctl --user start dotfiles-sync.service

# View sync log
cat ~/.local/share/dotfiles-sync.log
```

### Git Email Switching

- **Default:** chris.simpson@perceptual-robotics.com (work)
- **`~/software/personal/` repos:** c.a.simpson01@gmail.com (personal)

This is automatic via `[includeIf]` in `.gitconfig`. No manual switching needed.

### Secrets

Secrets are **never** stored in this repo. They live in Bitwarden and are pulled to `~/.bash_local` (git-ignored).

```bash
dotfiles-secrets-sync     # pull secrets from Bitwarden -> ~/.bash_local
```

To add a new secret:
1. Store it in Bitwarden
2. Add the mapping to `scripts/bin/dotfiles-secrets-sync` (in the `SECRETS` array)
3. Re-run `dotfiles-secrets-sync`

## How to Extend

### Add a new dotfile to an existing package

Just put the file in the right package directory, mirroring where it lives relative to `~`:

```bash
# Example: add a new config file
cp ~/.some_config dotfiles/bash/.some_config
cd ~/software/personal/dotfiles && stow -R bash
```

### Add a new package

```bash
mkdir -p ~/software/personal/dotfiles/newpkg/.config/newpkg
cp ~/.config/newpkg/config.toml dotfiles/newpkg/.config/newpkg/
cd ~/software/personal/dotfiles && stow newpkg
```

The auto-sync timer will stow it on all other machines automatically.

### Add a new cheat sheet

Create a `.cheat` file in `navi/.local/share/navi/cheats/custom/`:

```
% mytool, category

# Description of command
command --with <argument>

$ argument: echo -e "option1\noption2" --- --prevent-extra
```

Lines starting with `;` are reference-only (not executable). Lines starting with `$` define fzf-powered argument pickers.

### Add a new alias

Edit `bash/.bash_aliases`. It gets picked up on next shell start (or `source ~/.bash_aliases`).

### Add a new secret

1. Add the secret to Bitwarden
2. Edit `scripts/bin/dotfiles-secrets-sync`, add to the `SECRETS` array:
   ```bash
   "BITWARDEN_ITEM_NAME:ENV_VAR_NAME"
   ```
3. Run `dotfiles-secrets-sync`

### Add a tool that needs installing

1. If it's in apt: add to `packages.txt`
2. If it needs a custom install: add a block to `install.sh`
3. Add aliases to `bash/.bash_aliases` if needed
4. Add a cheat sheet in `navi/.local/share/navi/cheats/custom/`

## Updating Across Machines

### The normal workflow

1. Edit dotfiles on any machine
2. Commit and push
3. Every other machine picks it up within 30 minutes via auto-sync

### Manual sync

```bash
cd ~/software/personal/dotfiles
git pull
for d in */; do stow -R "$d"; done
```

### After changing install.sh or packages.txt

Auto-sync only pulls config changes. If you add new packages, re-run `install.sh` on each machine (it's idempotent -- safe to re-run).

## File Overview

```
dotfiles/
├── script/bootstrap           # Bootstrap script
├── packages.txt               # apt packages
├── .gitignore                 # keeps secrets out of repo
├── bash/                      # Shell config
│   ├── .bashrc
│   ├── .bash_profile
│   ├── .bash_aliases
│   └── .bash_local.example    # secret template
├── git/                       # Git config
│   ├── .gitconfig
│   ├── .gitconfig-personal
│   └── .gitignore_global
├── tmux/                      # Tmux config
│   └── .tmux.conf
├── ghostty/                   # Ghostty terminal config
│   └── .config/ghostty/config
├── nvim/                      # Neovim config (LazyVim)
│   └── .config/nvim/
│       ├── init.lua
│       ├── lazyvim.json
│       ├── lazy-lock.json
│       └── lua/
│           ├── config/
│           └── plugins/
├── scripts/                   # CLI scripts -> ~/bin
│   ├── bin/
│   │   ├── tmux-sessionizer
│   │   ├── tmux-worktree
│   │   └── dotfiles-secrets-sync
│   └── share/
│       └── tmux-layout.example
├── navi/                      # Cheat sheets
│   ├── .config/navi/config.yaml
│   └── .local/share/navi/cheats/custom/
│       ├── tmux.cheat
│       └── tools.cheat
├── starship/                  # Prompt config
│   └── .config/starship.toml
└── systemd/                   # Auto-sync timer
    └── .config/systemd/user/
        ├── dotfiles-sync.service
        └── dotfiles-sync.timer
```
