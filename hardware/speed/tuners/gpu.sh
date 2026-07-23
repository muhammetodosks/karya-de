#!/usr/bin/env bash
# Karya SPEED - GPU Tuner
set -euo pipefail

apply_gpu() {
    local profile="$1"
    local gpu_profile force_power adaptive

    gpu_profile=$(grep "^GPU_PROFILE=" "$profile" | cut -d= -f2)
    force_power=$(grep "^GPU_FORCE_POWER=" "$profile" | cut -d= -f2)
    adaptive=$(grep "^ADAPTIVE_CLOCK=" "$profile" | cut -d= -f2)

    # AMD GPU
    if [[ -d /sys/class/drm ]]; then
        for card in /sys/class/drm/card*/device; do
            [[ ! -d "$card" ]] && continue
            local pp="$(dirname "$card")/power_dpm_force_performance_level"
            [[ -w "$pp" ]] && echo "$gpu_profile" > "$pp" 2>/dev/null || true
            local ac="$(dirname "$card")/power_dpm_force_performance_level"
            if [[ -w "$ac" && "$gpu_profile" == "high" ]]; then
                echo "high" > "$ac" 2>/dev/null || true
            fi
        done
    fi

    # NVIDIA GPU
    if command -v nvidia-smi &>/dev/null; then
        if [[ "$gpu_profile" == "high" ]]; then
            nvidia-smi -pm 1 2>/dev/null || true
            nvidia-smi -ac 2100,1600 2>/dev/null || true
            nvidia-smi -pl 250 2>/dev/null || true
        elif [[ "$gpu_profile" == "low" ]]; then
            nvidia-smi -pm 0 2>/dev/null || true
            nvidia-smi -ac 300,210 2>/dev/null || true
            nvidia-smi -pl 50 2>/dev/null || true
        fi
    fi

    # Intel GPU
    if command -v intel_gpu_freq &>/dev/null; then
        if [[ "$gpu_profile" == "high" ]]; then
            intel_gpu_freq -max 2000 2>/dev/null || true
        elif [[ "$gpu_profile" == "low" ]]; then
            intel_gpu_freq -max 350 2>/dev/null || true
        fi
    fi

    echo "GPU: profile=$gpu_profile"
}

apply_gpu "${1:-/etc/karya/speed/current.conf}"
