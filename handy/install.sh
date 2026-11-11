#!/usr/bin/env bash
# Handy (local speech-to-text) with Ctrl+Space dictation on GNOME/Wayland.
#
#   Ctrl+Space   -> handy --toggle-transcription   (GNOME custom shortcut)
#   Ctrl+Escape  -> handy --cancel                 (GNOME custom shortcut)
#   Paste        -> ~/.local/bin/handy-paste.sh    (wl-copy + one ydotool Ctrl+V)
#
# Every step checks first, so re-running is a no-op and only asks for sudo
# when something is actually missing.

set -u
type warn &>/dev/null || warn() { printf "  [ !! ] %s\n" "$1"; }
PASTE_SCRIPT="$HOME/.local/bin/handy-paste.sh"
SETTINGS="$HOME/.local/share/com.pais.handy/settings_store.json"

# --- Handy itself (GitHub release .deb; apt resolves its dependencies) -------
if ! command -v handy &>/dev/null; then
    URL=$(curl -s "https://api.github.com/repos/cjpais/Handy/releases/latest" \
        | grep -Po '"browser_download_url": "\K[^"]*_amd64\.deb')
    if [ -n "$URL" ]; then
        curl -sLo /tmp/handy.deb "$URL"
        sudo apt install -y -qq /tmp/handy.deb
        rm -f /tmp/handy.deb
    else
        warn "handy: could not find a .deb in the latest release"
    fi
fi

# --- Paste tools ---------------------------------------------------------------
for pkg in ydotool wl-clipboard; do
    dpkg -s "$pkg" &>/dev/null || sudo apt install -y -qq "$pkg"
done

# --- Let ydotool create a virtual keyboard (uinput) ---------------------------
grep -qx uinput /etc/modules || echo uinput | sudo tee -a /etc/modules >/dev/null
lsmod | grep -q '^uinput' || [ -e /dev/uinput ] || sudo modprobe uinput

RULE='KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"'
if [ "$(cat /etc/udev/rules.d/99-uinput.rules 2>/dev/null)" != "$RULE" ]; then
    echo "$RULE" | sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null
    sudo udevadm control --reload-rules && sudo udevadm trigger
fi

if ! getent group input | grep -qw "$USER"; then
    sudo usermod -aG input "$USER"
    warn "handy: added $USER to group 'input' - log out and back in (or reboot)"
fi

# ydotoold: Ubuntu 26.04's ydotool package ships its own user service, serving
# $XDG_RUNTIME_DIR/.ydotool_socket. Don't add a second one - they collide.
if systemctl --user cat ydotool.service &>/dev/null; then
    systemctl --user is-enabled ydotool.service &>/dev/null || systemctl --user enable --now ydotool.service
else
    warn "handy: no ydotool.service user unit found - ydotoold must be started some other way"
fi

# --- GNOME shortcuts -----------------------------------------------------------
if command -v gsettings &>/dev/null; then
    MK=org.gnome.settings-daemon.plugins.media-keys
    P=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
    add_shortcut() {  # id name command binding
        gsettings set "$MK.custom-keybinding:$P/$1/" name "$2"
        gsettings set "$MK.custom-keybinding:$P/$1/" command "$3"
        gsettings set "$MK.custom-keybinding:$P/$1/" binding "$4"
        current=$(gsettings get "$MK" custom-keybindings)
        case "$current" in
            *"$P/$1/"*) ;;
            "@as []"|"[]") gsettings set "$MK" custom-keybindings "['$P/$1/']" ;;
            *) gsettings set "$MK" custom-keybindings "${current%]}, '$P/$1/']" ;;
        esac
    }
    add_shortcut handy-toggle 'Handy: toggle transcription' 'handy --toggle-transcription' '<Control>space'
    add_shortcut handy-cancel 'Handy: cancel' 'handy --cancel' '<Control>Escape'
fi

# --- Handy's own settings --------------------------------------------------------
# Handy writes settings_store.json on first launch (after onboarding / model
# download), so on a fresh machine run Handy once, quit it, and re-run this.
if [ ! -f "$SETTINGS" ]; then
    warn "handy: open Handy once (pick the Parakeet 0.6B Q8 model), quit it, then re-run handy/install.sh"
else
    python3 -I - "$SETTINGS" "$PASTE_SCRIPT" <<'EOF' || exit 1
import json, subprocess, sys
path, script = sys.argv[1], sys.argv[2]
d = json.load(open(path))
s = d["settings"]
want = {
    "paste_method": "external_script",
    "external_script_path": script,
    "shortcut_activation": "toggle",
    "overlay_style": "none",
    "post_process_enabled": False,
    "autostart_enabled": True,
}
changes = {k: v for k, v in want.items() if s.get(k) != v}
if s["bindings"]["transcribe"]["current_binding"] != "ctrl+space":
    changes["transcribe binding"] = "ctrl+space"
if not changes:
    sys.exit(0)
if subprocess.run(["pgrep", "-x", "handy"], capture_output=True).returncode == 0:
    print("  handy: quit Handy, then re-run handy/install.sh to apply: " + ", ".join(changes))
    sys.exit(0)
s.update({k: v for k, v in want.items()})
s["bindings"]["transcribe"]["current_binding"] = "ctrl+space"
json.dump(d, open(path, "w"), indent=2)
print("  handy: updated settings: " + ", ".join(changes))
EOF
fi
