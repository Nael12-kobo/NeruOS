# Standalone Qt Desktop Shell Prototype

This is the NeruOS Nebula shell UI prototype built with Qt Quick/QML. It is developed as an independent set of NeruOS components rather than a KDE Plasma theme.

**Important:** the prototype is still a normal maximized application. It runs on an existing Linux desktop session and uses that session's window manager and compositor. It is not yet an independent login session or a complete desktop environment.

## Build on Arch Linux / CachyOS

Install dependencies:

~~~bash
sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-declarative qt6-svg
~~~

Configure, compile, and run:

~~~bash
cmake -S . -B build -G Ninja
cmake --build build
./build/neruos-nebula
~~~

Or run `./build.sh` from this directory.

## v0.2 interactions

### NeruDock

- Hover over an app icon to magnify it.
- Nearby icons respond with a smaller scale based on pointer distance.
- Icons animate smoothly and show a tooltip.
- An indicator dot marks the currently open demo app.
- Click an icon to open its demo window.

### NeruBar

- Menu labels change based on the selected demo app.
- File, Code, Settings, Steam, and Store contexts have different menu groups.
- Menu actions can open demo apps, change workspace labels, select a wallpaper, or show shell information.
- Status buttons open NeruCenter.
- Search opens from the top bar or with `Alt+Space`.

### NeruSpace

- Select General, Coding, Gaming, or Study.
- Use `Ctrl+Alt+1` through `Ctrl+Alt+4` to switch workspace labels.

### Other controls

- Move the pointer to the far-left screen edge to reveal the hidden navigation rail.
- Open NeruSettings to choose a wallpaper for the current session.
- Press Escape to close transient UI.

## Current limitations

- Dock app windows are illustrative demo windows, not native application windows.
- Dock active state tracks the selected demo app only.
- NeruCenter values are local UI state and do not alter NetworkManager, Bluetooth, audio, brightness, or power settings.
- Workspace selection changes the prototype's workspace label only; it is not yet connected to a compositor.
- No independent login session, window manager, compositor, installer, or bootable ISO is provided.

The next shell milestone is native application discovery / launching, followed by an explicit window-management and session architecture decision.
