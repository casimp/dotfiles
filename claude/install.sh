#!/usr/bin/env bash
command -v claude &>/dev/null || exit 0

# NOTE: MCP servers intentionally NOT registered here.
# User-scope `claude mcp add` entries conflict with project-scope MCP
# config in work repos. Manage MCP per-project instead.

"$DOTFILES_DIR/scripts/bin/dotfiles-setup-claude-hooks" 2>/dev/null || true

if [ ! -d "$HOME/.claude/skills/gstack" ]; then
    git clone https://github.com/garrytan/gstack.git "$HOME/.claude/skills/gstack"
    (cd "$HOME/.claude/skills/gstack" && ./setup 2>/dev/null) || true
fi
