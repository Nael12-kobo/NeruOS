# NeruOS Roadmap

The roadmap is directional. Items are not promises of a date, and a milestone is only complete when its acceptance criteria are met.

## Milestone 0 — Public project foundation

**Status: In progress**

- [x] Establish the NeruOS name and Nebula visual direction.
- [x] Lock the initial dark / floating dock / custom wallpaper / hidden rail decisions.
- [x] Publish the design system and branding guide.
- [x] Create the logo and initial visual assets in SVG.
- [x] Add a standalone Qt/QML desktop prototype.
- [ ] Verify a clean build on a supported Arch Linux or CachyOS development machine.
- [ ] Capture real runtime screenshots and replace concept-only imagery where appropriate.

## Milestone 1 — Plasma integration

**Status: Planned**

- [ ] Create a Plasma Global Theme package.
- [ ] Create Nebula Plasma Style and color scheme.
- [ ] Create a matching icon theme.
- [ ] Build a panel layout that matches the Nebula design.
- [ ] Prototype NeruBar and NeruDock as maintainable Plasma components.
- [ ] Test Wayland and X11 behavior where relevant.
- [ ] Add keyboard navigation and reduced-motion settings.

## Milestone 2 — First-party desktop utilities

**Status: Planned**

- [ ] NeruSettings design and navigation.
- [ ] NeruSearch launcher with local application discovery.
- [ ] NeruCenter integration with actual system services.
- [ ] NeruSpace workspace presets.
- [ ] NeruFiles requirements and design.
- [ ] NeruStore requirements and package trust model.

## Milestone 3 — System engineering

**Status: Planned**

- [ ] Define supported hardware and minimum requirements.
- [ ] Establish reproducible package build scripts.
- [ ] Define system update and rollback strategy.
- [ ] Build a testable archiso profile.
- [ ] Add an installer and recovery documentation.
- [ ] Test fresh install, upgrade, rollback, and recovery.
- [ ] Add automated CI for prototype builds and package metadata.

## Milestone 4 — Gaming and compatibility

**Status: Planned**

- [ ] Integrate Steam and document Proton setup.
- [ ] Test Vulkan and Gamescope on supported GPUs.
- [ ] Maintain a per-game compatibility test log.
- [ ] Document controller, audio, and capture behavior.
- [ ] Clearly list anti-cheat limitations.
- [ ] Keep native Windows as a fallback for incompatible titles.

## Milestone 5 — Alpha release

**Status: Not started**

An alpha ISO will only be published after the installer, boot flow, system updates, recovery, and hardware support have been exercised on test machines. No ISO is currently available.

## Proposing roadmap changes

Open an issue with the milestone, user problem, proposed outcome, risk, and acceptance criteria. Large changes should be discussed before implementation.
