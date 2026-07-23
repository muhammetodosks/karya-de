# Changelog

## [v1.1.0] - 2026-07-23 — Karya Sun Devasa Güncelleme ☀️

### ☀️ Karya Sun — Bulut Altyapısı (5 Modül)
- **Karya Sync:** CRDT senkronizasyon motoru (Rust + WebSocket + tokio) — ~8.500 satır
- **Karya Vault:** Zero-knowledge şifreli veri deposu (Go + AES-256-GCM + Argon2id) — ~6.200 satır
- **Karya Relay:** WebRTC + QUIC uzaktan erişim relay (C++20 + libwebrtc) — ~4.800 satır
- **Karya Store:** GraphQL tema/eklenti pazaryeri backend (Node.js + Prisma + Redis + CDN) — ~5.100 satır
- **Karya Watch:** Prometheus + Loki + Grafana monitoring stack (Go) — ~3.400 satır
- **Karya Portal:** React + PWA web istemci (TypeScript) — ~12.000 satır
- **Dağıtım:** Docker Compose / Kubernetes Helm / Ansible (3 deployment seçeneği)
- **Kurulum:** `curl -sL https://karya-de.org/sun/deploy-docker.sh | bash`

### Karya SPEED — Donanım Performans Alt Sistemi
- **Yeni:** `hardware/speed/` — 9 ayrı tuner (CPU, GPU, RAM, IO, Storage, Network, Latency, Thermal, Sysctl)
- **3 Profil:** performance.conf / balanced.conf / powersave.conf
- **Servisler:** systemd (`karya-speed.service`) + runit (runit/) + path tetikleyici (`karya-speed.path`)
- **Udev:** AC adaptör algılama ile otomatik profil değiştirme (`99-karya-speed.rules`)
- **CLI:** `speed` komutu ile anında profil değiştirme
- **Yeni paket:** `packages/karya-speed/PKGBUILD`
- **AppArmor:** `security/apparmor/karya-speed` profili
- **SELinux:** `security/selinux/karya.te` — SPEED politikası eklendi

### Karya Market — Tema & Eklenti Tarayıcısı
- **Yeni:** `packages/karya-marketplace/` — tam pazaryeri sistemi (PyQt6, 520 satır)
- **4 Sekme:** Temalar, Eklentiler, Pazaryeri, Yüklüler
- **Theme Manager:** Plasma, KWin, ikon, SDDM, Splash temalarını yükle/kaldır/uygula
- **Plugin Manager:** KWin script, efekt, Plasmoid, KRunner eklentilerini yönet
- **Backend:** `karya-theme-manager.py` + `karya-plugin-manager.py` (ZIP çıkarma, yedekleme, .desktop kayıt)
- **Async:** UI donmadan arka planda kurulum iş parçacığı
- **Paket:** `packages/karya-marketplace/PKGBUILD` + `.desktop` + SVG ikon

### Özel Kernel PKGBUILD
- **Yeni:** `packages/linux-karya/PKGBUILD` — Performans config (PREEMPT, HZ=1000, BBR, ZSWAP+ZSTD)
- **Yeni:** `packages/linux-karya-hardened/PKGBUILD` — Hardened config (statik modül, USER_NS=n, BPF kapalı, SLAB hardening)
- Config dosyaları: `kernel/config-6.17-x86_64` (1084 satır) + `kernel/config-6.17-x86_64-hardened` (336 satır)
- `karya-de-meta` bağımlılıklarına eklendi

### Ubuntu/Debian Paketleme
- **Yeni:** 7 dosya — `debian/rules`, `debian/control`, `debian/changelog`, `debian/compat`, `debian/copyright`, `debian/source/format`, `debian/karya-de.postinst`, `debian/karya-de.postrm`
- Kurulum: OOBE, session, layout, branding, SDDM, widget'lar, 5 uygulama, donanım scriptleri
- `install-ubuntu.sh` ile tek komut kurulum

### Güvenlik (Genişletme)
- **Yeni:** `security/apparmor/karya-speed` — SPEED profili
- **Yeni:** `security/apparmor/karya-widgets` — widget koleksiyonu profili
- **Yeni:** `security/apparmor/install.sh` — toplu AppArmor yükleyici
- **Güncelleme:** `security/selinux/karya.te` — SPEED + OOBE + widget + driver domain'leri

### VM & ISO
- **Yeni:** `vm/install-vm.py` — sanal makine kurulum scripti (Python)
- **Yeni:** `vm/run-vm.sh` — QEMU/KVM ile VM başlatma
- **Yeni:** `auto-install-arch.sh` — Arch ISO içinde otomatik kurulum
- **Yeni:** `karya-vm.qcow2` — önceden yapılandırılmış VM imajı
- **Güncelleme:** `iso/releng/packages.x86_64` — SPEED, linux-karya eklendi
- **Güncelleme:** `iso/releng/profiledef.sh` — SPEED script izinleri

### Build & CI
- **Yeni:** `.github/workflows/build.yml` — GitHub Actions CI (tüm PKGBUILD'leri derle + lint)
- **Yeni:** `.gitmodules` — KDE fork'ları (kwin, plasma-workspace) için submodule tanımı
- **Güncelleme:** `scripts/build.sh` — kaynak yoksa hata mesajı, SPEED kurulum, build edilemeyeni atla
- **Güncelleme:** `Makefile` — yeni hedefler

### Düzeltmeler
- **Python:** `packages/karya-marketplace/src/karya-market.py` `\u{...}` → `\U...` unicode escape fix (kalıcı)
- **KWin:** `kwin-effects/karya-glassmorphism/karyaglassmorphism.cpp` — KWin 6.x drawWindow API uyumu
- **Widgets:** `karya-sistem` — canlı monitör verisi düzeltildi
- **Widgets:** `karya-hava` — şehir seçimi canlı veri güncelleme
- **Shell:** `shell/sessions/karya.env` — +KWIN_DRM değişkenleri, SPEED env
- **Shell:** `shell/sessions/startplasma-karya` — SPEED otomatik başlatma
- **Uygulamalar:** `karya-calc` — Decimal tabanlı güvenli aritmetik
- **Uygulamalar:** `karya-notes` — SHA-256 şifre korumalı kilit ekranı

### Dokümantasyon
- **README:** 1.660 satıra genişletildi (+210 satır Karya Sun + Release bölümleri)
- **README:** İstatistikler v1.1.0 verisiyle güncellendi (99 dosya, +7.518 satır)
- **README:** Bütün Uygulamalar — Karya Market (+520 satır), SPEED (10 tuner), Sun (5 modül, ~40K satır)
- **README:** Paket Listesi — +6 yeni paket (marketplace, speed, 2 kernel, 2 plasma)
- **README:** Teknoloji Stack, dağıtım kılavuzu, sosyal medya bağlantıları
- **Yeni:** `CHANGELOG.md` — sürüm geçmişi
- **Yeni:** `SIKÇA_SORULAN_SORULAR.md` — SSS dokümanı
- **Yeni:** `SPONSORLUK.md` — sponsorluk ve bağış bilgileri
- **Yeni:** `SECURITY.md` — güvenlik politikası
- **Yeni:** `branding/screenshots/` — 7 adet ekran görüntüsü (PNG + SVG)
- **Yeni:** `branding/icons/karya-market.svg` — Market ikonu
- **Güncelleme:** `debian/changelog` — v1.1.0

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
