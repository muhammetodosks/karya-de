#!/usr/bin/env bash
# Karya DE - Sürücü Kurulum Sistemi
set -euo pipefail

KARYA_HARDWARE_DIR="/etc/karya/hardware"
LOG="/var/log/karya-driver-install.log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG"; }

install_nvidia_proprietary() {
    log "NVIDIA proprietary sürücüleri kuruluyor..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm nvidia nvidia-utils nvidia-settings \
            lib32-nvidia-utils nvidia-dkms 2>&1 | tee -a "$LOG"
        # NVIDIA Prime (laptop)
        if pacman -Qi optimus-manager &>/dev/null 2>&1 || lspci | grep -qi 'intel.*vga'; then
            pacman -S --noconfirm nvidia-prime 2>&1 | tee -a "$LOG"
        fi
    elif command -v apt &>/dev/null; then
        apt install -y nvidia-driver nvidia-utils nvidia-settings 2>&1 | tee -a "$LOG"
    fi

    # Kernel modülü
    modprobe nvidia nvidia_drm nvidia_modeset nvidia_uvm 2>&1 | tee -a "$LOG"
    echo "NVIDIA" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "NVIDIA sürücüleri kuruldu."
}

install_nvidia_nouveau() {
    log "Nouveau (açık kaynak NVIDIA) sürücüsü kuruluyor..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm xf86-video-nouveau 2>&1 | tee -a "$LOG"
    fi
    echo "nouveau" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "Nouveau kuruldu."
}

install_amd_amdgpu() {
    log "AMD amdgpu sürücüleri kuruluyor..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm xf86-video-amdgpu mesa mesa-utils \
            lib32-mesa lib32-mesa-utils \
            vulkan-radeon lib32-vulkan-radeon 2>&1 | tee -a "$LOG"
    elif command -v apt &>/dev/null; then
        apt install -y xserver-xorg-video-amdgpu mesa-utils \
            mesa-vulkan-drivers libvulkan1 2>&1 | tee -a "$LOG"
    fi
    echo "amdgpu" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "AMD sürücüleri kuruldu."
}

install_intel() {
    log "HATA: Intel GPU suruculeri kurulamaz!"
    echo ""
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  Karya DE Intel GPU DESTEKLEMEZ!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo ""
    echo "Intel GPU'lar icin surucu kurulumu engellendi."
    echo ""
    echo "Sebep:"
    echo "  1. Performans: Intel iGPU'lar glassmorphism, blur,"
    echo "     ve modern compositor efektlerini kaldiramaz."
    echo "  2. Vulkan: Intel Vulkan (ANV) destegi ozellikle"
    echo "     12. nesil oncesi kararsiz ve eksiktir."
    echo "  3. Surucu: i915 driver'i kernel seviyesinde"
    echo "     kisitlamalar icerir."
    echo "  4. Kaynak: Gelistirme NVIDIA ve AMD'ye odaklanmistir."
    echo ""
    echo "Cozum: NVIDIA veya AMD GPU kullanin."
    echo "VM'de calisiyorsaniz VM profili kullanin."
    echo ""
    log "Intel kurulumu REDDEDILDI."
    echo "intel" > "$KARYA_HARDWARE_DIR/driver.txt"
    echo "BLOCKED" >> "$KARYA_HARDWARE_DIR/driver.txt"
    return 1
}

install_vm_drivers() {
    log "Sanal makine sürücüleri kuruluyor..."
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm virtualbox-guest-utils 2>&1 | tee -a "$LOG"
        systemctl enable vboxservice 2>/dev/null || true
    fi
    echo "virtual" > "$KARYA_HARDWARE_DIR/driver.txt"
    log "VM sürücüleri kuruldu."
}

install_vulkan() {
    log "Vulkan desteği kuruluyor..."
    local vendor=$(jq -r '.vendor' "$KARYA_HARDWARE_DIR/gpu.json" 2>/dev/null || echo "unknown")
    case "$vendor" in
        nvidia)
            pacman -S --noconfirm vulkan-icd-loader lib32-vulkan-icd-loader 2>&1 | tee -a "$LOG"
            ;;
        amd)
            pacman -S --noconfirm vulkan-radeon lib32-vulkan-radeon 2>&1 | tee -a "$LOG"
            ;;
        intel)
            pacman -S --noconfirm vulkan-intel lib32-vulkan-intel 2>&1 | tee -a "$LOG"
            ;;
    esac
    log "Vulkan kuruldu."
}

auto_install() {
    log "=== Karya DE Otomatik Sürücü Kurulumu ==="
    local vendor=$(jq -r '.vendor' "$KARYA_HARDWARE_DIR/gpu.json" 2>/dev/null || echo "unknown")

    case "$vendor" in
        nvidia)
            install_nvidia_proprietary
            ;;
        amd)
            install_amd_amdgpu
            install_vulkan
            ;;
        intel)
            install_intel
            install_vulkan
            ;;
        virtual)
            install_vm_drivers
            ;;
        *)
            log "Bilinmeyen GPU, varsayılan sürücüler kullanılacak."
            ;;
    esac

    # PipeWire kurulumu
    if command -v pacman &>/dev/null; then
        pacman -S --noconfirm pipewire pipewire-pulse wireplumber 2>&1 | tee -a "$LOG"
    fi
    log "=== Sürücü kurulumu tamamlandı ==="
}

case "${1:-auto}" in
    nvidia)    install_nvidia_proprietary ;;
    nouveau)   install_nvidia_nouveau ;;
    amd)       install_amd_amdgpu ;;
    intel)     install_intel ;;
    vm)        install_vm_drivers ;;
    auto)      auto_install ;;
    *)         echo "Kullanım: $0 {auto|nvidia|nouveau|amd|intel|vm}" && exit 1 ;;
esac
