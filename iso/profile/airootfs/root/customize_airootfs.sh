#!/usr/bin/env bash
set -euo pipefail

# The live account must be able to autologin on the VM console.
passwd --delete neru

# Grant the live desktop the device and journal access it needs in the VM.
usermod --append --groups video,render,input,audio,systemd-journal,adm neru
