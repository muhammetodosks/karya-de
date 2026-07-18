# Karya DE Guvenlik Sistemi

## Katmanli Guvenlik Mimarisi

```
+--------------------------------------------------+
|                 UYGULAMA KATMANI                  |
|  AppArmor / SELinux profilleri                   |
|  - karya-oobe: OOBE erisim kisitlamasi           |
|  - karya-widgets: Widget ag/dosya kisitlamasi    |
|  - kwin-karya: WM erisim kisitlamasi             |
|  - karya-drivers: Surucu yonetimi kisitlamasi    |
+--------------------------------------------------+
|                 SISTEM KATMANI                    |
|  Sysctl hardening                                 |
|  - ASLR, kptr_restrict, dmesg_restrict           |
|  - AG: rp_filter, syncookies, redirect kapat     |
|  - Core dump: suid_dumpable=0                    |
+--------------------------------------------------+
|                 KERNEL KATMANI                    |
|  LKM: karya-security.ko                          |
|  - Intel GPU bloklama (PCI probe)                |
|  - /tmp'den exec engelleme                        |
|  - Process izolasyonu                            |
|  - /proc/karya/sec/ ihlal izleme                 |
+--------------------------------------------------+
|                 KERNEL PARAMETRELERI              |
|  Boot cmdline hardening                           |
|  - pti=on (Meltdown)                             |
|  - mitigations=auto                              |
|  - lockdown=confidentiality                      |
|  - module.sig_enforce=1                          |
|  - iommu=force                                   |
+--------------------------------------------------+
|                 INTEL BLOKLAMA                    |
|  DKMS: karya-intel-block.ko                      |
|  - PCI probe ile Intel GPU tespiti               |
|  - Kernel panic + 5sn bekleme                    |
|  - Initramfs hook (boot oncesi bloklama)          |
|  - modprobe.blacklist=i915                       |
+--------------------------------------------------+
```

---

## 1. DKMS Intel Blocker (`kernel/intel-blocker/`)

### Nasil Calisir

1. **Boot asamasinda**: Initramfs hook'u PCI veriyolunu tarar
2. Intel GPU bulursa: kirmizi hata mesaji + `panic()`
3. Kernel modulu yuklu ise: `karya-intel-block` PCI probe'de tekrar dener
4. 3 katmanli bloklama (initramfs -> kernel module -> modprode blacklist)

### Bypass Korumasi

- `KARYA_SKIP_INTEL_CHECK=1` ile initramfs atlanamaz
- `allow_ignore=0` (varsayilan) ile module bypass edilemez
- Yuksek guvenlik modu: `karya-security.ko` da ayri bloklama yapar

### Kurulum

```bash
# DKMS ile kurulum
cd kernel/intel-blocker/dkms
make
sudo make install
sudo depmod -a

# Initramfs
sudo cp kernel/intel-blocker/initcpio/* /etc/initcpio/install/
sudo mkinitcpio -p linux

# Modprobe blacklist
sudo cp kernel/hardening/modprobe.d/90-karya-security.conf /etc/modprobe.d/
```

---

## 2. Kernel Guvenlik Modulu (`kernel/modules/karya-security.c`)

### Ozellikler

- **Intel GPU tespiti**: PCI taramasi ile
- **LOCKDOWN**: confidentiality seviyesinde kernel kilidi
- **Exec korumasi**: /tmp ve /dev/shm'den program calistirilamaz
- **SUID izleme**: SUID degisimleri loglanir
- **ProcFS arabirimi**: `/proc/karya/sec/` altinda durum izleme

### ProcFS Dosyalari

| Dosya | Icerik |
|-------|--------|
| `/proc/karya/sec/status` | Modul durumu, versiyon, ihlal sayaci |
| `/proc/karya/sec/version` | Versiyon bilgisi |
| `/proc/karya/sec/violations` | Ihlal loglari |

---

## 3. Sysctl Hardening (`kernel/hardening/`)

### Bellek Korumalari

| Ayar | Deger | Aciklama |
|------|-------|----------|
| `kernel.randomize_va_space` | 2 | Tam ASLR |
| `kernel.kptr_restrict` | 2 | Kernel pointer'lari gizle |
| `kernel.dmesg_restrict` | 1 | dmesg root'a kisitli |
| `kernel.kexec_load_disabled` | 1 | Kexec kapali |
| `user.max_user_namespaces` | 0 | User namespace kapali |

### Ag Korumalari

| Ayar | Deger | Aciklama |
|------|-------|----------|
| `net.ipv4.tcp_syncookies` | 1 | SYN flood korumasi |
| `net.ipv4.conf.all.rp_filter` | 1 | IP spoofing korumasi |
| `net.ipv4.conf.all.accept_redirects` | 0 | ICMP redirect reddet |
| `net.ipv4.conf.all.send_redirects` | 0 | ICMP redirect gonderme |
| `net.ipv4.conf.all.accept_source_route` | 0 | Source routing kapat |
| `net.ipv4.conf.all.log_martians` | 1 | Gizemli paketleri logla |
| `net.ipv4.tcp_timestamps` | 0 | TCP timestamp kapat |

---

## 4. Boot Parametreleri (`kernel/params.conf`)

### Spekulatif Saldiri Korumalari

| Parametre | Korumasi |
|-----------|----------|
| `pti=on` | Meltdown (KAISER) |
| `kpti=1` | Kernel PTI |
| `ssbd=force` | Spectre v4 (SSB) |
| `srso=on` | Return Stack Overflow |
| `retbleed=auto` | Retbleed |
| `l1tf=full` | L1 Terminal Fault |
| `mds=full` | ZombieLoad |
| `tsx_async_abort=full` | TAA |
| `mmio_stale_data=full` | MMIO Stale Data |

### Intel Modulleri Engelleme

```bash
modprobe.blacklist=i915
modprobe.blacklist=intel_agp
modprobe.blacklist=intel_gtt
modprobe.blacklist=mei
modprobe.blacklist=mei_me
```

---

## 5. AppArmor Profilleri (`security/apparmor/`)

| Profil | Hedef | Kisitlama |
|--------|-------|-----------|
| `karya-oobe` | OOBE sihirbazi | Sadece /etc/karya, pacman, bash |
| `karya-widgets` | Hava/Namaz/Haber/Sistem | Ag, /proc okuma, SSL |
| `kwin-karya` | Window manager | DRM, X11, GPU, input |
| `karya-drivers` | Surucu yonetimi | Pacman, modprobe, Xorg |

---

## 6. Dosya Butunlugu Kontrolu

Karya DE, kritik dosyalarin butunlugunu su sekilde korur:

```bash
# Kritik dosyalarin hash'leri
sha256sum /etc/karya/config/*.conf
sha256sum /usr/lib/karya/scripts/*.sh

# AIDE veya tripwire benzeri butunluk veritabani
# /var/lib/karya/integrity.db
```

---

## 7. Guvenlik Duyurulari

Guvenlik aciklari icin: `security@karya-de.org`

- **CVSS 9.0+**: 24 saat icinde yama
- **CVSS 7.0-8.9**: 72 saat icinde yama
- **CVSS 4.0-6.9**: Bir sonraki surumde duzeltme

---

## 8. Tehdit Modeli

| Tehdit | Katman | Cozum |
|--------|--------|-------|
| Intel GPU exploit | Kernel | Tam bloklama, 3 katman |
| Yetkisiz exec | Kernel + AppArmor | /tmp korumasi, profil kisitlamasi |
| Kernel exploit | Boot params | Lockdown, mitigasyonlar |
| Ag saldirilari | Sysctl | SYN flood, spoofing korumasi |
| DMA saldirilari | IOMMU | Zorunlu IOMMU, Thunderbolt kapali |
| Bellek siridirisi | Kernel | ASLR, kptr_restrict |
| Yetki yukseltme | AppArmor | SUID loglama, profil kisitlamasi |
