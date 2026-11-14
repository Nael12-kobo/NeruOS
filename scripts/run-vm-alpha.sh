#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$BASH_SOURCE")/.." && pwd)"
OUT="$ROOT/dist"
ISO=""
if [[ $# -gt 0 ]]; then
    ISO="$1"
fi

if [[ -z "$ISO" ]]; then
    ISO="$(find "$OUT" -maxdepth 1 -type f -name '*.iso' -printf '%T@ %p\n' | sort -nr | head -1 | cut -d' ' -f2-)"
fi

if [[ -z "$ISO" || ! -f "$ISO" ]]; then
    printf 'No ISO found. Build one first with scripts/build-vm-iso.sh\n' >&2
    exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    printf 'qemu-system-x86_64 is required to run the VM test.\n' >&2
    exit 1
fi

OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS="/usr/share/edk2/x64/OVMF_VARS.4m.fd"
if [[ ! -r "$OVMF_CODE" || ! -r "$OVMF_VARS" ]]; then
    printf 'UEFI firmware not found. Install edk2-ovmf on the host, or boot the ISO in VirtualBox with EFI enabled.\n' >&2
    exit 1
fi

# UEFI variables are writable, so use a disposable copy outside the project.
# No virtual hard disk or host block device is attached to this VM.
TMPBASE="$TMPDIR"
if [[ -z "$TMPBASE" ]]; then
    TMPBASE="/tmp"
fi
VM_STATE="$(mktemp -d "$TMPBASE/neruos-vm-alpha.XXXXXX")"
trap 'rm -rf -- "$VM_STATE"' EXIT
cp -- "$OVMF_VARS" "$VM_STATE/OVMF_VARS.fd"

printf 'Booting %s\n' "$ISO"
printf 'Diskless VM: 4 GiB RAM, 4 vCPUs, UEFI, NAT networking.\n'
printf 'No host disk is attached. UEFI variable state is temporary.\n'

qemu-system-x86_64 \
    -machine q35,accel=tcg \
    -cpu max \
    -m 4096 \
    -smp 4 \
    -device virtio-vga \
    -display gtk \
    -device virtio-keyboard \
    -device virtio-mouse \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -drive if=pflash,format=raw,unit=0,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,unit=1,file="$VM_STATE/OVMF_VARS.fd" \
    -cdrom "$ISO" \
    -boot menu=on
