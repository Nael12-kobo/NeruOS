if [[ -z "$WAYLAND_DISPLAY" && "$(tty 2>/dev/null)" == "/dev/tty1" && -z "$SSH_TTY" ]]; then
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=labwc
    exec dbus-run-session labwc
fi
