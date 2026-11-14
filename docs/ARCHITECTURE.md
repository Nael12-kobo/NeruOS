# NeruOS Architecture — Initial Proposal

This is a living architecture document. It describes the intended direction, not a completed implementation.

## High-level layers

~~~text
+---------------------------------------------------------+
| First-party applications                               |
| NeruFiles | NeruStore | NeruSettings | NeruSearch       |
+---------------------------------------------------------+
| NeruOS desktop experience                               |
| NeruBar | NeruDock | NeruCenter | NeruSpace             |
+---------------------------------------------------------+
| KDE Plasma 6 / KWin foundation                           |
| Plasma shell integration | Wayland session | portals    |
+---------------------------------------------------------+
| Arch Linux userland                                      |
| systemd | pacman | PipeWire | NetworkManager | portals   |
+---------------------------------------------------------+
| Linux kernel + hardware drivers                          |
+---------------------------------------------------------+
~~~

## Base system

- **Arch Linux** is the intended base for package availability and a rolling-release development model.
- **systemd** is the service manager inherited from the base.
- **pacman** is the initial package manager.
- **archiso** is the planned tool for building installation media after the desktop stack is stable.

No custom kernel is required for the first milestone. Kernel configuration and patches must be justified by a measurable need.

## Desktop foundation

The first integration target is **KDE Plasma 6 with KWin**. Plasma provides a stable foundation for panels, workspace management, window handling, Wayland, and accessibility while NeruOS builds a distinctive visual layer.

The initial Qt/QML prototype is deliberately a standalone application. It must not replace the user's running shell or modify their session configuration.

## UI technology

- Qt 6 / QML for interactive shell prototypes and future desktop components.
- SVG for scalable marks and simple UI artwork.
- C++ only where a native service or integration genuinely requires it.
- Prefer existing desktop standards and portals over custom privileged daemons.

## System integration boundaries

Prototype controls are visual demonstrations. They do not currently change real Wi-Fi, Bluetooth, audio, brightness, power, or display settings. Production integrations must use documented APIs and suitable permission boundaries.

A future NeruCenter may use existing user-session services such as NetworkManager, PipeWire, and power management interfaces. It should not run as root merely to display a settings panel.

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
