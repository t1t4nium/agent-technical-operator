#!/usr/bin/env bash
# Check libvirt/KVM ready. Exit 0=ok, 1=error.
set -euo pipefail
uri="${LIBVIRT_DEFAULT_URI:-qemu:///system}"
fail() { echo "FAIL: $1" >&2; exit 1; }
command -v virsh >/dev/null 2>&1 || fail "virsh not found"
command -v virt-install >/dev/null 2>&1 || fail "virt-install not found"
virsh --connect "$uri" version >/dev/null 2>&1 || fail "cannot connect to $uri"
if [ "$uri" = "qemu:///system" ]
then
  groups | grep -q libvirt || fail "$USER not in libvirt group"
  virsh --connect "$uri" capabilities 2>/dev/null | grep -q "type='kvm'" || fail "KVM inactive on $uri"
fi
echo "OK: $uri"
