# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). One command to set up a new machine, auto-syncs every 30 minutes.

## Quick Start (New Machine)

```bash
git clone git@github.com:YOUR_USER/dotfiles.git ~/software/personal/dotfiles
cd ~/software/personal/dotfiles
./install.sh
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
| `bash/` | Shell: history, aliases, tool init, PATH | `.bashrc`, `.bash_aliases`, `.bash_profile` |
| `git/` | Git: delta pager, aliases, auto email switching | `.gitconfig`, `.gitconfig-personal`, `.gitignore_global` |
| `tmux/` | Tmux: Ctrl+a prefix, vim nav, TPM plugins | `.tmux.conf` |
| `scripts/` | CLI tools: sessionizer, secrets sync | `bin/tmux-sessionizer`, `bin/dotfiles-secrets-sync` |
| `navi/` | Interactive cheat sheets (tmux + tools) | `.config/navi/`, `.local/share/navi/cheats/custom/` |
| `starship/` | Cross-shell prompt | `.config/starship.toml` |
| `systemd/` | Auto-sync timer (pulls dotfiles every 30 min) | `.config/systemd/user/dotfiles-sync.*` |
| `claude/` | Claude Code: global preferences, MCP rules | `.claude/CLAUDE.md` |

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

### Tmux (prefix = Ctrl+a)

| Binding | Action |
|---|---|
| `Ctrl+f` | Fuzzy find project -> tmux session |
| `Ctrl+a Ctrl+g` | Open navi cheat sheet popup |
| `Ctrl+a \|` | Split pane vertical |
| `Ctrl+a -` | Split pane horizontal |
| `Ctrl+a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl+a z` | Toggle pane zoom |
| `Alt+1..5` | Jump to window |
| `Ctrl+a r` | Reload tmux config |
| `Ctrl+a I` | Install TPM plugins |

### Shell

| Binding | Action |
|---|---|
| `Ctrl+f` | tmux-sessionizer (outside tmux) |
| `Ctrl+r` | Fuzzy search command history (fzf) |
| `Ctrl+t` | Fuzzy find file path (fzf) |
| `Alt+c` | Fuzzy cd into directory (fzf) |

## Claude Code Setup

### Global CLAUDE.md

`claude/.claude/CLAUDE.md` contains personal preferences that apply to every project: coding style, communication preferences, tool usage rules. This is stowed to `~/.claude/CLAUDE.md`.

### MCP Servers (installed globally by install.sh)

| Server | What it does |
|---|---|
| **GitLab** | MR management, issues, pipelines -- for work projects |
| **GitHub** | PRs, issues, repos -- for personal projects |
| **Context7** | Fetches up-to-date library docs (not stale training data) |
| **Playwright** | Browser automation and web testing |
| **DynamoDB** | Table queries, schema design, access pattern analysis |

### Skills

**gstack** is installed globally by `install.sh` -- provides `/review`, `/ship`, `/qa`, `/plan-ceo-review`, and more.

To add your own global skills: create `~/.claude/skills/my-skill/SKILL.md`. To add project-level skills: create `.claude/skills/my-skill/SKILL.md` in the project repo.

---

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

### Add a Claude Code MCP server

```bash
claude mcp add --scope user my-server -- npx -y @some/mcp-server
```

Then add the same command to `install.sh` so new machines get it.

### Add a Claude Code skill

```bash
mkdir -p ~/.claude/skills/my-skill
# Write SKILL.md with frontmatter (name, description) and instructions
```

For global skills that should sync, add them under `claude/.claude/skills/` in the dotfiles repo.

### Update global Claude preferences

Edit `claude/.claude/CLAUDE.md` in the dotfiles repo. Changes sync to all machines via auto-sync.

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
├── install.sh              # Bootstrap script (idempotent)
├── packages.txt            # apt packages
├── .gitignore              # keeps secrets out of repo
├── bash/                   # Shell config
│   ├── .bashrc
│   ├── .bash_profile
│   ├── .bash_aliases
│   └── .bash_local.example # secret template
├── git/                    # Git config
│   ├── .gitconfig
│   ├── .gitconfig-personal
│   └── .gitignore_global
├── tmux/                   # Tmux config
│   └── .tmux.conf
├── scripts/                # CLI scripts -> ~/bin
│   └── bin/
│       ├── tmux-sessionizer
│       └── dotfiles-secrets-sync
├── navi/                   # Cheat sheets
│   ├── .config/navi/config.yaml
│   └── .local/share/navi/cheats/custom/
│       ├── tmux.cheat
│       └── tools.cheat
├── starship/               # Prompt config
│   └── .config/starship.toml
├── claude/                 # Claude Code config
│   └── .claude/
│       └── CLAUDE.md       # Global preferences
└── systemd/                # Auto-sync timer
    └── .config/systemd/user/
        ├── dotfiles-sync.service
        └── dotfiles-sync.timer
```
