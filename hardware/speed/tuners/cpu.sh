#!/usr/bin/env bash
# Karya SPEED - CPU Tuner
set -euo pipefail

apply_cpu() {
    local profile="$1"
    local governor energy_perf no_turbo min_freq max_freq

    governor=$(grep "^GOVERNOR=" "$profile" | cut -d= -f2)
    energy_perf=$(grep "^ENERGY_PERF_PREF=" "$profile" | cut -d= -f2)
    no_turbo=$(grep "^NO_TURBO=" "$profile" | cut -d= -f2)
    min_freq=$(grep "^SCALING_MIN_FREQ=" "$profile" | cut -d= -f2)
    max_freq=$(grep "^SCALING_MAX_FREQ=" "$profile" | cut -d= -f2)

    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        local gov="$cpu/cpufreq/scaling_governor"
        local ep="$cpu/cpufreq/energy_performance_preference"
        local min="$cpu/cpufreq/scaling_min_freq"
        local max="$cpu/cpufreq/scaling_max_freq"

        [[ -w "$gov" ]] && echo "$governor" > "$gov" 2>/dev/null || true
        [[ -w "$ep" ]] && echo "$energy_perf" > "$ep" 2>/dev/null || true
        [[ -w "$min" && "$min_freq" != "0" ]] && echo "$min_freq" > "$min" 2>/dev/null || true
        [[ -w "$max" && "$max_freq" != "0" ]] && echo "$max_freq" > "$max" 2>/dev/null || true
    done

    [[ -w /sys/devices/system/cpu/intel_pstate/no_turbo ]] && echo "$no_turbo" > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    [[ -w /sys/devices/system/cpu/cpufreq/boost ]] && echo "$((1-no_turbo))" > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true

    echo "CPU: $governor / $energy_perf"
}

apply_cpu "${1:-/etc/karya/speed/current.conf}"
