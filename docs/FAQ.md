# Frequently Asked Questions

## Is NeruOS ready to install?

No. NeruOS has a public VM-only live ISO, currently v0.4.0-alpha2, for disposable virtual-machine testing. It does not include a persistent installer and is not supported for installation on physical hardware.

See the [VM Alpha testing guide](VM-ALPHA.md) for downloads, checksum verification, and safe testing instructions.

## Is NeruOS just a macOS theme for Arch Linux?

No. The Nebula visual direction uses broad desktop ideas such as a clean status area and floating launcher, but NeruOS has its own shell components, interaction rules, identity, and first-party utilities.

## Does the current prototype replace KDE Plasma?

The host development prototype runs as an ordinary Qt application over an existing desktop session and does not replace it. The separate VM Alpha image starts a dedicated labwc Wayland session with the NeruOS shell. Neither provides a persistent installation yet.

## Does NeruOS manage application windows?

labwc manages native windows in the VM Alpha session, including focus, minimize/maximize, close, switching, and virtual desktops. NeruOS sends selected actions to the compositor, but its dock process indicators are still best-effort and the shell does not yet maintain a complete native toplevel list or focused-window identity.

## Can NeruOS run Windows applications?

Some Windows applications may work through compatibility layers or virtualization, but support varies. The project will document verified results rather than promise universal compatibility.

## Can I play Valorant on NeruOS?

Do not assume so. Valorant's Vanguard anti-cheat relies on Windows-specific low-level components and is not supported as a native Linux/Proton game. A supported native Windows installation may be needed. NeruOS will not try to bypass or impersonate anti-cheat checks.

## Will NeruOS use its own kernel?

Not for the initial milestones. The project starts from the Arch Linux kernel and will only consider kernel changes when there is a clear engineering reason.

## Why is labwc used?

labwc provides the Wayland compositor and window-management foundation for the VM Alpha session. This lets NeruOS focus on the shell UI and first-party utilities instead of implementing a compositor.

## How can I help?

Try the VM Alpha image safely, report bugs, suggest design improvements, improve documentation, or propose a focused change. See CONTRIBUTING.md.
