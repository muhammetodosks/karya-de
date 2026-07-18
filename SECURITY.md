# Karya DE Guvenlik Politikasi

## Versiyon: 1.0.0 | Son Guncelleme: 2026

---

## 1. Giris

Karya DE, guvenlik odakli tasarlanmis bir masaustu ortamidir.
Bu belge, guvenlik politikalari, tehdit modeli, ve raporlama sureclerini aciklar.

---

## 2. Tehdit Modeli

### 2.1. Varsayilan Dusman Kabiliyeti

| Seviye | Kabiliyet | Karsi Onlem |
|--------|-----------|-------------|
| D1 | Script kiddie | Temel sysctl, AppArmor |
| D2 | Yetkisiz yerel kullanici | AppArmor profilleri |
| D3 | Ag tabanli saldirgan | Ag sysctl, firewall |
| D4 | Kernel exploit | Boot mitigasyonlari |
| D5 | Fiziksel erisim | IOMMU, disk sifreleme |

### 2.2. Varsayilan Guven Duzeyi

| Bilesen | Guven Seviyesi | Aciklama |
|---------|----------------|----------|
| KWin (kwin-karya) | Trusted | Window manager |
| OOBE | Semi-trusted | Sudo erisimi, AppArmor |
| Widget'lar | Restricted | Ag ve dosya erisimi kisitli |
| Driver Scripts | Semi-trusted | Pacman erisimi |
| SDDM | Trusted | PAM oturum yoneticisi |

---

## 3. Guvenlik Mimarisi

```
KATMAN 4: UYGULAMA
  - AppArmor profilleri (oobe, widgets, kwin, drivers)
  - SELinux politikasi (karya.te)

KATMAN 3: SISTEM
  - Sysctl hardening
  - Core dump kisitlamasi

KATMAN 2: BOOT PARAMETRELERI
  - CPU mitigations (Meltdown, Spectre, MDS, TAA, MMIO)
  - IOMMU forced

KATMAN 1: DONANIM
  - IOMMU
```

---

## 4. AppArmor Profilleri

| Profil | Dosya | Kisitlama |
|--------|-------|-----------|
| OOBE | `security/apparmor/karya-oobe` | /etc/karya, pacman, bash |
| Widgets | `security/apparmor/karya-widgets` | Ag, /proc, SSL |
| KWin | `security/apparmor/kwin-karya` | DRM, X11, GPU, input |
| Drivers | `security/apparmor/karya-drivers` | Pacman, modprobe, Xorg |

---

## 5. Guvenlik Duyurulari

### 5.1. Raporlama

Guvenlik aciklari: **security@karya-de.org**

### 5.2. Cozum Sureleri

| CVSS | Cozum Suresi |
|------|-------------|
| 9.0+ (Critical) | 24 saat |
| 7.0-8.9 (High) | 72 saat |
| 4.0-6.9 (Medium) | 14 gun |
| 0.1-3.9 (Low) | 90 gun |

---

## 6. Denetim ve Loglama

| Log | Konum | Icerik |
|-----|-------|--------|
| OOBE kurulum | `/var/log/karya-oobe.log` | Kurulum adimlari |
| Surucu kurulum | `/var/log/karya-driver-install.log` | Surucu islemleri |
| AppArmor | `/var/log/audit/audit.log` | AppArmor ihlalleri |

---

## 7. Guvenlik Ekibi

| Rol | Iletisim |
|-----|----------|
| Security Lead | security@karya-de.org |

---

*Karya DE - Guvenlik odakli, Turk yapimi masaustu ortami.*
