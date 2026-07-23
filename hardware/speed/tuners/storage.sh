#!/usr/bin/env bash
# Karya SPEED - Storage Tuner
set -euo pipefail

apply_storage() {
    local profile="$1"
    local read_ahead nr_requests sched_timeout

    read_ahead=$(grep "^READ_AHEAD_KB=" "$profile" | cut -d= -f2)
    nr_requests=$(grep "^NR_REQUESTS=" "$profile" | cut -d= -f2)
    sched_timeout=$(grep "^SCHEDULER_TIMEOUT=" "$profile" | cut -d= -f2)

    for disk in /sys/block/{sd*,nvme*,hd*,vd*}; do
        [[ ! -d "$disk" ]] && continue
        [[ -w "$disk/queue/read_ahead_kb" ]] && echo "$read_ahead" > "$disk/queue/read_ahead_kb" 2>/dev/null || true
        [[ -w "$disk/queue/nr_requests" ]] && echo "$nr_requests" > "$disk/queue/nr_requests" 2>/dev/null || true
        [[ -w "$disk/queue/iosched/slice_idle" ]] && echo "0" > "$disk/queue/iosched/slice_idle" 2>/dev/null || true
        [[ -w "$disk/queue/rq_affinity" ]] && echo "2" > "$disk/queue/rq_affinity" 2>/dev/null || true
        [[ -w "$disk/queue/iostats" ]] && echo "0" > "$disk/queue/iostats" 2>/dev/null || true
        echo "0" > "$disk/queue/add_random" 2>/dev/null || true

        # Rotational detection
        local rotational
        rotational=$(cat "$disk/queue/rotational" 2>/dev/null || echo "0")
        if [[ "$rotational" == "0" ]]; then
            [[ -w "$disk/queue/scheduler" ]] && echo "none" > "$disk/queue/scheduler" 2>/dev/null || true
            blockdev --setra "$((read_ahead * 2))" "/dev/$(basename $disk)" 2>/dev/null || true
        fi
    done

    # FSTRIM if SSD
    for fs in / /home /var; do
        mountpoint -q "$fs" || continue
        fstrim "$fs" 2>/dev/null || true
    done

    echo "Storage: read_ahead=${read_ahead}K nr_requests=$nr_requests"
}

apply_storage "${1:-/etc/karya/speed/current.conf}"
