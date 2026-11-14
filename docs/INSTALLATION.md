# Development Installation

NeruOS does not yet provide a persistent installer. A separate VM-only live ISO is published for disposable virtual-machine testing; it is not an installation image. This guide explains how to build the standalone shell prototype on an existing Arch Linux or CachyOS system.

## Safety

The current prototype is an ordinary maximized application. It does not replace KDE Plasma, install a display manager, modify boot entries, repartition disks, or change system settings.

Do not run prototype code with sudo.

## Dependencies

~~~bash
sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-declarative qt6-svg glib2 pacman-contrib
~~~

Qt 6.5 or newer and GLib/GIO 2.0 development files are required.

## Get the source

~~~bash
git clone https://github.com/Nael12-kobo/NeruOS.git
cd NeruOS/qt-desktop
~~~

## Configure and compile

~~~bash
cmake -S . -B build -G Ninja
cmake --build build
~~~

## Run

~~~bash
./build/neruos-nebula
~~~

## Inspect installed applications

~~~bash
./build/neruos-nebula --list-apps
~~~

Open NeruSearch immediately for a quick UI check:

~~~bash
./build/neruos-nebula --show-search
~~~

To launch a known desktop entry and run a short process-detection diagnostic:

~~~bash
./build/neruos-nebula --launch-app org.kde.dolphin.desktop
~~~

## Prototype controls

- Hover over NeruDock icons to magnify them.
- Click a dock alias to launch a matching installed Linux app through GIO. NeruSearch opens the installed application catalog.
- Search installed apps by display name and click a row to launch it.
- NeruSearch shows best-effort process status based on /proc executable-name matching.
- Use the NeruBar search icon or Alt+Space to open NeruSearch.
- Use the status controls to open NeruCenter.
- Move the pointer to the far-left screen edge to reveal the hidden navigation rail.
- Select General, Coding, Gaming, or Study in the workspace strip.
- Use Ctrl+Alt+1 through Ctrl+Alt+4 to change workspace labels.
- Open NeruSettings and choose a wallpaper.
- Press Escape to close transient UI.

The dock's running indicators are still based on best-effort process-name matching, not native window identity. Workspace and basic window actions are sent through wtype and require matching compositor key bindings; the VM Alpha labwc profile supplies those bindings. They are not a replacement for a native toplevel-management API.

NeruCenter reads and controls real session services when available: NetworkManager for Wi-Fi, PipeWire/WirePlumber for audio, and BlueZ for Bluetooth. Brightness and battery depend on hardware interfaces and user permissions. Controls report unavailable when a service, device, or authorization is missing; the shell does not run as root to force access.

The Session Panel uses systemd-logind for session and power actions and swaylock for screen locking when those tools and policies are present.

## Session architecture note

The application runs above the current desktop session and still uses its window manager / compositor. “Standalone shell” describes the direction and component architecture; this prototype is not yet an independent login session or complete desktop environment.

## Troubleshooting

### CMake cannot find Qt 6 or GIO

Confirm the packages are installed. On Arch Linux, install qt6-base, qt6-declarative, qt6-svg, and glib2, then rerun configuration from a clean build directory.

### An application does not appear

NeruSearch currently shows desktop entries that GIO considers visible. Some packages provide no desktop entry, mark entries hidden, or register applications through other mechanisms.

### An application does not launch

GIO launch errors are shown in a small notification. Check that the desktop entry is valid and that the required executable and dependencies are installed.

### Running status is inaccurate

The current tracker matches the desktop entry executable against visible /proc process names. Helper launchers, D-Bus services, sandbox wrappers, and multiple entries sharing an executable can make the status approximate.

### SVG wallpaper or logo does not render

Install qt6-svg. If the SVG image plugin still cannot be found, check the Qt plugin paths for the active Qt installation.

### The prototype does not start

Run it from the terminal and include the complete error output when opening an issue. Include your distro, Qt version, graphics session (Wayland or X11), and GPU model.

## Uninstall

Close the application and remove the cloned repository and its build directory. No system-wide NeruOS shell components are installed by this prototype.
