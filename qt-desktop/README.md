# Qt Desktop Prototype

This is a standalone Qt Quick/QML application used to explore the NeruOS Nebula desktop. It is **not** a Plasma shell replacement or a complete operating system.

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

Or run ./build.sh from this directory.

## Prototype interactions

- Use the floating dock to open demo application windows.
- Use the search button to open NeruSearch.
- Use the status button to open NeruCenter.
- Move the pointer to the far-left screen edge to reveal the navigation rail.
- Switch between General, Coding, Gaming, and Study workspace labels.
- Open NeruSettings and choose a custom wallpaper.
- Press Escape to dismiss open overlays and demo windows.

All controls are local UI demonstrations. They do not yet control NetworkManager, audio, brightness, power management, or real application launching.
