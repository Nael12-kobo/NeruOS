# Frequently Asked Questions

## Is NeruOS ready to install?

No. NeruOS is in its early design and prototype stage. There is no bootable ISO or supported installer yet.

## Is this just a macOS theme for Arch Linux?

No. The Nebula visual direction borrows broad ideas such as a clean global status area and floating launcher, but the project is intended to develop its own interaction rules, components, identity, and applications.

## Does the current prototype replace KDE Plasma?

No. It is a standalone Qt/QML application that runs on top of an existing desktop session. Plasma integration is a future milestone.

## Can NeruOS run Windows applications?

Some Windows applications may work through compatibility layers or virtualization, but support varies. The project will document verified results rather than promise universal compatibility.

## Can I play Valorant on NeruOS?

Do not assume so. Valorant's Vanguard anti-cheat relies on Windows-specific low-level components and is not supported as a native Linux/Proton game. A supported native Windows installation may be needed. NeruOS will not try to bypass or impersonate anti-cheat checks.

## Will NeruOS use its own kernel?

Not for the initial milestone. The project starts from the Arch Linux kernel and will only consider kernel changes when there is a clear engineering reason.

## Why KDE Plasma first?

Plasma and KWin provide mature window management and desktop infrastructure. Starting there lets the project focus on the Nebula identity and utilities rather than rebuilding every desktop subsystem at once.

## How can I help?

Try the prototype, report bugs, suggest design improvements, improve documentation, or propose a focused change. See CONTRIBUTING.md.
