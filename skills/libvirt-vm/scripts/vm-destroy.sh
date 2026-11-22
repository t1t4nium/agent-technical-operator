#!/usr/bin/env bash
# Delete a VM: undefine + remove its overlay disk and seed.
# Usage: vm-destroy.sh <name>
set -euo pipefail
# configurable settings (via env or here)
LIBVIRT_IMAGES_DIR="${LIBVIRT_IMAGES_DIR:-/var/lib/libvirt/images}"
CONNECT="${LIBVIRT_DEFAULT_URI:-qemu:///system}" # system connection (network + persistent VMs)
# ---------------------------------------
NAME="${1:?usage: vm-destroy.sh <name>}"
DISK="$LIBVIRT_IMAGES_DIR/$NAME.qcow2"
[ ! -d "$LIBVIRT_IMAGES_DIR" ] && echo "FAIL: $LIBVIRT_IMAGES_DIR doesn't exists" && exit 1
[ ! -f "$DISK" ] && echo "FAIL: $DISK doesn't exists" && exit 1
virsh --connect "$CONNECT" destroy "$NAME" 2>/dev/null || true
virsh --connect "$CONNECT" undefine "$NAME" --nvram # UEFI VMs; no-op for BIOS
rm -f "$DISK" "$LIBVIRT_IMAGES_DIR/$NAME-seed.iso" # overlay + seed only, template untouched
echo "VM '$NAME' deleted."
