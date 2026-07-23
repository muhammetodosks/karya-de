#!/usr/bin/env bash
# Karya DE - Arch ISO Profile

iso_name="karya-de-1.0.0-x86_64"
iso_label="KARYA_1_0"
iso_publisher="Karya DE Team <karya@karya-de.org>"
iso_application="Karya Desktop Environment Live/Install"
iso_version="1.0.0"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc,12')
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/etc/gshadow"]="0:0:400"
    ["/root"]="0:0:750"
    ["/root/.automated_script.sh"]="0:0:755"
    ["/usr/local/bin/choose-mirror"]="0:0:755"
    ["/usr/local/bin/Installation_guide"]="0:0:755"
    ["/usr/local/bin/livecd-sound"]="0:0:755"
    ["/etc/karya/hardware"]="0:0:755"
    ["/etc/karya/speed"]="0:0:755"
    ["/usr/lib/karya/scripts/detect-hardware.sh"]="0:0:755"
    ["/usr/lib/karya/scripts/install-drivers.sh"]="0:0:755"
    ["/usr/bin/speed"]="0:0:755"
    ["/usr/bin/karya-market"]="0:0:755"
    ["/usr/share/karya/speed/tuners/cpu.sh"]="0:0:755"
    ["/usr/share/karya/speed/tuners/io.sh"]="0:0:755"
    ["/usr/share/karya/speed/tuners/memory.sh"]="0:0:755"
    ["/usr/share/karya/speed/tuners/network.sh"]="0:0:755"
    ["/usr/share/karya/speed/tuners/gpu.sh"]="0:0:755"
    ["/usr/share/karya/speed/tuners/sysctl.sh"]="0:0:755"
    ["/usr/share/karya/speed/tuners/latency.sh"]="0:0:755"
    ["/usr/share/karya/speed/tuners/storage.sh"]="0:0:755"
    ["/usr/share/karya/speed/tuners/thermal.sh"]="0:0:755"
)
