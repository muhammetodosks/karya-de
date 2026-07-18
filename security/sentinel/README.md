# Karya Sentinel - 7/24 Derin Guvenlik Tarama ve Yama Sistemi

**Karya Sentinel**, Karya DE'nin guvenlik bel kemiğidir.
ASLA DURMAZ. Sadece kur, belirli bir saat ver ve birak. Gerisini o halleder.

## Felsefe

```
"Belirli bir saat veriyorsun ama 7/24 calisiyor. Her zaman senin.
 Sadece kur, birak, belirli saat veriyorsun. Her seyi derin tarama
 yapip hemen yamaliyor."
```

- **Sen belirle** → Sadece derin taramanin ne zaman baslayacagini soylersin
- **O calisir** → 7/24 surekli kalkan, hic durmaz
- **O tarar** → Dosya, proses, port, rootkit, config, CVE... HER SEY
- **O yamalar** → Acik bulursa BEKLEMEZ, HEMEN YAMALAR

## Mimarı

### FAZ 1: Surekli Kalkan (7/24 - Hic Durmaz)

| Denetim | Ne Yapar? |
|---------|-----------|
| Dosya Butunlugu | Kritik sistem dosyalarinin hash'ini kontrol eder |
| Proses Anomali | VNC, reverse shell, pipe-through-shell tespit eder |
| Ag Port | Supheli port dinlemelerini yakalar |
| SUID/SGID | Anormal SUID binary sayisini tespit eder |
| Kullanici | Root UID'li hesaplari ve bombos sifreleri bulur |
| /tmp /dev/shm | Herkese acik dosyalari denetler |

### FAZ 2: Derin Tarama (Kullanici Belirtilen Saatte)

| Denetim | Ne Yapar? |
|---------|-----------|
| Paket Denetimi | Arch Linux paketlerini CVE bazli tarar |
| Rootkit | Bilinen rootkit imzalari + gizli proses tespiti |
| Port Tarama | Acik portlari ve servislerini analiz eder |
| Config Denetim | AppArmor, sysctl, ASLR, core dump kontrolu |
| Sifre Politikasi | Sifresiz kullanicilari bulur |
| Kernel | Tainted kernel, eksik mitigasyon kontrolu |
| Dosya Sistemi | World-writable dosya taramasi |
| SSH | Root login, parola ile giris kontrolu |

### FAZ 3: Otomatik Yama (Hemen, Beklemeden)

| Yama | Ne Yapar? |
|------|-----------|
| AppArmor | Eksik profilleri yukler |
| Sysctl | Guvenlik ayarlarini uygular |
| /tmp | noexec,nosuid,nodev remount |
| /dev/shm | noexec,nosuid,nodev remount |
| Kritik Paket | CVSS 9.0+ paketleri otomatik gunceller |
| Dosya Izni | World-writable dosyalari kapatir |
| ASLR | Eksikse acar |

## Kurulum

### 1. Sentinel'i yukle

```bash
sudo cp security/sentinel/karya-sentinel.sh /usr/lib/karya/scripts/
sudo chmod +x /usr/lib/karya/scripts/karya-sentinel.sh
sudo cp security/sentinel/karya-sentinel.conf /etc/karya/sentinel.conf
```

### 2. Servis olarak baslat (runit)

```bash
sudo cp -r security/sentinel/runit/karya-sentinel /etc/runit/sv/
sudo ln -s /etc/runit/sv/karya-sentinel /etc/runit/runsvdir/default/
```

### 3. Veya systemd ile

```bash
sudo cp security/sentinel/karya-sentinel.service /etc/systemd/system/
sudo systemctl enable --now karya-sentinel
```

### 4. Veya manuel calistir

```bash
sudo /usr/lib/karya/scripts/karya-sentinel.sh start
```

## Kullanim

```bash
# Durum kontrol
karya-sentinel status

# Tek seferlik tarama
karya-sentinel scan

# Alert log
karya-sentinel alerts

# Manuel yama
karya-sentinel patch

# Manuel derin tarama
karya-sentinel deep
```

## Guvenlik Notu

**Bu sistemin tarama saatleri PUBLIC degildir.**
Kullanici kendi ortaminda belirledigi saatte derin tarama baslar.
Ancak FAZ 1 (Surekli Kalkan) her zaman, 7/24, hic durmadan calisir.

---

*Karya Sentinel - Gorunmez ama her zaman orada.*
