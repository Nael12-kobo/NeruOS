# NeruOS Architecture — Standalone Shell Direction

This is a living architecture document. It describes the intended direction and current prototype boundaries.

## High-level layers

~~~text
+----------------------------------------------------------+
| NeruOS first-party applications                          |
| NeruFiles | NeruStore | NeruSettings | NeruSearch        |
+----------------------------------------------------------+
| NeruOS standalone shell UI                               |
| NeruBar | NeruDock | NeruCenter | NeruSpace              |
+----------------------------------------------------------+
| Linux desktop session infrastructure                     |
| Display server / compositor / window management          |
| (host-provided during current prototype stage)            |
+----------------------------------------------------------+
| Arch Linux userland                                       |
| systemd | pacman | PipeWire | NetworkManager | portals    |
+----------------------------------------------------------+
| Linux kernel + hardware drivers                           |
+----------------------------------------------------------+
~~~

## Base system

- **Arch Linux** is the intended base for package availability and a rolling-release development model.
- **systemd** is the service manager inherited from the base.
- **pacman** is the initial package manager.
- **archiso** is the planned tool for building installation media after the shell and recovery strategy are stable.

No custom kernel is required for the initial milestones. Kernel configuration and patches must be justified by a measurable need.

## Standalone shell strategy

**Decision:** NeruOS will develop its own shell UI instead of targeting a KDE Plasma theme as its primary desktop experience.

The shell is being designed as a set of independent Qt/QML components:

- **NeruBar** — dynamic menus based on the active application, clock, status, and quick actions.
- **NeruDock** — floating launcher with pointer-driven magnification and active-app indicators.
- **NeruCenter** — quick settings and notifications.
- **NeruSearch** — application and settings search.
- **NeruSpace** — workspace identity and selection.

## Important prototype boundary

The current shell prototype is a normal maximized Qt Quick application. It runs **on top of** an existing Linux desktop session and therefore still relies on the host's display server, compositor, and window manager.

It does not yet:
- Replace KWin, Mutter, or another window manager / compositor.
- Provide a login manager or an independent desktop session.
- Manage native application windows, focus, workspaces, or multi-monitor layouts.
- Own system notifications or hardware controls.
- Provide an installer or bootable ISO.

A later milestone must select a window-management / compositor foundation or another explicit strategy. A shell UI and a compositor are separate responsibilities; writing the UI does not automatically supply window management.

## UI technology

- Qt 6 / QML for shell components and first-party interface prototypes.
- SVG for scalable marks and simple UI artwork.
- C++ only where native services or integration genuinely require it.
- Prefer desktop portals and documented session APIs over custom privileged daemons.

## System integration boundaries

Current NeruCenter toggles and sliders are local demo state. They do not change real Wi-Fi, Bluetooth, audio, brightness, power, or display settings.

A future implementation may connect to user-session services such as NetworkManager, PipeWire, and power management APIs. It should not run as root merely to display a settings panel.

## Application compatibility

1. **Linux-native applications** — preferred when available.
2. **Windows compatibility layers or virtualization** — evaluated per application; a compatibility layer is not the same as a Windows kernel.
3. **Native Windows boot** — remains the reliable fallback for software or games that require a supported Windows environment.

NeruOS will not impersonate Windows, tamper with anti-cheat systems, or attempt to bypass driver integrity checks.

## Security principles

- Keep the base system close to upstream Arch unless there is a clear reason to diverge.
- Sign and verify project packages when a repository is introduced.
- Do not execute downloaded scripts automatically.
- Do not require privileged access for ordinary UI functions.
- Document update, rollback, and recovery behavior before broad release.
