#!/usr/bin/env bash
set -euo pipefail

#
# Karya DE - Systemd'siz Kurulum (elogind + runit)
# ==================================================
# Kullanim:
#   curl -sL https://github.com/muhammetodosks/karya-de/raw/master/install-nosystemd.sh | sudo bash
#   curl -sL ... | sudo bash -s -- -y     # soru sormadan
#
# Hedef:  systemd olmayan Arch tabanli dagitimlar (Artix, Arco, vb.)
# Init:   runit + elogind
#

VERSION="1.0.0"
REPO_OWNER="muhammetodosks"
REPO_NAME="karya-de"
GITHUB="https://github.com/$REPO_OWNER/$REPO_NAME"
FORCE=0

for arg in "$@"; do
    case "$arg" in
        -y|--yes) FORCE=1 ;;
    esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║   Karya DE v$VERSION — SYSTEMD'SIZ KURULUM  ║"
echo "║   Init: elogind + runit                    ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Root kontrol
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[!] Root yetkisi gerekli.${NC}"
    echo "  curl -sL $GITHUB/raw/master/install-nosystemd.sh | sudo bash"
    exit 1
fi

# systemd kontrol — sistemde systemd varsa uyar
if command -v systemctl &>/dev/null && systemctl is-system-running &>/dev/null 2>&1; then
    echo -e "${YELLOW}[!] Bu sistemde systemd calisiyor.${NC}"
    echo "  Bu script systemd'siz dagitimlar icindir (Artix Linux vb.)."
    echo "  systemd'li sistemde standart kurulumu kullanin:"
    echo "    curl -sL $GITHUB/raw/master/install.sh | sudo bash"
    echo ""
    if [ "$FORCE" -eq 1 ]; then
        echo -e "  ${YELLOW}[-y] Devam ediliyor...${NC}"
    else
        echo -e "  ${YELLOW}Devam ediliyor (10sn)...${NC}"
        sleep 10
    fi
fi

# Paket yoneticisi kontrol
if ! command -v pacman &>/dev/null; then
    echo -e "${RED}[!] Bu script yalnizca pacman tabanli dagitimlar icindir.${NC}"
    echo "  Ubuntu icin: curl -sL $GITHUB/raw/master/install-ubuntu.sh | sudo bash"
    exit 1
fi

# ============================================================
echo ""
echo -e "${GREEN}[1/7] Sistem guncelleniyor...${NC}"
pacman -Syu --noconfirm

# ============================================================
echo -e "${GREEN}[2/7] runit + elogind kuruluyor...${NC}"

# runit kur (systemd'siz sistemde zaten yoksa)
if ! command -v runsvdir &>/dev/null; then
    pacman -S --noconfirm runit runit-rc
fi

# elogind kur (systemd-logind yerine)
if ! command -v elogind &>/dev/null && [ ! -f /usr/lib/elogind/elogind ]; then
    pacman -S --noconfirm elogind
fi

# Servis dizinleri
mkdir -p /etc/runit/sv

# elogind runit servisi
if [ ! -f /etc/runit/sv/elogind/run ]; then
    mkdir -p /etc/runit/sv/elogind
    cat > /etc/runit/sv/elogind/run << 'SVCE'
#!/bin/sh
exec /usr/lib/elogind/elogind
SVCE
    chmod +x /etc/runit/sv/elogind/run
    ln -sf /etc/runit/sv/elogind /etc/runit/runsvdir/default/
fi

# NetworkManager runit servisi
if [ ! -f /etc/runit/sv/NetworkManager/run ]; then
    mkdir -p /etc/runit/sv/NetworkManager
    cat > /etc/runit/sv/NetworkManager/run << 'SVCNM'
#!/bin/sh
exec /usr/bin/NetworkManager --no-daemon
SVCNM
    chmod +x /etc/runit/sv/NetworkManager/run
    ln -sf /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default/
fi

# PipeWire runit servisi
if [ ! -f /etc/runit/sv/pipewire/run ]; then
    mkdir -p /etc/runit/sv/pipewire
    cat > /etc/runit/sv/pipewire/run << 'SVCPW'
#!/bin/sh
exec /usr/bin/pipewire
SVCPW
    chmod +x /etc/runit/sv/pipewire/run
    ln -sf /etc/runit/sv/pipewire /etc/runit/runsvdir/default/
fi

# pipewire-pulse
if [ ! -f /etc/runit/sv/pipewire-pulse/run ]; then
    mkdir -p /etc/runit/sv/pipewire-pulse
    cat > /etc/runit/sv/pipewire-pulse/run << 'SVCPWP'
#!/bin/sh
exec /usr/bin/pipewire-pulse
SVCPWP
    chmod +x /etc/runit/sv/pipewire-pulse/run
    ln -sf /etc/runit/sv/pipewire-pulse /etc/runit/runsvdir/default/
fi

# Karya sentinel runit servisi
mkdir -p /etc/runit/sv/karya-sentinel
cat > /etc/runit/sv/karya-sentinel/run << 'SVCKS'
#!/bin/sh
# Karya DE sentinel — ilk calistirmada OOBE'yi baslatir
if [ ! -f /etc/karya/.oobe-complete ]; then
    exec /usr/bin/karya-oobe
fi
exec sleep infinity
SVCKS
chmod +x /etc/runit/sv/karya-sentinel/run
ln -sf /etc/runit/sv/karya-sentinel /etc/runit/runsvdir/default/

# ============================================================
echo -e "${GREEN}[3/7] Karya DE bagimliliklari kuruluyor...${NC}"
pacman -S --noconfirm --needed \
    qt6-base qt6-declarative qt6-wayland qt6-tools \
    kconfig kcoreaddons ki18n kio kservice kwindowsystem kwayland \
    extra-cmake-modules wayland-protocols \
    cmake python python-pip python-pyqt6 \
    jq pciutils git curl

# ============================================================
echo -e "${GREEN}[4/7] KWin (pencere yoneticisi) derleniyor...${NC}"
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

git clone --depth=1 --branch "v6.0.0" https://github.com/muhammetodosks/kwin.git kwin-src
cd kwin-src

# KF6 6.28+ uyumluluk yamasi
find . -name '*.kcfg' -exec sed -i 's|type="Enum"|type="Int"|' {} +

cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF \
    -DKWIN_BUILD_KCMS=OFF \
    -DKWIN_BUILD_DECORATIONS=ON

cmake --build build --parallel "$(nproc)"
DESTDIR=/ cmake --install build
cd /
rm -rf "$TEMP_DIR"

# ============================================================
echo -e "${GREEN}[5/7] Karya uygulamalari kuruluyor...${NC}"
TEMP_SRC=$(mktemp -d)
git clone --depth=1 --branch "v$VERSION" "$GITHUB" "$TEMP_SRC/karya-de"

for app in karya-calc karya-notes karya-search karya-settings; do
    echo "  -> $app"
    if [ -f "$TEMP_SRC/karya-de/packages/$app/src/$app.py" ]; then
        install -Dm755 "$TEMP_SRC/karya-de/packages/$app/src/$app.py" "/usr/bin/$app"
    fi
    if [ -f "$TEMP_SRC/karya-de/packages/$app/$app.desktop" ]; then
        install -Dm644 "$TEMP_SRC/karya-de/packages/$app/$app.desktop" \
            "/usr/share/applications/$app.desktop"
    fi
done

# OOBE
install -Dm755 "$TEMP_SRC/karya-de/packages/karya-oobe/src/karya-oobe.py" /usr/bin/karya-oobe
install -d /usr/lib/karya/oobe/services
if [ -d "$TEMP_SRC/karya-de/packages/karya-oobe/src/services" ]; then
    cp "$TEMP_SRC/karya-de/packages/karya-oobe/src/services/"*.py /usr/lib/karya/oobe/services/
fi
echo 'export PYTHONPATH=/usr/lib/karya/oobe:$PYTHONPATH' > /etc/profile.d/karya-oobe.sh
chmod 644 /etc/profile.d/karya-oobe.sh

# Donanim scriptleri
if [ -d "$TEMP_SRC/karya-de/hardware/scripts" ]; then
    install -d /usr/lib/karya/scripts
    cp "$TEMP_SRC/karya-de/hardware/scripts/"*.sh /usr/lib/karya/scripts/
    chmod +x /usr/lib/karya/scripts/*.sh
fi

# Session dosyalari
install -Dm644 "$TEMP_SRC/karya-de/shell/sessions/karya.desktop" \
    /usr/share/wayland-sessions/karya.desktop
install -Dm755 "$TEMP_SRC/karya-de/shell/sessions/startplasma-karya" \
    /usr/bin/startplasma-karya
install -Dm644 "$TEMP_SRC/karya-de/shell/sessions/karya.env" \
    /etc/profile.d/karya.env

# SDDM temasi
if [ -d "$TEMP_SRC/karya-de/sddm-theme/karya-sddm" ]; then
    cp -r "$TEMP_SRC/karya-de/sddm-theme/karya-sddm" /usr/share/sddm/themes/
    mkdir -p /etc/sddm.conf.d
    echo "[Theme]" > /etc/sddm.conf.d/karya.conf
    echo "Current=karya-sddm" >> /etc/sddm.conf.d/karya.conf
fi

rm -rf "$TEMP_SRC"

# ============================================================
echo -e "${GREEN}[6/7] Donanim algilaniyor...${NC}"
if [ -f /usr/lib/karya/scripts/detect-hardware.sh ]; then
    bash /usr/lib/karya/scripts/detect-hardware.sh 2>/dev/null || true
fi

# ============================================================
echo -e "${GREEN}[7/7] Temizlik yapiliyor...${NC}"
mkdir -p /etc/karya
touch /etc/karya/.oobe-ready

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Karya DE v$VERSION SYSTEMD'SIZ KURULDU!   ║${NC}"
echo -e "${GREEN}║  Init: elogind + runit                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Servisleri baslat:${NC}"
echo "    sudo runsvdir /etc/runit/runsvdir/default &"
echo ""
echo -e "  ${CYAN}SDDM'yi baslat:${NC}"
echo "    sudo sddm &"
echo ""
echo -e "  ${CYAN}Yeniden baslat:${NC}"
echo "    sudo reboot"
echo ""
echo -e "  ${CYAN}Detayli init kurulumu:${NC}"
echo "    $GITHUB/blob/master/docs/runit-setup.md"
echo ""
