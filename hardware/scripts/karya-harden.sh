#!/usr/bin/env bash
# Karya DE - Sistem Sertlestirme Scripti
# Bu script, kernel, sysctl ve AppArmor seviyesinde
# guvenlik politikalarini uygular.
set -euo pipefail

VERSION="1.0.0"
LOG="/var/log/karya-harden.log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG"; }

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Bu script root yetkisi gerektirir."
        echo "sudo bash $0"
        exit 1
    fi
}

install_kernel_module() {
    log "[1/8] Kernel guvenlik modulu kuruluyor..."
    
    if [[ ! -d /usr/src/karya-security-1.0.0 ]]; then
        mkdir -p /usr/src/karya-security-1.0.0
        cp kernel/modules/karya-security.c /usr/src/karya-security-1.0.0/
        cat > /usr/src/karya-security-1.0.0/Makefile << MAKEEOF
obj-m += karya-security.o
KDIR := /lib/modules/\$(shell uname -r)/build
PWD := \$(shell pwd)
all:
	\$(MAKE) -C \$(KDIR) M=\$(PWD) modules
clean:
	\$(MAKE) -C \$(KDIR) M=\$(PWD) clean
install:
	\$(MAKE) -C \$(KDIR) M=\$(PWD) modules_install
	depmod -a
MAKEEOF
        cat > /usr/src/karya-security-1.0.0/dkms.conf << DKMS
PACKAGE_NAME="karya-security"
PACKAGE_VERSION="1.0.0"
BUILT_MODULE_NAME[0]="karya-security"
DEST_MODULE_LOCATION[0]="/kernel/security/karya"
MAKE="make all"
CLEAN="make clean"
AUTOINSTALL="yes"
DKMS
    fi
    
    if command -v dkms &>/dev/null; then
        dkms add -m karya-security -v 1.0.0 2>/dev/null || true
        dkms build -m karya-security -v 1.0.0 2>/dev/null || true
        dkms install -m karya-security -v 1.0.0 2>/dev/null || true
    fi
    
    modprobe karya-security 2>/dev/null || true
    log "Kernel modulu: $(lsmod | grep karya-security || echo 'yuklenemedi')"
}

install_intel_blocker() {
    log "[2/8] Intel bloklama modulu kuruluyor..."
    
    if [[ ! -d /usr/src/karya-intel-block-1.0.0 ]]; then
        mkdir -p /usr/src/karya-intel-block-1.0.0
        cp kernel/intel-blocker/dkms/* /usr/src/karya-intel-block-1.0.0/
    fi
    
    if command -v dkms &>/dev/null; then
        dkms add -m karya-intel-block -v 1.0.0 2>/dev/null || true
        dkms build -m karya-intel-block -v 1.0.0 2>/dev/null || true
        dkms install -m karya-intel-block -v 1.0.0 2>/dev/null || true
    fi
    
    modprobe karya-intel-block 2>/dev/null || true
    log "Intel bloklama: $(lsmod | grep karya-intel-block || echo 'yuklenemedi')"
}

apply_sysctl_hardening() {
    log "[3/8] Sysctl hardening uygulaniyor..."
    
    cp kernel/hardening/90-karya-hardening.conf /etc/sysctl.d/90-karya-hardening.conf
    cp security/sysctl/99-karya-security.conf /etc/sysctl.d/99-karya-security.conf
    
    sysctl -p /etc/sysctl.d/90-karya-hardening.conf 2>/dev/null || true
    sysctl -p /etc/sysctl.d/99-karya-security.conf 2>/dev/null || true
    
    log "Sysctl hardening uygulandi."
}

apply_modprobe_blacklist() {
    log "[4/8] Modprobe blacklist uygulaniyor..."
    
    cp kernel/hardening/modprobe.d/90-karya-security.conf /etc/modprobe.d/90-karya-security.conf
    
    # Intel modullerini su an kaldir (yuklu ise)
    for mod in i915 intel_agp intel_gtt mei mei_me; do
        if lsmod | grep -q "^$mod"; then
            modprobe -r "$mod" 2>/dev/null || true
            log "Modul kaldirildi: $mod"
        fi
    done
    
    log "Modprobe blacklist uygulandi."
}

install_apparmor_profiles() {
    log "[5/8] AppArmor profilleri kuruluyor..."
    
    local profiles_dir="/etc/apparmor.d"
    mkdir -p "$profiles_dir"
    
    cp security/apparmor/karya-oobe "$profiles_dir/usr.bin.karya-oobe"
    cp security/apparmor/karya-widgets "$profiles_dir/usr.lib.qt6.qml.org.karya"
    cp security/apparmor/kwin-karya "$profiles_dir/usr.bin.kwin_karya"
    cp security/apparmor/karya-drivers "$profiles_dir/usr.lib.karya.scripts"
    
    if command -v apparmor_parser &>/dev/null; then
        apparmor_parser -r "$profiles_dir/usr.bin.karya-oobe" 2>/dev/null || true
        apparmor_parser -r "$profiles_dir/usr.lib.qt6.qml.org.karya" 2>/dev/null || true
        apparmor_parser -r "$profiles_dir/usr.bin.kwin_karya" 2>/dev/null || true
        apparmor_parser -r "$profiles_dir/usr.lib.karya.scripts" 2>/dev/null || true
        log "AppArmor profilleri yuklendi."
    else
        log "UYARI: AppArmor kurulu degil, profiller kaydedildi."
    fi
}

setup_boot_parameters() {
    log "[6/8] Boot parametreleri ayarlaniyor..."
    
    local params=""
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        params="$params $line"
    done < kernel/hardening/90-karya-kernel-params.conf
    
    if [[ -f /etc/default/grub ]]; then
        if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub; then
            sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"${params}\"|" /etc/default/grub
        fi
        grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
        log "GRUB yapilandirmasi guncellendi."
    fi
    
    log "Boot parametreleri ayarlandi."
}

setup_initramfs_hook() {
    log "[7/8] Initramfs hook kuruluyor..."
    
    local hook_name="karya-intel-block"
    cp kernel/intel-blocker/initcpio/hook "/etc/initcpio/hooks/$hook_name"
    cp kernel/intel-blocker/initcpio/install "/etc/initcpio/install/$hook_name"
    
    # mkinitcpio.conf'a hook ekle
    if [[ -f /etc/mkinitcpio.conf ]]; then
        if ! grep -q "karya-intel-block" /etc/mkinitcpio.conf; then
            sed -i "s/HOOKS=(\(.*\))/HOOKS=(\1 $hook_name)/" /etc/mkinitcpio.conf
        fi
    fi
    
    mkinitcpio -p linux 2>/dev/null || true
    log "Initramfs hook kuruldu ve initrd yeniden olusturuldu."
}

verify_security() {
    log "[8/8] Guvenlik dogrulamasi yapiliyor..."
    
    local score=0
    local total=12
    
    echo ""
    echo "============================================"
    echo "  Karya DE Guvenlik Dogrulama"
    echo "============================================"
    echo ""
    
    # 1. Kernel module
    if lsmod | grep -q "karya-security"; then
        echo "  [OK] Kernel security modulu yuklu"
        score=$((score + 1))
    else
        echo "  [--] Kernel security modulu yuklu degil"
    fi
    
    # 2. Intel blocker
    if lsmod | grep -q "karya-intel-block"; then
        echo "  [OK] Intel bloklama modulu yuklu"
        score=$((score + 1))
    else
        echo "  [--] Intel bloklama modulu yuklu degil"
    fi
    
    # 3. ASLR
    if [[ $(cat /proc/sys/kernel/randomize_va_space) -eq 2 ]]; then
        echo "  [OK] ASLR tam (randomize_va_space=2)"
        score=$((score + 1))
    else
        echo "  [--] ASLR eksik"
    fi
    
    # 4. kptr_restrict
    if [[ $(cat /proc/sys/kernel/kptr_restrict) -eq 2 ]]; then
        echo "  [OK] kptr_restrict tam"
        score=$((score + 1))
    else
        echo "  [--] kptr_restrict eksik"
    fi
    
    # 5. dmesg_restrict
    if [[ $(cat /proc/sys/kernel/dmesg_restrict) -eq 1 ]]; then
        echo "  [OK] dmesg kisitli"
        score=$((score + 1))
    else
        echo "  [--] dmesg kisitli degil"
    fi
    
    # 6. kexec disabled
    if [[ $(cat /proc/sys/kernel/kexec_load_disabled) -eq 1 ]]; then
        echo "  [OK] kexec kapali"
        score=$((score + 1))
    else
        echo "  [--] kexec acik"
    fi
    
    # 7. SYN cookies
    if [[ $(cat /proc/sys/net/ipv4/tcp_syncookies) -eq 1 ]]; then
        echo "  [OK] SYN cookies aktif"
        score=$((score + 1))
    else
        echo "  [--] SYN cookies pasif"
    fi
    
    # 8. ICMP redirect
    if [[ $(cat /proc/sys/net/ipv4/conf/all/accept_redirects) -eq 0 ]]; then
        echo "  [OK] ICMP redirect kapali"
        score=$((score + 1))
    else
        echo "  [--] ICMP redirect acik"
    fi
    
    # 9. AppArmor
    if command -v aa-status &>/dev/null; then
        local profiles=$(aa-status 2>/dev/null | grep -c "karya" || echo "0")
        if [[ $profiles -ge 1 ]]; then
            echo "  [OK] AppArmor: $profiles Karya profili yuklu"
            score=$((score + 1))
        else
            echo "  [--] AppArmor profili yok"
        fi
    else
        echo "  [--] AppArmor kurulu degil"
    fi
    
    # 10. BPF
    if [[ $(cat /proc/sys/net/core/bpf_jit_enable 2>/dev/null) -eq 0 ]]; then
        echo "  [OK] BPF JIT kapali"
        score=$((score + 1))
    else
        echo "  [--] BPF JIT acik"
    fi
    
    # 11. User NS
    local user_ns=$(cat /proc/sys/user/max_user_namespaces 2>/dev/null || echo "unknown")
    if [[ "$user_ns" == "0" ]]; then
        echo "  [OK] User namespaces kapali"
        score=$((score + 1))
    else
        echo "  [--] User namespaces acik ($user_ns)"
    fi
    
    # 12. Core dump
    if [[ $(cat /proc/sys/fs/suid_dumpable) -eq 0 ]]; then
        echo "  [OK] SUID core dump kapali"
        score=$((score + 1))
    else
        echo "  [--] SUID core dump acik"
    fi
    
    echo ""
    echo "============================================"
    echo "  Skor: $score/$total"
    if [[ $score -eq $total ]]; then
        echo "  DURUM: TAM GUVENLIK - Tum kontroller gecti"
    elif [[ $score -ge $((total / 2)) ]]; then
        echo "  DURUM: ORTA - $((total - score)) eksik var"
    else
        echo "  DURUM: DUSUK - $((total - score)) eksik var"
    fi
    echo "============================================"
    echo ""
    
    log "Guvenlik dogrulama: $score/$total"
}

main() {
    require_root
    
    echo ""
    echo "============================================"
    echo "  Karya DE Sistem Sertlestirme v$VERSION"
    echo "============================================"
    echo ""
    
    install_kernel_module
    install_intel_blocker
    apply_sysctl_hardening
    apply_modprobe_blacklist
    install_apparmor_profiles
    setup_boot_parameters
    setup_initramfs_hook
    verify_security
    
    echo ""
    echo "============================================"
    echo "  Sertlestirme tamamlandi!"
    echo "  Log: $LOG"
    echo "  Yeniden baslatmaniz onerilir."
    echo "============================================"
    echo ""
}

main "$@"
