# NeruOS VM Alpha — Safe Testing Guide

## Purpose

NeruOS VM Alpha is a live ISO intended for virtual-machine testing only. It is not an installer and it must not be used as a daily-driver system.

The ISO boots an Arch Linux live environment with the NeruOS Nebula shell on a lightweight Wayland session.

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
| Firmware | UEFI / EFI enabled |
| RAM | 4 GB minimum; 6 GB recommended |
| CPU | 2 cores minimum; 4 recommended |
| Display | Virtio / standard virtual graphics |
| Storage | No virtual disk required for live testing |
| Network | NAT / user-mode networking |
| ISO | x86_64 UEFI live image |

The ISO is currently built for x86_64 UEFI. Legacy BIOS boot is not included in this first VM profile.

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

It does not call sudo. If unprivileged user namespaces are disabled, the script exits rather than attempting a privileged build.

## Run with QEMU

~~~bash
./scripts/run-vm-alpha.sh
~~~

Or pass an explicit ISO path:

~~~bash
./scripts/run-vm-alpha.sh dist/neruos-vm-alpha-0.4.0-alpha1-x86_64.iso
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

- [ ] UEFI boot entry appears.
- [ ] Live user session starts.
- [ ] labwc starts without a black screen.
- [ ] NeruOS shell opens automatically.
- [ ] NeruDock magnification works.
- [ ] NeruSearch lists installed desktop applications.
- [ ] A native Linux application launches.
- [ ] Super+Enter opens the recovery terminal.
- [ ] Network connectivity works.
- [ ] Update checker shows package status.
- [ ] Shutdown and reboot return to the ISO without changing host disks.

A successful build is not considered a successful release until this checklist has been run in a VM.
