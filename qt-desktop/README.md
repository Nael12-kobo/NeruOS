# Standalone Qt Desktop Shell Prototype

This is the NeruOS Nebula shell UI prototype built with Qt Quick/QML. It is developed as an independent set of NeruOS components rather than a KDE Plasma theme.

**Important:** the prototype is still a normal maximized application. It runs on an existing Linux desktop session and uses that session's window manager and compositor. It is not yet an independent login session or a complete desktop environment.

## Build on Arch Linux / CachyOS

Install dependencies:

~~~bash
sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-declarative qt6-svg glib2 pacman-contrib
~~~

Configure, compile, and run:

~~~bash
cmake -S . -B build -G Ninja
cmake --build build
./build/neruos-nebula
~~~

Or run ./build.sh from this directory.

## v0.3 interactions

### NeruSearch and application catalog

- Discovers visible Linux desktop entries through GLib/GIO.
- Filters the application list by display name.
- Launches the selected desktop entry through GIO.
- Shows best-effort process status: Running, Not detected, or Unverified.
- Refreshes the catalog from the panel.
- Shows launch errors and launch feedback.

### NeruDock

- Hover over an app icon to magnify it.
- Nearby icons respond with a smaller scale based on pointer distance.
- Icons animate smoothly and show a tooltip.
- Dock aliases attempt to launch common installed file managers, browsers, terminal emulators, code editors, Steam, image viewers, and settings apps.
- The original demo-app indicator is not yet a native window-task indicator.

### NeruBar

- Menu labels change based on the selected demo app.
- File, Code, Settings, Steam, and Store contexts have different menu groups.
- Menu actions can open demo apps, change workspace labels, select a wallpaper, or show shell information.
- Status buttons open NeruCenter.
- Search opens from the top bar or with Alt+Space.

### System Updates

- Uses pacman-contrib's checkupdates command to compare installed packages with configured Arch repositories.
- Lists package names and old/new versions.
- Never installs packages or runs a privileged upgrade.
- Does not yet check for a NeruOS project release; that will use a separate signed release channel.
- In a live ISO, all writable changes disappear after shutdown.

### NeruSpace

- Select General, Coding, Gaming, or Study.
- Use Ctrl+Alt+1 through Ctrl+Alt+4 to switch workspace labels.

### Other controls

- Move the pointer to the far-left screen edge to reveal the hidden navigation rail.
- Open NeruSettings to choose a wallpaper for the current session.
- Press Escape to close transient UI.

## Diagnostic commands

List visible launchable desktop entries:

~~~bash
./build/neruos-nebula --list-apps
~~~

Open NeruSearch immediately for UI testing:

~~~bash
./build/neruos-nebula --show-search
~~~

Open the Control Center for UI testing:

~~~bash
./build/neruos-nebula --show-center
~~~

Test the freedesktop notification service on an existing session bus:

~~~bash
./build/neruos-nebula --test-notifications
~~~

Open the System Updates panel:

~~~bash
./build/neruos-nebula --show-updates
~~~

Run a terminal-only package update check:

~~~bash
./build/neruos-nebula --check-updates
~~~

Exit status is 0 when no updates are available, 10 when updates are available, and another non-zero value on error.

Launch a known desktop entry and run a short process-detection check:

~~~bash
./build/neruos-nebula --launch-app org.kde.dolphin.desktop
~~~

## Process status limitations

Process status is a best-effort executable-name match from /proc, not native-window tracking. Generic launchers such as Steam, Flatpak, env, and wrapper executables are reported as Unverified. Entries that share an executable are also Unverified to avoid false Running indicators.

D-Bus-activated apps, sandbox wrappers, helper processes, and apps that fork may still be missed. The selected compositor/window manager must be integrated before the shell can track real native windows, focus, minimize, and close state.

## Other limitations

- NeruCenter values are local UI state and do not alter NetworkManager, Bluetooth, audio, brightness, or power settings.
- Workspace selection changes the prototype's workspace label only; it is not yet connected to a compositor.
- No independent login session, window manager, compositor, or installer is provided. The UEFI VM Alpha ISO is still being built and has not been published yet.

## Nebula desktop visual shell

The desktop layout now uses a separate PNG wallpaper, the standalone NeruOS logo,
and individual transparent-corner PNG application icons from
`assets/icons/`. The supplied 512 × 512 icons are kept as individual files;
the QML dock references them by resource path.

### Visual components

- `DesktopBackground.qml` renders the wallpaper independently of the shell controls.
- `WallpaperManager.qml` owns the default and session-selected wallpaper.
- `DesktopLogo.qml` renders the standalone logo mark in NeruBar.
- `ApplicationDock.qml` and `DockItem.qml` render the floating dock and its
  individual application icons.
- `NeruBar.qml` renders the macOS-inspired top menu bar and status controls.

### Adding or replacing dock icons

Edit the `dockApps` array in `Main.qml`. Each entry uses its own PNG resource:

```qml
{ name: "NeruFiles", icon: "qrc:/assets/icons/files.png" }
```

Place additional PNG files in `assets/icons/`; CMake discovers them on the
next configure/build. Keep the file names and resource paths in the dock
configuration in sync.

## Control Center service integration

- Wi-Fi reads and toggles the NetworkManager radio through `nmcli`, without
  using sudo. It requires NetworkManager to be active and the session user to
  be authorized by polkit.
- Volume reads and updates the current output through `wpctl`, with `pactl`
  as a fallback when available. It requires an active PipeWire/WirePlumber or
  PulseAudio user session and a default output device.
- Brightness reads `/sys/class/backlight` and only enables the slider when
  the current user already has write access to the backlight device. NeruOS
  does not change system permissions or request elevated privileges.
- Bluetooth reads and toggles the BlueZ controller through `bluetoothctl`.
  The VM can still report no controller when QEMU or the host does not expose
  a Bluetooth adapter.
- Battery status is read from `/sys/class/power_supply` and remains hidden or
  unavailable on systems that do not expose a battery device.

The service layer refreshes hardware/session state periodically and disables
controls whose dependencies are missing. No packages are installed by the
desktop shell and no privileged commands are run.

## Login and session management

The session panel uses `systemd-logind` for logout, suspend, reboot, and
power-off, and starts the PAM-backed `swaylock` screen locker. The ISO now
includes a `swaylock` PAM policy that delegates authentication to
`system-auth`.

For a persistent installation, the ISO also packages `greetd`,
`greetd-regreet`, and `cage`, with a reference profile at
`/etc/greetd/config.toml.template`. It is deliberately not enabled in the
temporary VM Alpha live image: that image still auto-logs in as its disposable
live user and does not provision a real password-bearing account or a
dedicated greeter account. The graphical greeter must be enabled only after
the installed system provisions those accounts and the administrator chooses
to switch from live autologin to greetd.

## NeruOS Boot Animation

The session autostart launches `neruos-shell --boot-splash` before the full
desktop shell. This lightweight Qt Quick startup window appears as soon as
labwc is ready, without waiting for GIO application discovery or update checks.
It is fullscreen and frameless, displays the N logo with a `NeruOS` wordmark,
and fades away to reveal the desktop running behind it.

`BootAnimation.qml` recreates the supplied logo animation as native Qt Quick
Shapes: the N-shaped stroke draws in, pulses gently, and is accompanied by two
expanding ripples and three animated loading dots. The splash runs for about
five seconds and writes diagnostics to `~/.local/state/neruos-boot.log`.

The defaults are configured in the `BootAnimation` instance in
`BootSplash.qml`:

- `animationMode: "draw"` plays the logo-drawing loop. Set it to
  `"continuous"` to use the moving dash mode.
- `speedMultiplier` adjusts animation speed.
- `rippleEnabled` toggles the expanding rings.
- `loadingDotsEnabled` toggles the three loading dots.

This animation runs after the Wayland session and Qt shell have started. It is
not a firmware/UEFI splash and does not replace the Linux kernel boot screen.
