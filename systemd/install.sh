#!/usr/bin/env bash
systemctl --user daemon-reload
# Auto-sync timer intentionally left DISABLED.
# To enable periodic pull + re-stow later:
#   systemctl --user enable --now dotfiles-sync.timer
