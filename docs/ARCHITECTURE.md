# Karya DE Mimarisi

## Genel Bakış

Karya DE, KDE Plasma 6'nın tam fork'udur. Aşağıdaki bileşenlerden oluşur:

```
┌─────────────────────────────────────────────────┐
│                  Karya DE                         │
├─────────────────────────────────────────────────┤
│  ┌──────────┐  ┌─────────┐  ┌────────────────┐  │
│  │  KWin     │  │ Plasma  │  │  Widget'lar    │  │
│  │ (Window   │  │ Shell   │  │  Hava / Namaz  │  │
│  │  Manager) │  │ (Panel) │  │  / Haber       │  │
│  ├──────────┤  ├─────────┤  ├────────────────┤  │
│  │ - Tiling  │  │ - Üst   │  │ - QML/JS      │  │
│  │ - Gesture │  │   panel  │  │ - Plasma API   │  │
│  │ - Glass   │  │ - Dock   │  │ - Özel servis │  │
│  │   morph.  │  │ - LNF   │  │                │  │
│  └──────────┘  └─────────┘  └────────────────┘  │
├─────────────────────────────────────────────────┤
│  ┌──────────┐  ┌─────────┐  ┌────────────────┐  │
│  │elogind   │  │ runit   │  │  OOBE          │  │
│  │(Oturum)  │  │(Init)   │  │ (Kurulum       │  │
│  │          │  │         │  │  Sihirbazı)    │  │
│  └──────────┘  └─────────┘  └────────────────┘  │
└─────────────────────────────────────────────────┘
```

## Bileşen Detayları

### 1. KWin (kwin-karya)
- **Kaynak:** KDE Plasma 6 KWin fork
- **Değişiklikler:**
  - `src/tiling/karyatilemanager.*` - Otomatik pencere döşeme
  - Kısayol: Meta+T toggle, Meta+Shift+T layout değiştir
  - `kwin-effects/karya-glassmorphism/` - Özel blur efekti
  - 4 layout: MasterStack, Split, Grid, Monocle

### 2. Plasma Shell (plasma-workspace-karya)
- **Kaynak:** KDE Plasma 6 plasma-workspace fork
- **Değişiklikler:**
  - `shell/layouts/karya-panel-top.layout.lua` - Üst panel
  - `shell/layouts/karya-dock.layout.lua` - Alt dock
  - `shell/look-and-feel/karya-de/` - Tema paketi

### 3. Widget'lar
| Widget | ID | Açıklama |
|--------|-----|----------|
| Karya Hava | org.karya.hava | Türkiye hava durumu |
| Karya Namaz | org.karya.namaz | Diyanet namaz vakitleri |
| Karya Haber | org.karya.haber | TR haber başlıkları |

### 4. OOBE
- `karya-oobe/src/karya-oobe.py` - PyQt6 kurulum sihirbazı
- 7 adımlı: Hoşgeldin → GPU Sürücü → Layout → Bileşenler → Kullanıcı → Özet → Kurulum
- İlk çalıştırmada otomatik başlar

### 5. Init Sistemi
- **runit** varsayılan init
- **elogind** oturum yönetimi için
- Servisler: `/etc/runit/sv/`

## Derleme Sırası

```
1. kwin                (bağımlılık yok)
2. plasma-workspace    (kwin gerekir)
3. plasma-desktop      (workspace gerekir)
4. plasma-pa           (workspace gerekir)
5. systemsettings      (desktop gerekir)
6. breeze-icons        (tema)
7. kdeplasma-addons    (eklentiler)
```

## ISO Yapısı

Arch Linux tabanlı, archiso ile oluşturulur.
- Kernel: Stock Arch Linux
- Init: runit + elogind
- Display: X11 + Wayland
- Varsayılan: Wayland oturumu
