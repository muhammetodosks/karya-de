<picture>
  <source media="(prefers-color-scheme: dark)" srcset="branding/logo/karya-logo.svg">
  <img alt="Karya DE" src="branding/logo/karya-logo.svg" width="120" align="right">
</picture>

# Karya DE

![License](https://img.shields.io/badge/license-GPLv2-blue)
![Plasma](https://img.shields.io/badge/Plasma-6-orange)
![Qt](https://img.shields.io/badge/Qt-6-green)
![Arch](https://img.shields.io/badge/Arch-Linux-1793D1)
![Status](https://img.shields.io/badge/status-alpha-yellow)

**Modern, Türk yapımı masaüstü ortamı.** KDE Plasma 6 tabanlı, tam fork.

Karya DE, KDE Plasma 6'yı tamamen fork'layarak oluşturulmuş, Türk kullanıcılar için özel olarak tasarlanmış bir masaüstü ortamıdır. Modern görünüm, yüksek performans ve tam Türkçe desteği sunar.

---

## Görünüm

> Ekran görüntüleri ilk kararlı build sonrası eklenecek. Aşağıdaki konsept tasarımdır.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="branding/mockup/karya-mockup-dark.svg">
  <img alt="Karya DE Konsept" src="branding/mockup/karya-mockup-dark.svg" width="100%">
</picture>

---

## Özellikler

### 🪟 KWin Fork (kwin-karya)
- **Auto Tiling** - 4 layout: Master-Stack, Split, Grid, Monocle
- **Glassmorphism** - Özel şeffaf cam efekti (C++ + JS)
- **Gesture Desteği** - Trackpad/dokunmatik ekran hareketleri
- **Kısayollar:** Meta+T tiling aç/kapa, Meta+Shift+T layout değiştir, Meta+Shift+G glassmorphism toggle

### 🔝 Plasma Shell Fork
- **Üst panel** - Kickoff, icon tasks, system tray, saat (Türkiye saati)
- **Alt dock** - Otomatik gizlenen, ortalanmış uygulama dock'u
- **Tam Türkçe** - Tüm arayüz, menüler, mesajlar Türkçe

### ☀️ Türk Widget'lar
| Widget | Açıklama |
|--------|----------|
| **Karya Hava** | Türkiye şehirleri için anlık hava durumu |
| **Karya Namaz** | Diyanet bazlı namaz vakitleri, kalan süre |
| **Karya Haber** | Son dakika Türkiye haber başlıkları |

### 🎯 OOBE (Kurulum Sihirbazı)
İlk çalıştırmada kullanıcıyı karşılayan PyQt6 tabanlı kurulum sihirbazı:
1. Hoş Geldiniz
2. Tema Seçimi (Karya Karanlık/Aydınlık/Mavi/Klasik)
3. Panel Düzeni (Modern/Klasik/macOS/Minimal)
4. Bileşenler (Tiling, Glassmorphism, Animasyonlar)

### ⚡ Performans & Sistem
- **Wayland + X11** desteği (Wayland önerilen)
- **elogind + runit** ile systemd'siz çalışabilme
- **F2FS/XFS** dosya sistemi önerisi
- Düşük kaynak tüketimi için optimize edilmiş varsayılanlar

---

## Mimari

```
karya-de/
├── sources/                  # Fork'lanmış KDE repo'ları
│   ├── kwin/                 # KWin window manager
│   ├── plasma-workspace/     # Panel, shell, bildirimler
│   ├── plasma-desktop/       # Masaüstü uygulamaları
│   ├── plasma-pa/            # Ses yönetimi
│   └── systemsettings/       # Ayarlar
├── patches/                  # Karya patch'leri
│   └── kwin/                 # Tiling patch'i
├── kwin-effects/             # Custom KWin efektleri
│   ├── karya-glassmorphism/  # C++ glassmorphism efekti
│   └── scripts/              # KWin JS script'leri
├── shell/                    # Plasma yapılandırması
│   ├── layouts/              # Panel/dock layout'ları
│   ├── look-and-feel/        # Tema paketi
│   └── sessions/             # Oturum dosyaları
├── widgets/                  # Plasma 6 widget'ları
│   ├── karya-hava/           # Hava durumu
│   ├── karya-namaz/          # Namaz vakitleri
│   └── karya-haber/          # Haber başlıkları
├── branding/                 # Görsel kimlik
│   ├── logo/                 # SVG logo
│   ├── splash/               # Açılış ekranı
│   └── wallpapers/           # Duvar kağıtları
├── packages/                 # Arch PKGBUILD'ları
│   ├── karya-de-meta/        # Meta paket
│   ├── kwin-karya/           # Fork'lanmış KWin
│   ├── karya-widgets/        # Widget paketi
│   └── karya-oobe/           # Kurulum sihirbazı
├── iso/                      # Arch ISO konfigürasyonu
└── scripts/                  # Derleme araçları
```

---

## Kurulum

### Gereksinimler
- **Arch Linux** (geliştirme için)
- 4+ GB RAM
- 10+ GB boş disk
- Git, base-devel

### 1. Geliştirme Ortamını Kur

```bash
git clone https://github.com/muhammetodosks/karya-de.git
cd karya-de
make setup
```

Bu komut:
- Gerekli paketleri kurar (Qt6, KDE Frameworks, elogind, runit, vs.)
- Plasma 6 kaynak kodlarını `sources/` dizinine klonlar

### 2. Build Et

```bash
make build
```

Sırasıyla şu bileşenler derlenir:
1. `kwin-karya` - KWin fork
2. `plasma-workspace-karya` - Panel/shell fork
3. `plasma-desktop-karya` - Masaüstü fork
4. `plasma-pa-karya` - Ses fork
5. `systemsettings-karya` - Ayarlar fork
6. `breeze-karya` - Tema fork
7. `kdeplasma-addons` - Eklentiler

### 3. Sisteme Kur

```bash
make install
```

### 4. PKGBUILD ile Kur (Alternatif)

```bash
cd packages/kwin-karya
makepkg -si

cd ../karya-widgets
makepkg -si

cd ../karya-oobe
makepkg -si

cd ../karya-de-meta
makepkg -si
```

### 5. ISO Oluştur

```bash
make iso
```

ISO dosyası `iso/releng/out/` dizinine çıkar.

---

## Kullanım

### Oturum Başlatma

**Wayland (önerilen):**
```bash
dbus-run-session startplasma-wayland
```

**X11:**
```bash
startx
```

### Kısayollar
| Kısayol | İşlev |
|---------|-------|
| Meta+T | Auto tiling aç/kapa |
| Meta+Shift+T | Tiling layout değiştir |
| Meta+Shift+G | Glassmorphism aç/kapa |
| Alt+F1 | Uygulama menüsü |
| Meta+D | Masaüstünü göster |

---

## Katkıda Bulunma

1. Fork'la
2. Branch aç (`git checkout -b feature/yeni-ozellik`)
3. Commit yap (`git commit -m 'feat: yeni özellik eklendi'`)
4. Push'la (`git push origin feature/yeni-ozellik`)
5. Pull Request aç

---

## Lisans

GNU General Public License v2.0 - [LICENSE](LICENSE)

---

## Ekibimiz

**Karya DE Team** - [karya@karya-de.org](mailto:karya@karya-de.org)

---

*🇹🇷 Türk mühendisliği ile, Türk kullanıcılar için.*
