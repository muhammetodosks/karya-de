#!/usr/bin/env bash
# Karya SPEED - sysctl Optimizer
set -euo pipefail

apply_sysctl() {
    local profile="$1"

    sysctl -w kernel.sched_autogroup_enabled=1 >/dev/null 2>&1 || true
    sysctl -w kernel.sched_child_runs_first=1 >/dev/null 2>&1 || true
    sysctl -w kernel.sched_latency_ns=3000000 >/dev/null 2>&1 || true
    sysctl -w kernel.sched_migration_cost_ns=500000 >/dev/null 2>&1 || true
    sysctl -w kernel.sched_nr_migrate=32 >/dev/null 2>&1 || true
    sysctl -w kernel.sched_wakeup_granularity_ns=2000000 >/dev/null 2>&1 || true
    sysctl -w kernel.sched_min_granularity_ns=1500000 >/dev/null 2>&1 || true
    sysctl -w kernel.sched_tunable_scaling=1 >/dev/null 2>&1 || true
    sysctl -w kernel.numa_balancing=0 >/dev/null 2>&1 || true
    sysctl -w kernel.perf_event_paranoid=2 >/dev/null 2>&1 || true
    sysctl -w kernel.kptr_restrict=1 >/dev/null 2>&1 || true
    sysctl -w kernel.dmesg_restrict=1 >/dev/null 2>&1 || true
    sysctl -w kernel.randomize_va_space=2 >/dev/null 2>&1 || true
    sysctl -w kernel.pid_max=4194304 >/dev/null 2>&1 || true
    sysctl -w kernel.pty.max=4096 >/dev/null 2>&1 || true
    sysctl -w kernel.core_uses_pid=1 >/dev/null 2>&1 || true
    sysctl -w kernel.msgmax=65536 >/dev/null 2>&1 || true
    sysctl -w kernel.shmmax=68719476736 >/dev/null 2>&1 || true
    sysctl -w kernel.shmall=4294967296 >/dev/null 2>&1 || true
    sysctl -w fs.file-max=2097152 >/dev/null 2>&1 || true
    sysctl -w fs.inotify.max_user_watches=524288 >/dev/null 2>&1 || true
    sysctl -w fs.inotify.max_user_instances=1024 >/dev/null 2>&1 || true
    sysctl -w fs.inotify.max_queued_events=65536 >/dev/null 2>&1 || true

    echo "sysctl: kernel + fs optimized"
}

apply_sysctl "${1:-/etc/karya/speed/current.conf}"
