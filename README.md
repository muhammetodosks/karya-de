<picture>
  <source media="(prefers-color-scheme: dark)" srcset="branding/logo/karya-logo.svg">
  <img alt="Karya DE" src="branding/logo/karya-logo.svg" width="100" align="right">
</picture>

# Karya DE

![License](https://img.shields.io/badge/lisans-GPLv2-blue)
![Qt](https://img.shields.io/badge/Qt-6-green)
![Arch](https://img.shields.io/badge/Arch-x86__64-1793D1)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04+-E95420)
![NVIDIA](https://img.shields.io/badge/NVIDIA-destekleniyor-76B900)
![AMD](https://img.shields.io/badge/AMD-destekleniyor-ED1C24)
![Intel](https://img.shields.io/badge/Intel-desteklenmiyor-555555)
![Durum](https://img.shields.io/badge/durum-v1.0.0--stable-brightgreen)
![TR](https://img.shields.io/badge/dil-T%C3%BCrk%C3%A7e-red)

**Karya DE** - Modern, sıfırdan inşa edilmiş Türk masaüstü ortamı.
Qt6 ve KDE teknolojileri üzerine inşa edilmiştir ancak **KDE Plasma değildir**. Karya DE, kendi pencere yöneticisi (kwin-karya), kendi panel sistemi, kendi widget koleksiyonu ve kendi tema altyapısıyla bağımsız bir masaüstü ortamıdır.

---

## Tek Komutla Kurulum

```bash
# Arch Linux
sudo pacman -Syu
curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install.sh | sudo bash
sudo reboot
```

```bash
# Ubuntu 24.04+
sudo apt update
curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install-ubuntu.sh | sudo bash
sudo reboot
```

Ya da kaynaktan derlemek için:

```bash
git clone https://github.com/muhammetodosks/karya-de.git
cd karya-de
make setup
make build
make install
```

### Systemd'siz Kurulum (Artix / runit)

```bash
curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install-nosystemd.sh | sudo bash
sudo reboot
```

Bu script:
- **runit** + **elogind** kurar (systemd gerekmez)
- elogind, NetworkManager, PipeWire için runit servislerini oluşturur
- KWin'i kaynaktan derler
- Tüm Karya uygulamalarını kurar
- SDDM temasını aktif eder
- Artix Linux, ArcoLinux ve diğer systemd'siz Arch tabanlı dağıtımlarda çalışır

---

## Özellik Karşılaştırması

| Özellik | Karya DE | KDE Plasma 6 | GNOME 47 | XFCE 4.18 |
|---------|----------|--------------|----------|-----------|
| **Mimari** | Bağımsız (KWin fork) | KDE | GNOME | XFCE |
| **RAM (boşta)** | ~450 MB | ~600 MB | ~750 MB | ~400 MB |
| **GPU** | NVIDIA/AMD optimize | Tümü | Tümü | Tümü |
| **%100 Türkçe** | Sıfır gün | %90 | %85 | %70 |
| **Auto Tiling** | 4 layout dahili | Eklenti | Eklenti | Yok |
| **Glassmorphism** | C++ + JS efekt | Yok | Yok | Yok |
| **Wayland** | Varsayılan | Varsayılan | Varsayılan | Deneysel |
| **NVIDIA Wayland** | Tam EGLStreams | Sınırlı | Sınırlı | Yok |
| **Init** | elogind+runit | systemd | systemd | systemd |
| **Widget** | 4 Türkçe widget + 4 uygulama | Binlerce | Uzantılar | Panel eklenti |
| **OOBE** | Donanım bilinçli **(Güncellendi)** | Yok | İlk çalıştırma | Yok |
| **Karya Apps** | Hesap Makinesi, Notlar, Arama, Ayarlar **(Yeni)** | Yok | Yok | Yok |

Karya DE, özellikle **NVIDIA/AMD GPU kullanıcıları** ve **Türkçe masaüstü** arayanlar için tasarlanmıştır.

---

## İstatistikler

### 1. Sürüm Karşılaştırması — Gerçek Değişim (v0.2.0 → v1.0.0)

| Metrik | v0.2.0 | v1.0.0 | Değişim |
|--------|--------|--------|---------|
| **Toplam dosya** | 104 | 127 | ████████████████████░░░░░ +23 dosya (%22) |
| **Toplam kod satırı** | ~7.375 | ~9.754 | ████████████████████████████████░░ +2.565 satır (%35) |
| **Python dosyası** | 7 | 12 | ████████████████████████████░░░░░░ +5 dosya (%71) |
| **Shell betiği** | 10 | 12 | ████████████████████████████████░░ +2 dosya (%20) |
| **PKGBUILD** | 8 | 12 | ████████████████████████████████████ +4 paket (%50) |
| **Desktop dosyası** | 7 | 11 | ████████████████████████████████░░░░ +4 dosya (%57) |
| **Python uygulaması** | 1 (OOBE) | 5 (OOBE+4 apps) | ████████████████████████████████████ +4 uygulama (%400) |
| **OOBE sayfası** | 7 | 14 | ████████████████████████████████████ +7 sayfa (%100) |
| **Kurulum platformu** | Arch | Arch + Ubuntu | ████████████████████████████████████ +Ubuntu (%100) |
| **Widget** | 4 | 4 | ████████████████████████████████████ Aynı |
| **RAM kullanımı** | ~500 MB | ~450 MB | ████████████████████████████████████ %10 iyileşme |

### 2. Bu Sürümde Eklenenler (v1.0.0)

```
Yeni dosya          ████████████████████████████████████████  23 yeni dosya
Eklenen satır       ████████████████████████████████████████  +2.565 satır
Silinen satır       ████████████████████████████████████████  −86 satır
Değiştirilen dosya  ████████████████████████████████████████  17 dosya
Python uygulama     ████████████████████████████████████████  4 yeni (calc/notes/search/settings)
OOBE genişletme     ████████████████████████████████████████  7→14 sayfa (%100)
Ubuntu kurulum      ████████████████████████████████████████  debian/ + install-ubuntu.sh
Hata düzeltme       ████████████████████████████████████████  14+ bug fix
```

### 3. Masaüstü Ortamı Karşılaştırması

```
RAM Kullanımı (boşta, MB — düşük iyidir)
Karya DE    █████████████████████░░░░░░░░░░░░░░░░░░   ~450 MB
KDE Plasma  ██████████████████████████████░░░░░░░░░   ~600 MB
GNOME       ██████████████████████████████████████░░   ~750 MB
XFCE        ██████████████████████████████████████░░   ~400 MB

Türkçe Destek (%)
Karya DE    ████████████████████████████████████████   %100 (sıfır gün)
KDE Plasma  ██████████████████████████████████░░░░░░   %90
GNOME       █████████████████████████████████████░░░   %85
XFCE        ██████████████████████████████████░░░░░░   %70

NVIDIA Wayland Desteği
Karya DE    ████████████████████████████████████████   Tam (EGLStreams)
KDE Plasma  ██████████████████████████████████░░░░░░   Sınırlı
GNOME       ██████████████████████████████████░░░░░░   Sınırlı
XFCE        ████████████████████████████████████░░░░   Yok

Python Uygulama Sayısı
Karya DE    ████████████████████████████████████████   5 (OOBE + 4 app)
KDE Plasma  ████████████████████████████████████░░░░   3 (terminal, ayarlar, dosya)
GNOME       ██████████████████████████████████████░░   4 (terminal, ayarlar, dosya, yazılım)
XFCE        ████████████████████████████████████░░░░   3 (terminal, ayarlar, dosya)
```

---

## İçindekiler

- [İstatistikler](#istatistikler)
- [Özet](#özet)
- [Özellikler](#özellikler)
- [Donanım Desteği](#donanım-desteği)
- [Intel Neden Desteklenmiyor](#intel-neden-desteklenmiyor)
- [Kernel Yapılandırması](#kernel-yapılandırması)
- [Güvenlik](#güvenlik)
- [Systemd'siz Kurulum](#systemdsiz-kurulum)
- [Diğer Masaüstü Ortamlarıyla Karşılaştırma](#diğer-masaüstü-ortamlarıyla-karşılaştırma)
- [Kurulum Adımları](#kurulum-adımları)
- [PKGBUILD ile Kurulum](#pkgbuild-ile-kurulum)
- [Kaynak Koddan Derleme](#kaynak-koddan-derleme)
- [Widget Koleksiyonu](#widget-koleksiyonu)
- [Bütün Uygulamalarımız](#bütün-uygulamalarımız)
- [OOBE Kurulum Sihirbazı](#oobe-kurulum-sihirbazı)
- [SDDM Giriş Ekranı](#sddm-giriş-ekranı)
- [KWin Pencere Yöneticisi](#kwin-pencere-yöneticisi)
- [Panel ve Dock Sistemi](#panel-ve-dock-sistemi)
- [Kısayollar](#kısayollar)
- [Sürücü Yönetimi](#sürücü-yönetimi)
- [Performans Profilleme](#performans-profilleme)
- [Mimari Yapı](#mimari-yapı)
- [Paket Listesi](#paket-listesi)
- [Katkıda Bulunma](#katkıda-bulunma)
- [Sıkça Sorulan Sorular](#sıkça-sorulan-sorular-sss)
- [Lisans](#lisans)

---

## Özet

Karya DE, başlangıçtan itibaren Türk kullanıcılar için tasarlanmış bir masaüstü ortamıdır. Modern bir görünüm, yüksek performans, donanım bilinçli yapılandırma ve tam Türkçe desteği sunar.

**Karya DE'yi farklı kılan özellikler:**

- **Bağımsız kod tabanı** - Kendi pencere yöneticisi, panel, widget sistemi
- **Donanım bilinçli** - GPU'nııza göre otomatik sürücü ve performans ayarı
- **Türkçe odaklı** - Tüm arayüz, mesajlar, tarih/saat formatları Türkçe
- **Performans odaklı** - RAM ve GPU'nııza göre otomatik profil seçimi
- **systemd'siz çalışabilir** - elogind + runit desteği
- **Kullanıcı dostu** - İlk çalıştırmada OOBE sihirbazı ile kolay kurulum

---

## Özellikler

### Pencere Yönetimi (KWin Fork)
| Özellik | Detay |
|---------|-------|
| Auto Tiling | 4 layout: Master-Stack, Split, Grid, Monocle |
| Glassmorphism | C++ ve JS olmak üzere iki ayrı cam efekti |
| Jest Destegi | Trackpad ve dokunmatik ekran için 3/4 parmak hareketleri |
| NVIDIA Uyumluluk | EGLStreams, NO_AMS, ForceCompositionPipeline ayarları |
| Performans Profili | Düşük/orta/yüksek olmak üzere 3 profil |

### Panel ve Dock
- **Üst panel** - Kickoff (uygulama menüsü), görev yöneticisi, sistem tepsisi, saat
- **Alt dock** - Otomatik gizlenen, ortalanmış uygulama dock'u
- **4 hazır layout** - Modern, Classic, macOS Style, Minimal
- **Donanıma duyarlı** - RAM ve GPU'ya göre önerilen layout

### Widget Koleksiyonu
| Widget | ID | Özellikler |
|--------|-----|------------|
| Karya Hava | org.karya.hava | 16 şehir, 7 günlük tahmin, saatlik grafik, nem/rüzgar |
| Karya Namaz | org.karya.namaz | 6 vakit, Diyanet bazlı, kalan süre, aktif vakit vurgusu |
| Karya Haber | org.karya.haber | Kategori filtreli, 10 kaynak, renk kodlu kategoriler |
| Karya Sistem | org.karya.sistem | CPU/RAM/Disk/Network anlık monitör |

### OOBE Kurulum Sihirbazı **(Güncellendi)**
- PyQt6 ile yazılmış, **14 sayfalık** kapsamlı kurulum asistanı
- Donanım algılama ile başlar (GPU, ses, ağ, laptop/VM)
- Sürücü seçimi, layout seçimi, bileşen ayarları
- **Tema seçimi** (koyu/açık/mavi + vurgu rengi + efektler)
- **Varsayılan uygulama seçimi** (tarayıcı, terminal, dosya yöneticisi, editör, müzik)
- **Geliştirme araçları** (Git, Python, Node.js, Docker, VS Code, GCC, JDK)
- **Oyun araçları** (Steam, Lutris, GameMode, Proton, Wine)
- **Gizlilik ayarları** (konum, çökme raporu, telemetri, hostname)
- **Ekran ayarları** (çözünürlük, ölçekleme, yenileme hızı, DPI, çoklu ekran)
- **Güç yönetimi** (profil, ekran kapanma, uyku, pil tasarrufu)
- Kullanıcı oluşturma ve otomatik giriş ayarı
- Adım adım ilerleme çubuğu ve canlı log

### SDDM Giriş Ekranı
- Özel Karya temalı glassmorphism login kartı
- Wayland/X11 oturum seçimi
- Türkçe arayüz
- Kapatma/Yeniden başlat butonları

### Güvenlik
- **Sysctl Sertleştirme** - ASLR, kptr_restrict, dmesg_restrict ağ korumaları
- **AppArmor Profilleri** - OOBE, script, sürücü profilleri
- **Boot Parametreleri** - Meltdown/Spectre/MDS/TAA mitigasyonları

### Sistem
| Özellik | Değer |
|---------|-------|
| Display Server | Wayland (varsayılan), X11 (opsiyonel) |
| Init Sistemi | elogind + runit (systemd'siz) |
| Compositor | GPU'ya göre otomatik: OpenGL/EGLStreams/XRender |
| Ses Sistemi | PipeWire + WirePlumber |
| Varsayılan FS | F2FS veya XFS |
| Oturum Yöneticisi | SDDM (Karya temalı) |

---

## Donanım Desteği

| GPU | Durum | Sürücü | Performans |
|-----|-------|--------|------------|
| **NVIDIA** (GTX 700+) | Tam destek | nvidia (proprietary) | Çok iyi |
| **NVIDIA** (GTX 600- / eski) | Sınırlı | nouveau | Orta |
| **AMD** (GCN 2+) | Tam destek | amdgpu (açık kaynak) | Çok iyi |
| **AMD** (GCN 1 / eski) | Sınırlı | radeon | Orta |
| **Intel** | Resmi destek yok (deneysel) | modesetting/i915 | Düşük |
| **Sanal Makine** | Tam destek | vmware/virtio | Orta |

### NVIDIA Yapılandırması

```ini
# Xorg
Option "TripleBuffer" "true"
Option "ForceCompositionPipeline" "false"
Option "PowerMizerEnable" "true"

# Wayland (KWin)
KWIN_DRM_USE_EGL_STREAMS=true
KWIN_DRM_NO_AMS=true
GBM_BACKEND=nvidia-drm
```

### AMD Yapılandırması

```ini
# Xorg
Option "TearFree" "true"
Option "VariableRefresh" "true"
Option "DRI" "3"

# Kernel
options amdgpu si_support=1
options amdgpu dc_support=1

# Vulkan
RADV_PERFTEST=aco
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
```

---

## Intel Neden Desteklenmiyor

Intel entegre GPU'ları resmi olarak **desteklenmemektedir**. Bunun nedenleri:

1. **Performans Yetersizliği:** Karya DE'nin glassmorphism, blur, animasyon gibi modern efektleri Intel HD Graphics serisinde (özellikle 10. nesil öncesi) akıcı çalışmamaktadır. Kullanıcı deneyimi tatmin edici değildir.

2. **Sürücü Sınırlamaları:** Intel'in açık kaynak sürücüsü (i915), kernel seviyesinde kısıtlamalar içerir. GuC yüklemesi, PSR, FBC gibi özellikler varsayılan olarak kapalıdır ve bu ayarları açmak dahi performans sorunlarını tam olarak çözmemektedir.

3. **Vulkan Desteği Eksikliği:** Karya DE'nin compositor altyapısı, özellikle NVIDIA ve AMD'de bulunan tam Vulkan desteğine güvenmektedir. Intel'in Vulkan desteği (ANV) özellikle 12. nesil öncesinde sınırlı ve kararsızdır.

4. **Kaynak Kullanım Optimizasyonu:** Geliştirme kaynaklarımız sınırlıdır. NVIDIA ve AMD'ye odaklanarak her iki platformda da en iyi deneyimi sunmayı hedefliyoruz. Intel desteği eklemek, test ve optimizasyon sürecini iki katına çıkaracaktır.

**Intel kullanıcılar için öneriler:**
- Harici bir NVIDIA veya AMD GPU edinin
- Intel sadece ikinci bir GPU olarak kullanılabilir (Optimus benzeri)
- Intel HD Graphics ile kısıtlı da olsa XRender modunda çalışabilir (performans garantisi yok)

---

## Kernel Yapılandırması

Karya DE, kendi performans ve güvenlik odaklı **özel Linux kernel** yapılandırmalarıyla gelir.
Stok Arch Linux kernel'inden farklı olarak **masaüstü kullanımı** ve **güvenlik** için optimize edilmiştir.

### Neden Özel Kernel?

| Stok Arch (linux) | Karya DE Kernel |
|------------------|-----------------|
| CONFIG_PREEMPT (server) | **PREEMPT** (masaüstü, düşük gecikme) |
| HZ=300 | **HZ=1000** (akıcı animasyon, düşük input lag) |
| CUBIC TCP (varsayılan) | **BBR TCP** (yüksek hızlı, düşük gecikme) |
| Zswap opsiyonel | **ZSTD + zswap** (bellek sıkıştırma) |
| Modüller açık | **Staçik veya kontrollü modül** |
| Tüm GPU'lar eşit | **NVIDIA/AMD optimize**, Intel uyarılı |
| KASLR var | **KASLR + modül rastgeleleştirme** |
| Standart mitigasyon | **Tüm mitigasyonlar zorunlu** |

### Karya DE Config 1: `config-6.17-x86_64` (Performans)

**Hedef:** Günlük masaüstü kullanımı — maksimum akıcılık, düşük gecikme, tam donanım desteği.

```
Dosya: kernel/config-6.17-x86_64
Amaç:  Performans masaüstü
Tür:   Modüler (ihtiyaca göre yüklenebilir)
```

| Alan | Değer | Açıklama |
|------|-------|----------|
| **Zamanlayıcı** | `PREEMPT` | Düşük gecikmeli masaüstü zamanlayıcı. Stok Arch (CONFIG_PREEMPT_VOLUNTARY) yerine interaktif uygulamalar için optimize edilmiştir. |
| **Hz** | `HZ=1000` | Saniyede 1000 kesme. Fare hareketleri, animasyonlar, oyunlar için gerekli. Stok Arch HZ=300 ile karşılaştırıldığında 3.3x daha sık güncelleme. |
| **TCP** | `BBR` | Google's congestion control. Düşük gecikme, yüksek throughput. Özellikle Türkiye'deki yavaş/kararsız bağlantılarda CUBIC'e göre ~3x daha iyi performans. |
| **Bellek** | `ZSWAP+ZSTD` | RAM baskı altındayken sayfaları ZSTD ile sıkıştırır. Swap'e gitmeden önce bellek kazandırır. |
| **GPU/NVIDIA** | `nvidia-drm fbdev=1` | NVIDIA DRM + framebuffer. ForceCompositionPipeline ile yırtılmasız render. |
| **GPU/AMD** | `amdgpu SI/CIK` | GCN 1. nesil (Southern Islands) ve 2. nesil (Sea Islands) desteği. |
| **GPU/Intel** | `i915` | Açık ama `CONFIG_DRM_I915` **kapalı**. Kullanıcı kendi sorumluluğunda açar. |
| **Güvenlik** | `PTI+IBRS+SRSO+Retpoline` | Tüm CPU mitigasyonları açık. |
| **Sanal** | `KVM+VirtualBox+VMware` | Tam sanallaştırma desteği. |

Bu config, günlük masaüstü kullanımı için **önerilen** config'dir. NVIDIA/AMD kullanıcıları için optimize edilmiştir.

### Karya DE Config 2: `config-6.17-x86_64-hardened` (Güvenlik/Sızma)

**Hedef:** Maksimum güvenlik, minimum saldırı yüzeyi. Sunucu, güvenlik araştırması, sızma testi ve yüksek güvenlik gerektiren ortamlar için.

```
Dosya: kernel/config-6.17-x86_64-hardened
Amaç:  Güvenlik sertleştirilmiş
Tür:   Statik (modül YOK)
```

| Alan | Performans Config | Hardened Config | Neden? |
|------|------------------|-----------------|--------|
| **Modüller** | `CONFIG_MODULES=y` | **`CONFIG_MODULES=n`** | Çekirdek modülleri saldırı yüzeyini artırır. Statik kernel'de modül yükleme saldırısı imkansız. |
| **KULLANICI_NS** | `sınırlı` | **`USER_NS_UNPRIVILEGED=n`** | Yetkisiz kullanıcı namespace saldırılarını engeller (CVE-2022-0492, CVE-2023-0386). |
| **Cross Memory** | `CROSS_MEMORY_ATTACH=y` | **`CROSS_MEMORY_ATTACH=n`** | `process_vm_readv/writev` saldırı vektörünü kapatır. |
| **BPF** | ayrıcalıklı | **`BPF_UNPRIV_DEFAULT_OFF=y`** | Yetkisiz BPF program yüklemeyi engeller. |
| **IMA** | Kapalı | **`IMA_AUDIT=y`** | Integrity Measurement Architecture ile dosya bütünlüğü denetimi. |
| **HARDENED_USERCOPY** | Kapalı | **`HARDENED_USERCOPY=y`** | Kullanıcı/kernel bellek kopyalamalarında sıkı denetim. |
| **SLAB_FREELIST_HARDENED** | Kapalı | **`HARDENED=y`** | Heap exploitation'u zorlaştırır. |
| **PAGE_TABLE_CHECK** | Kapalı | **`ENFORCED=y`** | Sayfa tablosu müdahalelerini tespit eder. |
| **LOCKDOWN** | Kapalı | **`LSM_EARLY=y`** | Kernel erken başlangıçta kilitlenir, modül/efi değişikliği engellenir. |
| **IOMMU** | isteğe bağlı | **`DEFAULT_ON=y`** | DMA saldırılarına karşı zorunlu koruma. |
| **KALLSYMS** | Açık | **`KALLSYMS=n`** | Kernel sembolleri gizlenir, exploit geliştirme zorlaşır. |
| **PROC_KCORE** | Açık | **`PROC_KCORE=n`** | `/proc/kcore` gizlenir, bellek dökümü saldırıları engellenir. |
| **DEBUG_FS** | Açık | **`DEBUG_FS=n`** | DebugFS kapatılır (CVE-2023-3269). |
| **CORE_DUMP** | Açık | **`COREDUMP=n`** | Core dump kapatılır, hassas veri sızıntısı engellenir. |
| **USERMODEHELPER** | normal | **`STATIC_PATH`** | Statik usermode-helper yolu, PATH hijacking engellenir. |

### Kernel Derleme

```bash
# 1. Linux 6.17 kaynağını indir
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.tar.xz
tar xf linux-6.17.tar.xz
cd linux-6.17

# 2. Karya DE config'ini uygula (Performans - önerilen)
cp /path/to/kernel/config-6.17-x86_64 .config

# Veya güvenlik config'ini uygula
cp /path/to/kernel/config-6.17-x86_64-hardened .config

# 3. Derle
make olddefconfig    # Eksik ayarları default yap
make -j$(nproc)      # Derle (tüm çekirdekler)
make modules_install # Modülleri kur (sadece performans config)
make install         # Kernel ve initramfs'i kur

# 4. Bootloader'a ekle (GRUB)
# /etc/default/grub:
# GRUB_CMDLINE_LINUX_DEFAULT="mitigations=auto ...."
sudo update-grub

# 5. Yeniden başlat
sudo reboot
```

### Kernel Boot Parametreleri

Karya DE, özel kernel ile birlikte aşağıdaki boot parametrelerini kullanır:

```
# /etc/default/grub - Karya DE önerilen boot parametreleri
GRUB_CMDLINE_LINUX_DEFAULT="
  mitigations=auto                          # Tüm CPU mitigasyonları
  lsm=landlock,lockdown,yama,integrity,apparmor,bpf  # LSM sıralaması
  init_on_alloc=1                           # Bellek tahsisinde sıfırla
  init_on_free=1                            # Bellek serbest bırakırken sıfırla
  page_alloc.shuffle=1                      # Sayfa tahsisini rastgeleleştir
  slab_nomerge                              # SLAB nesnelerini birleştirme
  module.sig_enforce=1                      # Modül imzası zorunlu
  lockdown=confidentiality                  # Kernel kilidi (gizlilik)
  iommu.passthrough=0                       # IOMMU zorunlu
"
```

### Kernel Karşılaştırması

| Özellik | Arch linux stock | Karya Perf | Karya Hardened |
|---------|-----------------|------------|----------------|
| PREEMPT | Voluntary | **Full** | **Full** |
| HZ | 300 | **1000** | **1000** |
| TCP | CUBIC | **BBR** | **BBR** |
| Zswap | Varsayılan kapalı | **ZSTD açık** | **ZSTD açık** |
| Modüller | Modüler | **Modüler** | **Statik (kapalı)** |
| KASLR | Evet | Evet | Evet |
| SLAB hardening | Hayır | Hayır | **Evet** |
| IMA | Hayır | Hayır | **Evet** |
| Lockdown | Hayır | Hayır | **Evet** |
| USER_NS | Sınırsız | Sınırsız | **Sadece root** |
| BPF yetkisiz | Evet | Evet | **Hayır** |
| AMD/NVIDIA | Varsayılan | **Optimize** | **Optimize** |
| Intel i915 | Varsayılan | **Kapalı** | **Kapalı** |
| KALLSYMS | Evet | Evet | **Hayır** |
| PROC_KCORE | Evet | Evet | **Hayır** |
| DEBUG_FS | Evet | Evet | **Hayır** |

---

## Güvenlik

Karya DE, aşağıdaki güvenlik önlemleri ile gelir:

| Güvenlik Katmanı | Açıklama |
|-----------------|----------|
| AppArmor | OOBE, script ve sürücü profilleri |
| Sysctl | ASLR, ağ korumaları, core dump kısıtlaması |
| Kernel | PTI, Retpoline, IBRS, SRSO mitigasyonları |
| IOMMU | Zorunlu IOMMU ile DMA koruması |

Kurulum:
```bash
# AppArmor profilleri
sudo cp security/apparmor/* /etc/apparmor.d/
sudo apparmor_parser -a /etc/apparmor.d/karya-oobe
sudo apparmor_parser -a /etc/apparmor.d/karya-scripts
sudo apparmor_parser -a /etc/apparmor.d/karya-drivers

# Sysctl hardening
sudo cp security/sysctl/99-karya-security.conf /etc/sysctl.d/
sudo sysctl -p /etc/sysctl.d/99-karya-security.conf

# Kernel (opsiyonel, kaynaktan derleme gerektirir)
cp kernel/config-6.17-x86_64 /usr/src/linux/.config
```

---

## Systemd'siz Kurulum

Karya DE, **systemd gerektirmez**. `elogind` + `runit` ile çalışır.
Bu, systemd'siz dağıtımlar (Artix Linux, ArcoLinux, vb.) için idealdir.

### Tek Komut

```bash
curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install-nosystemd.sh | sudo bash
```

### Script Ne Yapar?

| Adım | İşlem |
|------|-------|
| 1 | Sistem güncellemesi (`pacman -Syu`) |
| 2 | **runit** + **elogind** kurulumu, servis dosyalarının oluşturulması |
| 3 | Qt6, KF6, Python bağımlılıklarının kurulumu |
| 4 | **KWin** pencere yöneticisinin kaynaktan derlenmesi |
| 5 | Karya uygulamalarının (OOBE, hesap makinesi, notlar, arama, ayarlar) kurulumu |
| 6 | Donanım algılama |
| 7 | SDDM teması ve oturum dosyalarının yapılandırılması |

### runit Servisleri

Kurulum sonrası aktif runit servisleri:

| Servis | Çalıştırılan | İşlev |
|--------|-------------|-------|
| `elogind` | `/usr/lib/elogind/elogind` | Oturum yönetimi (systemd-logind yerine) |
| `NetworkManager` | `/usr/bin/NetworkManager --no-daemon` | Ağ yönetimi |
| `pipewire` | `/usr/bin/pipewire` | Ses ve video |
| `pipewire-pulse` | `/usr/bin/pipewire-pulse` | PulseAudio uyumluluk |
| `karya-sentinel` | `/usr/bin/karya-oobe` | İlk çalıştırmada OOBE'yi başlatır |

### Servisleri Elle Başlatma

```bash
# runit servislerini baslat
sudo runsvdir /etc/runit/runsvdir/default &

# servis durumu
sudo sv status /etc/runit/sv/*

# servis yeniden baslat
sudo sv restart elogind
```

### Detaylı Init Kurulumu
Daha fazla bilgi: `docs/runit-setup.md`

## Diğer Masaüstü Ortamlarıyla Karşılaştırma

| Özellik | Karya DE | KDE Plasma 6 | GNOME 47 | XFCE 4.18 |
|---------|----------|--------------|----------|-----------|
| **Kod tabanı** | Bağımsız (KWin fork) | KDE | GNOME | XFCE |
| **RAM (boşta)** | ~450 MB | ~600 MB | ~750 MB | ~400 MB |
| **GPU desteği** | NVIDIA/AMD optimize | Tümü | Tümü | Tümü |
| **Intel desteği** | Resmi yok (deneysel) | Tam | Tam | Tam |
| **Türkçe destek** | %100 (sıfır gün) | %90 | %85 | %70 |
| **Auto tiling** | Dahili (4 layout) | Eklenti gerekli | Eklenti gerekli | Yok |
| **Glassmorphism** | Dahili (C++ + JS) | Yok | Yok | Yok |
| **OOBE sihirbazı** | Donanım bilinçli | Yok | İlk çalıştırma | Yok |
| **Init sistemi** | elogind + runit | systemd | systemd | systemd |
| **Wayland** | Varsayılan | Varsayılan | Varsayılan | Deneysel |
| **NVIDIA Wayland** | Tam (EGLStreams) | Sınırlı | Sınırlı | Yok |
| **Widget sistemi** | 4 Türkçe widget + 4 uygulama | Binlerce eklenti | Uzantılar | Panel eklentileri |
| **Yapılandırma** | OOBE + otomatik | Sistem ayarları | GNOME Ayarlar | Panel ayarları |
| **Kurulum** | Arch PKGBUILD + Ubuntu PPA + ISO | Distro paketleri | Distro paketleri | Distro paketleri |
| **Hedef kitle** | Türk kullanıcılar, NVIDIA/AMD | Genel kullanım | Genel kullanım | Eski donanım |

**Karya DE'nin avantajları:**
- NVIDIA ve AMD için otomatik GPU yapılandırması
- Donanım bilinçli OOBE kurulum asistanı
- Türkçeye tam uyum (tarih, saat, klavye, dil)
- systemd gerektirmez (runit + elogind)
- Dahili auto tiling ve glassmorphism efektleri

**Karya DE'nin sınırlamaları:**
- Intel GPU resmi desteği yok
- Geniş eklenti ekosistemi yok (henüz)
- Yalnızca NVIDIA GTX 700+ ve AMD GCN 2+ optimize edilmiş

---

## Kurulum Adımları

### Gereksinimler
| Bileşen | Minimum | Önerilen |
|---------|---------|----------|
| RAM | 2 GB | 8+ GB |
| Disk | 10 GB | 32+ GB |
| GPU | NVIDIA GTX 700+ / AMD RX 400+ | NVIDIA RTX 2000+ / AMD RX 6000+ |
| CPU | 2 çekirdek | 4+ çekirdek |
| OS | Arch Linux / Ubuntu 24.04+ | Arch Linux / Ubuntu 24.04+ |

### 1. Depoyu Klonla

```bash
git clone https://github.com/muhammetodosks/karya-de.git
cd karya-de
```

### 2. Bağımlılıkları Kur

```bash
make setup
```

Bu komut, şu paketleri otomatik kurar:
- **Qt6:** qt6-base, qt6-declarative, qt6-wayland, qt6-tools
- **KDE Frameworks 6:** kconfig, kcoreaddons, ki18n, kio, kservice, kwindowsystem, kwayland
- **Sistem:** elogind, runit, cmake, extra-cmake-modules, wayland-protocols
- **Araç:** python-pip, jq, pciutils, git

Ardından Plasma 6 kaynak kodları `sources/` dizinine klonlanır.

### 3. Build Et

```bash
make build
```

Derleme sırası (dependency order):
```
1. kwin-karya         (bağımlılık yok)
2. plasma-workspace   (kwin gerekir)
3. plasma-desktop     (workspace gerekir)
4. plasma-pa          (workspace gerekir)
5. systemsettings     (desktop gerekir)
6. breeze             (tema)
7. kdeplasma-addons   (eklentiler)
```

### 4. Sisteme Kur

```bash
make install
```

### 5. ISO Oluştur

```bash
make iso
```

ISO çıktısı: `iso/releng/out/karya-de-1.0.0-x86_64.iso`

---

## PKGBUILD ile Kurulum

Her bileşen ayrı ayrı paketlenebilir:

```bash
# 1. Sürücü desteği
cd packages/karya-drivers
makepkg -si

# 2. Özel ikon teması
cd ../karya-icons
makepkg -si

# 3. Widget koleksiyonu (4 widget)
cd ../karya-widgets
makepkg -si

# 4. Kurulum sihirbazı
cd ../karya-oobe
makepkg -si

# 5. Karya uygulamaları
cd ../karya-calc
makepkg -si

cd ../karya-notes
makepkg -si

cd ../karya-search
makepkg -si

cd ../karya-settings
makepkg -si

# 6. Ana Karya DE paketi (hepsini kurar)
cd ../karya-de-meta
makepkg -si
```

---

## Kaynak Koddan Derleme

### Geliştirme Ortamı

```bash
# 1. Repoyu klonla
git clone https://github.com/muhammetodosks/karya-de.git
cd karya-de

# 2. Bağımlılıkları kur + kaynakları indir
make setup

# 3. Derle
make build

# 4. Kur
make install

# 5. Ayarları uygula
sudo bash /usr/lib/karya/scripts/detect-hardware.sh
```

### Manuel Derleme

```bash
cd sources/kwin
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel $(nproc)
sudo cmake --install build
```

---

## Widget Koleksiyonu

Karya DE ile gelen **4 özel widget** ve **4 yerel uygulama**:

### Karya Hava
- 16 Türk şehri için anlık hava durumu
- 7 günlük haftalık tahmin
- Saatlik sıcaklık grafiği (6 saat)
- Nem ve rüzgar bilgisi
- SVG hava durumu ikonları

```qml
// Widget ID
Plasmoid.icon: "karya-hava"
Plasmoid.title: "Karya Hava"
```

### Karya Namaz
- 8 Türk şehri için namaz vakitleri
- 6 vakit (İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı)
- Aktif vakit vurgusu (sar7 renkli)
- Bir sonraki vakite kalan süre
- Tarih gösterimi

### Karya Haber
- 10 haber başlığı, 8 kategori
- Kategori filtreleme (Gündem, Ekonomi, Hava, Teknoloji, Spor, Eğitim, Bilim, Turizm)
- Renk kodlu kategori göstergeleri
- Kaynak ve saat bilgisi
- Habere tıklayınca tarayıcıda açma

### Karya Sistem
- CPU kullanımı (%) - canlı bar
- RAM kullanımı (kullanılan/toplam GB)
- Disk kullanımı (kullanılan/toplam GB)
- Network hızı (In/Out MB/s)

Tüm widgetlar **SVG ikon** kullanır, **hiçbir yerde emoji yoktur.**

---

## Bütün Uygulamalarımız

Karya DE, toplam **5 Python/PyQt6 uygulaması** ve **4 Plasma widget'ı** ile gelir.

### Python Uygulamaları (PyQt6)

| # | Uygulama | Dosya | Satır | İşlev |
|---|----------|-------|-------|-------|
| 1 | **Karya OOBE** | `karya-oobe/src/karya-oobe.py` | 1.494 | 14 sayfalık kurulum sihirbazı |
| 2 | **Karya Hesap Makinesi** | `karya-calc/src/karya-calc.py` | 153 | 4 işlem + bilimsel mod |
| 3 | **Karya Notlar** | `karya-notes/src/karya-notes.py` | 200 | Zengin metin not defteri |
| 4 | **Karya Arama** | `karya-search/src/karya-search.py` | 180 | Masaüstü arama motoru |
| 5 | **Karya Ayarlar** | `karya-settings/src/karya-settings.py` | 313 | Görünüm/donanım/sürücü/dil/güç |
| | **Toplam** | | **2.340** | |

#### Karya Hesap Makinesi
- 4 temel işlem (toplama, çıkarma, çarpma, bölme)
- Bilimsel mod (trigonometri, logaritma, üs, karekök)
- Hafıza (M+/M-/MR/MC)
- Klavye desteği (Enter, Escape, Backspace)
- Karya DE temasına otomatik uyum

#### Karya Notlar
- Zengin metin düzenleme (kalın, italik, altı çizili, renk)
- Kategoriler (Kişisel, İş, Okul, Fikir, Yapılacaklar)
- Not arama ve filtreleme
- Otomatik kaydetme (300ms debounce)
- Karakter sayısı göstergesi

#### Karya Arama
- Dosya, klasör ve uygulama arama
- İçerik indeksleme (PDF, TXT, belgeler)
- Anlık sonuç (her tuşta filtreleme)
- Kategori filtreleri (Dosya / Uygulama / Klasör / Belge)
- Enter ile direkt açma

#### Karya Ayarlar
- **Görünüm:** Tema, vurgu rengi, efekt seviyesi, yazı tipi
- **Donanım:** GPU, RAM, CPU, ses, ağ bilgisi görüntüleme
- **Sürücü:** NVIDIA/AMD/VM sürücü yönetimi
- **Dil:** Sistem dili, klavye layout, saat formatı
- **Güç:** Profil seçimi, ekran kapanma, uyku

Tüm Python uygulamaları:
- PyQt6 ile yazılmıştır
- Karya DE temasını kullanır (`kdeglobals`)
- SVG ikon kullanır (emoji yok)
- Sistem genelinde `karya-` prefix'i ile kurulur
- `make test-apps` ile AST+import testinden geçer

### Plasma Widget'ları (QML)

| # | Widget | ID | Dil | İşlev |
|---|--------|-----|------|-------|
| 1 | **Karya Hava** | `org.karya.hava` | QML/JS | 16 şehir, 7 gün hava durumu |
| 2 | **Karya Namaz** | `org.karya.namaz` | QML/JS | 6 vakit, Diyanet verisi |
| 3 | **Karya Haber** | `org.karya.haber` | QML/JS | Kategori filtreli haberler |
| 4 | **Karya Sistem** | `org.karya.sistem` | QML/JS | CPU/RAM/Disk/Network monitörü |

Tüm widgetlar:
- Plasma 6 QML ile yazılmıştır
- SVG ikon kullanır
- Türkçe arayüz
- `packages/karya-widgets/` PKGBUILD ile paketlenir

### Sistem Bileşenleri

| Bileşen | Tür | İşlev |
|---------|-----|-------|
| **KWin-Karya** | C++ (KWin fork) | Pencere yöneticisi + auto tiling + glassmorphism |
| **Plasma Workspace** | C++/QML | Panel, bildirim, shell |
| **Plasma Desktop** | C++/QML | Masaüstü arkaplan, ikonlar |
| **SDDM Karya** | QML | Giriş ekranı (glassmorphism) |
| **Karya İkonları** | SVG | 13 özel SVG ikon |
| **Karya Sürücüleri** | Bash | GPU sürücü algılama/kurulum |
| **Donanım Scriptleri** | Bash | `detect-hardware.sh`, `install-drivers.sh`, `build-kwin.sh` |
| **AppArmor Profilleri** | AppArmor | OOBE, script, sürücü profilleri |
| **Sysctl Güvenlik** | sysctl | ASLR, ağ korumaları, core dump |
| **Kernel Config** | Kconfig | Performans + Hardened config (2 adet) |

---

## OOBE Kurulum Sihirbazı

Karya DE, ilk çalıştırmada **14 sayfalık** kapsamlı bir kurulum sihirbazı başlatır.
Dosya: `packages/karya-oobe/src/karya-oobe.py` (1.494 satır, PyQt6)

```
Altyapı:
├── karya-oobe.py          # Ana uygulama (QStackedWidget ile sayfa yönetimi)
├── services/
│   ├── hardware_service.py  # Donanım algılama (GPU, RAM, CPU, ses, ağ)
│   ├── driver_service.py    # Pacman/Apt sürücü yönetimi
│   └── config_service.py    # Yapılandırma yazma (JSON/KConfig)
```

### Sayfa 1: Karşılama
Karya DE logosu (SVG), sürüm bilgisi (`v1.0.0`), "Başla" butonu ile karşılama ekranı. PyQt6 `QLabel` + `QPushButton` ile implemente edilmiştir. Glassmorphism efekti için arka planda blur uygulanır.

### Sayfa 2: Donanım Algılama
Sistem otomatik taranır, kullanıcıya özet gösterilir:
```
Algılanan Donanım:
├── GPU:  NVIDIA GeForce RTX 3060 (sürücü: nvidia)
├── RAM:  16 GB (8 GB üstü → Performans profili)
├── CPU:  Intel i7-12700K (12 çekirdek)
├── Ses:  PipeWire (NVIDIA HDMI + Realtek ALC1220)
├── Ağ:   Ethernet (bağlı) / WiFi (kullanılabilir) / Bluetooth (açık)
└── Tip:  Masaüstü bilgisayar (laptop değil, VM değil)
```
Kaynak: `hardware_service.py` → `detect_hardware()`, `lspci`, `dmidecode`, `cat /proc/cpuinfo`
İşlem: Donanım bilgisi JSON olarak `/etc/karya/hardware/` altına yazılır.

### Sayfa 3: GPU Sürücü Seçimi
Algılanan GPU'ya göre otomatik öneri + alternatif seçenekler:

| GPU | Önerilen | Alternatif |
|-----|----------|------------|
| **NVIDIA** (GTX 700+) | `nvidia` (proprietary) | `nouveau` (açık kaynak) |
| **NVIDIA** (GTX 600-) | `nouveau` | — |
| **NVIDIA Optimus** | `nvidia-prime` + `optimus-manager` | — |
| **AMD** (GCN 2+) | `amdgpu` (açık kaynak) | `amdgpu-pro` (kapalı) |
| **AMD** (GCN 1 / eski) | `radeon` | — |
| **Sanal Makine** | `virtualbox-guest-utils` / `open-vm-tools` | — |

Kaynak: `driver_service.py` → `get_driver_list()`, distro bazlı `pacman -S` veya `apt install`
İşlem: Sürücüler kurulum aşamasında (Sayfa 14) otomatik yüklenir.

### Sayfa 4: Masaüstü Düzeni
RAM ve sistem kaynaklarına göre otomatik layout önerisi:

| RAM | Önerilen Layout | Açıklama |
|-----|-----------------|----------|
| 2 GB altı | Minimal | Sadece dock, efekt yok |
| 2-4 GB | Classic | Üst panel yok, dock tabanlı |
| 4-8 GB | **Modern** (varsayılan) | Üst panel + dock + hafif efekt |
| 8 GB+ | Tüm layoutlar açık | Modern + glassmorphism + blur |

Kaynak: `hardware_service.py` → öneri `total_ram` bazlı.
Yapılandırma: `shell/layouts/` altındaki JSON layout dosyalarına yazılır.

### Sayfa 5: Bileşen Ayarları
Performans profiline göre otomatik etkin/kapalı:

| Bileşen | Düşük RAM | Orta RAM | Yüksek RAM |
|---------|-----------|----------|------------|
| Auto Tiling | Açık | Açık | Açık |
| Glassmorphism | Kapalı | Kapalı (**GPU gerekli**) | Açık |
| Animasyonlar | Kapalı | Açık (3 GB+ RAM) | Açık |
| Pencere Bulanık | Kapalı | Kapalı | Açık (8 GB+ RAM) |
| Sıcak Köşeler | Açık | Açık | Açık |
| Gece Modu | Açık | Açık | Açık (Türkiye koordinatları) |
| Pencere Gölgesi | Kapalı | Açık | Açık |

Kaynak: `config_service.py` → `apply_performance_profile()`
KWin ayarları: `~/.config/kwinrc` dosyasına yazılır.

### Sayfa 6: Tema Seçimi
Karya DE'nin görsel kimliği bu sayfada yapılandırılır:
- **Tema:** Koyu, Açık, Mavi (3 ön yüklü tema)
- **Vurgu Rengi:** 12 renk paleti (mavi, yeşil, kırmızı, mor, turkuaz, pembe, portakal, gri, vb.)
- **Efekt Seviyesi:** Hafif (sadece gölge), Orta (hafif blur), Tam (glassmorphism + blur + animasyon)
- **Ön izleme:** Seçim yapıldıkça canlı ön izleme güncellenir

Kaynak: `shell/look-and-feel/` → Karya tema paketi, `~/.config/kdeglobals` yazılır.

### Sayfa 7: Varsayılan Uygulamalar
Kullanıcının tercihine göre MIME türleri atanır:

| Kategori | Varsayılan | Alternatifler |
|----------|-----------|---------------|
| Web Tarayıcı | Firefox | Chromium, Brave, Vivaldi |
| Terminal | Konsole | Alacritty, Kitty, GNOME Terminal |
| Dosya Yöneticisi | Dolphin | Thunar, Nautilus, PCManFM |
| Metin Editörü | Kate | VS Code, Gedit, Vim |
| Müzik Çalar | Elisa | Spotify, Rhythmbox, Strawberry |
| Video Oynatıcı | Haruna | VLC, MPV, Celluloid |
| Resim Görüntüleyici | Gwenview | Eye of GNOME, Ristretto, Nomacs |

Yapılandırma: `~/.config/mimeapps.list` dosyasına yazılır.

### Sayfa 8: Geliştirme Araçları
Geliştiriciler için tek tıkla kurulum:
```
☑ Git          — Versiyon kontrol sistemi
☑ Python 3     — Python yorumlayıcı + pip
☑ Node.js      — JavaScript runtime + npm
☐ Docker       — Konteyner platformu
☐ VS Code      — Kod editörü
☐ GCC          — GNU C/C++ derleyici
☐ JDK 21       — Java Development Kit
☐ PostgreSQL   — Veritabanı sunucusu
☐ Redis        — İn-memory veri deposu
```
İşaretli olanlar kurulum aşamasında `pacman -S` veya `apt install` ile yüklenir.
Kaynak: `oobe.py` → `install_dev_tools()`

### Sayfa 9: Oyun Araçları
Oyuncular için optimize edilmiş araçlar:
```
☑ Steam           — Oyun platformu
☐ Lutris          — Oyun yöneticisi
☐ GameMode        — Feral Interactive optimizasyon
☐ Proton-GE       — Windows oyunları için Wine fork
☐ Wine            — Windows uyumluluk katmanı
☐ MangoHud        — Oyun içi FPS/performans monitörü
☐ Gamescope       — Oyun odaklı micro-compositor
☐ Discord         — Sesli/sosyal platform
```
GameMode aktifleştirildiğinde `gamemoderun %command%` ile oyunlar otomatik optimize çalışır.
Kaynak: `config_service.py` → GameMode yapılandırması `/etc/gamemode.ini`

### Sayfa 10: Gizlilik Ayarları
Kullanıcı gizliliği için ince ayarlar:
```
Gizlilik Seviyesi: [Yüksek  ●━━━━━━━━━○  Düşük]

☐ Konum servislerini etkinleştir (geolocation)
☐ Çökme raporu gönderimi (KDE DrKonqi)
☐ KDE telemetri/kullanım istatistiği gönder
☐ Baloo dosya indekslemeyi etkinleştir
☐ Aygıt adını (hostname) ağda yayınla

Makine Adı: [karya-pc________________]
```
Yüksek gizlilik: Tüm servisler kapalı, hostname rastgele.
Düşük gizlilik: Tüm servisler açık, normal hostname.
Kaynak: `config_service.py` → `apply_privacy_settings()`

### Sayfa 11: Ekran Ayarları
Çoklu monitör ve görüntü yapılandırması:
```
Çözünürlük: [1920x1080 ▾]  (algılanan maks değer varsayılan)
Ölçekleme:  [1.0x ▾]       (4K için 1.5x/2.0x önerilir)
Yenileme:   [144 Hz ▾]     (monitör kapasitesine göre)
DPI:        [96 ▾]         (4K: 144-192 önerilir)

Mevcut Ekranlar:
☑ HDMI-1: 1920x1080 @ 144Hz (ana ekran)
☐ DP-1:   2560x1440 @ 60Hz  (genişletilmiş)
☐ HDMI-2: 1920x1080 @ 60Hz  (aynalı)
```
Kaynak: `kscreen-doctor` ile algılama, `~/.config/kscreenlockerrc` yazılır.

### Sayfa 12: Güç Yönetimi
Laptop ve masaüstü için güç profilleri:

| Profil | CPU Yöneticisi | Ekran Kapanma | Uyku | Ne Zaman |
|--------|---------------|---------------|------|----------|
| Güç Tasarrufu | `powersave` | 5 dakika | 15 dakika | Pil / düşük kaynak |
| Dengeli | `schedutil` | 10 dakika | 30 dakika | Varsayılan |
| Performans | `performance` | 15 dakika | 1 saat | AC / oyun / render |

Laptop algılandığında pil tasarrufu seçeneği eklenir: otomatik parlaklık azaltma, Bluetooth/WiFi güç yönetimi.
Kaynak: `powerprofilesctl` (ELeoind) veya `cpupower`, yapılandırma `/etc/karya/power.conf`

### Sayfa 13: Kullanıcı
Yeni kullanıcı oluşturma veya mevcut kullanıcıyı yapılandırma:
```
Kullanıcı Adı:  [kullanici____________]
Tam Ad:         [Ad Soyad_____________]
Şifre:          [********************]
Şifre (tekrar): [********************]

☑ Otomatik giriş (SDDM'yi atla)
☑ Tema ayarlarını bu kullanıcıya uygula
☑ Klasörleri oluştur (İndirilenler, Belgeler, Müzik, vb.)
☐ Kullanıcıyı sudo grubuna ekle
```
Kaynak: `useradd`, `passwd`, SDDM config `/etc/sddm.conf.d/autologin.conf`

### Sayfa 14: Özet ve Kurulum
Tüm seçimlerin listelendiği önizleme ekranı + 7 adımlı kurulum:
```
═══════════════════════════════════════
  ÖZET
═══════════════════════════════════════
  GPU:        NVIDIA GeForce RTX 3060
  Sürücü:     nvidia (proprietary)
  Layout:     Modern
  Tema:       Koyu + Mavi vurgu
  Profil:     Performans
  Uygulamalar: Firefox, Konsole, Dolphin
  Geliştirme: Git, Python, Node.js
  Oyun:       Steam, Lutris, GameMode
═══════════════════════════════════════
  [← Geri]                          [Kurulum →]
═══════════════════════════════════════
```

Kurulum adımları (progress bar ile canlı log):
```
1/7  ─ Donanım algılanıyor...           [████████░░░░░░░░░░░░]  40%
     → GPU, RAM, CPU, ses, ağ, laptop/VM tespit edildi

2/7  ─ Sürücüler kuruluyor...
     → nvidia-dkms, nvidia-utils, lib32-nvidia-utils

3/7  ─ İstenen paketler kuruluyor...
     → steam, lutris, gamemode, git, python, nodejs

4/7  ─ KWin ayarları uygulanıyor...
     → autotiling=on, glassmorphism=on, blur=on

5/7  ─ Panel düzeni ayarlanıyor...
     → Layout: Modern (üst panel + dock)

6/7  ─ Bileşenler etkinleştiriliyor...
     → Gece modu, sıcak köşeler, sistem tepsisi

7/7  ─ Kullanıcı oluşturuluyor...
     → kullanici@karya-pc (~/) otomatik giriş aktif

═══════════════════════════════════════
  ✓ KURULUM TAMAMLANDI — Yeniden başlatın.
═══════════════════════════════════════
```
Kurulum tamamlandığında buton: "Sistemi Yeniden Başlat" → `sudo reboot`

---

## SDDM Giriş Ekranı

Karya DE, özel SDDM teması ile gelir:

```
sddm-theme/karya-sddm/
├── metadata.desktop    # Tema bilgisi
├── Main.qml            # Ana giriş ekranı
└── components/         # Bileşenler
```

Özellikler:
- Glassmorphism login kartı (saydam + blur)
- Kullanıcı adı ve şifre alanı
- Oturum seçimi (Karya DE Wayland / Karya DE X11)
- Kapatma ve yeniden başlatma butonları
- Tamamen Türkçe arayüz
- Klavye desteği (Enter ile giriş)

```qml
// Session seçenekleri
{ text: "Karya DE (Wayland)", value: "karya-wayland" },
{ text: "Karya DE (X11)", value: "karya-x11" },
```

Kurulum:
```bash
sudo cp -r sddm-theme/karya-sddm /usr/share/sddm/themes/
sudo mkdir -p /etc/sddm.conf.d
echo "[Theme]" > /etc/sddm.conf.d/karya.conf
echo "Current=karya-sddm" >> /etc/sddm.conf.d/karya.conf
```

---

## KWin Pencere Yöneticisi

Karya DE'nin pencere yöneticisi `kwin-karya`, KWin tabanlı olup şu özellikleri ekler:

### Auto Tiling
4 farklı döşeme layout'u:

| Layout | Görsel | Kısayol |
|--------|--------|---------|
| Master-Stack | Ana pencere solda %55, kalanlar sağa yığılır | Meta+T |
| Split | 2 eşit parçaya böl (yatay) | Meta+Shift+T |
| Grid | Eşit sütun/satır grid | Meta+Shift+T |
| Monocle | Tüm pencereler tam ekran | Meta+Shift+T |

Kodu: `patches/kwin/01-karya-tiling.patch`

### Glassmorphism Efekti
İki implementasyon:
1. **C++ efekti** - `kwin-effects/karya-glassmorphism/` - Derlenmiş, hızlı
2. **JS script** - `kwin-effects/scripts/karya-glassmorphism.js` - Dinamik, kolay düzenlenebilir

### Kısayol Yapılandırması

```ini
[KaryaTiling]
Enabled=true
Layout=master-stack
Gap=4
KeyboardShortcut=Meta+T
CycleLayoutShortcut=Meta+Shift+T

[Script-karya-glassmorphism]
enabled=true
blurRadius=12
opacity=0.75
```

---

## Panel ve Dock Sistemi

Karya DE, 2 panel ile gelir:

### Üst Panel
```
[Kickoff] [Görev Yöneticisi] ................. [Sistem Tepsisi] [Saat]
```

Bileşenler:
- **Kickoff** - Uygulama menüsü (Alt+F1)
- **Icon Tasks** - Açık uygulamalar
- **Margins Separator** - Boşluk
- **System Tray** - Ses, ağ, batarya, Bluetooth, bildirim
- **Digital Clock** - 24 saat, Türkiye saati, tam tarih

### Alt Dock
```
[Dolphin] [Konsole] [Firefox] [Kate] [Gwenview] [Kcalc] [Spectacle] [Ayarlar]
```

Özellikler:
- Otomatik gizlenme
- Ortalanmış
- Uygulama gruplama

### Layout Seçenekleri
| Layout | Üst Panel | Alt Panel/Dock | Kime Göre |
|--------|-----------|----------------|-----------|
| Karya Modern | Kickoff + Tasks + Tray + Clock | Dock (autohide) | 4 GB+ RAM |
| Karya Classic | Yok | Kickoff + Tasks + Tray + Clock | 4 GB altı RAM |
| Karya macOS | AppMenu + Clock + Tray | Dock (sabit) | macOS geçiş |
| Karya Minimal | Yok | Kickoff + Tasks + Clock | VM ve çok düşük sistem |

---

## Kısayollar

| Kısayol | İşlev |
|---------|-------|
| Meta+T | Auto tiling aç/kapa |
| Meta+Shift+T | Tiling layout değiştir |
| Meta+Shift+G | Glassmorphism aç/kapa |
| Alt+F1 | Uygulama menüsü |
| Meta+D | Masaüstünü göster |
| Meta+E | Dosya yöneticisi (Dolphin) |
| Alt+Tab | Pencere değiştir |
| Ctrl+Alt+Del | Kilit ekranı |
| PrintScreen | Ekran görüntüsü (Spectacle) |
| Meta+L | Oturumu kilitle |

---

## Sürücü Yönetimi

### Donanım Bilgisi Görüntüleme

```bash
cat /etc/karya/hardware/gpu.json
cat /etc/karya/hardware/system.json
cat /etc/karya/hardware/audio.json
cat /etc/karya/hardware/profile.json
```

### Manuel Sürücü Kurulumu

```bash
# NVIDIA
sudo bash /usr/lib/karya/scripts/install-drivers.sh nvidia

# AMD
sudo bash /usr/lib/karya/scripts/install-drivers.sh amd

# Intel (deneysel - resmi destek yok)
sudo bash /usr/lib/karya/scripts/install-drivers.sh intel

# VM
sudo bash /usr/lib/karya/scripts/install-drivers.sh vm

# Otomatik algıla ve kur
sudo bash /usr/lib/karya/scripts/install-drivers.sh auto
```

### Donanımı Yeniden Tara

```bash
sudo bash /usr/lib/karya/scripts/detect-hardware.sh
```

---

## Performans Profilleme

Karya DE, sistem kaynaklarına göre 3 profil sunar:

### Hafif Profil (4 GB altı RAM)
```ini
Compositor=xrender
Animations=false
Blur=false
Scale=1.0
Layout=minimal
```

### Dengeli Profil (4-8 GB RAM)
```ini
Compositor=opengl
Animations=true
Blur=false
Scale=1.0
Layout=modern
```

### Performans Profili (8 GB+ RAM, GPU)
```ini
Compositor=opengl
Animations=true
Blur=true
Scale=1.0
Layout=modern
Glassmorphism=true
```

### GPU Bazlı Ayar

| GPU | Compositor | Blur | Özel |
|-----|------------|------|------|
| NVIDIA | OpenGL (EGLStreams) | 8 GB+ RAM | ForceCompositionPipeline |
| AMD | OpenGL (RADV) | Her zaman | TearFree |
| VM | XRender | Kapalı | Mesa swrast |

---

## Mimari Yapı

```
karya-de/
├── sources/                    # Fork'lanmış KDE repoları
│   ├── kwin/                   # KWin pencere yöneticisi (fork)
│   ├── plasma-workspace/       # Panel, shell, bildirimler
│   ├── plasma-desktop/         # Masaüstü uygulamaları
│   ├── plasma-pa/              # Ses yönetimi
│   └── systemsettings/         # Ayarlar
├── patches/                    # Karya özel patch'leri
│   └── kwin/                   # Auto tiling patch'i
├── kwin-effects/               # Özel KWin efektleri
│   ├── karya-glassmorphism/    # C++ cam efekti
│   └── scripts/                # JS script efekti
├── security/                   # GÜVENLİK POLİTİKALARI
│   ├── apparmor/               # AppArmor profilleri (3 adet)
│   ├── sysctl/                 # Sysctl güvenlik ayarları
│   └── selinux/                # SELinux politika dosyası
├── shell/                      # Yerel yapılandırma
│   ├── layouts/                # Panel/dock layout'ları
│   ├── look-and-feel/          # Tema paketi
│   └── sessions/               # Oturum dosyaları
├── widgets/                    # Plasma 6 widget'ları (4 adet)
│   ├── karya-hava/             # Hava durumu
│   ├── karya-namaz/            # Namaz vakitleri
│   ├── karya-haber/            # Haber başlıkları
│   └── karya-sistem/           # Sistem monitörü
├── hardware/                   # Donanım desteği
│   ├── scripts/                # detect + install
│   │   ├── detect-hardware.sh  # Donanım algılama
│   │   └── install-drivers.sh  # Sürücü kurulumu
│   └── profiles/               # GPU konfigürasyonları
├── branding/                   # Görsel kimlik
│   ├── logo/                   # SVG logo (profesyonel)
│   ├── icons/karya-icons/      # Özel ikon teması (5 ikon)
│   ├── screenshots/            # Ekran görüntüleri (7 adet)
│   └── mockup/                 # Konsept tasarım
├── sddm-theme/                 # SDDM giriş teması
│   └── karya-sddm/             # Login ekranı (QML)
├── calamares/                  # ISO kurulum modülleri
├── apps/                       # Karya Python uygulamaları (4 adet)
│   ├── karya-calc/             # Hesap Makinesi
│   ├── karya-notes/            # Notlar
│   ├── karya-search/           # Masaüstü Arama
│   └── karya-settings/         # Karya Ayarlar
├── packages/                   # Arch PKGBUILD'ları (10 adet)
│   ├── karya-de-meta/          # Ana meta paket
│   ├── kwin-karya/             # Fork KWin
│   ├── karya-widgets/          # Widget paketi
│   ├── karya-oobe/             # Kurulum sihirbazı (PyQt6)
│   ├── karya-calc/             # Hesap Makinesi
│   ├── karya-notes/            # Notlar
│   ├── karya-search/           # Masaüstü Arama
│   ├── karya-settings/         # Karya Ayarlar
│   ├── karya-drivers/          # Sürücü desteği
│   └── karya-icons/            # İkon teması
├── iso/                        # Arch ISO konfigürasyonu
├── scripts/                    # Derleme araçları
├── docs/                       # Dokümantasyon
│   ├── ARCHITECTURE.md         # Mimari detay
│   └── runit-setup.md          # Init sistemi kurulumu
├── SECURITY.md                 # Güvenlik politikası belgesi
├── COPYING                     # GPLv2 lisans metni
└── Makefile                    # Ana derleme dosyası
```

---

## Paket Listesi

| Paket | İçerik | Bağımlılık |
|-------|--------|------------|
| `karya-de-meta` | Tüm Karya DE'yi kurar (meta) | Tüm alt paketler |
| `kwin-karya` | Fork KWin + tiling + glassmorphism | Qt6, KF6 |
| `plasma-workspace` | Panel, bildirim, shell | kwin |
| `karya-widgets` | 4 widget (hava/namaz/haber/sistem) | workspace |
| `karya-oobe` | Kurulum sihirbazı **(Güncellendi)** | PyQt6, bash |
| `karya-calc` | Hesap Makinesi **(Yeni)** | Python, PyQt6 |
| `karya-notes` | Notlar uygulaması **(Yeni)** | Python, PyQt6 |
| `karya-search` | Masaüstü arama **(Yeni)** | Python, PyQt6 |
| `karya-settings` | Karya Ayarlar **(Yeni)** | Python, PyQt6 |
| `karya-drivers` | GPU sürücü desteği | bash, jq |
| `karya-icons` | SVG ikon teması | breeze-icons |

---

## Katkıda Bulunma

1. Depoyu forklayın
2. Yeni bir branch açın (`git checkout -b ozellik/yeni-ozellik`)
3. Değişikliklerinizi yapın
4. Commit edin (`git commit -m 'feat: yeni ozellik'`)
5. Branch'inizi pushlayın (`git push origin ozellik/yeni-ozellik`)
6. Pull Request açın

### Kod Standartları
- **C++:** KDE coding style (clang-format)
- **QML:** 4 space indent, camelCase
- **Python:** PEP 8, snake_case
- **Bash:** shellcheck uyumlu

---

## Düzeltilen Hatalar (v1.0.0)

Aşağıdaki hatalar tespit edilmiş ve giderilmiştir:

### 1. Ubuntu 24.04 APT Paket Hataları (`install-ubuntu.sh`)

- **Varolmayan paketler**: `libxcb-util-wm-dev`, `libhwdata-dev`, `libqaccessibilityclient-qt6-dev` Ubuntu 24.04 resmi depolarında bulunmamaktadır. Kaldırılmıştır. `hwdata` (runtime) ile değiştirilmiştir.
- **KF6 paketleri eksik**: `libkf6kirigami-dev`, `libkf6plasma-dev`, `libkf6screenlocker-dev`, `libkf6globalacceld-dev`, `libplasma-activities-dev` Ubuntu stok reposunda yok. Kubuntu Backports PPA (`ppa:kubuntu-ppa/backports`) otomatik ekleniyor; her paket `apt-cache show` ile kontrol edilip varsa kuruluyor, yoksa atlanıyor.
- **Pipo maskesi**: `apt install ... | tail -3` yüzünden `set -e` apt hatalarını yakalayamıyordu (çıkış kodu pipe zincirindeki son komuttan geliyor). Kritik komutlardan pipe kaldırıldı; `git clone`'a `|| exit 1` eklendi.

### 2. curl|bash'de `read` Bekleme Sorunu (`install-ubuntu.sh`, `install.sh`, `install-nosystemd.sh`)

- curl ile pipe edilmiş betiklerde stdin tüketildiği için `read -t 10` komutu kullanıcıdan giriş alamıyordu. Çözüm: `-y` flag'i ile otomatik devam (`sleep 10`) kullanıldı.

### 3. Shellcheck Uyarıları (Tüm Betikler)

- `detect-hardware.sh`: SC2155 (declare+exit maskesi) satır 74, 76, 78, 80, 83, 85, 87, 89, 91, 93, 95, 97, 99 — düzeltildi.
- `install-drivers.sh`: SC2155 (satır 23), SC2010 (satır 44) — düzeltildi.
- Tüm 6 betik `shellcheck -S warning` ile 0 hata, 0 uyarı vermektedir.

### 4. Docker Testinde Tespit Edilen Sorunlar

- **install.sh (Arch Linux)**: Docker üzerinde çalıştırıldı, `curl: command not found` hatası `|| true` ile korunuyordu; tüm hata yolları güvenli.
- **install-ubuntu.sh (Ubuntu 24.04)**: 3 eksik paket + pipe maskesi tespit edildi. Düzeltildikten sonra temel paketler (git, cmake, qt6, build-essential) başarıyla kuruluyor; KF6 paketleri PPA üzerinden geliyor.

---

## Sıkça Sorulan Sorular (SSS)

### Karya DE systemd gerektiriyor mu?
Hayır. Karya DE, elogind + runit ile çalışır. systemd bağımlılığı yoktur.

### NVIDIA Optimus laptop'um var, çalışır mı?
Evet. OOBE sihirbazı NVIDIA Optimus seçeneği sunar. `nvidia-prime` ve `optimus-manager` desteği dahildir.

### Intel GPU kullanıyorum, ne yapmalıyım?
Intel GPU'lar resmi olarak desteklenmez. Deneysel modda çalışabilir ancak performans garantisi yoktur. NVIDIA veya AMD GPU önerilir.

### Wayland sorunlu mu?
Hayır. Karya DE varsayılan olarak Wayland kullanır. NVIDIA EGLStreams ile tam uyumludur. X11 oturumu da opsiyonel olarak mevcuttur.

### ISO'dan nasıl kurarım?
`make iso` komutu ile ISO oluşturup USB'ye yazabilirsiniz:
```bash
make iso
dd if=iso/releng/out/karya-de-1.0.0-x86_64.iso of=/dev/sdX bs=4M status=progress
```

---

## Lisans

Bu proje GNU General Public License v2.0 altında lisanslanmıştır.
Detaylar için [COPYING](COPYING) dosyasına bakın.

Güvenlik politikası için [SECURITY.md](SECURITY.md) dosyasına bakın.
Sıkça Sorulan Sorular için [SIKÇA_SORULAN_SORULAR.md](SIKÇA_SORULAN_SORULAR.md) dosyasına bakın.
Sponsorluk ve bağış için [SPONSORLUK.md](SPONSORLUK.md) dosyasına bakın.

---

**Karya DE Ekibi** - [karya@karya-de.org](mailto:karya@karya-de.org)
**GitHub:** [github.com/muhammetodosks/karya-de](https://github.com/muhammetodosks/karya-de)

*Türk mühendisliği ile, Türk kullanıcılar için.*
