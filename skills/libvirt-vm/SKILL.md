---
name: libvirt-vm
description: Manage libvirt VM
version: 1.0.0
platforms: [linux]
metadata:
  hermes:
    tags: [virtualization, vm, libvirt, kvm, qemu]
    category: devops
---

# libvirt VM

## When to Use
Use when the user wants to manage a KVM VM: start, stop, clone, snapshot, delete.

## Procedures

### Check setup
Start by checking libvirt/KVM setup.
Run `bash scripts/check.sh`: exit 0=ready, 1=error to be reported to the user.

### List VMs
- Running VMs: `virsh list`.
- All VMs: `virsh list --all`.

### Create VM
A VM is created by cloning a template.
Required information: OS, VM name, vCPUs, memory size (mb), disk size (gb).

Available scripts:
- AlmaLinux: `scripts/vm-almalinux-clone.sh`,
- Debian: `scripts/vm-debian-clone.sh`,
- FreeBSD: `scripts/vm-freebsd-clone.sh`.
Usage: `bash scripts/vm-<os>-clone.sh <vm_name> [vcpus] [memory_mb] [disk_size_gb]`.

First VM start may take 1-2 minutes. Get the VM IP. Then test SSH and report information.
If installation failed, don't try to fix and report error.

### Delete VM
Required information: VM name.
Run `bash scripts/vm-destroy.sh <vm_name>`.
If deletion failed, don't try to fix and report error.

### Start/Stop VM
Required information: VM name.
Start: `virsh start <name>`.
Stop: `virsh destroy --graceful <vm_name>`.
Force stop (only if graceful stop doesn't work): `virsh destroy <vm_name>`.

### Snapshot
Required information: VM name, snapshot name.

List VM snapshots: `virsh snapshot-list <vm_name>`.

Create snapshot:
1. gracefully stop the VM,
2. create snapshot `virsh snapshot-create-as <vm_name> <snapshot_name>`,
3. check by listing VM snapshots,
4. start VM and report information.

Delete snapshot: `virsh snapshot-delete <vm_name> <snapshot_name>`.

Revert snapshot: `virsh snapshot-revert <vm_name> <snapshot_name>`.

## Help
- `virsh --help`.
- `virsh <command> --help`.
