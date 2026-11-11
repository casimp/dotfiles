#!/usr/bin/env bash
# Handy external paste script: put the transcript on the clipboard, then send one Ctrl+V.
# Handy passes the text as $1 (falls back to stdin if no argument).
#
# GOTCHA: wl-copy forks a background process that keeps serving the clipboard.
# Its stdout/stderr MUST go to /dev/null, otherwise Handy waits on the open pipe
# and hangs with "not responding".
text="${1-$(cat)}"
printf '%s' "$text" | wl-copy >/dev/null 2>&1
export YDOTOOL_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/.ydotool_socket"
sleep 0.05
ydotool key 29:1 47:1 47:0 29:0 >/dev/null 2>&1   # LeftCtrl down, V down, V up, LeftCtrl up
