#!/usr/bin/env bash
# ============================================================
# Karya Sentinel - 24/7 Derin Guvenlik Tarama ve Yama Sistemi
# ============================================================
# Bu sistem ASLA durmaz. 7/24 calisir.
# Kullanici sadece "sakin saat" (quiet hours) belirler.
# Kritik acik bulursa BEKLEMEZ, HEMEN YAMALAR.
# ============================================================
set -euo pipefail

VERSION="1.0.0"
SENTINEL_DIR="/etc/karya/sentinel"
LOG_DIR="/var/log/karya"
LOCK_FILE="$SENTINEL_DIR/sentinel.lock"
CONFIG_FILE="/etc/karya/sentinel.conf"
TIMESTAMP_FILE="$SENTINEL_DIR/last_deep_scan"
STATE_FILE="$SENTINEL_DIR/state.json"
ALERT_FILE="$SENTINEL_DIR/alerts.log"
PATCH_LOG="$LOG_DIR/sentinel-patch.log"

mkdir -p "$SENTINEL_DIR" "$LOG_DIR"

# ============================================================
# KONFIGURASYON
# ============================================================
# Varsayilan degerler (kullanici /etc/karya/sentinel.conf ile ezer)
DEEP_SCAN_HOUR=${KARYA_SENTINEL_DEEP_HOUR:-03}   # Derin tarama baslangic saati
DEEP_SCAN_MIN=${KARYA_SENTINEL_DEEP_MIN:-00}      # Derin tarama baslangic dakika
SCAN_INTERVAL=${KARYA_SENTINEL_INTERVAL:-300}     # Hafif tarama araligi (saniye)
AUTO_PATCH=${KARYA_SENTINEL_AUTO_PATCH:-true}     # Otomatik yama
ALERT_EMAIL=${KARYA_SENTINEL_ALERT:-""}            # E-posta uyarisi (opsiyonel)

# Konfigurasyon dosyasini yukle
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# ============================================================
# YARDIMCI FONKSIYONLAR
# ============================================================

log()   { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SENTINEL] $*" | tee -a "$LOG_DIR/sentinel.log"; }
alert() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ALERT] $*" | tee -a "$ALERT_FILE"; }
patch_log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PATCH] $*" >> "$PATCH_LOG"; }

is_deep_scan_time() {
    local now_hour=$(date +%H)
    local now_min=$(date +%M)
    local start_min=$(( DEEP_SCAN_HOUR * 60 + DEEP_SCAN_MIN ))
    local now_min_total=$(( 10#$now_hour * 60 + 10#$now_min ))
    local end_min=$(( start_min + 120 ))  # 2 saatlik pencere

    # Gece yarisi gecisi kontrolu
    if (( start_min > end_min )); then
        # Orn: 23:00 - 01:00
        (( now_min_total >= start_min || now_min_total <= end_min )) && return 0 || return 1
    else
        (( now_min_total >= start_min && now_min_total <= end_min )) && return 0 || return 1
    fi
}

# ============================================================
# FAZ 1: SUREKLI KALKAN (7/24 - HER ZAMAN AKTIF)
# ============================================================

phase1_continuous_shield() {
    log "[FAZ-1] Surekli kalkan aktif - 7/24"

    # 1a. Dosya butunluk denetimi (kritik sistem dosyalari)
    local critical_files=(
        "/etc/karya/hardware/gpu.json"
        "/etc/karya/hardware/profile.json"
        "/etc/karya/sentinel.conf"
        "/etc/sysctl.d/99-karya-security.conf"
        "/etc/apparmor.d/karya-oobe"
        "/etc/apparmor.d/karya-widgets"
        "/etc/apparmor.d/kwin-karya"
        "/etc/apparmor.d/karya-drivers"
    )

    for f in "${critical_files[@]}"; do
        if [[ -f "$f" ]]; then
            local hash=$(sha256sum "$f" | cut -d' ' -f1)
            local known="$SENTINEL_DIR/hashes/$(echo "$f" | tr '/' '_').sha256"
            if [[ -f "$known" ]]; then
                local old=$(cat "$known")
                if [[ "$hash" != "$old" ]]; then
                    alert "DOSYA DEGISIKLIGI: $f (eski: $old, yeni: $hash)"
                    echo "$hash" > "$known"
                fi
            else
                mkdir -p "$SENTINEL_DIR/hashes"
                echo "$hash" > "$known"
            fi
        fi
    done

    # 1b. Calisan proses anomali denetimi
    local suspicious=0
    local ps_list=$(ps aux 2>/dev/null || true)

    # Kok ekran yakalama
    if echo "$ps_list" | grep -qi 'x11vnc\|vncserver\|vino\|x0vncserver\|krfb'; then
        alert "UYARI: VNC/Ekran paylasimi tespit edildi - guvenlik riski"
        suspicious=$((suspicious + 1))
    fi

    # Reverse shell denetimi
    if echo "$ps_list" | grep -qi 'nc -l\|ncat -l\|socat\|ngrok\|localtunnel'; then
        alert "KRITIK: Reverse shell/port yonlendirme tespit edildi!"
        suspicious=$((suspicious + 10))
    fi

    # Dosya indirme anomali
    if echo "$ps_list" | grep -qi 'wget.*sh\|curl.*|.*sh\|curl.*bash'; then
        alert "UYARI: Pipe-through-shell tespit edildi"
        suspicious=$((suspicious + 1))
    fi

    # 1c. Ag dinleme portu denetimi
    local listening=$(ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null || true)
    local unknown_ports=0
    if echo "$listening" | grep -q ':4444\|:5555\|:6666\|:7777\|:8888\|:9999'; then
        alert "KRITIK: Supheli port dinlemesi tespit edildi!"
        unknown_ports=$((unknown_ports + 5))
    fi

    # 1d. Kernel modulu denetimi
    local modules=$(lsmod 2>/dev/null || true)
    if echo "$modules" | grep -qi 'kvm\|vboxguest\|nvidia.*drm\|nvidia_modeset\|nvidia_uvm'; then
        : # Bilinmiyor/yasal moduller
    fi

    # 1e. SUID/SGID binary denetimi
    local suid_count=$(find /usr /bin /sbin -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | wc -l)
    if (( suid_count > 100 )); then
        alert "UYARI: Anormal SUID/SGID binary sayisi: $suid_count"
    fi

    # 1f. Kullanici hesap denetimi
    local root_uid_count=$(awk -F: '$3==0{print $1}' /etc/passwd 2>/dev/null | wc -l)
    if (( root_uid_count > 1 )); then
        alert "UYARI: Birden fazla root UID'li hesap: $(awk -F: '$3==0{print $1}' /etc/passwd | tr '\n' ' ')"
    fi

    # 1g. /tmp ve /dev/shm yazma denetimi
    local tmp_world=$(find /tmp /dev/shm -type f -perm -0002 2>/dev/null | wc -l)
    if (( tmp_world > 50 )); then
        alert "UYARI: /tmp ve /dev/shm'de $tmp_world herkese acik dosya"
    fi

    if (( suspicious > 0 || unknown_ports > 0 )); then
        log "[FAZ-1] $suspicious supheli proses, $unknown_ports bilinmeyen port"
    fi
}

# ============================================================
# FAZ 2: DERIN TARAMA (Kullanici belirtilen saatte, ama her an calisabilir)
# ============================================================

phase2_deep_scan() {
    log "[FAZ-2] Derin tarama basliyor - kapsamli guvenlik denetimi"

    # 2a. Paket guvenlik denetimi (Arch Linux)
    if command -v pacman &>/dev/null; then
        log "  Paket denetimi..."
        local updates=$(pacman -Qu 2>/dev/null | wc -l)
        if (( updates > 0 )); then
            log "  $updates paket guncellemesi mevcut"
            alert "GUNCELLEME: $updates paket guncellemesi bekliyor"

            # CVSS 9.0+ eslesmesi varsa HEMEN YAMA
            local security_pkgs=$(pacman -Qu 2>/dev/null | grep -i 'openssl\|gnutls\|nss\|curl\|wget\|libssh\|systemd\|linux\|kernel\|sudo\|polkit\|dbus\|glibc\|xorg\|mesa\|nvidia\|amdgpu\|firefox\|chromium\|thunderbird\|python\|perl\|php\|nginx\|apache\|mysql\|mariadb\|postgres\|redis' || true)
            if [[ -n "$security_pkgs" ]] && [[ "$AUTO_PATCH" == "true" ]]; then
                log "  KRITIK paket guncellemesi baslatiliyor..."
                if pacman -S --noconfirm $(echo "$security_pkgs" | awk '{print $1}') 2>&1 | tail -3 >> "$PATCH_LOG"; then
                    patch_log "Kritik paketler yamalandi: $(echo "$security_pkgs" | wc -l)"
                    alert "YAMA: Kritik paketler otomatik guncellendi"
                fi
            fi
        fi
    fi

    # 2b. Rootkit denetimi
    log "  Rootkit denetimi..."
    local rootkit_hints=0

    # Bilinen rootkit dosyalari
    for rk in ".suid" ".login" ".backdoor" "rk" "rootkit" "kbeast" "adore" "enyelkm"; do
        if find /usr /bin /sbin /lib /etc -name "*$rk*" 2>/dev/null | grep -q .; then
            alert "KRITIK: Rootkit bulgusu: $rk"
            rootkit_hints=$((rootkit_hints + 10))
        fi
    done

    # Hidden process check
    if command -v ps &>/dev/null; then
        local ps_visible=$(ps aux 2>/dev/null | wc -l)
        local proc_count=$(ls /proc/ | grep -c '^[0-9]' 2>/dev/null || echo "0")
        local diff=$(( proc_count - ps_visible ))
        if (( diff > 5 )); then
            alert "KRITIK: Gizli proses tespiti (proc: $proc_count, ps: $ps_visible)"
            rootkit_hints=$((rootkit_hints + 15))
        fi
    fi

    # 2c. Acik port denetimi
    log "  Port taramasi..."
    local open_ports=$(ss -tln 2>/dev/null | awk 'NR>1{print $4}' | grep -oP '\d+$' | sort -n | uniq || true)
    local known_ports="22 80 443 631 3306 5432 8080 8443"
    for port in $open_ports; do
        if ! echo "$known_ports" | grep -qw "$port"; then
            if (( port > 1024 )); then
                local svc=$(lsof -i :$port 2>/dev/null | tail -1 | awk '{print $1}' || echo "bilinmiyor")
                alert "UYARI: Acik port $port ($svc) - bilinen port degil"
            fi
        fi
    done

    # 2d. Sistem yapilandirma denetimi
    log "  Yapilandirma denetimi..."
    local misconfigs=0

    # AppArmor durumu
    if command -v aa-status &>/dev/null; then
        if ! aa-status 2>/dev/null | grep -q 'enforce'; then
            alert "KRITIK: AppArmor calismiyor veya enforce modda degil"
            misconfigs=$((misconfigs + 10))
        fi
    fi

    # Sysctl denetim
    if [[ "$(cat /proc/sys/kernel/randomize_va_space 2>/dev/null)" != "2" ]]; then
        alert "UYARI: ASLR tam olarak aktif degil"
        if [[ "$AUTO_PATCH" == "true" ]]; then
            echo 2 > /proc/sys/kernel/randomize_va_space 2>/dev/null || true
            patch_log "ASLR otomatik etkinlestirildi"
        fi
        misconfigs=$((misconfigs + 5))
    fi

    # Core dump
    if [[ "$(cat /proc/sys/fs/suid_dumpable 2>/dev/null)" != "0" ]]; then
        alert "UYARI: SUID core dump aktif"
        if [[ "$AUTO_PATCH" == "true" ]]; then
            echo 0 > /proc/sys/fs/suid_dumpable 2>/dev/null || true
            patch_log "Core dump otomatik kapatildi"
        fi
        misconfigs=$((misconfigs + 3))
    fi

    # 2e. Kullanici sifre politikasi
    log "  Sifre politikasi..."
    local empty_pass=$(awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow 2>/dev/null | grep -v ':\*:' | head -5 || true)
    if [[ -n "$empty_pass" ]]; then
        alert "KRITIK: Sifresiz kullanicilar: $empty_pass"
        misconfigs=$((misconfigs + 20))
    fi

    # 2f. Kernel guvenlik denetimi
    log "  Kernel denetimi..."
    if [[ -f /proc/sys/kernel/tainted ]]; then
        local tainted=$(cat /proc/sys/kernel/tainted)
        if (( tainted > 0 )); then
            alert "UYARI: Kernel tainted: $tainted (ozel-modul yuklu)"
        fi
    fi

    # 2g. Dosya sistemi denetimi
    log "  Dosya sistemi denetimi..."
    local world_writable=$(find /etc /usr /bin /sbin -type f -perm -0002 2>/dev/null | wc -l)
    if (( world_writable > 0 )); then
        alert "UYARI: $world_writable herkese acik dosya (/etc, /usr, /bin, /sbin)"
        if [[ "$AUTO_PATCH" == "true" ]]; then
            find /etc /usr /bin /sbin -type f -perm -0002 -exec chmod o-w {} \; 2>/dev/null || true
            patch_log "$world_writable herkese acik dosya duzeltildi"
            log "  $world_writable dosya otomatik duzeltildi"
        fi
    fi

    # 2h. SSH denetimi
    if [[ -f /etc/ssh/sshd_config ]]; then
        if grep -q 'PermitRootLogin yes' /etc/ssh/sshd_config 2>/dev/null; then
            alert "UYARI: Root SSH oturumu acik"
        fi
        if grep -q 'PasswordAuthentication yes' /etc/ssh/sshd_config 2>/dev/null; then
            alert "UYARI: SSH parola ile giris acik (oneri: publickey)"
        fi
    fi

    log "[FAZ-2] Derin tarama tamam - $misconfigs yanlis yapilandirma"
}

# ============================================================
# FAZ 3: OTOMATIK YAMA (Her zaman her seyi yamala)
# ============================================================

phase3_auto_patch() {
    [[ "$AUTO_PATCH" != "true" ]] && return
    log "[FAZ-3] Otomatik yama motoru aktif"

    local patched=0

    # 3a. AppArmor yukle (eksikse)
    if command -v apparmor_parser &>/dev/null; then
        for profile in /etc/apparmor.d/karya-*; do
            if [[ -f "$profile" ]]; then
                if ! aa-status 2>/dev/null | grep -q "$(basename $profile)"; then
                    apparmor_parser -a "$profile" 2>/dev/null || true
                    patch_log "AppArmor profili yuklendi: $(basename $profile)"
                    patched=$((patched + 1))
                fi
            fi
        done
    fi

    # 3b. Sysctl uygula (eksikse)
    local sysctl_file="/etc/sysctl.d/99-karya-security.conf"
    if [[ -f "$sysctl_file" ]]; then
        sysctl -p "$sysctl_file" 2>/dev/null || true
        patch_log "Sysctl ayarlari uygulandi"
        patched=$((patched + 1))
    fi

    # 3c. /tmp guvenligi
    if ! mount | grep -q '/tmp.*noexec'; then
        mount -o remount,noexec,nosuid,nodev /tmp 2>/dev/null || true
        patch_log "/tmp noexec/nosuid/nodev olarak remount edildi"
        patched=$((patched + 1))
    fi

    # 3d. /dev/shm guvenligi
    if mount | grep -q '/dev/shm'; then
        mount -o remount,noexec,nosuid,nodev /dev/shm 2>/dev/null || true
        patch_log "/dev/shm noexec/nosuid/nodev olarak remount edildi"
        patched=$((patched + 1))
    fi

    # 3e. Kritik proses korumasi
    if command -v systemctl &>/dev/null; then
        for svc in apparmor syslog-ng rsyslog auditd; do
            if systemctl is-enabled "$svc" &>/dev/null; then
                if ! systemctl is-active "$svc" &>/dev/null; then
                    systemctl start "$svc" 2>/dev/null || true
                    patch_log "Servis baslatildi: $svc"
                    patched=$((patched + 1))
                fi
            fi
        done
    fi

    log "[FAZ-3] $patched guvenlik duzeltmesi uygulandi"
}

# ============================================================
# ANA DONGU - 7/24 CALISIR
# ============================================================

main_loop() {
    log "=== Karya Sentinel v$VERSION BASLADI ==="
    log "Derin tarama: $DEEP_SCAN_HOUR:$DEEP_SCAN_MIN (2 saatlik pencere)"
    log "Hafif tarama araligi: $SCAN_INTERVAL saniye"
    log "Otomatik yama: $AUTO_PATCH"
    log "Bu sistem 7/24 calisir. Kullanici sadece derin tarama saatini belirler."
    log "========================================"

    # Ilk calistirmada hash baseline olustur
    phase1_continuous_shield

    while true; do
        # FAZ 1: Her zaman calisir
        phase1_continuous_shield

        # FAZ 2: Derin tarama - belirtilen saatte
        if is_deep_scan_time; then
            # Gunde bir kez calissin
            local today=$(date +%Y%m%d)
            local last_scan=""
            [[ -f "$TIMESTAMP_FILE" ]] && last_scan=$(cat "$TIMESTAMP_FILE")
            if [[ "$last_scan" != "$today" ]]; then
                phase2_deep_scan
                phase3_auto_patch
                echo "$today" > "$TIMESTAMP_FILE"
                log "Derin tarama tamamlandi - $today"
            fi
        fi

        sleep "$SCAN_INTERVAL"
    done
}

# ============================================================
# CLI KOMUTLARI
# ============================================================

case "${1:-start}" in
    start)
        main_loop
        ;;
    scan)
        # Tek seferlik manuel tarama
        phase1_continuous_shield
        phase2_deep_scan
        phase3_auto_patch
        echo "Tarama tamam. Log: $LOG_DIR/sentinel.log"
        ;;
    status)
        echo "Karya Sentinel v$VERSION"
        echo "Calisma dizini: $SENTINEL_DIR"
        echo "Son derin tarama: $(cat "$TIMESTAMP_FILE" 2>/dev/null || echo 'henuz yapilmadi')"
        echo "Derin tarama saati: $DEEP_SCAN_HOUR:$DEEP_SCAN_MIN"
        echo "Tarama araligi: $SCAN_INTERVAL saniye"
        echo "Otomatik yama: $AUTO_PATCH"
        echo "Alert sayisi: $(wc -l < "$ALERT_FILE" 2>/dev/null || echo 0)"
        if [[ -f "$STATE_FILE" ]]; then
            echo "Durum: $(cat "$STATE_FILE")"
        fi
        ;;
    alerts)
        cat "$ALERT_FILE" 2>/dev/null || echo "Alert yok"
        ;;
    patch)
        # Manuel yama calistir
        phase3_auto_patch
        ;;
    deep)
        # Manuel derin tarama
        phase2_deep_scan
        phase3_auto_patch
        echo "$(date +%Y%m%d)" > "$TIMESTAMP_FILE"
        ;;
    *)
        echo "Karya Sentinel v$VERSION"
        echo "Kullanim: $0 {start|scan|status|alerts|patch|deep}"
        echo ""
        echo "  start   - 7/24 sentinel olarak baslat (systemd/runit ile)"
        echo "  scan    - Tek seferlik guvenlik taramasi"
        echo "  status  - Sentinel durumu"
        echo "  alerts  - Alert logunu goster"
        echo "  patch   - Guvenlik yamalarini manuel uygula"
        echo "  deep    - Derin tarama baslat"
        exit 1
        ;;
esac
