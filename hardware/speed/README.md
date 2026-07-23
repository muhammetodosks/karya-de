# Karya SPEED

Karya DE'nin performans ayar sistemi. CPU, I/O, bellek, ağ, GPU, gecikme, depolama ve ısı yönetimini tek bir profille optimize eder.

## Kullanım

```
speed                     # Profilleri listele + durumu göster
speed performance         # Performans profiline geç
speed balanced            # Dengeli profile geç
speed powersave           # Güç tasarrufu profiline geç
speed status              # Mevcut durumu göster
speed daemon              # İzleme servisini başlat
```

## Profiller

| Profil | Amaç | Kullanım |
|--------|------|----------|
| performance | Maksimum performans, minimum gecikme | Masaüstü / Workstation / Oyun |
| balanced | Dengeli performans ve verimlilik | Dizüstü / Genel kullanım |
| powersave | Maksimum güç tasarrufu | Pil / Sessiz PC |

## Servisler (systemd)

```bash
systemctl enable --now karya-speed.service
```

## Bileşenler

- `profiles/` - Profil yapılandırma dosyaları (.conf)
- `tuners/` - Ayar uygulama scriptleri
- `speed.sh` - Ana CLI giriş noktası
- `udev/` - Udev kuralları (AC adaptörü algılama)
- `services/` - Systemd ve runit servisleri
