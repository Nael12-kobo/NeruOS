if [[ -z "$WAYLAND_DISPLAY" && "$(tty 2>/dev/null)" == "/dev/tty1" && -z "$SSH_TTY" ]]; then
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=labwc
    export WLR_RENDERER_ALLOW_SOFTWARE=1
    export WLR_NO_HARDWARE_CURSORS=1
    mkdir -p "$HOME/.local/state"
    # Do not exec: keep the login shell alive if the compositor exits, so
    # systemd does not restart getty in a loop and hide the diagnostic output.
    dbus-run-session labwc >>"$HOME/.local/state/labwc.log" 2>&1
    printf 'labwc exited with status %s\n' "$?" >>"$HOME/.local/state/labwc.log"
    printf '\nNeruOS desktop did not start. Check ~/.local/state/labwc.log\n'
fi
