# Karya DE — Sıkça Sorulan Sorular

## Karya DE nedir?

Karya DE, sıfırdan inşa edilmiş modern bir Türk masaüstü ortamıdır. Qt6 ve KDE Framework teknolojileri üzerine kuruludur ancak **KDE Plasma değildir**. Karya DE kendi pencere yöneticisi (kwin-karya), kendi panel sistemi, kendi widget koleksiyonu ve kendi tema altyapısıyla tamamen bağımsız bir masaüstü ortamıdır. Amacı, dağıtımdan bağımsız çalışabilen, hafif, hızlı ve modern bir Türkçe masaüstü deneyimi sunmaktır.

Projenin temel felsefesi şudur: Kullanıcıyı boğmayan, gereksiz animasyonlar ve süslü efektlerle kaynak tüketmeyen, işini hızlıca yapmasına olanak tanıyan bir arayüz. Karya DE, minimalist bir yaklaşımla tasarlanmıştır ancak özelleştirmeye tamamen açıktır. Her bileşen modülerdir ve istenildiğinde değiştirilebilir veya kaldırılabilir.

Projenin geliştirilme amacı, Türkiye'de açık kaynak masaüstü ekosistemine katkıda bulunmak ve Türkçe kullanıcı arayüzü deneyimini uluslararası standartlara taşımaktır. Karya DE, yalnızca bir yazılım projesi değil, aynı zamanda Türk yazılım mühendisliğinin açık kaynak dünyasındaki temsilcisidir.

## Karya DE, KDE Plasma'nın bir çatallaşması mı?

Hayır. Karya DE, KDE teknolojilerini (KWin, KF6, Qt6) alt yapı olarak kullanır ancak üst katmanda tamamen özgün bir yapıya sahiptir. Benzerlik yalnızca altta yatan teknolojilerden kaynaklanır, tıpkı birçok Linux dağıtımının aynı Linux çekirdeğini kullanması gibi.

KWin pencere yöneticisi çatallanmış ve Karya DE'ye özel olarak değiştirilmiştir (kwin-karya). Bu çatalda:
- Karya DE renk şeması ve animasyon hızları varsayılan olarak ayarlanmıştır
- Gereksiz efektler (wobbly windows, magic lamp, vb.) varsayılan olarak kapatılmıştır
- Hafiflik için OpenGL 2.0 geri dönüş desteği iyileştirilmiştir
- NVIDIA EGLStreams uyumluluğu için yamalar eklenmiştir
- Intel GPU'larda daha iyi hata yönetimi sağlanmıştır

Panel sistemi, widget'lar, temalar, OOBE, ses yönetimi ve uygulamalar sıfırdan yazılmıştır. Python/PyQt6 ile geliştirilmişlerdir. Plasma'nın aksine, Karya DE'nin paneli QML tabanlı değildir; daha hafif ve daha hızlı bir C++/Python hibrit yapı kullanır. Kısacası: motor aynı ama gövde, kaporta ve iç tasarım tamamen farklıdır.

## Hangi dağıtımlar destekleniyor?

Resmi olarak desteklenenler:

- **Arch Linux** (ve tabanlı dağıtımlar: EndeavourOS, Arco Linux, Manjaro, Garuda Linux)
- **Artix Linux** (systemd'siz, runit-init ile)
- **Ubuntu 24.04 (Noble) ve üzeri**

Diğer dağıtımlarda kaynaktan derleme yapabilirsiniz. Bunun için `make setup && make build && make install` komutlarını kullanabilirsiniz. Fedora 40+, Debian Testing/Bookworm, openSUSE Tumbleweed ve Void Linux'ta da çalıştığı bildirilmiştir ancak resmi destek yoktur.

### Kurulum Öncesi Dikkat Edilmesi Gerekenler

Kurulumdan önce sisteminizin güncel olduğundan emin olun:
- Arch Linux: `sudo pacman -Syu`
- Ubuntu: `sudo apt update && sudo apt upgrade`
- Artix: `sudo pacman -Syu`

Kurulum sırasında sisteminizde halihazırda bir masaüstü ortamı (GNOME, KDE, XFCE vb.) yüklü olması sorun teşkil etmez. Karya DE, mevcut masaüstü ortamınızın yanına kurulur ve SDDM'den oturum seçerek kullanılır.

### Desteklenmeyen Dağıtımlar

- **Windows ve macOS**: Karya DE, Linux tabanlı bir masaüstü ortamıdır. Windows veya macOS üzerinde doğrudan çalışmaz. Ancak WSL2 veya sanal makine üzerinde kullanılabilir.
- **Android/iOS**: Mobil işletim sistemleri için şu anda bir sürüm bulunmamaktadır.
- **Çok eski Linux dağıtımları**: Ubuntu 20.04 veya daha eski sürümlerde Qt6 ve KF6 paketleri bulunmadığı için Karya DE çalışmaz.

## Nasıl kurarım?

Tek komutla:

```bash
# Arch Linux
curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install.sh | sudo bash

# Ubuntu 24.04+
curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install-ubuntu.sh | sudo bash

# Systemd'siz (Artix)
curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install-nosystemd.sh | sudo bash

# Kaynaktan
git clone https://github.com/muhammetodosks/karya-de.git
cd karya-de
make setup
make build
make install
```

Kurulum sonrası bilgisayarı yeniden başlatın ve SDDM giriş ekranında "Karya" oturumunu seçin.

### Kurulum Sırasında Karşılaşılabilecek Sorunlar

**curl | bash yöntemi neden güvenli?** GitHub raw içeriği HTTPS üzerinden sunulur ve indirilen betik çalıştırılmadan önce sisteminizde gerekli kontrolleri yapar. Alternatif olarak betiği indirip inceleyebilirsiniz:

```bash
curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install.sh > install.sh
less install.sh  # incele
sudo bash install.sh
```

**Kurulum yarıda kalırsa ne yapmalıyım?** Betik, her adımda bir önceki adımın başarılı olduğunu kontrol eder (set -e). Hata alırsanız, hatanın nerede olduğunu görmek için çıktıyı inceleyin. Genellikle eksik bağımlılıklar veya internet bağlantısı sorunları nedeniyle kurulum yarıda kalır. Çözüm için `sudo pacman -Syu` veya `sudo apt update` komutlarını çalıştırıp tekrar deneyin.

**Kurulum ne kadar sürer?** İnternet hızınıza bağlı olarak 5-20 dakika arasında değişir. En uzun süren adım, KWin pencere yöneticisinin derlenmesidir (kaynak kurulumda yaklaşık 5-10 dakika). Paket yöneticisi üzerinden kurulumda bu süre 2-3 dakikaya düşer.

## Karya DE hangi GPU'ları destekliyor?

- **AMD** (amdgpu): Tam destek. Açık kaynak sürücü kutudan çıkar. Radeon HD 7000 serisi ve üzeri tüm GPU'lar desteklenir. Vulkan ve OpenGL tam uyumludur.
- **NVIDIA** (nouveau ve propriyeter): Destekleniyor. Propriyeter sürücü için `nvidia-dkms` ve `nvidia-utils` paketleri kurulmalıdır. Optimus (hibrit) sistemlerde `nvidia-prime` kullanılır.
- **Intel** (i915): Deneysel destek. Bazı Intel GPU'larda (özellikle 12. nesil öncesi) KWin hata verebilir. Intel Arc (DG2/Alchemist) GPU'lar daha iyi desteklenir.
- **VM**: QEMU/KVM (virtio), VMware, VirtualBox'ta test edilmiştir. VM'de 3D hızlandırma için VirtIO GPU veya VMware SVGA II önerilir.

Donanım algılama otomatiktir: `bash /usr/lib/karya/scripts/detect-hardware.sh` ile sürücü seçimi yapılır. Bu betik, sisteminizdeki GPU'yu algılar, uygun sürücüyü önerir ve gerekli paketleri kurar.

### GPU Sorun Giderme

**Ekran gelmiyor, beyaz/kara ekran kalıyorsa:** 
1. CTRL+ALT+F2 ile TTY'ye geçin
2. `sudo bash /usr/lib/karya/scripts/detect-hardware.sh --reset` çalıştırın
3. `sudo systemctl restart display-manager` ile yeniden başlatın

**NVIDIA sürücü hatası:**
```bash
# Sürücü durumunu kontrol et
nvidia-smi
# Çekirdek modülünü kontrol et
lsmod | grep nvidia
# Gerekirse sürücüyü yeniden kur
sudo pacman -S nvidia-dkms nvidia-utils
```

**AMD GPU performans sorunu:**
```bash
# Mesa sürümünü kontrol et
glxinfo | grep "OpenGL version"
# Vulkan desteğini kontrol et
vulkaninfo | grep "Vulkan Instance"
```

## Karya DE'nin sistem gereksinimleri nelerdir?

| Bileşen | Minimum | Önerilen |
|---------|---------|----------|
| CPU | 2 çekirdek @ 2.0 GHz | 4+ çekirdek @ 2.5 GHz |
| RAM | 2 GB | 4+ GB |
| Disk | 5 GB | 10+ GB (SSD önerilir) |
| GPU | OpenGL 3.3 destekli | Vulkan 1.2+ destekli |
| Ekran | 1280x720 | 1920x1080+ |

Karya DE, KDE Plasma'dan yaklaşık %30 daha az RAM kullanır. Boşta ~400-600 MB arası bellek tüketimi hedeflenmiştir. Karşılaştırma yapmak gerekirse:
- **GNOME 45**: Boşta yaklaşık 900-1100 MB
- **KDE Plasma 6**: Boşta yaklaşık 700-900 MB
- **Karya DE 1.0**: Boşta yaklaşık 400-600 MB
- **XFCE 4.18**: Boşta yaklaşık 350-500 MB

Karya DE, XFCE'ye yakın bir hafiflik sunarken, görsel olarak çok daha modern bir deneyim sağlar.

### Depolama Detayları

| Bileşen | Boyut |
|---------|-------|
| KWin-karya ve kütüphaneler | ~180 MB |
| Python uygulamaları | ~15 MB |
| Widget'lar | ~8 MB |
| İkon teması | ~45 MB |
| SDDM teması | ~12 MB |
| Donanım scriptleri | ~2 MB |
| OOBE | ~5 MB |
| **Toplam** | **~267 MB** |

## Hangi uygulamalar geliyor?

Karya DE ile birlikte gelen ilk parti uygulamalar:

### Masaüstü Uygulamaları

- **karya-calc**: Basit ama şık hesap makinesi (Python/PyQt6). Bilimsel mod, döviz çevirici ve geçmiş özellikleri içerir.
- **karya-notes**: Hızlı not alma uygulaması. Markdown desteği, etiketleme, arama ve kategorilendirme özellikleri vardır. Notlar yerel dosya sisteminde JSON formatında saklanır.
- **karya-search**: Masaüstü arama (krunner alternatifi). Uygulamalar, dosyalar, ayarlar ve web üzerinde arama yapabilir. AI destekli akıllı tamamlama özelliği bulunur.
- **karya-settings**: Ayarlar paneli. Görünüm, ses, ağ, donanım, klavye kısayolları ve kullanıcı hesaplarını yönetir. Kategorilere ayrılmış modern bir arayüz sunar.

### Sistem Bileşenleri

- **karya-oobe**: İlk açılış deneyimi (karşılama sihirbazı). Dil, klavye düzeni, saat dilimi, ağ bağlantısı, GPU sürücüsü seçimi ve kullanıcı hesabı oluşturma adımlarını içerir.
- **karya-widgets**: Masaüstü widget koleksiyonu. Saat, takvim, sistem monitörü, hava durumu, not defteri ve medya oynatıcı widget'ları içerir.
- **karya-icons**: Özel ikon teması. 2000+ ikon içeren, SVG tabanlı, ölçeklenebilir ikon seti.
- **karya-drivers**: Donanım yönetimi araçları. GPU algılama, sürücü kurulumu, yazıcı yönetimi ve Bluetooth yapılandırması.

### Gelecek Uygulamalar

- **karya-terminal**: Varsayılan terminal emülatörü (QML tabanlı, GPU hızlandırmalı) — v1.1
- **karya-files**: Dosya yöneticisi (Python/PyQt6, çift panelli) — v1.2
- **karya-backup**: Yedekleme aracı (zaman makinesi benzeri) — v2.0
- **karya-store**: Uygulama mağazası (Flatpak/AppImage entegrasyonlu) — v2.0

## Nasıl katkıda bulunabilirim?

1. **Hata bildirimi**: GitHub Issues sayfasından hata raporu açın. Hata raporunuzda: işletim sistemi, Karya DE sürümü, hatanın nasıl tekrarlanacağı ve varsa hata çıktısını (log) belirtin.
2. **Kod katkısı**: Pull request göndermeden önce `CONTRIBUTING.md` dosyasını okuyun. Kod stili kurallarına uyduğunuzdan emin olun.
3. **Çeviri**: `localization/` dizinindeki çeviri dosyalarına katkıda bulunun. Şu anda Türkçe ve İngilizce desteklenmektedir. Almanca, Fransızca, Arapça çeviriler için gönüllü aranmaktadır.
4. **Tema/paket**: Kendi tema veya paketinizi `packages/` dizini altına ekleyin. Tema oluşturma rehberi için `docs/theming.md` dosyasına bakın.
5. **Dokümantasyon**: README, wiki veya dokümantasyon dosyalarını iyileştirin. Eksik veya hatalı dokümantasyon bulursanız lütfen düzeltin.
6. **Test**: Geliştirme sürümlerini test edin ve geri bildirim gönderin. Test etmek için `make test` komutunu kullanabilirsiniz.
7. **Topluluk**: Sosyal medyada Karya DE'yi tanıtın, forumlarda soruları yanıtlayın, yeni kullanıcılara yardımcı olun.

## Hangi lisansı kullanıyor?

Karya DE, **GNU Genel Kamu Lisansı v2.0 (GPLv2)** ile lisanslanmıştır. Bu lisans şu anlama gelir:

- **Kullanım**: Karya DE'yi herhangi bir amaç için kullanabilirsiniz (ticari, kişisel, eğitim).
- **Dağıtım**: Karya DE'yi kopyalayıp dağıtabilirsiniz.
- **Değiştirme**: Karya DE'yi değiştirebilir ve özelleştirebilirsiniz.
- **Paylaşma**: Değiştirilmiş sürümleri dağıtırsanız, kaynak kodunu da açık hale getirmelisiniz (copyleft).

Alt bileşenler (widget'lar, uygulamalar) aksi belirtilmediği sürece aynı lisansı taşır. KWin çatalı olan kwin-karya, orijinal KWin lisansı olan GPLv2+ ile uyumludur.

### Üçüncü Parti Lisanslar

- **Qt6**: LGPLv3 / GPLv3
- **KDE Frameworks 6**: LGPLv2.1+ / GPLv2+
- **Python 3**: Python Software Foundation License
- **PyQt6**: GPLv3 (ticari lisans da mevcuttur)
- **PipeWire**: MIT
- **libepoxy**: MIT

## Karya DE stabil mi?

Sürüm 1.0.0 itibarıyla temel masaüstü işlevleri (pencere yönetimi, panel, widget'lar, oturum yönetimi) kararlıdır. Günlük kullanım için uygundur. Karya DE ile şu işlemleri sorunsuzca yapabilirsiniz:

- Web'de gezinme (Firefox, Chromium, Chrome)
- Ofis işleri (LibreOffice, OnlyOffice)
- Kod geliştirme (VSCode, IntelliJ, Vim, Neovim)
- Medya oynatma (VLC, MPV, Spotify)
- E-posta ve mesajlaşma
- Dosya yönetimi

Hâlâ geliştirme aşamasında olan özellikler:

- Kapsamlı ayarlar paneli (şu anda temel ayarlar mevcut) — v1.2'de tamamlanması planlanıyor
- Ağ yönetimi widget'ı (şu anda sistem tepsisinden yapılıyor)
- Bildirim geçmişi
- Sanal masaüstü yöneticisi
- Kapsamlı tema mağazası
- Ekran yakalama ve kayıt
- Uzaktan masaüstü

### Bilinen Sorunlar

1. **Intel GPU'larda KWin hatası**: Bazı Intel HD Graphics 4000/5000 serisi GPU'larda KWin başlatma sırasında çökebilir. Geçici çözüm: `KWIN_COMPOSE=NONE` ile başlatın.
2. **NVIDIA G-Sync/FreeSync**: Karya DE'nin KWin çatalında G-Sync/FreeSync desteği henüz eklenmemiştir.
3. **Çoklu monitör**: Üçten fazla monitörde bazı düzen sorunları yaşanabilir.
4. **HiDPI**: 200% ölçeklemede bazı uygulamalar bulanık görünebilir (henüz tüm Qt6 uygulamaları HiDPI'yi tam desteklemez).

## NVIDIA Optimus (hibrit grafik) destekleniyor mu?

Evet. Karya DE, NVIDIA Optimus sistemlerde `prime-run` veya `nvidia-prime` ile çalışabilir. Otomatik GPU seçimi için `karya-drivers` bileşeni kullanılır. Kurulum sırasında `nvidia-prime` ve `optimus-manager` desteklenir.

### Optimus Yapılandırması

Karya DE, NVIDIA Optimus sistemlerde üç farklı yapılandırma seçeneği sunar:

1. **Tam NVIDIA**: Yalnızca NVIDIA GPU kullanılır (yüksek performans, yüksek güç tüketimi)
2. **Tam AMD/Intel**: Yalnızca entegre GPU kullanılır (düşük performans, düşük güç tüketimi)
3. **Hibrit (prime-run)**: Uygulama bazında GPU seçimi yapılır

Yapılandırmayı değiştirmek için:

```bash
# Mevcut GPU'yu kontrol et
glxinfo | grep "OpenGL renderer"

# Belirli bir uygulamayı NVIDIA ile çalıştır
prime-run aplikasyon_adi

# Karya DE OOBE'den GPU seçimi
sudo /usr/bin/karya-oobe --gpu-select
```

## Wayland mi X11 mi?

Karya DE, **öncelikli olarak Wayland** üzerinde çalışır. Wayland oturumu, daha iyi güvenlik, daha iyi performans ve daha iyi yüksek çözünürlük (HiDPI) desteği sunar.

### Wayland'in Avantajları

- **Daha iyi güvenlik**: Her uygulama kendi arabelleğinde çizim yapar, diğer uygulamaların içeriğini göremez
- **Daha iyi performans**: Doğrudan arabellek değişimi (direct buffer swap) ile daha az gecikme
- **Daha iyi HiDPI**: Her ekran için bağımsız ölçekleme
- **Daha iyi dokunmatik**: Çoklu dokunmatik hareketler için yerel destek
- **Daha iyi VRR**: Değişken yenileme hızı (FreeSync/Adaptive Sync) desteği

### Wayland Sınırlamaları

- **Ekran yakalama**: Bazı uygulamalar (OBS Studio, Discord paylaşımı) Wayland'de ekstra yapılandırma gerektirebilir. `xdg-desktop-portal` ve `pipewire` kurulu olmalıdır.
- **Uzak masaüstü**: X11'e göre daha az olgun, `wayvnc` veya `gnome-remote-desktop` alternatif olarak kullanılabilir.
- **Klavye kısayolları**: X11'deki bazı gelişmiş klavye kısayolları Wayland'de sınırlandırılmıştır (güvenlik nedeniyle).

X11 desteği mevcuttur ancak sınırlıdır ve bazı efektler çalışmayabilir. X11 oturumu seçmek için SDDM'de "Karya (X11)" seçeneğini kullanın.

## Güvenlik açığı bildirimi nasıl yapılır?

Lütfen `SECURITY.md` dosyasını okuyun. Kritik güvenlik açıklarını doğrudan GitHub Issues'a açmak yerine, e-posta veya güvenli iletişim kanalları üzerinden bildirin.

### Güvenlik Açığı Raporlama Süreci

1. **Keşif**: Bir güvenlik açığı bulduğunuzda, öncelikle bunun Karya DE ile ilgili olduğundan emin olun.
2. **Bildirim**: Güvenlik açığını doğrudan GitHub Issues'a açmak yerine `muhammetodosks@gmail.com` adresine e-posta gönderin. Konu satırına `[GÜVENLİK]` ekleyin.
3. **Doğrulama**: Ekibimiz, bildiriminizi aldıktan sonra 48 saat içinde size yanıt verir ve açığı doğrulamak için sizinle iletişime geçer.
4. **Düzeltme**: Açık doğrulandıktan sonra, bir yama hazırlanır ve test edilir. Kritik açıklar için yama 7 gün içinde yayınlanır.
5. **Açıklama**: Yama yayınlandıktan sonra, güvenlik açığı kamuoyuna duyurulur ve raporlayan kişiye teşekkür edilir.

### Güvenlik Politikası Kapsamı

Aşağıdaki bileşenler güvenlik politikamız kapsamındadır:
- KWin pencere yöneticisi (kwin-karya)
- Panel sistemi
- OOBE (ilk açılış deneyimi)
- Donanım algılama script'leri
- Sistem genelinde çalışan Python uygulamaları

Aşağıdakiler güvenlik politikamızın DIŞINDADIR:
- Web tarayıcıları (Firefox, Chromium)
- Üçüncü parti uygulamalar
- Linux çekirdeği
- SDDM giriş yöneticisi

## Karya DE ticari kullanıma uygun mu?

Evet. GPLv2 lisansı ticari kullanıma izin verir. Kurumsal ortamlarda kullanılabilir, özelleştirilebilir ve dağıtılabilir. Ancak, ticari destek şu anda resmi olarak sunulmamaktadır.

### Ticari Kullanım Senaryoları

- **Kurumsal masaüstü**: Şirket içi bilgisayarlarda standart masaüstü ortamı olarak kullanılabilir.
- **Özelleştirilmiş dağıtım**: Karya DE'yi çatallayarak kendi markanızla dağıtabilirsiniz.
- **Eğitim kurumları**: Okullar ve üniversitelerde bilgisayar laboratuvarlarında kullanılabilir.
- **Devlet kurumları**: Kamu kurumlarında yerli masaüstü ortamı olarak tercih edilebilir.
- **Gömülü sistemler**: Otomasyon, dijital tabela ve ATM gibi özel amaçlı sistemlerde kullanılabilir.

Ticari kullanım için daha esnek lisanslama seçenekleri (LGPL veya özel lisans) için doğrudan iletişime geçebilirsiniz.

## ISO kalıbı var mı?

Evet. Karya DE, Calamares yükleyicisi ile birlikte gelen bir Arch Linux tabanlı ISO kalıbına sahiptir. ISO'yu derlemek için:

```bash
make iso
```

Bu komut, `iso/` dizininde önyüklenebilir bir ISO kalıbı oluşturur. ISO, Calamares grafik yükleyici, Karya DE ve tüm bileşenleri içerir.

### ISO Oluşturma Gereksinimleri

- **archiso** paketi kurulu olmalı (`sudo pacman -S archiso`)
- En az 10 GB boş disk alanı
- En az 4 GB RAM
- root yetkisi

### ISO'yu USB'ye Yazma

```bash
# ISO'yu oluştur
make iso

# USB'ye yaz (sdX yerine kendi USB cihazınızı yazın)
dd if=iso/releng/out/karya-de-1.0.0-x86_64.iso of=/dev/sdX bs=4M status=progress

# Alternatif: Rufus (Windows) veya Balena Etcher (tüm platformlar)
```

ISO kalıbı şunları içerir:
- Arch Linux tabanı (6.6 LTS çekirdek)
- Karya DE 1.0.0
- Ön yüklenmiş uygulamalar (Firefox, LibreOffice, VLC, GIMP)
- Calamares grafik yükleyici
- Karya SDDM teması
- NVIDIA ve AMD sürücüleri
- PipeWire ses altyapısı

## Özel tema oluşturabilir miyim?

Evet. Karya DE, tema paketlerini destekler. Tema oluşturmak için:

1. `packages/templates/theme/` dizinini kopyalayın
2. Renkleri, duvar kağıtlarını ve stilleri değiştirin
3. `make theme` ile temayı paketleyin

Tema formatı ve API dokümantasyonu için `docs/theming.md` dosyasına bakın.

### Tema Bileşenleri

Bir Karya teması şu bileşenlerden oluşur:

```yaml
theme:
  name: "Tema Adı"          # Tema adı (benzersiz olmalı)
  version: "1.0.0"          # Tema sürümü
  author: "Adınız"           # Tema yazarı
  description: "Açıklama"    # Kısa açıklama
  
  colors:                     # Renk paleti (hex)
    primary: "#3B82F6"       # Ana renk
    secondary: "#8B5CF6"     # İkincil renk
    accent: "#F59E0B"        # Vurgu rengi
    background: "#1E1E2E"    # Arka plan
    surface: "#2D2D3F"      # Yüzey
    text: "#CDD6F4"          # Metin rengi
  
  fonts:                     # Yazı tipleri
    default: "Inter"         # Varsayılan yazı tipi
    monospace: "JetBrains Mono" # Monospace yazı tipi
    size: 10                 # Varsayılan punto
  
  wallpaper:                 # Duvar kağıdı
    path: "wallpaper.jpg"    # Dosya yolu (1920x1080 önerilir)
    mode: "fill"             # cover, fill, fit, tile, center
  
  icons:                     # İkon teması
    inherit: "karya-icons"   # Üst tema
    override:                # Geçersiz kılınan ikonlar
      - name: "folder"       # İkon adı
        path: "icons/folder.svg"
```

Tema dosyaları `~/.local/share/karya/themes/` dizinine veya sistem geneli için `/usr/share/karya/themes/` dizinine yerleştirilir.

### Topluluk Temaları

Kullanıcılar tarafından oluşturulmuş temaları GitHub Issues veya topluluk sayfamızda paylaşabilirsiniz. Gelecekteki sürümlerde tema mağazası eklenecektir.

## Karya DE'yi VM'de test edebilir miyim?

Evet. Karya VM görüntüsü (`karya-vm.qcow2`) doğrudan QEMU ile kullanılabilir:

```bash
make vm
```

Bu komut, VM'yi otomatik olarak başlatır. SSH üzerinden VM'e bağlanmak için:

```bash
make vm-ssh
```

VM, varsayılan olarak 2 CPU, 4 GB RAM ve 20 GB disk ile yapılandırılmıştır.

### VM Yapılandırma Detayları

| Parametre | Değer |
|-----------|-------|
| CPU | 2 çekirdek (host-passthrough) |
| RAM | 4 GB |
| Disk | 20 GB (qcow2, dinamik) |
| GPU | VirtIO (3D hızlandırmalı) |
| Ses | Intel HDA |
| Ağ | VirtIO (NAT) |
| Port yönlendirme | 2222 (SSH) → 22 |
| VNС | 5900 |
| Ön yüklü yazılım | Karya DE + araçlar |

VM'yi manuel başlatmak için:

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 2 \
  -m 4096 \
  -drive file=karya-vm.qcow2,format=qcow2 \
  -vga virtio \
  -display gtk \
  -soundhw hda \
  -net user,hostfwd=tcp::2222-:22 \
  -net nic
```

## Ses çalışmıyor, ne yapmalıyım?

Karya DE, PipeWire ses sunucusunu kullanır. Kontrol listesi:

1. PipeWire kurulu mu? `pacman -Qs pipewire`
2. PipeWire servisi çalışıyor mu? `systemctl --user status pipewire`
3. Ses seviyesi açık mı? `wpctl status`
4. Doğru çıkış cihazı seçili mi? `wpctl set-default <ID>`

Eğer hâlâ ses gelmiyorsa, `karya-settings` panelinden ses ayarlarını kontrol edin veya terminalden `alsamixer` çalıştırın.

### Ses Sorun Giderme Rehberi

**Hiç ses yok:**
```bash
# PipeWire durumunu kontrol et
systemctl --user status pipewire pipewire-pulse

# Gerekirse yeniden başlat
systemctl --user restart pipewire pipewire-pulse

# ALSA üzerinden test et
speaker-test -c 2 -l 1
```

**Kulaklık algılanmıyor:**
```bash
# Ses cihazlarını listele
wpctl status

# Çıkış cihazlarını listele
pactl list sinks

# Varsayılan çıkışı değiştir
wpctl set-default <ID>
```

**Mikrofon çalışmıyor:**
```bash
# Mikrofon seviyesini kontrol et
wpctl status | grep -i mic

# Mikrofonu etkinleştir
pactl set-source-mute @DEFAULT_SOURCE@ 0
```

**PipeWire kurulu değilse:**
```bash
# Arch Linux
sudo pacman -S pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber

# Ubuntu
sudo apt install pipewire pipewire-pulse wireplumber
```

### Ses Yönetimi Araçları

| Araç | Görev | Komut |
|------|-------|-------|
| wpctl | PipeWire ses kontrolü | `wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.5` |
| pactl | PulseAudio uyumluluk | `pactl list sinks short` |
| pw-cli | PipeWire CLI | `pw-cli info all` |
| pavucontrol | GUI ses kontrolü | `sudo pacman -S pavucontrol` |
| helvum | PipeWire grafik düzenleyici | `sudo pacman -S helvum` |

## Karya DE'yi kaldırmak istiyorum

```bash
# Arch Linux
sudo pacman -Rns karya-de-meta

# Ubuntu
sudo dpkg -r karya-de-meta

# İz bırakmadan kaldırma
sudo rm -rf /opt/karya-de /usr/lib/karya /etc/karya /usr/bin/karya-*
```

### Kaldırma Sonrası Temizlik

Karya DE'yi tamamen kaldırmak ve sisteminizi eski haline getirmek için:

```bash
# 1. Paketleri kaldır
sudo pacman -Rns karya-de-meta kwin-karya karya-drivers karya-icons 2>/dev/null || true

# 2. Kwin yapılandırmasını temizle
rm -rf ~/.config/kwin* ~/.local/share/kwin*

# 3. Karya yapılandırmasını temizle
rm -rf ~/.config/karya ~/.local/share/karya

# 4. Sistem dosyalarını temizle
sudo rm -rf /opt/karya-de /usr/lib/karya /etc/karya
sudo rm -f /usr/bin/karya-*
sudo rm -f /etc/profile.d/karya-env.sh /etc/profile.d/karya-oobe.sh

# 5. SDDM temasını kaldır
sudo rm -rf /usr/share/sddm/themes/karya-sddm
sudo rm -f /etc/sddm.conf.d/karya.conf

# 6. Session dosyasını kaldır
sudo rm -f /usr/share/wayland-sessions/karya.desktop
sudo rm -f /usr/bin/startplasma-karya
```

## Güncelleme nasıl yapılır?

```bash
# Arch Linux
sudo pacman -Syu

# Ubuntu
sudo apt update && sudo apt upgrade

# Kaynaktan
git pull
make build
make install
```

Güncellemeler haftalık olarak yayınlanır. Büyük sürümler (v1.x, v2.x) aylık olarak planlanmıştır.

### Güncelleme Politikası

- **Yamalar (v1.0.1 → v1.0.2)**: Hata düzeltmeleri ve küçük iyileştirmeler. Haftalık olarak yayınlanır. Geriye dönük tam uyumludur.
- **Orta sürüm (v1.0 → v1.1)**: Yeni özellikler ve API değişiklikleri. Aylık olarak yayınlanır. Büyük ölçüde geriye dönük uyumludur.
- **Büyük sürüm (v1 → v2)**: Kapsamlı değişiklikler, yeni mimari. Yılda 1-2 kez yayınlanır. Geriye dönük uyumluluk garanti edilmez.

### Güncelleme Notları

Güncellemeleri takip etmek için:

- **CHANGELOG.md**: Tüm sürüm notları bu dosyada listelenir
- **GitHub Releases**: Her sürüm için ayrıntılı release notları
- **E-posta bildirimi**: Büyük sürümler için e-posta listesi (yakında)

## Karya DE'nin gelecek planları nelerdir?

### Kısa Vade (v1.1 - v1.2)

1. **v1.1** (1-2 ay):
   - Bildirim yönetimi ve bildirim geçmişi
   - Ağ yöneticisi widget'ı (Wi-Fi, Bluetooth, VPN)
   - Tema mağazası (topluluk temaları)
   - Ekran yakalama aracı (karya-screenshot)
   - Klavye kısayol yöneticisi

2. **v1.2** (3-4 ay):
   - Sanal masaüstü yöneticisi (Pager widget)
   - Gelişmiş ayarlar paneli (tüm kategoriler)
   - Varsayılan terminal (karya-terminal)
   - Çoklu monitör iyileştirmeleri
   - Yerleşik ekran kaydı (karya-recorder)

### Orta Vade (v2.0)

3. **v2.0** (6-8 ay):
   - Eklenti sistemi (üçüncü parti eklenti desteği)
   - Paket yöneticisi entegrasyonu (GUI paket yöneticisi)
   - Dokunmatik ekran desteği (dokunmatik hareketler)
   - Kapsamlı erişilebilirlik desteği
   - Flatpak/AppImage entegrasyonu
   - Yeni tema motoru (CSS benzeri stil sistemi)

### Uzun Vade (v2.x+)

4. **Mobil cihazlar**: Karya Shell'in tablet ve mobil cihazlarda çalışacak hafif sürümü
5. **Uzak masaüstü**: Yerleşik VNC/RDP sunucusu
6. **Bulut entegrasyonu**: Nextcloud, Google Drive, OneDrive ile yerel entegrasyon
7. **AI asistanı**: Yerel AI modeli ile akıllı masaüstü arama ve otomasyon
8. **Oyun modu**: Oyun performansını artırmak için özel profil

### Topluluk İstekleri

Karya DE'nin yol haritası, topluluk geri bildirimlerine göre şekillenir. Özellik isteklerinizi GitHub Issues üzerinde `[ÖNERİ]` etiketiyle paylaşabilirsiniz. En çok oy alan özellikler bir sonraki sürüme eklenir.

## Karya DE'yi kendi projemde kullanabilir miyim?

Evet. GPLv2 lisansı, Karya DE'yi kendi projelerinizde kullanmanıza izin verir. Ancak dikkat etmeniz gereken bazı noktalar vardır:

### Kendi Dağıtımınızda Karya DE

Karya DE'yi kendi Linux dağıtımınıza dahil etmek için:

1. **Paketleme**: Karya DE paketlerini kendi paket yöneticiniz için paketleyin
2. **Bağımlılıklar**: Qt6, KF6, Python 3.12+ ve PipeWire'in sisteminizde bulunduğundan emin olun
3. **SDDM**: SDDM giriş yöneticisini yapılandırın
4. **Wayland**: Wayland oturumunu etkinleştirin

### Ticari Ürünlerde Karya DE

Karya DE'yi ticari bir ürünün parçası olarak kullanıyorsanız:

- Kaynak kodunu açık tutmalısınız (GPLv2 şartı)
- Karya DE logolarını ve markasını kullanmak için izin almalısınız
- Ticari destek ve danışmanlık için iletişime geçebilirsiniz

## Nereden yardım alabilirim?

- **GitHub Issues**: Teknik sorunlar, hata bildirimleri ve özellik istekleri için
- **E-posta**: muhammetodosks@gmail.com — doğrudan iletişim için
- **Dokümantasyon**: `docs/` dizinindeki belgeler
- **Sıkça Sorulan Sorular**: Bu dosya (sorular.md)

### Yardım Almadan Önce

1. Bu SSS dosyasını okuyun (sorunuzun yanıtı burada olabilir)
2. GitHub Issues'da benzer bir sorun aratın
3. `docs/` dizinindeki dokümantasyonu inceleyin
4. Hata mesajlarını okuyun ve anlamaya çalışın

### Hata Bildirirken Şunları Belirtin

- İşletim sistemi ve sürümü
- Karya DE sürümü (`karya-settings → Hakkında`)
- Hatanın adım adım tekrarlanma şekli
- Hata çıktısı (terminal çıktısı veya log dosyası)
- Donanım bilgisi (GPU, RAM, CPU)

## Sık Karşılaşılan Hatalar ve Çözümleri

### KWin başlatılamıyor

**Belirti**: Masaüstü gelmiyor, siyah ekran kalıyor.

**Çözüm**:
```bash
# TTY'ye geçin (CTRL+ALT+F2)
# KWin'i el ile başlatmayı deneyin
kwin_wayland --exit
export KWIN_COMPOSE=QML
kwin_wayland &
```

### Panel görünmüyor

**Belirti**: Masaüstü açılıyor ama panel yok.

**Çözüm**:
```bash
# Panel log'larını kontrol et
journalctl -xe | grep karya-panel

# Panel'i el ile başlat
/usr/bin/karya-panel &

# Config dosyasını sıfırla
rm -rf ~/.config/karya/panel
```

### Uygulamalar açılmıyor

**Belirti**: Python uygulamaları (karya-calc, karya-notes) tıklanınca açılmıyor.

**Çözüm**:
```bash
# Terminalden çalıştırıp hata mesajını gör
karya-calc

# Eksik Python bağımlılıklarını kontrol et
pip3 list | grep PyQt6

# PYTHONPATH'i kontrol et
echo $PYTHONPATH
```

### GPU sürücü sorunu

**Belirti**: Düşük performans, ekran yırtılması, çökme.

**Çözüm**:
```bash
# Detaylı GPU bilgisi
sudo bash /usr/lib/karya/scripts/detect-hardware.sh --verbose

# Sürücüleri yeniden kur
sudo bash /usr/lib/karya/scripts/install-drivers.sh --force
```

### SDDM'de Karya oturumu görünmüyor

**Belirti**: SDDM'de sadece diğer masaüstü ortamları listeleniyor.

**Çözüm**:
```bash
# Session dosyasını kontrol et
ls -la /usr/share/wayland-sessions/karya.desktop

# Eksikse yeniden oluştur
sudo install -Dm644 /opt/karya-de/shell/sessions/karya.desktop /usr/share/wayland-sessions/karya.desktop
sudo install -Dm755 /opt/karya-de/shell/sessions/startplasma-karya /usr/bin/startplasma-karya
```

### Karya DE çok yavaş

**Belirti**: Genel sistem yavaşlığı, pencere açılışlarında gecikme.

**Çözüm**:
```bash
# Sistem kaynaklarını kontrol et
htop

# GPU hızlandırmayı kontrol et
glxinfo | grep -i "renderer\|vendor"

# Gereksiz efektleri kapat
kwriteconfig6 --file ~/.config/kwinrc --group Compositing --key Enabled false
qdbus-qt6 org.kde.KWin /Compositor suspend
```