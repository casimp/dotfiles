#!/usr/bin/env bash
# Install latest stable neovim (Ubuntu apt version is too old)
if ! nvim --version 2>/dev/null | head -1 | grep -qE 'v0\.[8-9]|v[1-9]'; then
    sudo add-apt-repository -y ppa:neovim-ppa/stable
    sudo apt update -qq
    sudo apt install -y -qq neovim
fi
