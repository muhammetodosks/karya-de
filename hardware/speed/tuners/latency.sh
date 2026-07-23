#!/usr/bin/env bash
# Karya SPEED - Latency Tuner
set -euo pipefail

apply_latency() {
    local profile="$1"
    local latency_target hung_task rcutree timer_slack numa

    latency_target=$(grep "^LATENCY_TARGET=" "$profile" | cut -d= -f2)
    hung_task=$(grep "^HUNG_TASK_TIMEOUT=" "$profile" | cut -d= -f2)
    rcutree=$(grep "^RCUTREE_KTHREAD_PRIO=" "$profile" | cut -d= -f2)
    timer_slack=$(grep "^TIMER_SLACK=" "$profile" | cut -d= -f2)
    numa=$(grep "^NUMA_BALANCING=" "$profile" | cut -d= -f2)

    sysctl -w kernel.hung_task_timeout_secs="$hung_task" >/dev/null 2>&1 || true
    sysctl -w kernel.numa_balancing="$numa" >/dev/null 2>&1 || true
    sysctl -w kernel.timer_slack_ns="$timer_slack" >/dev/null 2>&1 || true
    sysctl -w vm.stat_interval=1 >/dev/null 2>&1 || true

    # IRQ affinity - distribute across all cores
    local ncpus
    ncpus=$(nproc)
    local mask=""
    for ((i=1; i<=ncpus; i++)); do
        mask="${mask}1"
    done
    local hex_mask
    hex_mask=$(printf '%x' $((2#${mask:0:60})))

    for irq in /proc/irq/*/smp_affinity; do
        [[ -w "$irq" ]] && echo "$hex_mask" > "$irq" 2>/dev/null || true
    done

    sysctl -w kernel.task_delayacct=0 >/dev/null 2>&1 || true
    sysctl -w kernel.softlockup_panic=0 >/dev/null 2>&1 || true
    sysctl -w kernel.hung_task_panic=0 >/dev/null 2>&1 || true

    echo "Latency: target=$latency_target hung=$hung_task"
}

apply_latency "${1:-/etc/karya/speed/current.conf}"
