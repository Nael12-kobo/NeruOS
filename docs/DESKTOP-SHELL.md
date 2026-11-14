# NeruOS Nebula Desktop Shell

## Current architecture

NeruOS is a dedicated Wayland live session built around a native Qt 6 / C++ / QML desktop shell. The VM Alpha profile starts a labwc Wayland session, then launches the NeruOS boot splash and the full shell in sequence.

- **Qt Quick shell:** draws the desktop, menu bar, dock, control center, notification center, search, file manager, settings, and session panel.
- **labwc:** owns native window creation, focus, decoration, minimize/maximize, snapping, window switching, and four virtual desktops.
- **System services:** NetworkManager, PipeWire/WirePlumber, BlueZ, systemd-logind, and the session D-Bus provide hardware and session operations.
- **GIO:** discovers and launches installed Linux desktop entries.
- **User preferences:** QSettings stores wallpaper, accent color, appearance preference, and dock pins in the user's profile.

The shell does not replace the compositor. It is the desktop shell running inside the dedicated labwc session.

## Priority 1 — Native window management

Native application windows are managed by labwc. The profile configures four named desktops, a window switcher, maximize/restore, minimize, close, snapping, and show-desktop shortcuts.

NeruOS exposes workspace and keyboard-based window operations from its Window menu through `WorkspaceController` and `wtype`. The shell window is configured to remain present across the virtual desktops.

`ForeignToplevelModel` connects to `zwlr_foreign_toplevel_manager_v1` when the compositor advertises it. The model receives native window handles, title, app ID, active/minimized/maximized/fullscreen state, and close events. It provides native activation, minimize, maximize, and close requests. This protocol is optional and is not advertised by every Wayland compositor.

## Priority 2 — NeruDock integration

The dock reads individually replaceable PNG icons from `assets/icons/`. Each dock item keeps its image aspect ratio, magnifies on hover, shows an active/running indicator, and dispatches application requests.

The app catalog scans visible Linux desktop entries through GIO. On compositors that provide the foreign-toplevel protocol, NeruDock uses native app IDs and active-window state for running indicators and maps aliases to existing windows. Clicking an already-open app activates a matching window directly. On unsupported compositors it falls back to the older `/proc` executable matching and compositor window menu.

NeruSearch's separate process-status column still uses `/proc`; generic launchers, sandbox wrappers, D-Bus-activated applications, and helper processes can make that diagnostic incomplete.

Pinned applications are stored in `DesktopSettings` and rebuilt into the dock when preferences change.

## Priority 3 — NeruCenter and system controls

`SystemControls` exposes real session state and commands without running sudo:

- **Wi-Fi:** NetworkManager `nmcli`; the user session must be authorized by polkit.
- **Audio:** PipeWire/WirePlumber `wpctl`, with `pactl` fallback, when a default output exists.
- **Bluetooth:** BlueZ `bluetoothctl`; the image enables the Bluetooth service, but the device must expose a controller.
- **Brightness:** `/sys/class/backlight`; the slider is enabled only when the backlight node is writable by the session user.
- **Battery:** reads capacity and charging state from `/sys/class/power_supply`.

Controls are disabled or report an unavailable status when the service or hardware is missing. The shell does not change system permissions or elevate privileges.

## Priority 4 — Notification Center

`NotificationBridge` registers the freedesktop `org.freedesktop.Notifications` service on the session D-Bus. Applications can send notifications to NeruOS; the shell stores the latest 30 notification entries in the current session and supports replacement and close events. The center also receives NeruOS system and operation messages.

The current history is in-memory and is cleared when the shell exits. It is not yet a persistent notification database.

## Priority 5 — NeruSpace

labwc provides four actual virtual desktops: General, Coding, Gaming, and Study. Super+1–4 switches desktops; Super+Shift+1–4 moves the focused window; Ctrl+Alt+1–4 invokes the same switch action from the shell and updates the menu-bar label. Window Overview and Next Window invoke the labwc client list and window switcher.

## Priority 6 — NeruFiles

NeruFiles is a native Qt Quick window backed by `FileSystemModel`. It supports home/location navigation, directory listing, selection, refresh, create/rename, move-to-trash, and optional hidden-file visibility. File operations are performed as the current user and report permission or I/O failures through NeruOS notifications.

## Priority 7 — NeruSettings

NeruSettings stores wallpaper path, accent color, dark-appearance preference, and pinned dock applications using QSettings. Wallpaper selection is applied through `WallpaperManager` and restored when the shell starts. Dock pin/unpin updates the live dock immediately. The dark-appearance preference is stored; full light-palette coverage across every shell component remains future work.

## Priority 8 — Login and session management

The Session Panel calls `systemd-logind` for logout, suspend, restart, and power-off. Lock Screen uses `swaylock` with an ISO PAM profile that includes `system-auth`.

The image packages greetd, Regreet, and cage and carries a reference `/etc/greetd/config.toml.template` for persistent installations. The live VM deliberately keeps its temporary auto-login user, so greetd is not enabled and there is no interactive login prompt in VM Alpha. A persistent installation must provision a normal user and a dedicated greeter account before enabling the greetd service.

## Boot identity

- UEFI uses the themed NeruOS GRUB menu.
- Legacy BIOS uses the ArchISO-supported Syslinux menu with the matching Nebula palette.
- The native `BootAnimation.qml` splash appears after the Wayland session starts and before the full desktop shell.
- The early firmware and kernel boot sequence remains outside Qt/QML.

## Development and validation

Build the native shell:

```bash
cd qt-desktop
cmake -S . -B build -G Ninja
cmake --build build -j2
qmllint Main.qml NeruBar.qml NeruDock.qml NeruFiles.qml NeruSettings.qml NotificationCenter.qml SessionPanel.qml
```

Useful smoke-test options:

```bash
./build/neruos-nebula --list-windows
```

This prints native window titles, app IDs, dock alias mapping, and compositor state when the active Wayland compositor supports the foreign-toplevel protocol.

```bash
./build/neruos-nebula --show-center
./build/neruos-nebula --show-files
./build/neruos-nebula --show-settings
./build/neruos-nebula --show-notifications
./build/neruos-nebula --show-session
./build/neruos-nebula --test-notifications
```

The VM Alpha image is temporary and diskless. Changes made inside a running VM disappear when it is powered off.
