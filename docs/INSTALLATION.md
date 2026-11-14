# Development Installation

NeruOS does not have an installable ISO yet. This guide explains how to build the current standalone UI prototype on an existing Arch Linux or CachyOS system.

## Safety

The current prototype is an ordinary application. It does not replace KDE Plasma, install a display manager, modify boot entries, repartition disks, or change system settings.

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

To build and run in one step:

~~~bash
chmod +x build.sh
./build.sh
~~~

## Troubleshooting

### CMake cannot find Qt 6

Confirm the packages are installed and that Qt CMake package files are available. Install qt6-base and qt6-declarative, then rerun configuration from a clean build directory.

### SVG wallpaper or logo does not render

Install qt6-svg. If the SVG image plugin still cannot be found, check the Qt plugin paths for the active Qt installation.

### The prototype does not start

Run it from the terminal and include the complete error output when opening an issue. Include your distro, Qt version, graphics session (Wayland or X11), and GPU model.

## Uninstall

Close the application and remove the cloned repository and its build directory. No system-wide NeruOS shell components are installed by this prototype.
