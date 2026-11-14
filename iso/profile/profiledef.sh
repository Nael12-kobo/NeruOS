#!/usr/bin/env bash
# NeruOS VM Alpha profile. Based on the official Arch Linux releng profile.
# shellcheck disable=SC2034

iso_name="neruos-vm-alpha"
iso_label="NERUOS_$(date +%Y%m)"
iso_publisher="NeruOS Project"
iso_application="NeruOS Nebula VM Alpha Live"
iso_version="0.4.0-alpha3"
# Keep systemd-firstboot from opening an interactive root-password prompt on tty1.
# The live image provisions its own user and machine ID; no firstboot wizard is needed.
# Keep early boot quiet; the native NeruOS Boot Animation takes over
# when the graphical session starts. Errors remain available through journald.
kernel_params_x86_64="systemd.firstboot=0 quiet loglevel=3 systemd.show_status=false rd.udev.log_level=3 vt.global_cursor_default=0"
install_dir="neru"
# UEFI uses the fully themed GRUB menu. Legacy BIOS uses the ArchISO-supported
# Syslinux path with the same NeruOS background and matching color palette.
bootmodes=('bios.syslinux'
           'uefi.grub')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')

file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/usr/local/bin/neruos-shell"]="0:0:755"
  ["/usr/local/bin/neruos-session-autostart"]="0:0:755"
  ["/etc/systemd/system/getty@tty1.service.d/autologin.conf"]="0:0:644"
  ["/etc/pam.d/swaylock"]="0:0:644"
  ["/etc/greetd/config.toml.template"]="0:0:644"
)
