# Karya DE Güvenlik Politikasi

## Versiyön: 1.0.0 | Son Guncelleme: 2026

---

## 1. Giriş

Karya DE, guvenlik odakli tasarlanmis bir masaüstü ortamidir.
Bu belge, guvenlik politikalari, tehdit modeli, ve raporlama sureclerini açıklar.

---

## 2. Tehdit Modeli

### 2.1. Varsayilan Dusman Kabiliyeti

| Seviye | Kabiliyet | Karsi Onlem |
|--------|-----------|-------------|
| D1 | Script kiddie | Temel sysctl, AppArmor |
| D2 | Yetkisiz yerel kullanıcı | AppArmor profilleri |
| D3 | Ag tabanlı saldirgan | Ag sysctl, firewall |
| D4 | Kernel exploit | Boot mitigasyönlari |
| D5 | Fiziksel erisim | IOMMU, disk şifreleme |

### 2.2. Varsayilan Guven Duzeyi

| Bilesen | Guven Seviyesi | Açıklama |
|---------|----------------|----------|
| KWin (kwin-karya) | Trusted | Window manager |
| OOBE | Semi-trusted | Sudo erisimi, AppArmor |
| Widget'lar | Restricted | Ag ve dosya erisimi kisitli |
| Driver Scripts | Semi-trusted | Pacman erisimi |
| SDDM | Trusted | PAM oturum yöneticisi |

---

## 3. Güvenlik Mimarisi

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

## 5. Güvenlik Duyurulari

### 5.1. Raporlama

Güvenlik açıklari: **security@karya-de.org**

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
| OOBE kurulum | `/var/log/karya-oobe.log` | Kurulum adımlari |
| Surucu kurulum | `/var/log/karya-driver-install.log` | Surucu işlemleri |
| AppArmor | `/var/log/audit/audit.log` | AppArmor ihlalleri |

---

## 7. Güvenlik Ekibi

| Rol | Iletisim |
|-----|----------|
| Security Lead | security@karya-de.org |

---

*Karya DE - Güvenlik odakli, Türk yapimi masaüstü ortami.*
