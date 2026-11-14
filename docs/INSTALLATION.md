# Development Installation

NeruOS does not have an installable ISO yet. This guide explains how to build the current standalone shell prototype on an existing Arch Linux or CachyOS system.

## Safety

The current prototype is an ordinary maximized application. It does not replace KDE Plasma, install a display manager, modify boot entries, repartition disks, or change system settings.

Do not run prototype code with sudo.

## Dependencies

~~~bash
sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-declarative qt6-svg
~~~

Qt 6.5 or newer is required by the current CMake configuration.

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

Or build and run with:

~~~bash
chmod +x build.sh
./build.sh
~~~

## Prototype controls

- Hover over NeruDock icons to magnify them.
- Click a dock icon to open its demo window.
- NeruBar's menu labels change according to the selected demo application.
- Use the NeruBar search icon or Alt+Space to open NeruSearch.
- Use the status controls to open NeruCenter.
- Move the pointer to the far-left screen edge to reveal the hidden navigation rail.
- Select General, Coding, Gaming, or Study in the workspace strip.
- Use Ctrl+Alt+1 through Ctrl+Alt+4 to change workspace labels.
- Open NeruSettings and choose a wallpaper.
- Press Escape to close transient UI.

The dock, menus, workspace selector, and app windows are prototype-level interactions. They do not yet manage native windows or actually change system hardware settings.

## Session architecture note

The application runs above the current desktop session and still uses its window manager / compositor. “Standalone shell” describes the direction and component architecture; this prototype is not yet an independent login session or desktop environment.

## Troubleshooting

### CMake cannot find Qt 6

Confirm the packages are installed and that Qt CMake package files are available. Install qt6-base and qt6-declarative, then rerun configuration from a clean build directory.

### SVG wallpaper or logo does not render

Install qt6-svg. If the SVG image plugin still cannot be found, check the Qt plugin paths for the active Qt installation.

### The prototype does not start

Run it from the terminal and include the complete error output when opening an issue. Include your distro, Qt version, graphics session (Wayland or X11), and GPU model.

## Uninstall

Close the application and remove the cloned repository and its build directory. No system-wide NeruOS shell components are installed by this prototype.
