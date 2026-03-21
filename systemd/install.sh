#!/usr/bin/env bash
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-sync.timer 2>/dev/null || true
