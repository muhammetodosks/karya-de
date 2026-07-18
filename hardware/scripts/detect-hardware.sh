#!/usr/bin/env bash
# Karya DE - Donanım Algılama Sistemi
set -euo pipefail

KARYA_HARDWARE_DIR="/etc/karya/hardware"
mkdir -p "$KARYA_HARDWARE_DIR"

# ============================================================
# GPU ALGILAMA
# ============================================================
detect_gpu() {
    local gpu_info=""
    local gpu_vendor="unknown"
    local gpu_model=""
    local gpu_driver=""
    local gpu_is_nvidia=false
    local gpu_is_amd=false
    local gpu_is_intel=false

    # lspci ile GPU ara
    if command -v lspci &>/dev/null; then
        gpu_info=$(lspci -nn | grep -E 'VGA|3D|Display' 2>/dev/null || true)
    fi

    if echo "$gpu_info" | grep -qi 'nvidia\|nvidia corporation'; then
        gpu_vendor="nvidia"
        gpu_is_nvidia=true
        gpu_model=$(echo "$gpu_info" | grep -i nvidia | head -1 | sed 's/.*: //' | sed 's/ \[.*//' | cut -c1-80)
        # NVIDIA driver varlığını kontrol et
        if modinfo nvidia &>/dev/null; then
            gpu_driver="nvidia"
        elif modinfo nouveau &>/dev/null; then
            gpu_driver="nouveau"
        else
            gpu_driver="none"
        fi

    elif echo "$gpu_info" | grep -qi 'amd\|advanced micro devices\|radeon\|amd/ati'; then
        gpu_vendor="amd"
        gpu_is_amd=true
        gpu_model=$(echo "$gpu_info" | grep -i 'amd\|radeon' | head -1 | sed 's/.*: //' | sed 's/ \[.*//' | cut -c1-80)
        if modinfo amdgpu &>/dev/null; then
            gpu_driver="amdgpu"
        elif modinfo radeon &>/dev/null; then
            gpu_driver="radeon"
        else
            gpu_driver="none"
        fi

    elif echo "$gpu_info" | grep -qi 'intel'; then
        gpu_vendor="intel"
        gpu_is_intel=true
        gpu_model=$(echo "$gpu_info" | grep -i 'intel.*graphics\|intel.*hd\|intel.*iris' | head -1 | sed 's/.*: //' | sed 's/ \[.*//' | cut -c1-80)
        if modinfo i915 &>/dev/null; then
            gpu_driver="i915"
        else
            gpu_driver="modesetting"
        fi

    elif echo "$gpu_info" | grep -qi 'vmware\|virtualbox\|qemu\|vm'; then
        gpu_vendor="virtual"
        gpu_model="Virtual Machine GPU"
        gpu_driver="modesetting"
    fi

    # JSON çıktı
    cat > "$KARYA_HARDWARE_DIR/gpu.json" << JSONEOF
{
    "vendor": "$gpu_vendor",
    "model": "$gpu_model",
    "driver": "$gpu_driver",
    "is_nvidia": $gpu_is_nvidia,
    "is_amd": $gpu_is_amd,
    "is_intel": $gpu_is_intel,
    "has_proprietary_driver": $( [[ "$gpu_driver" == "nvidia" || "$gpu_driver" == "amdgpu-pro" ]] && echo "true" || echo "false" ),
    "needs_proprietary_driver": $( [[ "$gpu_vendor" == "nvidia" ]] && echo "true" || echo "false" )
}
JSONEOF
    echo "GPU: $gpu_vendor - $gpu_model ($gpu_driver)"
}

# ============================================================
# SES SİSTEMİ ALGILAMA
# ============================================================
detect_audio() {
    local audio_info=""
    local audio_server=""
    local has_pulse=false
    local has_pipewire=false

    # PipeWire kontrol
    if pgrep -x pipewire &>/dev/null || command -v pipewire &>/dev/null; then
        has_pipewire=true
        audio_server="pipewire"
    elif pgrep -x pulseaudio &>/dev/null || command -v pulseaudio &>/dev/null; then
        has_pulse=true
        audio_server="pulseaudio"
    else
        audio_server="none"
    fi

    # ALSA cihazlarını tara
    local alsa_cards=$(aplay -l 2>/dev/null | grep -c 'card' || echo "0")
    local audio_hw=$(lspci -nn 2>/dev/null | grep -i 'audio' | head -3 | sed 's/.*: //' | cut -c1-80)

    cat > "$KARYA_HARDWARE_DIR/audio.json" << JSONEOF
{
    "server": "$audio_server",
    "has_pipewire": $has_pipewire,
    "has_pulseaudio": $has_pulse,
    "alsa_cards": $alsa_cards,
    "hardware": "$audio_hw"
}
JSONEOF
    echo "Audio: $audio_server - $alsa_cards cihaz"
}

# ============================================================
# AĞ ALGILAMA
# ============================================================
detect_network() {
    local wlan=false
    local eth=false
    local bt=false

    for iface in /sys/class/net/*; do
        local name=$(basename "$iface")
        [[ "$name" == "lo" ]] && continue
        if [[ -d "$iface/wireless" ]]; then
            wlan=true
        else
            eth=true
        fi
    done

    if lsusb 2>/dev/null | grep -qi 'bluetooth\|bt'; then
        bt=true
    elif [[ -d /sys/class/bluetooth ]]; then
        bt=true
    fi

    cat > "$KARYA_HARDWARE_DIR/network.json" << JSONEOF
{
    "wifi": $wlan,
    "ethernet": $eth,
    "bluetooth": $bt
}
JSONEOF
    echo "Network: wifi=$wlan eth=$eth bt=$bt"
}

# ============================================================
# SİSTEM BİLGİLERİ
# ============================================================
detect_system() {
    local ram_total=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
    local cpu_model=$(grep 'model name' /proc/cpuinfo | head -1 | sed 's/.*: //' | cut -c1-60)
    local cpu_cores=$(nproc)
    local cpu_threads=$(grep -c processor /proc/cpuinfo)
    local kernel=$(uname -r)
    local arch=$(uname -m)
    local is_laptop=false
    local is_vm=false

    # Laptop kontrolü (batarya var mı?)
    if [[ -d /sys/class/power_supply ]] && ls /sys/class/power_supply | grep -q 'BAT[0-9]'; then
        is_laptop=true
    fi

    # VM kontrolü
    if grep -qi 'hypervisor\|kvm\|qemu\|vmware\|virtualbox' /proc/cpuinfo 2>/dev/null; then
        is_vm=true
    fi

    cat > "$KARYA_HARDWARE_DIR/system.json" << JSONEOF
{
    "ram_mb": $ram_total,
    "cpu_model": "$cpu_model",
    "cpu_cores": $cpu_cores,
    "cpu_threads": $cpu_threads,
    "kernel": "$kernel",
    "arch": "$arch",
    "is_laptop": $is_laptop,
    "is_vm": $is_vm
}
JSONEOF
    echo "System: $cpu_model ($cpu_cores cores) - ${ram_total}MB RAM"
}

# ============================================================
# PERFORMANS PROFİLİ OLUŞTUR
# ============================================================
generate_profile() {
    local gpu_vendor=$(jq -r '.vendor' "$KARYA_HARDWARE_DIR/gpu.json" 2>/dev/null || echo "unknown")
    local ram=$(jq -r '.ram_mb' "$KARYA_HARDWARE_DIR/system.json" 2>/dev/null || echo "4096")
    local is_laptop=$(jq -r '.is_laptop' "$KARYA_HARDWARE_DIR/system.json" 2>/dev/null || echo "false")
    local is_vm=$(jq -r '.is_vm' "$KARYA_HARDWARE_DIR/system.json" 2>/dev/null || echo "false")

    # RAM'e göre profil
    if [[ $ram -lt 4096 ]]; then
        local profile="lightweight"
        local compositor="xrender"
        local animations=false
        local blur=false
    elif [[ $ram -lt 8192 ]]; then
        local profile="balanced"
        local compositor="opengl"
        local animations=true
        local blur=false
    else
        local profile="performance"
        local compositor="opengl"
        local animations=true
        local blur=true
    fi

    # GPU'ya göre ayar
    case "$gpu_vendor" in
        nvidia)
            compositor="opengl"
            # NVIDIA'da blur performansı düşük
            if $is_laptop; then blur=false; fi
            ;;
        amd)
            compositor="opengl"
            blur=true
            ;;
        intel)
            compositor="opengl"
            blur=$([[ $ram -ge 8192 ]] && echo "true" || echo "false")
            ;;
        virtual)
            compositor="xrender"
            animations=false
            blur=false
            ;;
    esac

    cat > "$KARYA_HARDWARE_DIR/profile.json" << JSONEOF
{
    "profile": "$profile",
    "compositor": "$compositor",
    "animations": $animations,
    "blur": $blur,
    "scale_factor": 1,
    "force_no_vsync": $is_vm,
    "disable_splash": false
}
JSONEOF

    # KWin config yaz
    mkdir -p /etc/xdg/kwin
    cat > /etc/xdg/kwin/kwinrc << KWINEOF
[Compositing]
Backend=$compositor
Enabled=true
OpenGLIsUnsafe=false
QtAD=-1
$([[ "$animations" == "true" ]] && echo "AnimationsDuration=150" || echo "AnimationsDuration=0")

[MouseBindings]
CommandAllKey=Meta

[KaryaTiling]
Enabled=true
AutoTileOnStart=true
Layout=master-stack
Gap=4

[TabBox]
ShowTabBox=false
Layout=thumbnail_grid

[NightColor]
Active=true
Latitude=39.0
Longitude=35.0
KWINEOF

    echo "Profil: $profile (GPU: $gpu_vendor, Compositor: $compositor)"
}

# ============================================================
# ANA ÇALIŞTIRMA
# ============================================================
main() {
    echo "=== Karya DE Donanım Algılama ==="
    detect_gpu
    detect_audio
    detect_network
    detect_system
    generate_profile
    echo "=== Tamamlandı ==="
}

main "$@"
