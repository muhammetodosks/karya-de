#!/usr/bin/env bash
set -e

# Karya DE - Automatic Arch Linux Installation
# This runs inside the Arch ISO live environment

echo "=== Karya DE Auto Installer ==="

# Detect disk
DISK=""
for d in /dev/vda /dev/sda /dev/nvme0n1; do
  [ -b "$d" ] && DISK="$d" && break
done

if [ -z "$DISK" ]; then
  echo "Disk bulunamadi!"
  lsblk
  exit 1
fi

echo "Disk: $DISK"

# Partition
echo "=== Partitioning ==="
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary btrfs 513MiB 100%

# Format
echo "=== Formatting ==="
mkfs.fat -F32 "${DISK}1"
mkfs.btrfs -f "${DISK}2"

# Mount
mount "${DISK}2" /mnt
mount --mkdir "${DISK}1" /mnt/boot

# Install base
echo "=== Installing base system ==="
pacstrap -K /mnt base base-devel linux linux-firmware btrfs-progs \
  sudo git vim networkmanager grub efibootmgr

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot config
arch-chroot /mnt /bin/bash << 'CHROOT'
  set -e

  # Time
  ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
  hwclock --systohc

  # Locale
  echo "tr_TR.UTF-8 UTF-8" >> /etc/locale.gen
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  echo "LANG=tr_TR.UTF-8" > /etc/locale.conf

  # Hostname
  echo "karya-vm" > /etc/hostname

  # Network
  systemctl enable NetworkManager

  # Users
  echo "root:123456" | chpasswd
  useradd -m -G wheel -s /bin/bash karya
  echo "karya:123456" | chpasswd
  echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

  # Bootloader
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  # Enable multilib
  echo "[multilib]" >> /etc/pacman.conf
  echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

CHROOT

# Clone and build Karya DE
arch-chroot /mnt /bin/bash << 'BUILD'
  set -e

  cd /home/karya
  sudo -u karya git clone https://github.com/muhammetodosks/karya-de.git
  cd karya-de
  sudo -u karya make setup
  sudo -u karya make build
  make install

BUILD

# Cleanup
umount -R /mnt
echo "=== Karya DE kurulumu tamam! ==="
