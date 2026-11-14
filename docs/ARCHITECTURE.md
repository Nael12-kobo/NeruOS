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

- **NeruBar** — dynamic demo-app menus, clock, status, and quick actions.
- **NeruDock** — floating launcher with pointer-driven magnification and app aliases.
- **NeruSearch** — installed Linux desktop-entry discovery, GIO launch, and best-effort process status.
- **NeruCenter** — quick settings and notifications.
- **NeruSpace** — workspace identity and selection.

## Application catalog and launch

The initial catalog is implemented in C++ with Qt's QAbstractListModel and GLib/GIO.

- GIO enumerates visible launchable desktop entries.
- The model exposes display name, desktop ID, description, executable, and best-effort process status to QML.
- Search filters the display-name role and launches a selected entry through g_app_info_launch().
- Dock aliases map common NeruOS app names to available Linux applications.
- Process status is inferred by comparing distinct executable names with processes visible in /proc.

The status model is intentionally conservative:
- **Running** means a matching process name was found.
- **Not detected** means the executable is trackable but no match was found; this does not prove no related window exists.
- **Unverified** means a generic launcher or duplicate executable prevents reliable matching.

This is not native window tracking. D-Bus, sandbox, wrapper, helper, and forked applications can be missed. The selected compositor/window manager must provide real window identity and focus integration in a future milestone.

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
- GLib/GIO for standard desktop application discovery and launch.
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
