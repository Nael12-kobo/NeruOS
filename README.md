<div align="center">
  <img src="assets/logo-horizontal.svg" alt="NeruOS Nebula Edition" width="360">
  <p><strong>A fluid, powerful, and beautiful Linux experience.</strong></p>
  <p>
    <img src="https://img.shields.io/badge/status-early%20prototype-9277E8?style=flat-square" alt="Early prototype">
    <img src="https://img.shields.io/badge/base-Arch%20Linux-1793D1?style=flat-square&logo=archlinux&logoColor=white" alt="Arch Linux">
    <img src="https://img.shields.io/badge/desktop-KDE%20Plasma-1D99F3?style=flat-square&logo=kde&logoColor=white" alt="KDE Plasma">
    <img src="https://img.shields.io/badge/UI-Qt%206%20%2F%20QML-41CD52?style=flat-square&logo=qt&logoColor=white" alt="Qt 6">
    <img src="https://img.shields.io/badge/license-MIT-54C8EB?style=flat-square" alt="MIT">
  </p>
</div>


# NeruOS — Nebula Edition

**NeruOS** is an early-stage, community-oriented Linux operating system project built around Arch Linux. Its first edition, **Nebula**, explores a distinctive desktop experience inspired by deep-space colors, soft light, and calm, purposeful interaction.

The goal is not to reskin another desktop and call it a new operating system. NeruOS is intended to grow into a coherent ecosystem: a carefully designed desktop, first-party utilities, sensible system defaults, documented installation and recovery, and a gaming and application-compatibility strategy that is honest about Linux's boundaries.

> **Current status:** design and standalone desktop prototype. NeruOS is not yet a bootable distribution, does not provide an installation ISO, and should not be installed as a daily-driver operating system.

## Nebula design direction

- **Appearance:** dark by default.
- **Dock:** floating, horizontally centered near the bottom.
- **Wallpaper:** user-selectable; Nebula artwork is the default concept.
- **Navigation rail:** hidden by default and revealed from the left screen edge.
- **Visual language:** atmospheric, minimal, premium, and readable — not a macOS clone.
- **Accent colors:** Nebula Cyan and Nebula Violet, with Aurora Pink used sparingly.

See the [Nebula Design System](docs/DESIGN-SYSTEM.md) and [Branding Guide](docs/BRANDING.md).

## Planned desktop components

| Component | Purpose | Status |
|---|---|---|
| **NeruBar** | Top status bar, app menu, and system indicators | Concept / prototype |
| **NeruDock** | Floating app launcher and task indicators | Concept / prototype |
| **NeruCenter** | Quick settings and notifications | UI demo |
| **NeruSearch** | Universal app and settings launcher | UI demo |
| **NeruSpace** | General, Coding, Gaming, and Study workspace presets | UI demo |
| **NeruFiles** | First-party file manager experience | Future work |
| **NeruStore** | Software discovery experience | Future work |
| **NeruSwitch** | Optional one-time boot selector integration | Future work |

## Technology direction

| Area | Direction |
|---|---|
| Base system | Arch Linux |
| Desktop foundation | KDE Plasma 6 / KWin |
| UI toolkit | Qt 6 and QML |
| Package management | pacman |
| System image | archiso, after the desktop foundation is stable |
| Graphics | Wayland-first direction; hardware support must be tested |
| Gaming | Steam, Proton, Vulkan, Gamescope where supported |
| Windows software | Native ports or compatibility layers where practical; Windows VM for selected productivity apps |
| Strict Windows anti-cheat games | A supported native Windows installation may still be required |

### Windows compatibility and anti-cheat

NeruOS will aim for useful Windows application compatibility, but it cannot promise that every EXE or every game will run on Linux. Compatibility depends on APIs, vendor support, drivers, and anti-cheat policy.

Some kernel-level anti-cheat systems require a Windows kernel and may reject virtual machines. Games such as Valorant should therefore be treated as requiring a supported native Windows environment unless their publisher changes its platform policy. NeruOS will not attempt to bypass or impersonate anti-cheat security checks.

## Try the current UI prototype

The **qt-desktop/** directory contains a standalone Qt Quick/QML prototype. It is designed to be tested on an existing Arch Linux or CachyOS KDE Plasma session without replacing Plasma or changing boot configuration.

### Build requirements

- Arch Linux or CachyOS
- CMake, Ninja, and a C++17 compiler
- Qt 6.5 or newer: Qt Quick, Qt Quick Controls 2, and Qt SVG

Install packages:

~~~bash
sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-declarative qt6-svg
~~~

Build and run:

~~~bash
git clone https://github.com/Nael12-kobo/NeruOS.git
cd NeruOS/qt-desktop
cmake -S . -B build -G Ninja
cmake --build build
./build/neruos-nebula
~~~

Or use the helper script:

~~~bash
chmod +x build.sh
./build.sh
~~~

The prototype is an ordinary application window. Close it like any other application. It does not install a shell, alter your Plasma configuration, or modify your bootloader.

See [Prototype Installation](docs/INSTALLATION.md).

## Repository map

~~~text
NeruOS/
├── assets/                 # Logo, brand art, desktop concept
├── docs/                   # Project, design, architecture, and install docs
├── qt-desktop/             # Standalone Qt/QML desktop prototype
├── .github/                # Issue and pull request templates
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── SECURITY.md
~~~

## Roadmap

NeruOS is being developed in public and in small, reviewable stages:

1. **Project foundation** — public repository, brand identity, written design system, safe UI prototype.
2. **Desktop integration** — translate the prototype into maintainable Plasma 6 components and theme packages.
3. **First-party utilities** — settings, search, file management, and app discovery.
4. **System engineering** — reproducible packages, installer work, updates, rollback, and recovery.
5. **Gaming and compatibility** — document verified Proton compatibility and supported hardware.
6. **Alpha ISO** — only after installation, recovery, and upgrade paths are tested.

Read the [full roadmap](docs/ROADMAP.md). Planned features are not released features.

## Contributing

Issues, documentation improvements, design feedback, and code contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

Original NeruOS project code and documentation are provided under the [MIT License](LICENSE), unless a file states otherwise. Third-party assets and dependencies retain their own licenses.

<div align="center">
  <img src="assets/logo-mark.svg" alt="" width="44">
  <p><strong>NeruOS — Find your flow.</strong><br><sub>Built in the open. Powered by curiosity.</sub></p>
</div>
