#!/usr/bin/env bash
set -e

VM_DIR="$(cd "$(dirname "$0")" && pwd)"
ISO="/tmp/archlinux.iso"
DISK="$VM_DIR/../karya-vm.qcow2"
MEM=${MEM:-4096}
CPUS=${CPUS:-4}

if [ ! -f "$ISO" ]; then
    echo "ISO bulunamadi: $ISO"
    echo "Once indir: curl -Lo $ISO https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
    exit 1
fi

if [ ! -f "$DISK" ]; then
    echo "Disk olusturuluyor: $DISK"
    qemu-img create -f qcow2 "$DISK" 40G
fi

echo "=== Karya DE VM Baslatiliyor ==="
echo "  RAM: ${MEM}MB"
echo "  CPU: $CPUS"
echo "  Disk: $DISK"
echo "  ISO: $ISO"
echo "  VNC: localhost:0 (port 5900)"
echo "  SSH: localhost:2222 -> VM:22"
echo ""

exec qemu-system-x86_64 \
    -enable-kvm \
    -m "$MEM" \
    -smp "$CPUS" \
    -cpu host \
    -drive file="$DISK",format=qcow2 \
    -cdrom "$ISO" \
    -boot d \
    -vga virtio \
    -display vnc=127.0.0.1:0 \
    -device virtio-net,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -serial mon:stdio
