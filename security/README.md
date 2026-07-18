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
|                 BOOT KATMANI                      |
|  CPU mitigations                                  |
|  - pti=on (Meltdown)                             |
|  - ssbd=force, srso=on, retbleed=auto            |
|  - l1tf=full, mds=full                           |
+--------------------------------------------------+
```

---

## 1. AppArmor Profilleri (`security/apparmor/`)

| Profil | Hedef | Kisitlama |
|--------|-------|-----------|
| `karya-oobe` | OOBE sihirbazi | Sadece /etc/karya, pacman, bash |
| `karya-widgets` | Hava/Namaz/Haber/Sistem | Ag, /proc okuma, SSL |
| `kwin-karya` | Window manager | DRM, X11, GPU, input |
| `karya-drivers` | Surucu yonetimi | Pacman, modprobe, Xorg |

---

## 2. Guvenlik Duyurulari

Guvenlik aciklari icin: `security@karya-de.org`

- **CVSS 9.0+**: 24 saat icinde yama
- **CVSS 7.0-8.9**: 72 saat icinde yama
- **CVSS 4.0-6.9**: Bir sonraki surumde duzeltme
