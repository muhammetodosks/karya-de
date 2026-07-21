#!/usr/bin/env bash
# Karya DE - Surucu Kurulum Sistemi
set -euo pipefail

KARYA_HARDWARE_DIR="/etc/karya/hardware"
LOG="/var/log/karya-driver-install.log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG"; }

install_nvidia_proprietary() {
    log "NVIDIA proprietary suruculeri kuruluyor..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm nvidia nvidia-utils nvidia-settings \
            lib32-nvidia-utils nvidia-dkms 2>&1 | tee -a "$LOG"
        if pacman -Qi optimus-manager &>/dev/null 2>&1 || lspci | grep -qi 'intel.*vga'; then
            pacman -S --noconfirm nvidia-prime 2>&1 | tee -a "$LOG"
        fi
    elif command -v apt &>/dev/null; then
        apt install -y nvidia-driver nvidia-utils nvidia-settings 2>&1 | tee -a "$LOG"
    fi
    modprobe nvidia nvidia_drm nvidia_modeset nvidia_uvm 2>&1 | tee -a "$LOG"
    echo "NVIDIA" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "NVIDIA suruculeri kuruldu."
}

install_nvidia_nouveau() {
    log "Nouveau (acik kaynak NVIDIA) surucusu kuruluyor..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm xf86-video-nouveau 2>&1 | tee -a "$LOG"
    fi
    echo "nouveau" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "Nouveau kuruldu."
}

install_amd_amdgpu() {
    log "AMD amdgpu suruculeri kuruluyor..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm xf86-video-amdgpu mesa mesa-utils \
            lib32-mesa lib32-mesa-utils \
            vulkan-radeon lib32-vulkan-radeon 2>&1 | tee -a "$LOG"
    elif command -v apt &>/dev/null; then
        apt install -y xserver-xorg-video-amdgpu mesa-utils \
            mesa-vulkan-drivers libvulkan1 2>&1 | tee -a "$LOG"
    fi
    echo "amdgpu" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "AMD suruculeri kuruldu."
}

install_intel() {
    log "UYARI: Intel GPU'lar resmi olarak desteklenmez."
    log "Intel suruculeri deneniyor (deneysel)..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm xf86-video-intel mesa-utils \
            vulkan-intel lib32-vulkan-intel 2>&1 | tee -a "$LOG"
    elif command -v apt &>/dev/null; then
        apt install -y xserver-xorg-video-intel mesa-utils \
            mesa-vulkan-drivers 2>&1 | tee -a "$LOG"
    fi
    echo "intel" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "Intel suruculeri kuruldu (resmi destek yok - deneysel)."
}

install_vm_drivers() {
    log "Sanal makine suruculeri kuruluyor..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm virtualbox-guest-utils 2>&1 | tee -a "$LOG"
        systemctl enable vboxservice 2>/dev/null || true
    fi
    echo "virtual" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "VM suruculeri kuruldu."
}

install_vulkan() {
    log "Vulkan destegi kuruluyor..."
    local vendor
    vendor=$(jq -r '.vendor' "$KARYA_HARDWARE_DIR/gpu.json" 2>/dev/null || echo "unknown")
    case "$vendor" in
        nvidia) pacman -S --noconfirm vulkan-icd-loader lib32-vulkan-icd-loader 2>&1 | tee -a "$LOG" ;;
        amd) pacman -S --noconfirm vulkan-radeon lib32-vulkan-radeon 2>&1 | tee -a "$LOG" ;;
        intel) pacman -S --noconfirm vulkan-intel lib32-vulkan-intel 2>&1 | tee -a "$LOG" ;;
    esac
    log "Vulkan kuruldu."
}

auto_install() {
    log "=== Karya DE Otomatik Surucu Kurulumu ==="
    local vendor
    vendor=$(jq -r '.vendor' "$KARYA_HARDWARE_DIR/gpu.json" 2>/dev/null || echo "unknown")

    case "$vendor" in
        nvidia) install_nvidia_proprietary ;;
        amd) install_amd_amdgpu; install_vulkan ;;
        intel)
            echo ""
            echo "  [UYARI] Intel GPU algilandi."
            echo "  Intel GPU'lar resmi olarak desteklenmez."
            echo "  NVIDIA veya AMD GPU onerilir."
            echo "  Kuruluma devam ediliyor (deneysel)..."
            install_intel; install_vulkan
            ;;
        virtual) install_vm_drivers ;;
        *) log "Bilinmeyen GPU, varsayilan suruculer kullanilacak." ;;
    esac

    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm pipewire pipewire-pulse wireplumber 2>&1 | tee -a "$LOG"
    fi
    log "=== Surucu kurulumu tamamlandi ==="
}

case "${1:-auto}" in
    nvidia)  install_nvidia_proprietary ;;
    nouveau) install_nvidia_nouveau ;;
    amd)     install_amd_amdgpu ;;
    intel)   install_intel ;;
    vm)      install_vm_drivers ;;
    auto)    auto_install ;;
    *)       echo "Kullanim: $0 {auto|nvidia|nouveau|amd|intel|vm}" && exit 1 ;;
esac
