# Standalone Qt Desktop Shell Prototype

This is the NeruOS Nebula shell UI prototype built with Qt Quick/QML. It is developed as an independent set of NeruOS components rather than a KDE Plasma theme.

**Important:** the prototype is still a normal maximized application. It runs on an existing Linux desktop session and uses that session's window manager and compositor. It is not yet an independent login session or a complete desktop environment.

## Build on Arch Linux / CachyOS

Install dependencies:

~~~bash
sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-declarative qt6-svg glib2
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
- No independent login session, window manager, compositor, installer, or bootable ISO is provided.
