# Changelog

## [v1.0.0-hotfix] - 2026-07-23

### Karya Market (Theme + Plugin + Marketplace)
- **Yeni:** `packages/karya-marketplace/` - tam pazaryeri sistemi
- **Tema Yoneticisi:** Plasma, KWin, ikon, SDDM, Splash, renk, cursor, Aurora temalarini yukle/kaldir/uygula
- **Eklenti Yoneticisi:** KWin script, efekt, Plasmoid, KRunner, Karya eklentilerini yonet
- **Pazaryeri GUI:** PyQt6 ile 4 sekme (Temalar, Eklentiler, Pazaryeri, Yukluler)
- **KDE Store entegrasyonu:** api.kde-look.org uzerinden binlerce tema ve eklenti arama
- **CLI destegi:** `karya-theme-manager` ve `karya-plugin-manager` komut satiri araclari
- **KDE Plasma 6 entegrasyonu:** lookandfeeltool, plasma-apply-desktoptheme, kwinrc, DBus
- **SVG ikon + .desktop + PKGBUILD** tam paketleme

### Karya SPEED (Performance Tuning)
- Yeni: `hardware/speed/` - tam performans ayar sistemi
  - 3 profil: performance, balanced, powersave
  - 9 tuner: CPU, I/O, Memory, Network, GPU, sysctl, Latency, Storage, Thermal
  - CLI: `speed` komutu ile profil değiştirme
  - systemd + runit servis desteği
  - udev kuralları (AC adaptör algılama)
- Yeni: `packages/karya-speed/PKGBUILD` - Arch paketi
- Yeni: `packages/linux-karya/PKGBUILD` - performans kernel paketi
- Yeni: `packages/linux-karya-hardened/PKGBUILD` - güvenlik kernel paketi
- Güncelleme: `karya-de-meta` bağımlılıklarına `karya-speed`, `linux-karya` eklendi

### Kernel
- Yeni: kernel 6.17 x86_64 yapılandırma dosyaları (performance + hardened)
- Yeni: kernel config'leri Karya DE optimizasyonları ile yapılandırıldı

### Güvenlik
- Yeni: `security/apparmor/karya-speed` - SPEED AppArmor profili
- Yeni: `security/apparmor/install.sh` - toplu AppArmor yükleyici
- Güncelleme: `security/selinux/karya.te` - SPEED SELinux politikası eklendi

### Build Sistemi
- Yeni: `.gitmodules` - KDE fork'ları için git submodule tanımları
- Düzeltme: `scripts/build.sh` - kaynak yoksa hata mesajı + build edilemeyeni atla
- Güncelleme: `scripts/build.sh` - SPEED kurulum adımı eklendi
- Güncelleme: `.github/workflows/build.yml` - tüm PKGBUILD'leri derle + lint adımı

### KWin/Shell
- Düzeltme: `kwin-effects/karya-glassmorphism/karyaglassmorphism.cpp` - KWin 6.x API uyumluluğu (drawWindow)
- Güncelleme: `shell/sessions/karya.env` - KWIN_DRM değişkenleri, SPEED env
- Güncelleme: `shell/sessions/startplasma-karya` - SPEED profili otomatik başlatma

### Widget'lar
- Düzeltme: `widgets/karya-sistem/` - canlı sistem monitör verisi bağlantısı
- Düzeltme: `widgets/karya-hava/` - şehir seçimi canlı veri güncelleme

### Uygulamalar
- Düzeltme: `karya-calc` - Decimal tabanlı güvenli aritmetik, input sanitizasyonu
- Yeni: `karya-notes` - şifre koruması (SHA-256 kilit ekranı)

### ISO
- Güncelleme: `iso/releng/packages.x86_64` - karya-speed eklendi
- Güncelleme: `iso/releng/profiledef.sh` - SPEED script izinleri

## [v0.2.0] - 2026-07-19

### Altyapı
- Kwin-karya PKGBUILD: tüm bağımlılıklar eklendi (knighttime, milou, aurorae, breeze, vulkan-headers, vb)
- Kwin-karya PKGBUILD: KF6 6.28+ uyumluluğu için DecorationPolicy tip hatası kaynak kodu yaması
- Kwin-karya PKGBUILD: KWIN_BUILD_KCMS=OFF (gereksiz KCM modülleri kapatıldı)
- plasma-desktop-karya PKGBUILD oluşturuldu (dock + panel layout)
- plasma-workspace-karya PKGBUILD oluşturuldu (oturum yönetimi)
- shell/sessions: karya.desktop + startplasma-karya + karya.env eklendi

### Kararlılık
- KWin build artık tüm bağımlılıklarla çalışıyor
- SDDM oturumu için gerekli dosyalar eklendi

## [v1.0.0] - 2026-07-20

### Yeni Özellikler
- Ubuntu 24.04+ desteği (apt tabanlı kurulum)
- PPA altyapısı (debian/ paketleme)
- install-ubuntu.sh: tek komutla Ubuntu kurulumu
- **4 Karya Python uygulaması:** Hesap Makinesi, Notlar, Masaüstü Arama, Karya Ayarlar
- **OOBE 14 sayfaya genişletildi:** tema, varsayılan uygulama, dev araçları, oyun, gizlilik, ekran, güç yönetimi sayfaları eklendi
- OOBE: NVIDIA blokajı kaldırıldı, tüm GPU'lar desteklenir
- OOBE: çoklu monitör yapılandırma desteği

### Düzeltmeler
- kwin-karya PKGBUILD: DecorationPolicy tip hatası için sed tüm .kcfg dosyalarını tarar
- install-ubuntu.sh: KWin kaynağı doğru dizinde build edilir
- driver_service.py: pacman/apt ayrımı distro algılamaya göre yapılır
- hardware_service.py: detect_distro() fonksiyonu eklendi
- OOBE: donanım özetinde dağıtım bilgisi gösterilir
- install.sh: `makepkg` root olarak çalıştırılmaz (sudo -u kullanıcı eklendi)
- install-ubuntu.sh: `curl | bash` içinde `read` komutu kaldırıldı (non-interactive)
- install.sh, install-ubuntu.sh: `set -o pipefail` eklendi
- debian/rules: `dh_auto_test` devre dışı, quoted globs, nullglob/shopt eklendi
- debian/control: gereksiz -dev bağımlılıkları ve Xorg sürücüleri temizlendi
- PKGBUILD (karya-calc/notes/search/settings): `package()` içinde kaynak yolu `src/` öneki ile düzeltildi
- kwin-karya PKGBUILD: kaynak URL'leri repo-absolute yapıldı
- make-karya-pkgbuild.sh: paket isimlendirme ve PKGVER/PKGREL düzeltildi
- make test-apps: tüm Python uygulamaları `ast.parse` ve import testinden geçer

### Değişiklikler
- README: Ubuntu kurulum bölümü eklendi, badge'ler güncellendi
- README: "Yalnızca Arch" sınırlaması kaldırıldı
- README: OOBE bölümü 14 sayfaya göre güncellendi, "Güncellendi" ibareleri eklendi
- README: 4 yeni Karya uygulaması paket listesine ve mimari şemaya eklendi
- PKGBUILD pkgrel=4
- install.sh: `makepkg --noconfirm` bayrağı eklendi
