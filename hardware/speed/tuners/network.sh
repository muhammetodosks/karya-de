#!/usr/bin/env bash
# Karya SPEED - Network Tuner
set -euo pipefail

apply_network() {
    local profile="$1"
    local congestion fastopen slow_start mtu_probing
    local rmem wmem rmem_def wmem_def

    congestion=$(grep "^NET_IPV4_TCP_CONG_CONTROL=" "$profile" | cut -d= -f2)
    fastopen=$(grep "^NET_IPV4_TCP_FASTOPEN=" "$profile" | cut -d= -f2)
    slow_start=$(grep "^NET_IPV4_TCP_SLOW_START_AFTER_IDLE=" "$profile" | cut -d= -f2)
    mtu_probing=$(grep "^NET_IPV4_TCP_MTU_PROBING=" "$profile" | cut -d= -f2)

    # Read key=value pairs for sysctl
    while IFS='=' read -r key val; do
        key="${key#"${key%%[![:space:]]*}"}"
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        case "$key" in
            NET_CORE_*) sysctl -w "net.core.${key#NET_CORE_}=$val" >/dev/null 2>&1 || true ;;
            NET_IPV4_*) sysctl -w "net.ipv4.${key#NET_IPV4_}=$val" >/dev/null 2>&1 || true ;;
        esac
    done < "$profile"

    modprobe -q tcp_"$congestion" 2>/dev/null || true
    sysctl -w net.ipv4.tcp_congestion_control="$congestion" >/dev/null 2>&1 || true
    ethtool -K $(ip route get 1 | awk '{print $5; exit}') gro on gso on tso on 2>/dev/null || true

    echo "Network: $congestion tfo=$fastopen mtu_probe=$mtu_probing"
}

apply_network "${1:-/etc/karya/speed/current.conf}"
