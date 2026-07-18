# Karya DE

Modern, Türk yapımı masaüstü ortamı. KDE Plasma 6 tabanlı, tam fork.

## Özellikler

- **Kwin fork** - Custom tiling, gesture desteği, glassmorphism efekti
- **Üst panel + dock** - Modern, sade arayüz
- **Tam Türkçe** - Arayüz, menüler, mesajlar Türkçe
- **Türk widget'lar** - Hava durumu TR, Namaz Vakti, TR Haber
- **Kurulum sihirbazı** - İlk çalıştırmada kullanıcıyı yönlendir
- **Wayland + X11** - Çift protokol desteği, Wayland önerilen
- **elogind + runit** - systemd'siz çalışabilir

## Mimarisi

```
karya-de/
├── sources/           # Fork'lanmış KDE repo'ları (git submodule)
├── branding/          # Logo, splash, cursor, icon, font
├── widgets/           # Plasma 6 widget'ları (QML/JS)
├── kwin-effects/      # Custom KWin efektleri (C++/QML)
├── shell/             # Panel layout, look-and-feel
├── localization/      # Türkçe çeviri dosyaları
├── packages/          # Arch Linux PKGBUILD'ları
├── iso/               # archiso yapılandırması
└── scripts/           # Derleme araçları
```

## Bağımlılıklar

- Arch Linux (geliştirme)
- Qt 6.5+
- KDE Plasma 6 kaynak kodları
- elogind
- runit (opsiyonel)
- cmake, extra-cmake-modules, gcc, python
