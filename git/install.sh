#!/usr/bin/env bash
# delta (git pager)
if ! command -v delta &>/dev/null; then
    URL=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"browser_download_url": "\K[^"]*amd64\.deb')
    if [ -n "$URL" ]; then
        curl -sLo /tmp/delta.deb "$URL"
        sudo dpkg -i /tmp/delta.deb
        rm -f /tmp/delta.deb
    fi
fi
