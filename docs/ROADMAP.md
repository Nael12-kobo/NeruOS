# NeruOS Roadmap

The roadmap is directional. Items are not promises of a date, and a milestone is only complete when its acceptance criteria are met.

## Milestone 0 — Public project foundation

**Status: Complete**

- [x] Establish the NeruOS name and Nebula visual direction.
- [x] Lock the initial dark / floating dock / custom wallpaper / hidden rail decisions.
- [x] Publish the design system and branding guide.
- [x] Create the logo and initial visual assets in SVG.
- [x] Create a public source repository and contribution guidelines.

## Milestone 1 — Standalone shell prototype

**Status: In progress**

- [x] Build the standalone Qt/QML shell application.
- [x] Split NeruBar and NeruDock into reusable QML components.
- [x] Add dynamic app-context menus to NeruBar.
- [x] Add pointer-driven magnification, tooltips, and active-app indicator to NeruDock.
- [x] Add keyboard shortcuts for search and workspace selection.
- [x] Keep the prototype isolated from the active desktop session and boot configuration.
- [ ] Verify on multiple resolutions and Wayland / X11 sessions.
- [ ] Add keyboard navigation and reduced-motion support to all shell components.
- [ ] Capture real runtime screenshots.

## Milestone 2 — Native application integration

**Status: Planned**

- [ ] Discover installed applications from desktop entry files.
- [ ] Launch applications through standard desktop APIs.
- [ ] Track running application state and active windows.
- [ ] Integrate focus, minimize, and close behavior.
- [ ] Replace demo app windows with real application windows.
- [ ] Define multi-monitor and fractional-scaling behavior.

## Milestone 3 — Session and system services

**Status: Planned**

- [ ] Select a window-management / compositor strategy.
- [ ] Define the standalone login session and session startup.
- [ ] Integrate real NetworkManager, PipeWire, and power-management controls.
- [ ] Integrate notifications and desktop portals.
- [ ] Add shell crash recovery and safe fallback session.
- [ ] Test Wayland and required compatibility paths.

## Milestone 4 — First-party utilities

**Status: Planned**

- [ ] NeruSettings design and navigation.
- [ ] NeruSearch launcher with local application discovery.
- [ ] NeruCenter integration with actual system services.
- [ ] NeruSpace integration with the selected compositor.
- [ ] NeruFiles requirements and design.
- [ ] NeruStore requirements and package trust model.

## Milestone 5 — System engineering

**Status: Planned**

- [ ] Define supported hardware and minimum requirements.
- [ ] Establish reproducible package build scripts.
- [ ] Define system update and rollback strategy.
- [ ] Build a testable archiso profile.
- [ ] Add an installer and recovery documentation.
- [ ] Test fresh install, upgrade, rollback, and recovery.
- [ ] Add automated CI for prototype builds and package metadata.

## Milestone 6 — Gaming and compatibility

**Status: Planned**

- [ ] Integrate Steam and document Proton setup.
- [ ] Test Vulkan and Gamescope on supported GPUs.
- [ ] Maintain a per-game compatibility test log.
- [ ] Document controller, audio, and capture behavior.
- [ ] Clearly list anti-cheat limitations.
- [ ] Keep native Windows as a fallback for incompatible titles.

## Milestone 7 — Alpha release

**Status: Not started**

An alpha ISO will only be published after the session, installer, boot flow, system updates, recovery, and hardware support have been exercised on test machines. No ISO is currently available.

## Proposing roadmap changes

Open an issue with the milestone, user problem, proposed outcome, risk, and acceptance criteria. Large changes should be discussed before implementation.
