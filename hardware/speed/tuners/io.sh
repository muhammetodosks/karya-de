#!/usr/bin/env bash
# Karya SPEED - I/O Scheduler Tuner
set -euo pipefail

apply_io() {
    local profile="$1"
    local scheduler quantum nr_requests

    scheduler=$(grep "^IO_SCHEDULER=" "$profile" | cut -d= -f2)
    quantum=$(grep "^IO_QUANTUM=" "$profile" | cut -d= -f2)
    nr_requests=$(grep "^IO_NR_REQUESTS=" "$profile" | cut -d= -f2)

    for disk in /sys/block/{sd*,nvme*,hd*,vd*}; do
        [[ ! -d "$disk" ]] && continue
        local sched="$disk/queue/scheduler"
        local que="$disk/queue/iosched/quantum"
        local nrq="$disk/queue/nr_requests"

        if [[ -w "$sched" ]]; then
            if grep -q "$scheduler" "$sched" 2>/dev/null; then
                echo "$scheduler" > "$sched" 2>/dev/null || true
            else
                local first=$(awk '{print $1}' "$sched" | tr -d '[]' 2>/dev/null)
                [[ -n "$first" ]] && echo "$first" > "$sched" 2>/dev/null || true
            fi
        fi

        [[ -w "$que" ]] && echo "$quantum" > "$que" 2>/dev/null || true
        [[ -w "$nrq" ]] && echo "$nr_requests" > "$nrq" 2>/dev/null || true

        echo 0 > "$disk/queue/nomerges" 2>/dev/null || true
        echo 0 > "$disk/queue/add_random" 2>/dev/null || true
        echo 2 > "$disk/queue/write_cache" 2>/dev/null || true
    done

    echo "I/O: $scheduler (quantum=$quantum nr_requests=$nr_requests)"
}

apply_io "${1:-/etc/karya/speed/current.conf}"
