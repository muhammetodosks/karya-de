# Karya DE — Sıkça Sorulan Sorular

## Karya DE nedir?

Karya DE, sıfırdan inşa edilmiş modern bir Türk masaüstü ortamıdır. Qt6 ve KDE Framework teknolojileri üzerine kuruludur ancak **KDE Plasma değildir**. Karya DE kendi pencere yöneticisi (kwin-karya), kendi panel sistemi, kendi widget koleksiyonu ve kendi tema altyapısıyla tamamen bağımsız bir masaüstü ortamıdır. Amacı, dağıtımdan bağımsız çalışabilen, hafif, hızlı ve modern bir Türkçe masaüstü deneyimi sunmaktır.

## Karya DE, KDE Plasma'nın bir çatallaşması mı?

Hayır. Karya DE, KDE teknolojilerini (KWin, KF6, Qt6) alt yapı olarak kullanır ancak üst katmanda tamamen özgün bir yapıya sahiptir. KWin pencere yöneticisi çatallanmış ve Karya DE'ye özel olarak değiştirilmiştir (kwin-karya). Panel sistemi, widget'lar, temalar, OOBE, ses yönetimi ve uygulamalar sıfırdan yazılmıştır. Kısacası: motor aynı ama gövde, kaporta ve iç tasarım tamamen farklıdır.

## Hangi dağıtımlar destekleniyor?

Resmi olarak desteklenenler:

- **Arch Linux** (ve tabanlı dağıtımlar: EndeavourOS, Arco Linux, Manjaro)
- **Artix Linux** (systemd'siz, runit-init ile)
- **Ubuntu 24.04 (Noble) ve üzeri**

Diğer dağıtımlarda kaynaktan derleme yapabilirsiniz. Bunun için `make setup && make build && make install` komutlarını kullanabilirsiniz. Fedora, Debian Testing ve openSUSE Tumbleweed'de de çalıştığı bildirilmiştir ancak resmi destek yoktur.

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

## Karya DE hangi GPU'ları destekliyor?

- **AMD** (amdgpu): Tam destek. Açık kaynak sürücü kutudan çıkar.
- **NVIDIA** (nouveau ve propriyeter): Destekleniyor. Propriyeter sürücü için `nvidia-dkms` ve `nvidia-utils` paketleri kurulmalıdır.
- **Intel** (i915): Deneysel destek. Bazı Intel GPU'larda (özellikle 12. nesil öncesi) KWin hata verebilir.
- **VM**: QEMU/KVM (virtio), VMware, VirtualBox'ta test edilmiştir.

Donanım algılama otomatiktir: `bash /usr/lib/karya/scripts/detect-hardware.sh` ile sürücü seçimi yapılır.

## Karya DE'nin sistem gereksinimleri nelerdir?

| Bileşen | Minimum | Önerilen |
|---------|---------|----------|
| CPU | 2 çekirdek @ 2.0 GHz | 4+ çekirdek @ 2.5 GHz |
| RAM | 2 GB | 4+ GB |
| Disk | 5 GB | 10+ GB (SSD önerilir) |
| GPU | OpenGL 3.3 destekli | Vulkan 1.2+ destekli |
| Ekran | 1280x720 | 1920x1080+ |

Karya DE, KDE Plasma'dan yaklaşık %30 daha az RAM kullanır. Boşta ~400-600 MB arası bellek tüketimi hedeflenmiştir.

## Hangi uygulamalar geliyor?

Karya DE ile birlikte gelen ilk parti uygulamalar:

- **karya-calc**: Basit ama şık hesap makinesi (Python/PyQt6)
- **karya-notes**: Hızlı not alma uygulaması
- **karya-search**: Masaüstü arama (krunner alternatifi)
- **karya-settings**: Ayarlar paneli
- **karya-oobe**: İlk açılış deneyimi (karşılama sihirbazı)
- **karya-widgets**: Masaüstü widget koleksiyonu
- **karya-icons**: Özel ikon teması
- **karya-drivers**: Donanım yönetimi araçları

## Nasıl katkıda bulunabilirim?

1. **Hata bildirimi**: GitHub Issues sayfasından hata raporu açın.
2. **Kod katkısı**: Pull request göndermeden önce `CONTRIBUTING.md` dosyasını okuyun.
3. **Çeviri**: `localization/` dizinindeki çeviri dosyalarına katkıda bulunun.
4. **Tema/paket**: Kendi tema veya paketinizi `packages/` dizini altına ekleyin.
5. **Dokümantasyon**: README, wiki veya dokümantasyon dosyalarını iyileştirin.

## Hangi lisansı kullanıyor?

Karya DE, **GNU Genel Kamu Lisansı v2.0 (GPLv2)** ile lisanslanmıştır. Alt bileşenler (widget'lar, uygulamalar) aksi belirtilmediği sürece aynı lisansı taşır. KWin çatalı olan kwin-karya, orijinal KWin lisansı olan GPLv2+ ile uyumludur.

## Karya DE stabil mi?

Sürüm 1.0.0 itibarıyla temel masaüstü işlevleri (pencere yönetimi, panel, widget'lar, oturum yönetimi) kararlıdır. Günlük kullanım için uygundur. Hâlâ geliştirme aşamasında olan özellikler:

- Kapsamlı ayarlar paneli (şu anda temel ayarlar mevcut)
- Ağ yönetimi widget'ı (şu anda sistem tepsisinden yapılıyor)
- Bildirim geçmişi
- Sanal masaüstü yöneticisi
- Kapsamlı tema mağazası

## NVIDIA Optimus (hibrit grafik) destekleniyor mu?

Evet. Karya DE, NVIDIA Optimus sistemlerde `prime-run` veya `nvidia-prime` ile çalışabilir. Otomatik GPU seçimi için `karya-drivers` bileşeni kullanılır. Kurulum sırasında `nvidia-prime` ve `optimus-manager` desteklenir.

## Wayland mi X11 mi?

Karya DE, **öncelikli olarak Wayland** üzerinde çalışır. X11 desteği sınırlıdır ve bazı efektler çalışmayabilir. Wayland oturumu, daha iyi güvenlik, daha iyi performans ve daha iyi yüksek çözünürlük (HiDPI) desteği sunar.

## Güvenlik açığı bildirimi nasıl yapılır?

Lütfen `SECURITY.md` dosyasını okuyun. Kritik güvenlik açıklarını doğrudan GitHub Issues'a açmak yerine, e-posta veya güvenli iletişim kanalları üzerinden bildirin.

## Karya DE ticari kullanıma uygun mu?

Evet. GPLv2 lisansı ticari kullanıma izin verir. Kurumsal ortamlarda kullanılabilir, özelleştirilebilir ve dağıtılabilir. Ancak, ticari destek şu anda resmi olarak sunulmamaktadır.

## ISO kalıbı var mı?

Evet. Karya DE, Calamares yükleyicisi ile birlikte gelen bir Arch Linux tabanlı ISO kalıbına sahiptir. ISO'yu derlemek için:

```bash
make iso
```

Bu komut, `iso/` dizininde önyüklenebilir bir ISO kalıbı oluşturur. ISO, Calamares grafik yükleyici, Karya DE ve tüm bileşenleri içerir.

## Özel tema oluşturabilir miyim?

Evet. Karya DE, tema paketlerini destekler. Tema oluşturmak için:

1. `packages/templates/theme/` dizinini kopyalayın
2. Renkleri, duvar kağıtlarını ve stilleri değiştirin
3. `make theme` ile temayı paketleyin

Tema formatı ve API dokümantasyonu için `docs/theming.md` dosyasına bakın.

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

## Ses çalışmıyor, ne yapmalıyım?

Karya DE, PipeWire ses sunucusunu kullanır. Kontrol listesi:

1. PipeWire kurulu mu? `pacman -Qs pipewire`
2. PipeWire servisi çalışıyor mu? `systemctl --user status pipewire`
3. Ses seviyesi açık mı? `wpctl status`
4. Doğru çıkış cihazı seçili mi? `wpctl set-default <ID>`

Eğer hâlâ ses gelmiyorsa, `karya-settings` panelinden ses ayarlarını kontrol edin veya terminalden `alsamixer` çalıştırın.

## Karya DE'yi kaldırmak istiyorum

```bash
# Arch Linux
sudo pacman -Rns karya-de-meta

# Ubuntu
sudo dpkg -r karya-de-meta

# İz bırakmadan kaldırma
sudo rm -rf /opt/karya-de /usr/lib/karya /etc/karya
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

## Karya DE'nin gelecek planları nelerdir?

1. **v1.1**: Bildirim yönetimi, ağ yöneticisi widget'ı, tema mağazası
2. **v1.2**: Sanal masaüstü yöneticisi, gelişmiş ayarlar, ekran yakalama
3. **v2.0**: Eklenti sistemi, paket yöneticisi entegrasyonu, dokunmatik ekran desteği
4. **Uzun vadeli**: Mobil cihazlar için Karya Shell, uzak masaüstü, bulut entegrasyonu

## Nereden yardım alabilirim?

- **GitHub Issues**: Teknik sorunlar için
- **E-posta**: muhammetodosks@gmail.com
- **Dokümantasyon**: `docs/` dizinindeki belgeler
