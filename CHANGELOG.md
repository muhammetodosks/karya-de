# Changelog

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
