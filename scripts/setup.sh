#!/usr/bin/env bash
set -euo pipefail

KARYA_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCES_DIR="$KARYA_DIR/sources"

echo "=== Karya DE Geliştirme Ortamı Kurulumu ==="

# 1. Gerekli paketleri kontrol et
echo "[1/4] Gerekli paketler kontrol ediliyor..."
REQUIRED_PKGS=(
    base-devel git cmake extra-cmake-modules
    qt6-base qt6-declarative qt6-tools qt6-wayland
    kconfig kcoreaddons kcrash kdbusaddons kdeclarative
    kglobalaccel kguiaddons ki18n kiconthemes kio
    kitemmodels kitemviews kpackage kservice kwidgetsaddons
    kwindowsystem kxmlgui kwayland kcmutils kirigami2
    kconfigwidgets kdesignerplugin kglobalaccel ktextwidgets
    kxmlrpcclient kdoctools knewstuff knotifications
    kstatusnotifieritem krunner kuserfeedback sonnet
    syntax-highlighting threadweaver
    plasma-wayland-protocols wayland-protocols
    elogind runit
    python-pip python-jinja jq
)

if command -v pacman &>/dev/null; then
    sudo pacman -S --needed "${REQUIRED_PKGS[@]}"
elif command -v apt &>/dev/null; then
    echo "[!] Debian/Ubuntu tespit edildi. pacman gerekiyor."
    echo "    Lütfen Arch Linux'a geç veya pacman'i derle."
    exit 1
fi

# 2. Git submodule'leri başlat
echo "[2/4] Git submodule'ler başlatılıyor..."
cd "$KARYA_DIR"
git submodule update --init --recursive || true

# 3. Fork'lanacak repo'ları klonla (eğer yoksa)
echo "[3/4] Plasma 6 kaynakları kontrol ediliyor..."
clone_if_missing() {
    local name="$1"
    local url="$2"
    local dir="$SOURCES_DIR/$name"
    if [ ! -d "$dir/.git" ]; then
        echo "    + Klonlanıyor: $name"
        git clone --depth=1 "$url" "$dir"
    else
        echo "    * Mevcut: $name"
    fi
}

clone_if_missing "kwin" "https://invent.kde.org/plasma/kwin.git"
clone_if_missing "plasma-workspace" "https://invent.kde.org/plasma/plasma-workspace.git"
clone_if_missing "plasma-desktop" "https://invent.kde.org/plasma/plasma-desktop.git"
clone_if_missing "plasma-pa" "https://invent.kde.org/plasma/plasma-pa.git"
clone_if_missing "systemsettings" "https://invent.kde.org/plasma/systemsettings.git"
clone_if_missing "breeze" "https://invent.kde.org/plasma/breeze.git"
clone_if_missing "kdeplasma-addons" "https://invent.kde.org/plasma/kdeplasma-addons.git"

# 4. Build dizini oluştur
echo "[4/4] Build dizinleri oluşturuluyor..."
for repo in kwin plasma-workspace plasma-desktop plasma-pa systemsettings breeze kdeplasma-addons; do
    mkdir -p "$SOURCES_DIR/$repo/build"
done

echo ""
echo "=== Kurulum tamamlandı ==="
echo "Şimdi 'scripts/build.sh' çalıştırabilirsin."
