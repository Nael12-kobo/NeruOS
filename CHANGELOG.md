# Changelog

All notable project changes will be recorded here.

## v0.4.0-alpha1 — VM safety and update foundation

- Added a UEFI-only ArchISO live profile for virtual-machine testing.
- Designed the first image without an installer or host-disk attachment.
- Added a non-root ArchISO build helper that keeps downloaded tools and build output inside the repository cache.
- Added a diskless QEMU launch helper and VirtualBox testing instructions.
- Added a recovery terminal shortcut and fallback terminal behavior.
- Added a System Updates panel that reports Arch package updates without installing them.
- Documented the distinction between Arch package updates and future signed NeruOS project releases.
- Added VM Alpha safety, requirements, and testing documentation.

## v0.3.0 — Native application discovery prototype

- Added a GIO-backed application catalog using visible Linux desktop entries.
- Added filtering and native launch through GAppInfo / GIO.
- Added common dock aliases for file managers, browsers, terminal emulators, code editors, Steam, image viewers, and settings apps.
- Added best-effort process status by matching distinctive desktop entry executable names with visible /proc processes.
- Added an Unverified state for generic launchers and duplicate executables to avoid misleading Running badges.
- Added application launch feedback in the NeruOS shell.
- Added --list-apps, --launch-app, and --show-search diagnostic modes.
- Updated architecture, installation, desktop-shell, and roadmap documentation to clarify process tracking and compositor limitations.

## v0.2.0 — Standalone shell prototype

- Split the desktop prototype into reusable NeruBar and NeruDock QML components.
- Added dynamic application-context menus to NeruBar.
- Added pointer-driven dock magnification with animated scaling.
- Added dock tooltips and an active-app indicator.
- Added Alt+Space for NeruSearch.
- Added Ctrl+Alt+1..4 workspace shortcuts.
- Added basic menu actions for app selection, wallpaper, workspace, and shell information.
- Clarified the standalone shell direction and the current dependency on a host compositor/window manager.

## v0.1.0 — Nebula prototype baseline

- Established the NeruOS name and Nebula visual identity.
- Locked the first desktop decisions: dark mode, floating dock, custom wallpaper, and hidden navigation rail.
- Added original SVG logo assets and a desktop concept illustration.
- Added the initial Qt 6 / QML standalone desktop prototype.
- Added architecture, design system, branding, roadmap, installation, FAQ, and contributor documentation.
- Clarified that the repository does not yet provide an installable OS image.
