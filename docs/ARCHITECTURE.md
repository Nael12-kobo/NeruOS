# NeruOS Architecture

This document describes the current implementation and the boundaries between the NeruOS shell, the Wayland session, and the Arch base system.

## High-level layers

~~~text
+----------------------------------------------------------+
| NeruOS first-party utilities                              |
| NeruFiles | NeruSettings | NeruSearch | NeruStore (planned)|
+----------------------------------------------------------+
| NeruOS desktop shell                                      |
| NeruBar | NeruDock | NeruCenter | NeruSpace               |
| Notification Center | Session Panel                       |
+----------------------------------------------------------+
| Wayland session infrastructure                            |
| labwc compositor / window manager (VM Alpha session)      |
+----------------------------------------------------------+
| Arch Linux userland                                       |
| systemd | pacman | PipeWire | NetworkManager | BlueZ       |
+----------------------------------------------------------+
| Linux kernel + hardware drivers                           |
+----------------------------------------------------------+
~~~

## Base system

- **Arch Linux** is the base for package availability and a rolling-release development model.
- **systemd** provides service and login-session management.
- **pacman** manages Arch base packages.
- **archiso** builds the current x86_64 VM-only live image.
- The current live image is for virtual-machine testing. It is not a persistent installer.

No custom kernel is required for the current milestones. Kernel configuration and patches must be justified by a measurable need.

## Shell and session strategy

NeruOS develops its own Qt 6 / C++ / QML desktop shell. It is not a KDE Plasma theme.

There are two supported development contexts:

1. **Host prototype:** the shell runs as an ordinary application over an existing Linux desktop session. It does not replace that session or change the host login configuration.
2. **VM Alpha:** the ArchISO live profile starts a dedicated Wayland session using labwc, then launches the NeruOS boot splash and desktop shell. labwc owns native windows, focus, decoration, window actions, and virtual desktops; NeruOS supplies the desktop UI and first-party utilities.

NeruOS does not implement its own Wayland compositor. Keeping the compositor separate allows the project to focus on shell behavior without taking ownership of display-server responsibilities.

## Application catalog and launch

The application catalog is implemented in C++ with Qt's QAbstractListModel and GLib/GIO.

- GIO enumerates visible, launchable Linux desktop entries.
- The model exposes display name, desktop ID, description, executable, and process-status information to QML.
- Search launches a selected entry through GIO.
- Dock aliases map common NeruOS app names to available Linux applications.
- The current process indicator compares distinctive executable names with processes visible in /proc.

The status model is intentionally conservative:

- **Running** means a matching process name was found.
- **Not detected** means the executable is trackable but no match was found; this does not prove that no related window exists.
- **Unverified** means a generic launcher or duplicate executable prevents reliable matching.

This is not native-window tracking. D-Bus activation, sandboxing, wrappers, helper processes, and forked applications can make process matching incomplete. labwc manages native windows in VM Alpha, but the shell does not yet consume a native toplevel list or authoritative focused-window identity.

## Window and workspace operations

The VM Alpha profile configures labwc with four virtual desktops and common window actions. NeruOS sends selected workspace and window shortcuts through wtype. The action is therefore dependent on the active compositor's key bindings.

The next window-integration stage is to expose native window identity, title, focus, workspace, and state to the shell. Until that exists, dock indicators are process-based and NeruBar application context is not guaranteed to represent the true focused window.

## System services

The SystemControls layer talks to user-session services and hardware interfaces without running the shell as root:

- **Wi-Fi:** NetworkManager through nmcli, subject to polkit authorization.
- **Audio:** PipeWire / WirePlumber through wpctl, with a pactl fallback.
- **Bluetooth:** BlueZ through bluetoothctl with bounded command execution.
- **Brightness:** writable nodes under /sys/class/backlight when exposed and permitted.
- **Battery:** capacity and charging state under /sys/class/power_supply when exposed.
- **Notifications:** freedesktop notification service on the session D-Bus.
- **Session actions:** systemd-logind; screen locking uses swaylock with the VM Alpha PAM profile.

Controls are unavailable when their service, device, or permission is missing. The shell does not elevate privileges to make a control appear usable. Desktop portal integration, shell crash recovery, and physical-device validation remain open work.

## First-party utilities

- **NeruFiles** uses a Qt file-system model for browsing and common file operations as the current user.
- **NeruSettings** persists wallpaper, accent, appearance preference, and dock pins with QSettings.
- **NeruSearch** discovers and launches visible Linux desktop entries through GIO.
- **NeruCenter** displays system status and controls supported services.
- **Notification Center** receives session notifications and keeps a bounded in-memory history.
- **Session Panel** exposes lock, logout, suspend, restart, and power-off actions where permitted.
- **NeruStore** remains planned; package sources, signature checks, and its trust model must be defined first.

## Image, persistence, and updates

The VM Alpha image is an ArchISO-based live system with UEFI GRUB and Legacy BIOS Syslinux boot paths. The supplied QEMU helpers use a diskless configuration and do not attach host block devices. The live root is temporary; changes made in the VM disappear at shutdown.

The public v0.4.0-alpha2 prerelease is for VM testing only. It does not contain a persistent installer, account provisioning flow, signed NeruOS package repository, project update feed, upgrade transaction, or rollback implementation. Arch package status can be checked in the live session, but those updates are not persistent across VM reboots.

## Application compatibility

1. **Linux-native applications** are preferred when available.
2. **Windows compatibility layers or virtualization** are evaluated per application; a compatibility layer is not the same as a Windows kernel.
3. **Native Windows boot** remains the reliable fallback for software or games that require a supported Windows environment.

NeruOS will not impersonate Windows, tamper with anti-cheat systems, or attempt to bypass driver-integrity checks.

## Security principles

- Keep the base system close to upstream Arch unless there is a clear reason to diverge.
- Sign and verify project packages when a NeruOS repository is introduced.
- Do not execute downloaded scripts automatically.
- Do not require privileged access for ordinary UI functions.
- Apply file operations as the logged-in user and report permission failures.
- Document installation, update, rollback, and recovery behavior before a hardware release.
