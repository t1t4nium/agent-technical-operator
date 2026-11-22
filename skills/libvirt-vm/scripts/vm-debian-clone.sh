#!/usr/bin/env bash
# Create a Debian VM from the cloud template (generic).
# Usage: vm-debian-clone.sh <name> [vcpus] [memory_mb] [disk_size_gb]
# Example: vm-debian-clone.sh test1 2 2048 10
set -euo pipefail
# configurable settings (via env or here)
LIBVIRT_IMAGES_DIR="${LIBVIRT_IMAGES_DIR:-/var/lib/libvirt/images}"
TEMPLATE="${TEMPLATE:-$LIBVIRT_IMAGES_DIR/debian-13-amd64.qcow2}" # read-only template
NETWORK="${NETWORK:-default}" # default NAT network of libvirt
CONNECT="${LIBVIRT_DEFAULT_URI:-qemu:///system}" # system connection (network + persistent VMs)
OS_VARIANT="${OS_VARIANT:-debian13}"
SSH_KEY_FILE="${SSH_KEY_FILE:-$HOME/.ssh/id_ed25519.pub}" # agent's public key
USER_LOGIN="${USER_LOGIN:-debian}" # default user of the cloud image
# ---------------------------------------
NAME="${1:?usage: vm-debian-clone.sh <name> [vcpus] [memory_mb] [disk_size_gb]}"
VCPUS="${2:-2}"
MEM_MB="${3:-2048}"
DISK_GB="${4:-0}" # 0 = same size as the template (no resizing)
DISK="$LIBVIRT_IMAGES_DIR/$NAME.qcow2"
SEED="$LIBVIRT_IMAGES_DIR/$NAME-seed.iso"
[ ! -d "$LIBVIRT_IMAGES_DIR" ] && echo "FAIL: $LIBVIRT_IMAGES_DIR doesn't exists" && exit 1
[ -f "$DISK" ] && echo "FAIL: $DISK already exists" && exit 1
# 0. make sure the default network is active
if [ "$(virsh --connect "$CONNECT" net-info "$NETWORK" 2>/dev/null | awk '/^Active:/ {print $2}')" != "yes" ]
then
  echo "Starting network '$NETWORK'..."
  virsh --connect "$CONNECT" net-start "$NETWORK"
fi
# 1. copy-on-write overlay disk
if [ "$DISK_GB" -gt 0 ]
then
  qemu-img create -f qcow2 -b "$TEMPLATE" -F qcow2 "$DISK" "${DISK_GB}G" >/dev/null
else
  qemu-img create -f qcow2 -b "$TEMPLATE" -F qcow2 "$DISK" >/dev/null
fi
# 2. cloud-init seed: name + agent's SSH key
SSH_KEY="$(cat "$SSH_KEY_FILE")"
SEEDDIR="$(mktemp -d)"
trap 'rm -rf "$SEEDDIR"' EXIT
cat > "$SEEDDIR/meta-data" <<EOF
instance-id: $NAME
local-hostname: $NAME
EOF
cat > "$SEEDDIR/user-data" <<EOF
#cloud-config
ssh_authorized_keys:
  - $SSH_KEY
disable_root: true
EOF
genisoimage -quiet -output "$SEED" -volid cidata -joliet -rock "$SEEDDIR"
# 3. define and start the VM (BIOS boot, no UEFI needed for Debian)
virt-install \
  --connect "$CONNECT" \
  --name "$NAME" \
  --memory "$MEM_MB" \
  --vcpus "$VCPUS" \
  --os-variant "$OS_VARIANT" \
  --disk path="$DISK",format=qcow2,bus=virtio \
  --disk path="$SEED",device=cdrom \
  --network network="$NETWORK",model=virtio \
  --graphics none \
  --video vga \
  --serial pty \
  --import \
  --noautoconsole
cat <<EOF
Done. VM '$NAME' is starting (first boot: cloud-init configures SSH).
  IP          : virsh -c $CONNECT net-dhcp-leases $NETWORK
  SSH         : ssh $USER_LOGIN@<ip>
  Debug (VGA) : virsh -c $CONNECT screenshot $NAME /tmp/$NAME.png
  Delete      : vm-destroy.sh $NAME
EOF
