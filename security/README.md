# Karya DE Güvenlik Sistemi

## Katmanlı Güvenlik Mimarisi

```
+--------------------------------------------------+
|          SENTINEL (7/24 - Hic Durmaz)             |
|  Dosya butunlugu, proses anomali, rootkit,       |
|  port tarama, otomatik yama                      |
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

## 1. Karya Sentinel (`security/sentinel/`)

7/24 çalışan derin güvenlik tarama ve otomatik yama sistemi.

| Bileşen | Açıklama |
|---------|----------|
| `karya-sentinel.sh` | Ana sentinel script (7/24 çalışır) |
| `karya-sentinel.conf` | Kullanıcı yapılandırması (sadece saat) |
| `runit/karya-sentinel/run` | Runit servisi |
| `README.md` | Detaylı dökümantasyon |

**Detaylı bilgi:** [security/sentinel/README.md](sentinel/README.md)

---

## 2. AppArmor Profilleri (`security/apparmor/`)

| Profil | Hedef | Kısıtlama |
|--------|-------|-----------|
| `karya-oobe` | OOBE sihirbazı | Sadece /etc/karya, pacman, bash |
| `karya-widgets` | Hava/Namaz/Haber/Sistem | Ağ, /proc okuma, SSL |
| `kwin-karya` | Window manager | DRM, X11, GPU, input |
| `karya-drivers` | Sürücü yönetimi | Pacman, modprobe, Xorg |

---

## 3. Sysctl Sertleştirme (`security/sysctl/`)

```bash
sudo cp security/sysctl/99-karya-security.conf /etc/sysctl.d/
sudo sysctl -p /etc/sysctl.d/99-karya-security.conf
```

---

## 4. SELinux Politikası (`security/selinux/`)

Opsiyonel SELinux desteği.

---

## 5. Güvenlik Duyuruları

Güvenlik açıkları için: `security@karya-de.org`

- **CVSS 9.0+ (Critical)**: 24 saat / **Sentinel anında yamalar**
- **CVSS 7.0-8.9 (High)**: 72 saat
- **CVSS 4.0-6.9 (Medium)**: 14 gün
- **CVSS 0.1-3.9 (Low)**: 90 gün

---

*Karya Sentinel — Görünmez ama her zaman orada.*
