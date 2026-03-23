#!/usr/bin/env bash
# Clear plugin cache (keeps lazy.nvim itself) so pinned versions are respected
find ~/.local/share/nvim/lazy -maxdepth 1 -mindepth 1 -not -name lazy.nvim -exec rm -rf {} +
# Sync neovim plugins via lazy.nvim
nvim --headless "+Lazy! sync" +qa
