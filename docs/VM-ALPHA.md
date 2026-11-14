# NeruOS VM Alpha — Safe Testing Guide

## Purpose

NeruOS VM Alpha is a live ISO intended for virtual-machine testing only. It is not an installer and it must not be used as a daily-driver system.

The ISO boots an Arch Linux live environment with the NeruOS Nebula shell on a lightweight Wayland session. The x86_64 image supports UEFI through a themed GRUB menu and Legacy BIOS through the ArchISO-supported Syslinux compatibility path. Both menus share the NeruOS dark navy and blue-violet visual identity.

## Safety model

- The ISO boots from read-only installation media.
- No installer is included.
- No host disks are attached by the QEMU helper script.
- The live root filesystem uses a temporary writable overlay.
- Changes made inside the VM disappear when the live session is shut down.
- The build scripts do not use sudo and do not install packages into the host operating system.
- A recovery terminal can be opened with Super+Enter.

For an additional safety boundary, do not attach shared folders or host block devices while testing an early alpha.

## VM recommendations

| Setting | Recommendation |
|---|---|
| Firmware | UEFI / EFI (themed GRUB) or Legacy BIOS (Syslinux compatibility menu) |
| RAM | 4 GB minimum; 6 GB recommended |
| CPU | 2 cores minimum; 4 recommended |
| Display | Virtio / standard virtual graphics |
| Storage | No virtual disk required for live testing |
| Network | NAT / user-mode networking |
| ISO | x86_64 hybrid live image (UEFI + Legacy BIOS) |

The ISO is built for x86_64 and includes both UEFI and Legacy BIOS boot paths. UEFI displays the full NeruOS GRUB theme. Legacy BIOS uses Syslinux because the ArchISO build framework used by this repository provides BIOS boot through Syslinux; it shares the NeruOS background image and color palette.

## Build the ISO on Arch Linux / CachyOS

From the repository root:

~~~bash
./scripts/build-vm-iso.sh
~~~

The build helper:
1. Fetches the official Arch archiso source if it is not already present.
2. Downloads required build utilities into .cache/iso-tools.
3. Builds the NeruOS shell.
4. Validates the QML files.
5. Copies the shell into the live image profile.
6. Runs the ArchISO build in an unprivileged user namespace.
7. Writes the ISO into dist/.

The UEFI GRUB theme assets live in `iso/profile/grub/theme/`. The menu configuration
is in `iso/profile/grub/grub.cfg`. Legacy BIOS menu files and its splash image
are in `iso/profile/syslinux/`. GRUB's image and font assets are bundled into the
ISO; the build does not install GRUB or other packages on the CachyOS host.

It does not call sudo. If unprivileged user namespaces are disabled, the script exits rather than attempting a privileged build.

## Run with QEMU

~~~bash
./scripts/run-vm-alpha.sh
~~~

Or pass an explicit ISO path:

~~~bash
./scripts/run-vm-alpha.sh dist/neruos-vm-alpha-0.4.0-alpha1-x86_64.iso
~~~

To test the Legacy BIOS / Syslinux path:

~~~bash
./scripts/run-vm-alpha-bios.sh
~~~

The helper uses a temporary, diskless VM configuration and does not attach a writable host disk.

## Run with VirtualBox

1. Create a new Linux (64-bit) virtual machine.
2. Give it at least 4 GB RAM and 2–4 CPU cores.
3. Enable EFI in System → Motherboard.
4. Open Storage and attach the NeruOS ISO to the virtual optical drive.
5. Leave the virtual disk empty or detach it.
6. Set Network to NAT.
7. Start the VM and select the NeruOS live boot entry.

Do not select an installer or partitioning option: this alpha does not contain an installer.

## Live-session controls

| Shortcut | Action |
|---|---|
| Super + Enter | Open recovery terminal |
| Super + E | Open file manager |
| Alt + Tab | Switch application windows |
| Alt + F4 | Close focused window |
| Super + Q | Exit the NeruOS session |

The autologin starts the live user session and launches labwc. NeruOS starts automatically from the labwc autostart file. If the shell exits, the recovery helper opens a terminal.

## Testing checklist

- [ ] UEFI boot entry is named NeruOS Nebula Edition.
- [ ] The default live entry starts without a 15-second boot-menu delay.
- [ ] Live user session starts.
- [ ] labwc starts without a black screen.
- [ ] NeruOS shell opens automatically.
- [ ] NeruOS Boot Animation shows the animated N logo, ripples, and loading dots.
- [ ] Boot Animation fades into the Nebula desktop.
- [ ] NeruDock magnification works.
- [ ] NeruSearch lists installed desktop applications.
- [ ] A native Linux application launches.
- [ ] Super+Enter opens the recovery terminal.
- [ ] Network connectivity works.
- [ ] Update checker shows package status.
- [ ] Shutdown and reboot return to the ISO without changing host disks.

## v0.4.0-alpha1 release smoke test

The current v0.4.0-alpha1 ISO was rebuilt with the Nebula desktop services and booted in a diskless QEMU UEFI VM. The VM reached the animated NeruOS splash and then the full desktop, including the top menu bar, Nebula wallpaper, dock, and System Updates panel.

Verified during this run:
- [x] UEFI ISO boot reaches the NeruOS Boot Animation.
- [x] Boot Animation transitions to the full Nebula desktop.
- [x] Top menu bar and floating dock render.
- [x] System Updates panel opens and reports package status.
- [x] The QEMU helper attaches no host disk.

The following remain hardware- or path-specific and should be tested separately:
- [ ] Legacy BIOS boot and full desktop. In the current SeaBIOS/QEMU run, the Syslinux path did not reach the NeruOS desktop; the last captured screens remained on a dark boot/loading background.
- [ ] Wi-Fi hardware and polkit authorization on a physical device.
- [ ] Audio output and volume through PipeWire/WirePlumber.
- [ ] Bluetooth controller availability and power toggling.
- [ ] Physical display brightness and battery reporting.
- [ ] Lock, logout, suspend, restart, and power-off on an installed persistent system.

A successful build is not considered a complete hardware release until this checklist has been run on the target devices.
