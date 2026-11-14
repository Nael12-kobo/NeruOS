#!/usr/bin/env bash
# NeruOS VM Alpha profile. Based on the official Arch Linux releng profile.
# shellcheck disable=SC2034

iso_name="neruos-vm-alpha"
iso_label="NERUOS_$(date +%Y%m)"
iso_publisher="NeruOS Project"
iso_application="NeruOS Nebula VM Alpha Live"
iso_version="0.4.0-alpha1"
install_dir="neru"
bootmodes=('uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')

file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/home/neru/.bash_profile"]="1000:1000:644"
  ["/home/neru/.config"]="1000:1000:755"
  ["/home/neru/.config/labwc"]="1000:1000:755"
  ["/home/neru/.config/labwc/autostart"]="1000:1000:755"
  ["/home/neru/.config/labwc/environment"]="1000:1000:644"
  ["/home/neru/.config/labwc/rc.xml"]="1000:1000:644"
  ["/usr/local/bin/neruos-shell"]="0:0:755"
  ["/etc/systemd/system/getty@tty1.service.d/autologin.conf"]="0:0:644"
  # Keep this last: changing the home directory to mode 750 first would
  # prevent a rootless builder from resolving the remaining child paths.
  ["/home/neru"]="1000:1000:755"
)
