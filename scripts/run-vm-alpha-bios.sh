#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$BASH_SOURCE")/.." && pwd)"
OUT="$ROOT/dist"
ISO="${1:-}"

if [[ -z "$ISO" ]]; then
    ISO="$(find "$OUT" -maxdepth 1 -type f -name '*.iso' -printf '%T@ %p\n' | sort -nr | head -1 | cut -d' ' -f2-)"
fi

if [[ -z "$ISO" || ! -f "$ISO" ]]; then
    printf 'No ISO found. Build one first with scripts/build-vm-iso.sh\n' >&2
    exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    printf 'qemu-system-x86_64 is required to run the BIOS test.\n' >&2
    exit 1
fi

QEMU_ACCEL="tcg"
QEMU_CPU="max"
if [[ -r /dev/kvm && -w /dev/kvm ]]; then
    QEMU_ACCEL="kvm"
    QEMU_CPU="host"
fi

TMPBASE="${TMPDIR:-/tmp}"
VM_STATE="$(mktemp -d "$TMPBASE/neruos-vm-alpha-bios.XXXXXX")"
trap 'rm -rf -- "$VM_STATE"' EXIT

printf 'Booting Legacy BIOS test: %s\n' "$ISO"
printf 'Diskless VM: 4 GiB RAM, 4 vCPUs, SeaBIOS, NAT networking.\n'
printf 'Acceleration: %s. No host disk is attached.\n' "$QEMU_ACCEL"

qemu-system-x86_64 \
    -machine "q35,accel=$QEMU_ACCEL" \
    -cpu "$QEMU_CPU" \
    -monitor "unix:$VM_STATE/qemu-monitor.sock,server=on,wait=off" \
    -m 4096 \
    -smp 4 \
    -device virtio-vga \
    -display gtk \
    -device virtio-keyboard \
    -device virtio-mouse \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0 \
    -cdrom "$ISO" \
    -boot order=d
