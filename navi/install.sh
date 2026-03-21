#!/usr/bin/env bash
# navi binary
if ! command -v navi &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    V=$(curl -s "https://api.github.com/repos/denisidoro/navi/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    if [ -n "$V" ]; then
        curl -sLo /tmp/navi.tar.gz "https://github.com/denisidoro/navi/releases/download/v${V}/navi-v${V}-x86_64-unknown-linux-musl.tar.gz"
        tar xf /tmp/navi.tar.gz -C "$HOME/.local/bin" navi
        rm -f /tmp/navi.tar.gz
    fi
fi

# Community cheat sheets
if [ ! -d "$HOME/.local/share/navi/cheats/denisidoro__cheats" ]; then
    mkdir -p "$HOME/.local/share/navi/cheats"
    git clone --depth 1 https://github.com/denisidoro/cheats.git "$HOME/.local/share/navi/cheats/denisidoro__cheats"
fi
