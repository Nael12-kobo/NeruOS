# Application Discovery, Launch, and Process Status

## Discovery

NeruOS uses GLib/GIO's application information API to read launchable desktop applications available to the current user session.

The current catalog:
- Enumerates visible GAppInfo entries.
- Skips entries that the desktop environment marks as hidden.
- Stores the application display name, desktop file ID, description, and executable.
- Sorts entries by display name.
- Exposes them as a Qt list model for NeruSearch.
- Can be refreshed from the search panel.

This uses the desktop entry ecosystem instead of attempting to parse each Exec field manually.

## Native launch

A selected result is launched through g_app_info_launch() with a GAppLaunchContext. GIO is responsible for interpreting the desktop entry's launch configuration and field codes.

The dock uses a small set of friendly aliases that map to common installed applications. For example, NeruFiles tries common Linux file managers, while NeruTerminal tries common terminal emulators. If none of the preferred applications is installed, NeruOS reports that no matching application is available and asks the user to choose from NeruSearch.

An alias is convenience logic, not a guaranteed package dependency.

## Process status

The catalog periodically scans visible /proc process entries and compares the process executable name with the executable exposed by each desktop entry.

This is deliberately described as **best-effort process status**, not definitive running-window state.

The UI uses three labels:

- **Running** — a matching process name was detected.
- **Not detected** — the executable is distinctive enough to track, but no matching process was found. This does not prove that no related window or helper process exists.
- **Unverified** — the entry uses a generic launcher or shares its executable with another entry, so the process name cannot identify that app reliably.

Known limitations:
- D-Bus-activated apps can delegate work to an existing service process.
- Sandboxed apps, wrapper scripts, helper processes, and launchers may use a different executable name.
- Two desktop entries can refer to the same executable and therefore share a process indicator.
- A process may exist without a visible window.
- A visible window can use a different process than the desktop entry executable.
- The current prototype does not know which native window is focused or on which workspace it appears.

A future desktop-session integration must use the selected compositor/window manager's supported APIs to track actual windows, activation, focus, and lifecycle.

## CLI diagnostics

After building the prototype, list visible launchable entries from the terminal:

~~~bash
./build/neruos-nebula --list-apps
~~~

This command prints the application count, display name, desktop ID, executable, and best-effort process state without opening the shell UI.

To open the search panel immediately for UI testing, use:

~~~bash
./build/neruos-nebula --show-search
~~~

A launch-and-detection diagnostic is also available:

~~~bash
./build/neruos-nebula --launch-app org.kde.dolphin.desktop
~~~

It launches the selected desktop entry through GIO, waits briefly, then reports whether its executable process was detected. Use a known, trackable desktop entry when running this diagnostic; generic launchers are reported as unverified in the UI.

## Security

- The prototype does not run as root.
- It delegates launch handling to GIO.
- It does not construct a shell command from an application's display name.
- It does not execute arbitrary search text.
- Launch errors are surfaced in the UI.
