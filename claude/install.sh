#!/usr/bin/env bash
command -v claude &>/dev/null || exit 0

claude mcp add --transport http --scope user GitLab https://gitlab.com/api/v4/mcp 2>/dev/null || true
claude mcp add --scope user github -- npx -y @anthropic-ai/github-mcp-server 2>/dev/null || true
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true
claude mcp add --scope user playwright -- npx -y @playwright/mcp@latest 2>/dev/null || true
claude mcp add --scope user dynamodb -- npx -y @awslabs/dynamodb-mcp-server 2>/dev/null || true

ln -sf "$DOTFILES_DIR/claude/.claude/keybindings.json" "$HOME/.claude/keybindings.json"

"$DOTFILES_DIR/scripts/bin/dotfiles-setup-claude-hooks" 2>/dev/null || true

if [ ! -d "$HOME/.claude/skills/gstack" ]; then
    git clone https://github.com/garrytan/gstack.git "$HOME/.claude/skills/gstack"
    (cd "$HOME/.claude/skills/gstack" && ./setup 2>/dev/null) || true
fi
