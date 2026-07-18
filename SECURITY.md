# Karya DE Guvenlik Politikasi

## Versiyon: 1.0.0 | Son Guncelleme: 2026

---

## 1. Giris

Karya DE, sifirdan guvenlik odakli tasarlanmis bir masaustu ortamidir.
Bu belge, guvenlik politikalari, tehdit modeli, ve raporlama sureclerini aciklar.

---

## 2. Tehdit Modeli

### 2.1. Varsayilan Dusman Kabiliyeti

| Seviye | Kabiliyet | Karsi Onlem |
|--------|-----------|-------------|
| D1 | Script kiddie | Temel sysctl, AppArmor |
| D2 | Yetkisiz yerel kullanici | Kernel hardening, exec korumasi |
| D3 | Ag tabanli saldirgan | IOMMU, ag sysctl, firewall |
| D4 | Kernel exploit | Panic on OOM, lockdown, mitigations |
| D5 | Fiziksel erisim | DMA koruma, disk sifreleme |

### 2.2. Varsayilan Guven Duzeyi

| Bilesen | Guven Seviyesi | Aciklama |
|---------|----------------|----------|
| KWin (kwin-karya) | Trusted | Kernel modul yetkisiyle calisir |
| OOBE | Semi-trusted | Sudo erisimi, AppArmor profili |
| Widget'lar | Restricted | Ag ve dosya erisimi kisitli |
| Driver Scripts | Semi-trusted | Pacman ve modprobe erisimi |
| SDDM | Trusted | PAM oturum yoneticisi |
| User Apps | Unrestricted | Normal kullanici kosullari |

---

## 3. Katmanli Guvenlik Mimarisi

```
KATMAN 5: UYGULAMA
  - AppArmor profilleri (oobe, widgets, kwin, drivers)
  - SELinux politikasi (karya.te)
  - SUID loglama

KATMAN 4: SISTEM
  - Sysctl hardening (10 kategori)
  - Core dump kisitlamasi
  - Dosya butunlugu

KATMAN 3: KERNEL MODULU
  - karya-security.ko LSM
  - Intel GPU bloklama
  - /tmp exec korumasi
  - ProcFS izleme (/proc/karya/sec/)

KATMAN 2: BOOT PARAMETRELERI
  - CPU mitigations (Meltdown, Spectre, MDS, TAA, etc)
  - Lockdown mode (confidentiality)
  - Module signing enforced
  - IOMMU forced

KATMAN 1: INTEL BLOKLAMA
  - Initramfs hook (boot oncesi)
  - DKMS kernel module (panic)
  - modprobe blacklist (i915, mei, etc)
  - /bin/false override
```

---

## 4. Kernel Guvenligi

### 4.1. Boot Parametreleri

```
# CPU Guvenlik Aciklari Korumalari
pti=on                    # Meltdown (KAISER)
kpti=1                    # Kernel Page Table Isolation
ssbd=force                # Speculative Store Bypass
srso=on                   # Return Stack Overflow
retbleed=auto             # Retbleed (AMD/Intel)
l1tf=full                 # L1 Terminal Fault
mds=full                  # Microarchitectural Data Sampling
tsx_async_abort=full      # TSX Async Abort
mmio_stale_data=full      # MMIO Stale Data

# Kernel Sertlestirme
lockdown=confidentiality   # Kernel kilidi
module.sig_enforce=1       # Zorunlu modul imzasi
iommu.passthrough=0        # IOMMU zorunlu
intel_iommu=on             # Intel VT-d
amd_iommu=on               # AMD-Vi
stack_guard_gap=256        # Stack smashing koruma
vsyscall=none              # vsyscall kapat
debugfs=off                # DebugFS kapat
page_poison=1              # Sayfa zehirleme
slub_debug=FZ              # SLUB hata ayiklama
mem.devmem=0               # /dev/mem kapat
```

### 4.2. Sysctl Hardening

**Bellek Korumalari:**
```
kernel.randomize_va_space = 2    # Tam ASLR
kernel.kptr_restrict = 2         # Kernel pointer gizle
kernel.dmesg_restrict = 1        # dmesg kisitla
kernel.kexec_load_disabled = 1   # kexec kapat
vm.panic_on_oom = 2              # OOM'de panic
kernel.panic_on_oops = 1         # OOPS'de panic
kernel.panic = 10                # 10sn sonra reboot
```

**Ag Korumalari:**
```
net.ipv4.tcp_syncookies = 1              # SYN flood
net.ipv4.conf.all.rp_filter = 1          # Spoofing
net.ipv4.conf.all.accept_redirects = 0   # ICMP redirect
net.ipv4.conf.all.send_redirects = 0     # ICMP redirect gonderme
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1       # Martian log
net.ipv4.tcp_timestamps = 0              # TCP timestamp kapat
net.ipv4.tcp_fin_timeout = 15            # FIN timeout
```

### 4.3. Kernel Module Guvenligi

**Bloklanan Moduleler:**
```
# Intel GPU (tamamen engelli)
i915, intel_agp, intel_gtt, mei, mei_me

# Guvenlik acigi tasiyanlar
usb_storage, bluetooth, firewire_ohci, thunderbolt
```

**Zorunlu Imzalama:**
```
module.sig_enforce=1
# Tum moduller gecerli bir imza ile imzalanmalidir
# Imzasiz moduller yuklenemez
```

---

## 5. Intel GPU Bloklama Sistemi

Karya DE, Intel GPU'lari **kernel seviyesinde** bloklar. Bu katmanli bloklama sistemi:

### 5.1. Calisma Prensipleri

```
Baslangic
    |
    v
[1] Initramfs Hook
    |-- PCI taramasi (vendor 0x8086, class 0x0300/0x0380)
    |-- Intel GPU bulursa -> kirmizi hata + panic()
    |-- ATLATILAMAZ (KARYA_SKIP_INTEL_CHECK ise yaramaz)
    |
    v
[2] DKMS Kernel Module (karya-intel-block)
    |-- PCI probe callback kaydeder
    |-- Intel GPU tespitinde:
    |   - pr_emerg() ile mesaj
    |   - 5 saniye bekle (goruntu icin)
    |   - panic() cagir
    |-- allow_ignore=0 ile bypass edilemez
    |
    v
[3] Modprobe Blacklist
    |-- i915 -> /bin/false
    |-- intel_agp -> /bin/false
    |-- 20+ Intel modulu bloklandi
    |
    v
[4] LSM Kernel Module (karya-security)
    |-- Ayri bir PCI taramasi daha yapar
    |-- KWin calismadan once kontrol eder
    |-- /proc/karya/sec/violations loglar
    |
    v
[TAM BLOKLAMA]
```

### 5.2. DKMS Modulu Detaylari

```c
// Kaynak: kernel/intel-blocker/dkms/karya-intel-block.c
// PCI Vendor: Intel (0x8086)
// Class: VGA Controller (0x0300), Display (0x0380)
// Eylem: panic("Karya DE: Intel GPU desteklenmiyor")

// Parametreler:
//   block_intel = true (varsayilan)
//   allow_ignore = false (varsayilan)
//   panic_delay = 5 (saniye)
```

### 5.3. Initramfs Hook

```bash
# /etc/mkinitcpio.conf
HOOKS=(... karya-intel-block udev ...)
# (udev'den ONCE calisir)
```

---

## 6. Uygulama Katmani Guvenligi

### 6.1. AppArmor Profilleri

| Profil | Dosya | Erisim |
|--------|-------|--------|
| OOBE | `security/apparmor/karya-oobe` | /etc/karya, pacman, bash |
| Widgets | `security/apparmor/karya-widgets` | /proc, ag, SSL |
| KWin | `security/apparmor/kwin-karya` | DRM, X11, GPU, input |
| Drivers | `security/apparmor/karya-drivers` | Pacman, modprobe, Xorg |

### 6.2. SELinux Politikasi

```bash
# Kaynak: security/selinux/karya.te
# Type: karya_oobe_t, karya_kwin_t, karya_widgets_t, karya_drivers_t
# Domain: restricted
# Ag: yalnizca gerekli portlar
```

### 6.3. SUID/SGID Korumasi

```bash
# /proc/sys/fs/suid_dumpable = 0
# SUID degisimleri kernel modulu tarafindan loglanir
```

---

## 7. Ag Guvenligi

### 7.1. Varsayilan Firewall Onerisi

```bash
# nftables ile temel guvenlik
#!/sbin/nft -f

table inet karya {
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Loopback
        iif "lo" accept
        
        # Established/Related
        ct state established,related accept
        
        # SSH (opsiyonel)
        tcp dport 22 accept
        
        # ICMP (sinirli)
        icmp type { echo-request, echo-reply, destination-unreachable, time-exceeded } accept
        
        # Drop everything else
        log prefix "KARYA-DROP: " drop
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

### 7.2. Wayland Guvenligi

```bash
# Wayland, X11'den daha guvenlidir:
# - Her pencere kendi buffer'ina sahiptir
# - Keylogger imkansiz
# - Ekran goruntusu alma izne tabidir
# - window manager izin sistemi vardir
```

---

## 8. Guvenlik Duyurulari

### 8.1. Raporlama

Guvenlik aciklari: **security@karya-de.org**
PGP Key: `0xKARYA2026`

### 8.2. Soz Verilen Cozum Sureleri

| CVSS | Cozum Suresi | Guncelleme |
|------|-------------|------------|
| 9.0+ (Critical) | 24 saat | 12 saatte bir |
| 7.0-8.9 (High) | 72 saat | 24 saatte bir |
| 4.0-6.9 (Medium) | 14 gun | Haftalik |
| 0.1-3.9 (Low) | 90 gun | Bir sonraki surum |

### 8.3. Guvenlik Guncellemeleri

```bash
# Karya DE guvenlik guncellemeleri
karya-sec-update
# veya
pacman -Syu karya-security-updates
```

---

## 9. Denetim ve Loglama

### 9.1. Log Dosyalari

| Log | Konum | Icerik |
|-----|-------|--------|
| Kernel ihlalleri | `/proc/karya/sec/violations` | Kernel modulu ihlalleri |
| OOBE kurulum | `/var/log/karya-oobe.log` | Kurulum adimlari |
| Surucu kurulum | `/var/log/karya-driver-install.log` | Surucu islemleri |
| AppArmor | `/var/log/audit/audit.log` | AppArmor ihlalleri |
| Sistem log | `/var/log/messages` | Genel sistem olaylari |

### 9.2. Audit

```bash
# Kernel modulu durumu
cat /proc/karya/sec/status

# Violations
cat /proc/karya/sec/violations

# AppArmor status
sudo aa-status

# Son guvenlik olaylari
sudo journalctl -t kernel | grep KaryaDE-SEC
```

---

## 10. Guvenlik Acigi Veritabani

| ID | Bilesen | CVSS | Durum | Cozum |
|----|---------|------|-------|-------|
| - | - | - | - | - |

*(Henuz kayitli guvenlik acigi yoktur)*

---

## 11. Uyumluluk

| Standart | Seviye | Aciklama |
|----------|--------|----------|
| OWASP Top 10 | Uyumlu | Web bilesenleri icin |
| CIS Benchmarks | Kismi | Linux benchmark |
| ISO 27001 | Hedef | 2027 Q1 |
| GDPR | Uyumlu | Kullanici verisi toplanmaz |

---

## 12. Guvenlik Ekibi

| Rol | Kisi | Iletisim |
|-----|------|----------|
| Security Lead | Karya DE Ekibi | security@karya-de.org |
| Kernel Security | Karya DE Ekibi | kernel-security@karya-de.org |
| AppArmor/SELinux | Karya DE Ekibi | apparmor@karya-de.org |

---

## 13. Degisiklik Gecmisi

| Tarih | Versiyon | Degisiklik |
|-------|----------|------------|
| 2026 | 1.0.0 | Ilk surum |

---

*Karya DE - Guvenlik odakli, Turk yapimi masaustu ortami.*
