#!/usr/bin/env python3
"""
Karya DE VM - Automated Arch Linux Installer via Serial Console
"""
import pexpect
import sys
import os
import time

DISK = os.path.expanduser("~/Desktop/mamıuf/karya-de/karya-vm.qcow2")
ISO = "/tmp/archlinux.iso"

if not os.path.exists(ISO):
    print(f"ISO not found: {ISO}")
    sys.exit(1)
if not os.path.exists(DISK):
    print(f"Creating disk: {DISK}")
    os.system(f"qemu-img create -f qcow2 {DISK} 40G")

qemu_cmd = (
    f"qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 -cpu host "
    f"-drive file={DISK},format=qcow2 "
    f"-cdrom {ISO} -boot d "
    f"-vga virtio -display vnc=127.0.0.1:0 "
    f"-device virtio-net,netdev=net0 "
    f"-netdev user,id=net0,hostfwd=tcp::2222-:22 "
    f"-nographic"
)

print("Starting QEMU...")
child = pexpect.spawn(qemu_cmd, timeout=300, encoding='utf-8', codec_errors='replace')
child.logfile = sys.stdout

# Wait for boot
print("Waiting for boot...")
time.sleep(15)

# Send some newlines to wake up
child.sendline("")
time.sleep(2)

# Check if we're at a shell
child.sendline("echo BOOT_CHECK_OK")
try:
    idx = child.expect_exact(["BOOT_CHECK_OK", "root@archiso", pexpect.TIMEOUT], timeout=10)
    print(f"Boot check result: {idx}")
except:
    print("Boot check failed")

child.interact()
