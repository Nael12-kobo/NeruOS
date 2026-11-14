# NeruOS Standalone Desktop Shell

## Product direction

NeruOS develops its own shell UI in Qt 6 / QML. The shell is not intended to be a KDE Plasma theme. The selected direction is a set of small components that share Nebula design tokens and communicate through signals and explicit properties.

## Component map

| Component | Responsibility | Prototype state |
|---|---|---|
| NeruBar | Active-app menu, clock, status actions | Dynamic menu groups and clickable menu actions |
| NeruDock | Floating app launcher, magnification, active indicator | Pointer-driven scaling, tooltips, demo-app selection |
| NeruCenter | Quick settings / notification surface | UI state only |
| NeruSearch | App and settings launcher | Local suggestions and shortcut |
| NeruSpace | Workspace identity | Four selectable labels and shortcuts |
| Navigation Rail | Secondary app navigation | Hidden edge-triggered panel |

## NeruDock magnification behavior

1. Pointer position is mapped into the dock's local coordinate system.
2. Each icon compares its center position with the pointer's horizontal position.
3. A distance-based scale factor is calculated.
4. A short eased animation updates the icon scale.
5. When the pointer leaves the icon, the scale returns to its resting value.
6. The selected demo application receives an indicator.

The magnification is visual only. It does not affect native window focus or task state yet.

## NeruBar dynamic context

NeruBar receives the active demo application's name from the parent shell. It builds a menu group for that context:

- Desktop: NeruOS, File, View, Workspace, Window, Help.
- NeruFiles: File, Edit, View, Go, Window, Help.
- NeruCode: File, Edit, Selection, View, Run, Terminal, Help.
- NeruSettings: NeruSettings, Appearance, Desktop, System, Help.
- Steam: Steam, View, Friends, Games, Help.
- NeruStore: Store, Categories, Library, Help.

The current menu actions are local prototype commands. They demonstrate shell navigation and state changes; they are not application-specific native menu integration.

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

The prototype does not yet provide:
- A dedicated login session or display-manager entry.
- Window placement, stacking, minimization, focus, or multi-monitor policy.
- Native app task tracking or app lifecycle management.
- A compositor or Wayland display server.
- Real system service controls.

A later engineering decision must determine whether NeruOS integrates a supported compositor/window manager or adopts another documented route. The project must not imply a standalone Qt UI automatically replaces those system layers.

## Next implementation work

1. Native application discovery using desktop entry files.
2. Launch applications with standard desktop APIs.
3. Observe running app / window state through the selected session architecture.
4. Connect NeruCenter to real user-session services with least privilege.
5. Decide compositor and independent session strategy.
