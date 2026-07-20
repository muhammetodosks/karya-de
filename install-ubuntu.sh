#!/bin/bash
set -e

KARYA_VERSION="1.0.0"
KARYA_REPO="https://github.com/muhammetodosks/karya-de.git"
FORCE=0

for arg in "$@"; do
    case "$arg" in
        -y|--yes) FORCE=1 ;;
    esac
done

echo "========================================"
echo "  Karya DE v$KARYA_VERSION - Ubuntu Kurulum"
echo "========================================"

# Root kontrol
if [ "$EUID" -ne 0 ]; then
    echo "[!] Lutfen sudo ile calistirin:"
    echo "    curl -sL $KARYA_REPO/raw/master/install-ubuntu.sh | sudo bash"
    exit 1
fi

# Ubuntu versiyon kontrol
UBUNTU_VERSION=$(lsb_release -cs 2>/dev/null || echo "unknown")
echo "[*] Ubuntu: $(lsb_release -ds 2>/dev/null || echo 'Tespit edilemedi')"

if [ "$UBUNTU_VERSION" != "noble" ] && [ "$UBUNTU_VERSION" != "jammy" ]; then
    echo "[!] Uyari: Karya DE Ubuntu 24.04 (Noble) icin test edilmistir."
    if [ "$FORCE" -eq 0 ]; then
        echo "    Devam etmek icin -y argumanini kullanin:"
        echo "    curl -sL ... | sudo bash -s -- -y"
        echo "    Devam ediliyor (10sn)..."
        sleep 10
    fi
fi

echo ""
echo "[1/6] Paket kaynaklari guncelleniyor..."
apt update -qq

echo ""
echo "[2/6] Bagimliliklari kuruluyor..."
apt install -y -qq \
    git cmake build-essential pkg-config \
    qt6-base-dev qt6-declarative-dev qt6-wayland-dev qt6-shadertools-dev qt6-tools-dev \
    libkf6config-dev libkf6coreaddons-dev libkf6crash-dev libkf6dbusaddons-dev \
    libkf6declarative-dev libkf6globalaccel-dev libkf6guiaddons-dev libkf6i18n-dev \
    libkf6iconthemes-dev libkf6kio-dev libkf6itemmodels-dev libkf6itemviews-dev \
    libkf6package-dev libkf6service-dev libkf6widgetsaddons-dev libkf6windowsystem-dev \
    libkf6xmlgui-dev libkf6wayland-dev libkf6auth-dev libkf6idletime-dev libkf6svg-dev \
    libkf6newstuff-dev libkf6runner-dev libkf6notifications-dev libkf6doctools-dev \
    libkf6kirigami-dev libkf6plasma-dev libkf6screenlocker-dev \
    libkf6globalacceld-dev libplasma-activities-dev \
    extra-cmake-modules wayland-protocols plasma-wayland-protocols \
    libepoxy-dev libxcb-cursor-dev libxcb-keysyms1-dev \
    libxcb-util-dev libxcb-util-wm-dev libxcb-xrm-dev \
    libdrm-dev libinput-dev libei-dev libsystemd-dev \
    libvulkan-dev liblcms2-dev libhwdata-dev libcanberra-dev \
    libxkbcommon-dev libx11-dev libxcvt-dev libdisplay-info-dev \
    libevdev-dev libqaccessibilityclient-qt6-dev \
    python3-pyqt6 python3-pip 2>&1 | tail -3

echo ""
echo "[3/6] Karya DE kaynagi indiriliyor..."
git clone --depth=1 --branch "v$KARYA_VERSION" "$KARYA_REPO" /opt/karya-de 2>&1 | tail -1
cd /opt/karya-de

echo ""
echo "[4/6] KWin (pencere yoneticisi) derleniyor..."
# KWin fork'unu indir (PKGBUILD dizininde degil, kwin kaynaginda build et)
KWIN_VERSION="6.0.0"
git clone --depth=1 --branch "v$KWIN_VERSION" https://github.com/muhammetodosks/kwin.git /tmp/kwin-karya
cd /tmp/kwin-karya
# KF6 6.28+ uyumluluk yamasi
find . -name '*.kcfg' -exec sed -i 's|type="Enum"|type="Int"|' {} +
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF \
    -DKWIN_BUILD_KCMS=OFF \
    -DKWIN_BUILD_DECORATIONS=ON
cmake --build build --parallel "$(nproc)" 2>&1 | tail -5
DESTDIR=/ cmake --install build
cd /opt/karya-de

echo ""
echo "[5/6] Karya uygulamalari kuruluyor..."
for app in karya-calc karya-notes karya-search karya-settings; do
    if [ -d "/opt/karya-de/packages/$app" ]; then
        echo "  -> $app"
        install -Dm755 "/opt/karya-de/packages/$app/src/$app.py" "/usr/bin/$app"
        if [ -f "/opt/karya-de/packages/$app/$app.desktop" ]; then
            install -Dm644 "/opt/karya-de/packages/$app/$app.desktop" \
                "/usr/share/applications/$app.desktop"
        fi
    fi
done

echo ""
echo "[6/6] Kurulum tamamlaniyor..."
# Session dosyasi
install -Dm644 /opt/karya-de/shell/sessions/karya.desktop /usr/share/wayland-sessions/karya.desktop
install -Dm755 /opt/karya-de/shell/sessions/startplasma-karya /usr/bin/startplasma-karya
install -Dm644 /opt/karya-de/shell/sessions/karya.env /etc/profile.d/karya.env

# Layout dosyalari
install -Dm644 /opt/karya-de/shell/layouts/karya-dock.layout.lua \
    /usr/share/plasma/layout-templates/org.karya.karya-dock/contents/layout.lua
install -Dm644 /opt/karya-de/shell/layouts/karya-panel-top.layout.lua \
    /usr/share/plasma/layout-templates/org.karya.karya-panel-top/contents/layout.lua

# OOBE - copy package directly (no setup.py needed)
install -d /usr/lib/karya/oobe/services
cp /opt/karya-de/packages/karya-oobe/src/karya-oobe.py /usr/bin/karya-oobe
chmod 755 /usr/bin/karya-oobe
cp /opt/karya-de/packages/karya-oobe/src/services/*.py /usr/lib/karya/oobe/services/
# Ensure PYTHONPATH includes OOBE services
mkdir -p /etc/profile.d
echo 'export PYTHONPATH=/usr/lib/karya/oobe:$PYTHONPATH' > /etc/profile.d/karya-oobe.sh
chmod 644 /etc/profile.d/karya-oobe.sh

# SDDM temasi
if [ -d /opt/karya-de/sddm-theme ]; then
    cp -r /opt/karya-de/sddm-theme/karya-sddm /usr/share/sddm/themes/ 2>/dev/null || true
    mkdir -p /etc/sddm.conf.d
    echo "[Theme]" > /etc/sddm.conf.d/karya.conf
    echo "Current=karya-sddm" >> /etc/sddm.conf.d/karya.conf
fi

echo ""
echo "========================================"
echo "  Karya DE v$KARYA_VERSION KURULDU!"
echo "========================================"
echo "  Yeniden baslatin ve SDDM'de 'Karya'"
echo "  oturumunu secin."
echo ""
echo "  sudo reboot"
echo "========================================"
