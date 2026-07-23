#!/usr/bin/env bash
# Karya SPEED - Memory Management Tuner
set -euo pipefail

apply_memory() {
    local profile="$1"
    local swap vfs_cache dirty dirty_bg dirty_exp dirty_wb min_free
    local compaction extfrag khugepaged thp reclaim

    swap=$(grep "^SWAPPINESS=" "$profile" | cut -d= -f2)
    vfs_cache=$(grep "^VFS_CACHE_PRESSURE=" "$profile" | cut -d= -f2)
    dirty=$(grep "^DIRTY_RATIO=" "$profile" | cut -d= -f2)
    dirty_bg=$(grep "^DIRTY_BACKGROUND_RATIO=" "$profile" | cut -d= -f2)
    dirty_exp=$(grep "^DIRTY_EXPIRE_CENTISECS=" "$profile" | cut -d= -f2)
    dirty_wb=$(grep "^DIRTY_WRITEBACK_CENTISECS=" "$profile" | cut -d= -f2)
    min_free=$(grep "^MIN_FREE_KBYTES=" "$profile" | cut -d= -f2)
    compaction=$(grep "^COMPACTION_PROACTIVENESS=" "$profile" | cut -d= -f2)
    extfrag=$(grep "^EXTFRAG_THRESHOLD=" "$profile" | cut -d= -f2)
    khugepaged=$(grep "^KHUGEPAGED_DEFRAG=" "$profile" | cut -d= -f2)
    thp=$(grep "^TRANSPARENT_HUGEPAGE=" "$profile" | cut -d= -f2)
    reclaim=$(grep "^RECLAIM_COMPACTION_DISABLED=" "$profile" | cut -d= -f2)

    sysctl -w vm.swappiness="$swap" >/dev/null 2>&1 || true
    sysctl -w vm.vfs_cache_pressure="$vfs_cache" >/dev/null 2>&1 || true
    sysctl -w vm.dirty_ratio="$dirty" >/dev/null 2>&1 || true
    sysctl -w vm.dirty_background_ratio="$dirty_bg" >/dev/null 2>&1 || true
    sysctl -w vm.dirty_expire_centisecs="$dirty_exp" >/dev/null 2>&1 || true
    sysctl -w vm.dirty_writeback_centisecs="$dirty_wb" >/dev/null 2>&1 || true
    sysctl -w vm.min_free_kbytes="$min_free" >/dev/null 2>&1 || true
    sysctl -w vm.compaction_proactiveness="$compaction" >/dev/null 2>&1 || true
    sysctl -w vm.extfrag_threshold="$extfrag" >/dev/null 2>&1 || true
    sysctl -w vm.reclaim_compaction_disabled="$reclaim" >/dev/null 2>&1 || true
    echo "$thp" > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true
    echo "$khugepaged" > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag 2>/dev/null || true

    echo "Memory: swap=$swap thp=$thp"
}

apply_memory "${1:-/etc/karya/speed/current.conf}"
