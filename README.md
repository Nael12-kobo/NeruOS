<div align="center">
  <img src="assets/logo-horizontal.svg" alt="NeruOS Nebula Edition" width="360">
  <p><strong>A fluid, powerful, and beautiful Linux experience.</strong></p>
  <p>
    <img src="https://img.shields.io/badge/status-early%20prototype-9277E8?style=flat-square" alt="Early prototype">
    <img src="https://img.shields.io/badge/base-Arch%20Linux-1793D1?style=flat-square&logo=archlinux&logoColor=white" alt="Arch Linux">
    <img src="https://img.shields.io/badge/shell-standalone%20prototype-4F8FEA?style=flat-square" alt="Standalone shell prototype">
    <img src="https://img.shields.io/badge/UI-Qt%206%20%2F%20QML-41CD52?style=flat-square&logo=qt&logoColor=white" alt="Qt 6">
    <img src="https://img.shields.io/badge/license-MIT-54C8EB?style=flat-square" alt="MIT">
  </p>
</div>

# NeruOS — Nebula Edition

**NeruOS** is an early-stage, community-oriented Linux operating system project built around Arch Linux. Its first edition, **Nebula**, explores a distinctive desktop experience inspired by deep-space colors, soft light, and calm, purposeful interaction.

The long-term direction is a **standalone NeruOS desktop shell**, not a KDE Plasma theme. The current work is a Qt Quick/QML shell prototype that runs as a normal maximized application on top of an existing Linux desktop session. It does not yet replace the window manager, compositor, login session, or desktop environment.

> **Current status:** standalone shell prototype v0.3. NeruOS is not yet a bootable distribution, does not provide an installation ISO, and should not be installed as a daily-driver operating system.

## Nebula design direction

- **Appearance:** dark by default.
- **Dock:** floating, horizontally centered near the bottom, with pointer-driven magnification.
- **NeruBar:** dynamic application menus and system status area.
- **Wallpaper:** user-selectable; Nebula artwork is the default concept.
- **Navigation rail:** hidden by default and revealed from the left screen edge.
- **Visual language:** atmospheric, minimal, premium, and readable — not a macOS clone.
- **Accent colors:** Nebula Cyan and Nebula Violet, with Aurora Pink used sparingly.

See the [Nebula Design System](docs/DESIGN-SYSTEM.md) and [Branding Guide](docs/BRANDING.md).

## Current v0.3 prototype

| Component | v0.3 status |
|---|---|
| **NeruBar** | Dynamic menu groups and clickable prototype actions |
| **NeruDock** | Pointer magnification, tooltips, app aliases, and launch requests |
| **NeruSearch** | Discovers installed Linux desktop applications through GIO; filters and launches selected entries |
| **Process status** | Periodically compares desktop entry executables with visible /proc process names |
| **NeruCenter** | UI values for Wi-Fi, Bluetooth, brightness, and volume; hardware APIs are not connected |
| **NeruSpace** | General, Coding, Gaming, and Study labels; not yet connected to a compositor |
| **Navigation Rail** | Hidden by default; revealed from the left edge |
| **Wallpaper** | User can choose an image for the current prototype session |

**Process status is a best-effort indicator, not a window manager's active-window state.** Apps that launch through helper processes, D-Bus activation, sandboxes, or wrappers may not match the desktop entry executable. Multiple entries using the same executable may share a process status.

## Standalone shell strategy

The project is organized around its own shell components:

- **NeruBar** — dynamic app menu, clock, status area, and quick actions.
- **NeruDock** — app launcher, active demo indicator, and magnification.
- **NeruCenter** — quick settings and notifications.
- **NeruSearch** — installed Linux app discovery, launch, and process status.
- **NeruSpace** — workspace identity and selection.
- **NeruFiles / NeruStore / NeruSettings** — planned first-party applications.

A standalone shell still needs a Linux graphics session and a window manager / compositor. The current prototype uses the one already running on the host machine. Replacing that foundation requires a separate engineering milestone.

## Technology direction

| Area | Direction |
|---|---|
| Base system | Arch Linux |
| Shell UI | Qt 6 and QML |
| Application discovery / launch | GIO GAppInfo / desktop entries |
| Current window / compositor host | Existing Linux desktop session (for safe development and testing) |
| Long-term desktop session | Standalone NeruOS shell integration; compositor/window-management choice still to be decided |
| Package management | pacman |
| System image | archiso, after the shell and recovery strategy are stable |
| Graphics | Wayland-first direction; hardware support must be tested |
| Gaming | Steam, Proton, Vulkan, Gamescope where supported |
| Windows software | Native ports or compatibility layers where practical; Windows VM for selected productivity apps |
| Strict Windows anti-cheat games | A supported native Windows installation may still be required |

### Windows compatibility and anti-cheat

NeruOS will aim for useful Windows application compatibility, but it cannot promise that every EXE or every game will run on Linux. Compatibility depends on APIs, vendor support, drivers, and anti-cheat policy.

Some kernel-level anti-cheat systems require a Windows kernel and may reject virtual machines. Games such as Valorant should therefore be treated as requiring a supported native Windows environment unless their publisher changes its platform policy. NeruOS will not attempt to bypass or impersonate anti-cheat security checks.

## Try the current UI prototype

The **qt-desktop/** directory contains a standalone Qt Quick/QML shell prototype. It is designed to be tested on an existing Arch Linux or CachyOS session without replacing the current desktop shell or changing boot configuration.

### Build requirements

- Arch Linux or CachyOS
- CMake, Ninja, and a C++17 compiler
- Qt 6.5 or newer: Qt Quick, Qt Quick Controls 2, and Qt SVG
- GLib / GIO 2.0 development files

Install packages:

~~~bash
sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-declarative qt6-svg glib2
~~~

Build and run:

~~~bash
git clone https://github.com/Nael12-kobo/NeruOS.git
cd NeruOS/qt-desktop
cmake -S . -B build -G Ninja
cmake --build build
./build/neruos-nebula
~~~

List discovered applications from the terminal:

~~~bash
./build/neruos-nebula --list-apps
~~~

To launch a known desktop entry and run a short process-detection check:

~~~bash
./build/neruos-nebula --launch-app org.kde.dolphin.desktop
~~~

The prototype is a normal maximized application window. Close it like any other application. It does not install a shell, change your Plasma / GNOME configuration, or modify your bootloader.

See [Prototype Installation](docs/INSTALLATION.md), [Application Discovery and Launch](docs/APPLICATION-LAUNCHING.md), and [Desktop Shell Architecture](docs/DESKTOP-SHELL.md).

## Repository map

~~~text
NeruOS/
├── assets/                 # Logo and brand assets
├── docs/                   # Project, design, architecture, and install docs
├── qt-desktop/
│   ├── AppCatalog.h/.cpp   # GIO app discovery, launch, process status
│   ├── Main.qml            # Shell composition
│   ├── NeruBar.qml         # Dynamic menu and status bar
│   └── NeruDock.qml        # Floating magnifying dock
├── .github/                # Issue and pull request templates
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── SECURITY.md
~~~

## Roadmap

1. **Shell prototype** — standalone QML components, dynamic NeruBar, magnifying NeruDock, and keyboard interaction.
2. **Application discovery and launch** — read desktop entries, launch through GIO, and show best-effort process status.
3. **Native window integration** — reliable application/window state, focus, minimize, and close via a chosen session architecture.
4. **System services** — real NeruCenter controls, notifications, and session integration.
5. **Desktop session engineering** — compositor/window-manager strategy, login session, crash recovery, and multi-monitor behavior.
6. **First-party utilities** — NeruSettings, NeruFiles, and NeruStore.
7. **System image** — reproducible Arch-based image, installer, updates, rollback, and recovery.
8. **Alpha ISO** — only after installation, recovery, and upgrade paths are tested.

Read the [full roadmap](docs/ROADMAP.md). Planned features are not released features.

## Contributing

Issues, documentation improvements, design feedback, and code contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

Original NeruOS project code and documentation are provided under the [MIT License](LICENSE), unless a file states otherwise. Third-party assets and dependencies retain their own licenses.

<div align="center">
  <img src="assets/logo-mark.svg" alt="" width="44">
  <p><strong>NeruOS — Find your flow.</strong><br><sub>Built in the open. Powered by curiosity.</sub></p>
</div>
