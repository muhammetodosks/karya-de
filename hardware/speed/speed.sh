#!/usr/bin/env bash
# Karya SPEED - Performance Tuning System
# Usage: speed <profile|command>
# Profiles: performance, balanced, powersave
# Commands: status, apply, daemon, help
set -euo pipefail

KARYA_SPEED_DIR="/etc/karya/speed"
PROFILE_DIR="/usr/share/karya/speed/profiles"
TUNER_DIR="/usr/share/karya/speed/tuners"
CURRENT_PROFILE="$KARYA_SPEED_DIR/current.conf"
STATE_FILE="$KARYA_SPEED_DIR/state.json"

mkdir -p "$KARYA_SPEED_DIR"

init() {
    if [[ ! -f "$CURRENT_PROFILE" ]]; then
        cp "$PROFILE_DIR/balanced.conf" "$CURRENT_PROFILE"
    fi
    if [[ ! -f "$STATE_FILE" ]]; then
        echo '{"profile":"balanced","applied":false,"timestamp":0}' > "$STATE_FILE"
    fi
}

list_profiles() {
    echo "Karya SPEED - Available Profiles:"
    echo ""
    for f in "$PROFILE_DIR"/*.conf; do
        local name
        name=$(basename "$f" .conf)
        local desc
        desc=$(grep "^#" "$f" | head -3 | tr -d '# ')
        printf "  %-15s %s\n" "$name" "$desc"
    done
}

apply_profile() {
    local profile_name="$1"
    local profile_file="$PROFILE_DIR/$profile_name.conf"

    if [[ ! -f "$profile_file" ]]; then
        echo "ERROR: Profile '$profile_name' not found."
        echo "Available: performance, balanced, powersave"
        return 1
    fi

    echo "=== Karya SPEED: $profile_name ==="

    cp "$profile_file" "$CURRENT_PROFILE"

    for tuner in "$TUNER_DIR"/*.sh; do
        local tname
        tname=$(basename "$tuner" .sh)
        echo -n "  [$tname] "
        bash "$tuner" "$CURRENT_PROFILE"
    done

    local ts
    ts=$(date +%s)
    echo "{\"profile\":\"$profile_name\",\"applied\":true,\"timestamp\":$ts}" > "$STATE_FILE"
    echo "=== Karya SPEED: $profile_name applied ==="
}

show_status() {
    local current_state current_profile ts
    if [[ -f "$STATE_FILE" ]]; then
        current_profile=$(jq -r '.profile // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
        ts=$(jq -r '.timestamp // 0' "$STATE_FILE" 2>/dev/null || echo "0")
        if [[ "$ts" != "0" ]]; then
            local date_str
            date_str=$(date -d "@$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
            echo "Active Profile: $current_profile (applied $date_str)"
        else
            echo "Active Profile: $current_profile"
        fi
    else
        echo "No profile applied yet."
    fi

    echo ""
    echo "Current System State:"
    echo "  CPU Governor:     $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo N/A)"
    echo "  I/O Scheduler:    $(cat /sys/block/sda/queue/scheduler 2>/dev/null | awk '{print $1}' | tr -d '[]' || echo N/A)"
    echo "  Swappiness:       $(sysctl -n vm.swappiness 2>/dev/null || echo N/A)"
    echo "  TCP CC:           $(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo N/A)"
    echo "  THP:              $(cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null | awk '{print $1}' | tr -d '[]' || echo N/A)"
}

daemon_mode() {
    echo "Karya SPEED daemon starting..."
    local last_profile=""

    while true; do
        local current_profile
        if [[ -f "$CURRENT_PROFILE" ]]; then
            current_profile=$(basename "$(readlink -f "$CURRENT_PROFILE")" .conf)
        else
            current_profile="unknown"
        fi

        if [[ "$current_profile" != "$last_profile" ]]; then
            if [[ -f "$CURRENT_PROFILE" ]]; then
                for tuner in "$TUNER_DIR"/*.sh; do
                    bash "$tuner" "$CURRENT_PROFILE"
                done
                last_profile="$current_profile"
            fi
        fi

        sleep 30
    done
}

main() {
    init

    if [[ $# -eq 0 ]]; then
        list_profiles
        echo ""
        show_status
        return
    fi

    case "${1:-}" in
        performance|balanced|powersave)
            apply_profile "$1"
            ;;
        status)
            show_status
            ;;
        apply)
            if [[ -n "${2:-}" ]]; then
                apply_profile "$2"
            else
                echo "Usage: speed apply <profile>"
                return 1
            fi
            ;;
        daemon)
            daemon_mode
            ;;
        list|profiles)
            list_profiles
            ;;
        help|--help|-h)
            echo "Karya SPEED - Performance Tuning System"
            echo ""
            echo "Usage:"
            echo "  speed                    List profiles and show status"
            echo "  speed <profile>          Apply profile (performance/balanced/powersave)"
            echo "  speed status             Show current state"
            echo "  speed apply <profile>    Apply profile"
            echo "  speed daemon             Run monitoring daemon"
            echo "  speed list               List available profiles"
            echo "  speed help               This help"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Usage: speed <profile|status|apply|daemon|list|help>"
            return 1
            ;;
    esac
}

main "$@"
