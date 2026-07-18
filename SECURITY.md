# Karya DE Güvenlik Politikası

**Versiyon: 2.0.0 | Son Güncelleme: 2026**

> **Karya Sentinel**: 7/24 çalışan, derin tarama yapan, açık bulursa beklemeden yamalayan otomatik güvenlik sistemi.
> Kullanıcı sadece derin tarama saatini belirler. Gerisini Sentinel halleder.

---

## 1. Güvenlik Felsefesi

Karya DE'nin güvenlik yaklaşımı üç prensibe dayanır:

| Prensip | Açıklama |
|---------|----------|
| **7/24 Koruma** | Güvenlik asla uyumaz. Sürekli kalkan her an aktiftir. |
| **Derin Tarama** | Yüzeysel kontrol yetmez. Dosya, proses, rootkit, kernel, config, CVE — her şey taranır. |
| **Anında Yama** | Açık tespit edildiği an yamalanır. Bekleme, onay, erteleme yok. |

---

## 2. Tehdit Modeli

### 2.1. Varsayılan Düşman Kabiliyeti

| Seviye | Kabiliyet | Karşı Önlem |
|--------|-----------|-------------|
| D1 | Script kiddie | Sürekli kalkan, sysctl, AppArmor |
| D2 | Yetkisiz yerel kullanıcı | AppArmor profilleri, dosya bütünlüğü |
| D3 | Ağ tabanlı saldırgan | Port tarama, ağ sysctl, güvenlik duvarı |
| D4 | Kernel exploit | Kernel hardening, tainted kernel denetimi, boot mitigasyonları |
| D5 | Rootkit | Rootkit imza taraması, gizli proses tespiti, dosya hash baseline |
| D6 | Fiziksel erişim | IOMMU, /tmp koruması, disk şifreleme |

### 2.2. Varsayılan Güven Düzeyi

| Bileşen | Güven Seviyesi | Açıklama |
|---------|----------------|----------|
| KWin (kwin-karya) | Trusted | Window manager |
| OOBE | Semi-trusted | Sudo erişimi, AppArmor profili |
| Widget'lar | Restricted | Ağ ve dosya erişimi kısıtlı |
| Driver Scripts | Semi-trusted | Pacman erişimi |
| SDDM | Trusted | PAM oturum yöneticisi |
| **Karya Sentinel** | **Root (denetlenen)** | **Her şeye erişir ama hash baseline ile denetlenir** |

---

## 3. Karya Sentinel — 7/24 Güvenlik Sistemi

**Karya Sentinel**, Karya DE'nin güvenlik bel kemiğidir.

```
KARYA SENTINEL MIMARISI
┌─────────────────────────────────────────────────────┐
│                   SENTINEL CORE                      │
│              (7/24 - Hic Durmaz)                     │
├──────────────┬──────────────────┬────────────────────┤
│   FAZ 1      │     FAZ 2        │      FAZ 3         │
│ Surekli      │    Derin         │     Otomatik       │
│ Kalkan       │    Tarama        │     Yama           │
├──────────────┼──────────────────┼────────────────────┤
│ • Dosya hash │ • Rootkit tarama │ • AppArmor yukle   │
│ • Proses     │ • CVE paket      │ • Sysctl uygula    │
│ • Port       │ • Config audit   │ • /tmp koru        │
│ • SUID/SGID  │ • Port analiz    │ • Paket yama       │
│ • Kullanici  │ • Kernel denetim │ • Dosya izin       │
│ • /tmp       │ • SSH denetim    │ • ASLR etkinles    │
└──────────────┴──────────────────┴────────────────────┘
        24/7          Schedule           Auto
```

### 3.1. Faz 1 — Sürekli Kalkan (7/24)

Hiç durmaz. Her `SCAN_INTERVAL` saniyede bir çalışır.

| Denetim | Frekans | Tepki |
|---------|---------|-------|
| Dosya bütünlüğü (SHA256) | Her çevrim | Hash değişirse → ALERT |
| Proses anomali (VNC, reverse shell) | Her çevrim | Bulursa → ALERT (KRITIK) |
| Açık port denetimi | Her çevrim | Şüpheli port → ALERT |
| SUID/SGID binary | Her çevrim | 100+ → UYARI |
| Root UID hesapları | Her çevrim | Fazlaysa → ALERT |
| /tmp, /dev/shm | Her çevrim | Açık dosya → UYARI |
| Kernel tainted | Derin tarama | Tainted → ALERT |

### 3.2. Faz 2 — Derin Tarama (Zamanlanmış)

Kullanıcının belirlediği saatte başlar. 2 saatlik pencerede çalışır.
**Zaman bilgisi PUBLIC değildir, yayınlanmaz.**

| Denetim | Kapsam | Tepki |
|---------|--------|-------|
| Paket CVE taraması | pacman -Qu, kritik paket filter | CVSS 9.0+ → HEMEN YAMA |
| Rootkit taraması | 20+ bilinen rootkit imzası, gizli proses | Bulursa → KRITIK ALERT |
| Açık port analizi | Tüm TCP dinleme, bilinmeyen portlar | Şüpheli → ALERT |
| AppArmor durumu | enforce mod kontrolü | Devre dışıysa → KRITIK ALERT |
| Sysctl denetimi | ASLR, core dump, rp_filter | Eksikse → OTOMATİK DÜZELT |
| Sifre politikası | Boş/sifresiz hesaplar | Bulursa → KRITIK ALERT |
| SSH denetimi | Root login, password auth | Açıksa → UYARI |
| World-writable dosya | /etc, /usr, /bin, /sbin | Bulursa → OTOMATİK DÜZELT |

### 3.3. Faz 3 — Otomatik Yama (Anında)

Açık bulunduğu an çalışır. Beklemez, sormaz.

| Yama | Koşul | Ne Yapar? |
|------|-------|-----------|
| AppArmor profil | Eksik profil | `apparmor_parser -a` ile yükler |
| Sysctl güvenlik | Eksik değer | `sysctl -p` ile uygular |
| /tmp guvenligi | noexec eksik | `mount -o remount,noexec,nosuid,nodev` |
| /dev/shm guvenligi | noexec eksik | `mount -o remount,noexec,nosuid,nodev` |
| Kritik paket | CVSS 9.0+ | `pacman -S` ile günceller |
| World-writable dosya | 0002 izin | `chmod o-w` ile kapatır |
| ASLR | Kapalıysa | echo 2 > /proc/sys/kernel/randomize_va_space |

### 3.4. Sentinel Konfigürasyonu

```bash
# /etc/karya/sentinel.conf
# Kullanıcı SADECE derin tarama saatini belirler.

# Derin tarama baslangic saati (ornek: gece 03:00)
KARYA_SENTINEL_DEEP_HOUR=03
KARYA_SENTINEL_DEEP_MIN=00

# Hafif tarama araligi (saniye)
KARYA_SENTINEL_INTERVAL=300

# Otomatik yama (true/false)
KARYA_SENTINEL_AUTO_PATCH=true
```

### 3.5. Sentinel Kurulumu

```bash
# Yukle
sudo cp security/sentinel/karya-sentinel.sh /usr/lib/karya/scripts/
sudo chmod +x /usr/lib/karya/scripts/karya-sentinel.sh

# Konfigurasyon
sudo cp security/sentinel/karya-sentinel.conf /etc/karya/sentinel.conf

# Servis olarak baslat (runit)
sudo cp -r security/sentinel/runit/karya-sentinel /etc/runit/sv/
sudo ln -s /etc/runit/sv/karya-sentinel /etc/runit/runsvdir/default/

# Veya manuel
sudo /usr/lib/karya/scripts/karya-sentinel.sh start
```

### 3.6. Sentinel Kullanımı

```bash
karya-sentinel status    # Durum goruntule
karya-sentinel scan      # Tek seferlik tarama
karya-sentinel alerts    # Alert log
karya-sentinel patch     # Manuel yama
karya-sentinel deep      # Derin tarama baslat
```

---

## 4. Güvenlik Mimarisi

```
KATMAN 5: SENTINEL (7/24)
  - Dosya butunlugu
  - Proses anomali
  - Port tarama
  - Rootkit tespiti
  - Otomatik yama

KATMAN 4: UYGULAMA
  - AppArmor profilleri (oobe, widgets, kwin, drivers)
  - SELinux politikasi (karya.te)

KATMAN 3: SISTEM
  - Sysctl hardening (ASLR, kptr_restrict, core dumps)
  - Ag guvenligi (rp_filter, syncookies)

KATMAN 2: BOOT
  - CPU mitigations (PTI, IBRS, SRSO, Retpoline)
  - IOMMU forced

KATMAN 1: DONANIM
  - IOMMU
```

---

## 5. AppArmor Profilleri

| Profil | Dosya | Kısıtlama |
|--------|-------|-----------|
| OOBE | `security/apparmor/karya-oobe` | /etc/karya, pacman, bash |
| Widgets | `security/apparmor/karya-widgets` | Ağ, /proc, SSL |
| KWin | `security/apparmor/kwin-karya` | DRM, X11, GPU, input |
| Drivers | `security/apparmor/karya-drivers` | Pacman, modprobe, Xorg |
| **Sentinel** | `security/apparmor/karya-sentinel` | **Her sey (hash baseline ile denetlenir)** |

---

## 6. Güvenlik Duyuruları

### 6.1. Raporlama

Güvenlik açıkları: **security@karya-de.org**

### 6.2. Çözüm Süreleri

| CVSS | Çözüm Süresi | Sentinel Tepkisi |
|------|-------------|------------------|
| 9.0+ (Critical) | 24 saat (insan) / **Anında (Sentinel)** | HEMEN YAMA |
| 7.0-8.9 (High) | 72 saat | Derin taramada YAMA |
| 4.0-6.9 (Medium) | 14 gün | Derin taramada YAMA |
| 0.1-3.9 (Low) | 90 gün | Bilgilendirme |

**Sentinel, CVSS 9.0+ açıkları için insan müdahalesini BEKLEMEZ.
Tespit ettiği an yamalar.**

---

## 7. Denetim ve Loglama

| Log | Konum | İçerik |
|-----|-------|--------|
| Sentinel ana log | `/var/log/karya/sentinel.log` | Tüm sentinel aktivitesi |
| Sentinel alert | `/var/log/karya/sentinel-alerts.log` | Guvenlik uyarilari |
| Sentinel yama | `/var/log/karya/sentinel-patch.log` | Otomatik yama kayitlari |
| OOBE kurulum | `/var/log/karya/oobe.log` | Kurulum adımları |
| Sürücü kurulum | `/var/log/karya/driver-install.log` | Sürücü işlemleri |
| AppArmor | `/var/log/audit/audit.log` | AppArmor ihlalleri |

---

## 8. Güvenlik Ekibi

| Rol | İletişim |
|-----|----------|
| Security Lead | security@karya-de.org |
| Sentinel Maintainer | sentinel@karya-de.org |

---

## 9. Sıkça Sorulan Sorular

### Sentinel hangi saatlerde çalışır?
**24/7.** Sürekli kalkan (Faz 1) hiç durmaz. Derin tarama (Faz 2) kullanıcının belirlediği saatte başlar. **Derin tarama saati PUBLIC değildir.**

### Sentinel açık bulursa ne yapar?
**Hemen yamalar.** Özellikle CVSS 9.0+ kritik açıklarda insan onayı beklemez. Tespit → Yama saniyeler içinde gerçekleşir.

### Sentinel'i durdurabilir miyim?
Teknik olarak evet. Ancak **önerilmez.** Sentinel olmadan sistem güvenlik açıklarına karşı korumasızdır.

### Sentinel sistem kaynağı tüketir mi?
Faz 1 (sürekli kalkan) ~5 saniyede tamamlanır, 5 dakikada bir çalışır. Derin tarama (Faz 2) ~30-60 saniye sürer. Toplam CPU kullanımı ihmal edilebilir düzeydedir.

### Sentinel güncellemeleri nasıl alır?
Karya DE paket güncellemesiyle birlikte gelir. `karya-sentinel.sh` script'i her güncellemede hash baseline ile doğrulanır.

---

*Karya DE — Güvenlik odaklı, Türk yapımı masaüstü ortamı.*
*Karya Sentinel — Görünmez ama her zaman orada.*
