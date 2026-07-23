#!/usr/bin/env bash
# Karya SPEED - Thermal Tuner
set -euo pipefail

apply_thermal() {
    local profile="$1"
    local thermal_gov

    thermal_gov=$(grep "^THERMAL_GOVERNOR=" "$profile" | cut -d= -f2)

    for tzone in /sys/class/thermal/thermal_zone*; do
        [[ ! -d "$tzone" ]] && continue
        local gov="$tzone/policy"
        [[ -w "$gov" ]] && echo "$thermal_gov" > "$gov" 2>/dev/null || true
    done

    # Intel P-state
    local hwp="/sys/devices/system/cpu/intel_pstate"
    if [[ -d "$hwp" ]]; then
        if [[ "$thermal_gov" == "performance" ]]; then
            echo 1 > "$hwp/no_turbo" 2>/dev/null || true
            echo 0 > "$hwp/max_perf_pct" 2>/dev/null || true
            echo 100 > "$hwp/min_perf_pct" 2>/dev/null || true
        elif [[ "$thermal_gov" == "powersave" ]]; then
            echo 1 > "$hwp/no_turbo" 2>/dev/null || true
            echo 30 > "$hwp/max_perf_pct" 2>/dev/null || true
            echo 0 > "$hwp/min_perf_pct" 2>/dev/null || true
        fi
    fi

    # AMD pstate
    local amd_pstate="/sys/devices/system/cpu/amd_pstate"
    if [[ -d "$amd_pstate" ]]; then
        if [[ "$thermal_gov" == "performance" ]]; then
            echo 100 > "$amd_pstate/max_perf" 2>/dev/null || true
            echo 100 > "$amd_pstate/min_perf" 2>/dev/null || true
        elif [[ "$thermal_gov" == "powersave" ]]; then
            echo 20 > "$amd_pstate/max_perf" 2>/dev/null || true
            echo 0 > "$amd_pstate/min_perf" 2>/dev/null || true
        fi
    fi

    echo "Thermal: $thermal_gov"
}

apply_thermal "${1:-/etc/karya/speed/current.conf}"
