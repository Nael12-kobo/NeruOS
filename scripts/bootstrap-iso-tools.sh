#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLROOT="$ROOT/.cache/iso-tools"
DOWNLOADS="$ROOT/.cache/iso-tool-packages"
mkdir -p "$TOOLROOT" "$DOWNLOADS"

fetch_package() {
    local repo="$1"
    local arch="$2"
    local package="$3"
    local metadata filename package_path mirror_arch

    metadata="$(curl --fail --silent --show-error \
        "https://archlinux.org/packages/${repo}/${arch}/${package}/json/")"
    filename="$(python -c 'import json,sys; print(json.load(sys.stdin)["filename"])' <<<"$metadata")"
    mirror_arch="$arch"
    # Arch mirrors publish architecture-independent packages in the x86_64 repository directory.
    [[ "$mirror_arch" == "any" ]] && mirror_arch="x86_64"
    package_path="$DOWNLOADS/$filename"

    if [[ ! -s "$package_path" ]]; then
        printf 'Downloading %s...\n' "$filename"
        curl --fail --location --show-error --retry 3 \
            "https://geo.mirror.pkgbuild.com/${repo}/os/${mirror_arch}/${filename}" \
            --output "$package_path"
    fi

    printf 'Extracting %s...\n' "$filename"
    bsdtar -xf "$package_path" -C "$TOOLROOT"
}

# These tools are unpacked into the repository cache. Nothing is installed
# into the host OS, and no host package database is changed.
fetch_package extra any arch-install-scripts
fetch_package extra x86_64 squashfs-tools
fetch_package extra x86_64 libisoburn
fetch_package extra x86_64 libburn
fetch_package extra x86_64 libisofs

export PATH="$TOOLROOT/usr/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLROOT/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

for command_name in pacstrap arch-chroot mksquashfs xorriso; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Missing required build tool: %s\n' "$command_name" >&2
        exit 1
    fi
done

if ldd "$(command -v xorriso)" | grep -q 'not found'; then
    printf 'xorriso has unresolved shared-library dependencies:\n' >&2
    ldd "$(command -v xorriso)" | grep 'not found' >&2 || true
    exit 1
fi

if ldd "$(command -v mksquashfs)" | grep -q 'not found'; then
    printf 'mksquashfs has unresolved shared-library dependencies:\n' >&2
    ldd "$(command -v mksquashfs)" | grep 'not found' >&2 || true
    exit 1
fi

printf '\nLocal ISO build tools are ready.\n'
printf 'Tool cache: %s\n' "$TOOLROOT"
