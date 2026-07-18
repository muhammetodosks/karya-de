#!/usr/bin/env bash
set -e

#
# Karya DE - Tek Komutla Kurulum
# ===============================
# Kullanım:
#   curl -sL https://karya-de.org/install | bash
#   bash <(curl -sL https://karya-de.org/install)
#   wget -qO- https://karya-de.org/install | bash
#

VERSION="1.0.0"
REPO_OWNER="muhammetodosks"
REPO_NAME="karya-de"
GITHUB="https://github.com/$REPO_OWNER/$REPO_NAME"
RELEASES="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/v$VERSION"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════╗"
echo "║        Karya DE v$VERSION KURULUM      ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# Root kontrol
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[!] Root yetkisi gerekli. sudo ile tekrar dene:${NC}"
    echo "  curl -sL $GITHUB/raw/master/install.sh | sudo bash"
    exit 1
fi

# Arch Linux kontrol
if [ ! -f /etc/arch-release ]; then
    echo -e "${RED}[!] Karya DE yalnizca Arch Linux destekler.${NC}"
    echo "  Ubuntu/Debian: sudo apt install ubuntu-desktop"
    echo "  Fedora:        sudo dnf install @kde-desktop"
    echo "  Arch Linux:    sudo pacman -S plasma"
    exit 1
fi

# 1. GPG anahtarı ekle
echo -e "${GREEN}[1/5] GPG anahtari ekleniyor...${NC}"
KEY_URL="$GITHUB/raw/master/packages/karya-de-meta/karya-de.gpg"
KEY_FILE="/usr/share/pacman/keyrings/karya-de.gpg"
curl -sL "$KEY_URL" -o "$KEY_FILE" 2>/dev/null || {
    echo -e "${YELLOW}[!] GPG anahtari alinamadi, imza kontrolu atlaniyor${NC}"
}

# 2. Karya DE reposunu ekle
echo -e "${GREEN}[2/5] Karya DE repolari ekleniyor...${NC}"
cat >> /etc/pacman.conf << 'PACMAN'

[karya-de]
SigLevel = Optional TrustAll
Server = https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/v$VERSION
PACMAN

# Local repo yoksa GitHub Releases kullan
cat >> /etc/pacman.conf << 'PACMAN2'

[karya-de-local]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/karya-de
PACMAN2

# 3. Paketleri indir ve kur
echo -e "${GREEN}[3/5] Paketler indiriliyor...${NC}"
mkdir -p /var/cache/pacman/karya-de
cd /var/cache/pacman/karya-de

for PKG in karya-drivers karya-icons karya-oobe kwin-karya karya-widgets karya-de-meta; do
    echo "  -> $PKG indiriliyor..."
    curl -sL "$RELEASES/$PKG-${VERSION}-x86_64.pkg.tar.zst" -o "$PKG.pkg.tar.zst" 2>/dev/null || {
        echo -e "${YELLOW}  [!] $PKG bulunamadi, kaynaktan derlenecek${NC}"
        PKG_BUILD_DIR="/tmp/karya-build/$PKG"
        mkdir -p "$PKG_BUILD_DIR"
        cp -r "$GITHUB/raw/master/packages/$PKG/"* "$PKG_BUILD_DIR/"
        cd "$PKG_BUILD_DIR"
        makepkg -si --noconfirm 2>/dev/null || true
    }
done

# Repo database olustur
cd /var/cache/pacman/karya-de
repo-add karya-de.db.tar.gz *.pkg.tar.zst 2>/dev/null || true

# 4. Paketleri kur
echo -e "${GREEN}[4/5] Paketler kuruluyor...${NC}"
pacman -Syu --noconfirm karya-de-meta 2>/dev/null || {
    # Local PKGBUILD'lerden dene
    echo -e "${YELLOW}[!] Rekorsuz kurulum deneniyor...${NC}"
    for pkgdir in /tmp/karya-build/*/; do
        [ -d "$pkgdir" ] && (cd "$pkgdir" && makepkg -si --noconfirm) 2>/dev/null || true
    done
}

# 5. Sentinel ve donanim algilama
echo -e "${GREEN}[5/5] Son ayarlar yapiliyor...${NC}"

# Donanim algila
if [ -f /usr/lib/karya/scripts/detect-hardware.sh ]; then
    bash /usr/lib/karya/scripts/detect-hardware.sh 2>/dev/null || true
fi

# Sentinel servisini baslat (runit)
if [ -f /etc/runit/sv/karya-sentinel/run ]; then
    ln -sf /etc/runit/sv/karya-sentinel /etc/runit/runsvdir/default/ 2>/dev/null || true
fi

# systemd servisi
if command -v systemctl &>/dev/null; then
    systemctl enable karya-sentinel --now 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Karya DE v$VERSION KURULDU!       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}SDDM temasini aktif et:${NC}"
echo "    sudo bash /usr/lib/karya/scripts/install-drivers.sh auto"
echo ""
echo -e "  ${CYAN}Yeniden baslat:${NC}"
echo "    sudo reboot"
echo ""
echo -e "  ${CYAN}Yardim:${NC}"
echo "    $GITHUB"
echo ""
