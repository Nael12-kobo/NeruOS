#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "$BASH_SOURCE")/.." && pwd)"
PROFILE="$ROOT/iso/profile"
BUILD_PROFILE="$ROOT/.cache/neruos-build-profile"
ARCHISO_SOURCE="$ROOT/tools/archiso"
TOOLROOT="$ROOT/.cache/iso-tools"
WORK="$ROOT/.cache/archiso-work-vm-alpha-uefi"
OUT="$ROOT/dist"
APP_BUILD="$ROOT/qt-desktop/build"

if [[ ! -x "$ARCHISO_SOURCE/archiso/mkarchiso" ]]; then
    mkdir -p "$ROOT/tools"
    git clone --depth 1 https://github.com/archlinux/archiso.git "$ARCHISO_SOURCE"
fi

if [[ ! -f "$PROFILE/profiledef.sh" ]]; then
    printf 'NeruOS ISO profile is missing: %s\n' "$PROFILE" >&2
    exit 1
fi

if ! command -v unshare >/dev/null 2>&1 || ! unshare --user --map-root-user true 2>/dev/null; then
    printf 'This build requires unprivileged user namespaces (unshare --user --map-root-user).\n' >&2
    printf 'No sudo/root build is attempted by this script.\n' >&2
    exit 1
fi

mkdir -p "$ROOT/.cache/pacman-cache" "$WORK" "$OUT"
"$ROOT/scripts/bootstrap-iso-tools.sh"

export PATH="$TOOLROOT/usr/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLROOT/usr/lib"

printf '\nBuilding the NeruOS shell...\n'
cmake -S "$ROOT/qt-desktop" -B "$APP_BUILD" -G Ninja
cmake --build "$APP_BUILD"
qmllint "$ROOT/qt-desktop/Main.qml" \
        "$ROOT/qt-desktop/NeruBar.qml" \
        "$ROOT/qt-desktop/NeruDock.qml"

# Make a disposable copy of the ISO profile so the committed profile remains
# portable. The cache path is rewritten only in this build copy.
rm -rf -- "$BUILD_PROFILE"
cp -a -- "$PROFILE" "$BUILD_PROFILE"
sed "s|^CacheDir = .*|CacheDir = $ROOT/.cache/pacman-cache|" \
    "$PROFILE/pacman.conf" > "$BUILD_PROFILE/pacman.conf"

install -D -m 0755 "$APP_BUILD/neruos-nebula" \
    "$BUILD_PROFILE/airootfs/usr/local/bin/neruos-shell"

printf '\nBuilding the lightweight UEFI live ISO (non-root user namespace)...\n'
"$ARCHISO_SOURCE/archiso/mkarchiso" \
    -v \
    -w "$WORK" \
    -o "$OUT" \
    "$BUILD_PROFILE"

printf '\nISO build finished. Output directory: %s\n' "$OUT"
find "$OUT" -maxdepth 1 -type f -name '*.iso' -printf '%f  %k KB\n' | sort
