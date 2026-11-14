# NeruOS Standalone Desktop Shell

## Product direction

NeruOS develops its own shell UI in Qt 6 / QML. The shell is not intended to be a KDE Plasma theme. The current architecture is a set of small components that share Nebula design tokens and communicate through signals and explicit properties.

## Component map

| Component | Responsibility | Prototype state |
|---|---|---|
| NeruBar | Active demo-app menu, clock, status actions | Dynamic menu groups and clickable prototype actions |
| NeruDock | Floating app launcher, magnification, app aliases | Pointer-driven scaling, tooltips, native GIO launch requests |
| NeruSearch | Discover, filter, launch installed Linux apps | GIO catalog and process status |
| NeruCenter | Quick settings / notification surface | UI state only |
| NeruSpace | Workspace identity | Four selectable labels and shortcuts |
| Navigation Rail | Secondary app navigation | Hidden edge-triggered panel |

## Application discovery and launch

NeruSearch uses GIO to enumerate visible installed desktop entries and launch them through the desktop entry's application metadata.

Process status is a best-effort match between each entry's executable and process names visible in /proc. It can miss D-Bus, sandboxed, wrapped, or helper-based applications and can mark multiple entries that share an executable. It is not active-window tracking.

See [Application Discovery and Launch](APPLICATION-LAUNCHING.md).

## NeruDock magnification behavior

1. Pointer position is mapped into the dock's local coordinate system.
2. Each icon compares its center position with the pointer's horizontal position.
3. A distance-based scale factor is calculated.
4. A short eased animation updates the icon scale.
5. When the pointer leaves the icon, the scale returns to its resting value.

The dock can launch known application aliases through the catalog. The dock's original demo-app indicator is not yet a full native-window task indicator.

## NeruBar dynamic context

NeruBar receives the selected demo application's name from the parent shell. It builds a menu group for that context:

- Desktop: NeruOS, File, View, Workspace, Window, Help.
- NeruFiles: File, Edit, View, Go, Window, Help.
- NeruCode: File, Edit, Selection, View, Run, Terminal, Help.
- NeruSettings: NeruSettings, Appearance, Desktop, System, Help.
- Steam: Steam, View, Friends, Games, Help.
- NeruStore: Store, Categories, Library, Help.

Native application launching does not yet update the global app menu from the actual focused native window. That requires window-manager integration.

## Keyboard interaction

| Shortcut | Action |
|---|---|
| Alt + Space | Toggle NeruSearch |
| Escape | Close transient panels and demo window |
| Ctrl + Alt + 1 | Select General |
| Ctrl + Alt + 2 | Select Coding |
| Ctrl + Alt + 3 | Select Gaming |
| Ctrl + Alt + 4 | Select Study |

## Prototype boundary: shell vs compositor

A desktop shell and a compositor/window manager are different responsibilities.

The current prototype is a normal maximized Qt application. It relies on the host desktop session to:
- Create and manage the application window.
- Render the surface and route pointer / keyboard events.
- Manage focus, other windows, display outputs, and workspaces.

The prototype does not yet:
- Replace KWin, Mutter, or another window manager / compositor.
- Provide a dedicated login session or display-manager entry.
- Manage native application windows, focus, minimize, or close.
- Know which native window is active.
- Own system notifications or hardware controls.
- Provide an installer or bootable ISO.

A later engineering decision must determine whether NeruOS integrates a supported compositor/window manager or adopts another explicit route. A shell UI does not automatically supply window management.

## Next implementation work

1. Native application discovery and launch have an initial GIO implementation.
2. Integrate native app/window state with a selected session architecture.
3. Connect NeruCenter to real user-session services with least privilege.
4. Decide compositor and independent session strategy.
