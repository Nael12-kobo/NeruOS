# NeruOS Roadmap

The roadmap is directional. Items are not promises of a date, and a milestone is complete only when its acceptance criteria are met. Status reflects the main source branch and public VM Alpha state as of 14 November 2026. The latest public image is v0.4.0-alpha3.

## Milestone 0 — Public project foundation

**Status: Complete**

- [x] Establish the NeruOS name and Nebula visual direction.
- [x] Lock the initial dark / floating dock / custom wallpaper / hidden rail decisions.
- [x] Publish the design system and branding guide.
- [x] Create the logo and initial visual assets in SVG.
- [x] Create a public source repository and contribution guidelines.

## Milestone 1 — Nebula desktop shell

**Status: In progress**

- [x] Build the Qt 6 / C++ / QML shell and reusable desktop components.
- [x] Add NeruBar menus, system status, clock, and quick actions.
- [x] Add NeruDock icons, aliases, tooltips, and pointer-driven magnification.
- [x] Add NeruSearch with GIO desktop-entry discovery and application launch.
- [x] Add NeruFiles, NeruSettings, NeruCenter, Notification Center, and Session Panel.
- [x] Add boot animation and saved appearance / dock preferences.
- [x] Use compositor-backed native window state for dock indicators and app activation when the WLR protocol is available; retain process fallback elsewhere.
- [ ] Complete keyboard navigation and reduced-motion behavior across shell components.
- [ ] Verify layouts on multiple resolutions, fractional scaling, and multi-monitor setups.

## Milestone 2 — Native window integration

**Status: In progress**

- [x] Select labwc as the Wayland compositor / window manager for the VM Alpha session.
- [x] Delegate native window management and virtual desktops to labwc.
- [x] Connect core workspace and window actions through compositor keyboard shortcuts.
- [x] Consume native toplevel title, app ID, state, and active-window updates through the WLR foreign-toplevel protocol.
- [x] Map native app IDs to dock aliases, show running/active indicators, and activate an existing matching window on click.
- [ ] Drive NeruBar application context from the focused native window.
- [x] Add native-handle activation, minimize, maximize, and close operations to the window model.
- [ ] Wire minimize/maximize/close into dedicated NeruOS UI controls and test them in the labwc VM.
- [x] Run native-window discovery smoke test inside the VM Alpha labwc session and verify app IDs, focus state, and the dock running indicator.
- [ ] Define multi-monitor and fractional-scaling behavior.

## Milestone 3 — Session and system services

**Status: In progress**

- [x] Read and control Wi-Fi through NetworkManager where the session user is authorized.
- [x] Read and control volume through PipeWire / WirePlumber.
- [x] Read and control Bluetooth through BlueZ with bounded command execution.
- [x] Report brightness and battery only when the hardware exposes usable devices.
- [x] Receive desktop notifications through the session D-Bus.
- [x] Use systemd-logind for session and power actions.
- [x] Provide a PAM-backed screen lock using swaylock.
- [ ] Integrate desktop portals and verify file-picker / screen-sharing permissions.
- [ ] Add shell crash recovery and a safe fallback session.
- [ ] Exercise network, audio, Bluetooth, lock, suspend, reboot, and power-off on physical hardware.

## Milestone 4 — First-party utilities

**Status: In progress**

- [x] Implement NeruSettings for saved wallpaper, appearance, accent, and dock preferences.
- [x] Implement NeruFiles with navigation and basic file operations.
- [x] Implement NeruSearch for installed Linux application discovery and launch.
- [x] Implement NeruCenter hardware status and controls where supported.
- [x] Implement Notification Center and Session Panel.
- [ ] Expand search indexing beyond desktop-entry display names.
- [ ] Define NeruStore requirements, package sources, signature checks, and trust model.

## Milestone 5 — System engineering

**Status: In progress**

- [x] Create an ArchISO-based x86_64 live profile.
- [x] Build the image through a repository-local helper without installing packages on the host.
- [x] Provide diskless VM launch helpers for UEFI and Legacy BIOS testing.
- [x] Document VM safety, build steps, boot paths, and smoke-test results.
- [ ] Define supported hardware and minimum requirements from real test results.
- [ ] Establish a signed NeruOS package repository and project update channel.
- [ ] Implement a persistent installer and first-boot account provisioning.
- [ ] Implement upgrade, rollback, and recovery flows.
- [ ] Add automated tests for shell behavior, package metadata, and image release gates.

## Milestone 6 — Gaming and compatibility

**Status: Planned**

- [ ] Integrate Steam and document Proton setup.
- [ ] Test Vulkan and Gamescope on supported GPUs.
- [ ] Maintain a per-game compatibility test log.
- [ ] Document controller, audio, and capture behavior.
- [ ] Clearly list anti-cheat limitations and retain a native Windows fallback for incompatible titles.

## Milestone 7 — VM Alpha release

**Status: Published — v0.4.0-alpha3 (14 November 2026)**

- [x] Publish the x86_64 live ISO with UEFI GRUB and Legacy BIOS Syslinux boot paths.
- [x] Boot to the Nebula desktop through the UEFI VM path.
- [x] Boot to the Nebula desktop through the Legacy BIOS / Syslinux path in QEMU.
- [x] Verify core shell windows, workspaces, notifications, and available VM hardware status.
- [x] Verify labwc native toplevel discovery and NeruDock running indicators in the guest.
- [x] Publish the v0.4.0-alpha3 ISO and SHA-256 checksum in the GitHub prerelease.
- [x] Keep the image VM-only, without an installer or host-disk attachment in the supplied VM helper scripts.
- [ ] Collect additional VM compatibility reports and maintain a repeatable regression matrix.

A published VM Alpha is a disposable testing image. It is not a persistent installer and does not establish physical-hardware readiness.

## Milestone 8 — Persistent installation and Hardware Alpha

**Status: Planned**

- [ ] Finalize the supported hardware list and installation requirements.
- [ ] Implement and test a persistent installer with safe disk-selection safeguards.
- [ ] Provision user accounts, login manager, permissions, and recovery access.
- [ ] Sign project packages and update metadata; verify upgrade and rollback behavior.
- [ ] Test boot, graphics, networking, audio, Bluetooth, battery, suspend, and recovery on target laptops.
- [ ] Publish a hardware Alpha only after installation, update, rollback, and recovery acceptance tests pass.

## Proposing roadmap changes

Open an issue with the milestone, user problem, proposed outcome, risk, and acceptance criteria. Large architectural changes should be discussed before implementation.
