if [[ -z "$WAYLAND_DISPLAY" && "$(tty 2>/dev/null)" == "/dev/tty1" && -z "$SSH_TTY" ]]; then
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=labwc
    export WLR_RENDERER_ALLOW_SOFTWARE=1
    export WLR_NO_HARDWARE_CURSORS=1
    mkdir -p "$HOME/.local/state"

    # Hide the autologin/TTY banner before the graphical session starts.
    # NeruOS Boot Animation becomes the first visible UI once Qt is ready.
    # Diagnostic output remains in the per-user log files.
    printf '\033[?25l\033[H\033[2J\033[3J'

    # Keep the login shell alive if labwc exits so a readable recovery
    # console can be shown instead of restarting getty in a loop.
    dbus-run-session labwc >>"$HOME/.local/state/labwc.log" 2>&1
    labwc_status=$?

    # Restore the cursor and console only when the graphical session exits.
    printf '\033[?25h\033[H\033[2J\033[3J'
    printf 'labwc exited with status %s\n' "$labwc_status" >>"$HOME/.local/state/labwc.log"
    printf '\nNeruOS desktop did not start. Check ~/.local/state/labwc.log\n'
fi
