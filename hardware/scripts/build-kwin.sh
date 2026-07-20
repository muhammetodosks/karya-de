#!/bin/bash
# Karya DE - KWin Build Service (called on first boot)
# Compiles the KWin fork from source

set -e

BUILD_LOG="/var/log/karya-kwin-build.log"
KWIN_VERSION="6.0.0"
KWIN_REPO="https://github.com/muhammetodosks/kwin.git"

exec >> "$BUILD_LOG" 2>&1

echo "[Karya Build] Basliyor: $(date)"

# Check if KWin is already built
if [ -f /usr/bin/kwin_karya_wrapper ] || [ -f /usr/lib/libkwin.so.6 ]; then
    echo "[Karya Build] KWin zaten derlenmis. Atlaniyor."
    exit 0
fi

echo "[Karya Build] Bagimliliklar kontrol ediliyor..."
if command -v apt &>/dev/null; then
    apt install -y -qq \
        cmake extra-cmake-modules \
        qt6-base-dev qt6-declarative-dev qt6-wayland-dev qt6-shadertools-dev qt6-tools-dev \
        libkf6config-dev libkf6coreaddons-dev libkf6crash-dev libkf6dbusaddons-dev \
        libkf6declarative-dev libkf6globalaccel-dev libkf6guiaddons-dev libkf6i18n-dev \
        libkf6iconthemes-dev libkf6kio-dev libkf6itemmodels-dev libkf6itemviews-dev \
        libkf6package-dev libkf6service-dev libkf6widgetsaddons-dev libkf6windowsystem-dev \
        libkf6xmlgui-dev libkf6wayland-dev libkf6auth-dev libkf6idletime-dev libkf6svg-dev \
        libkf6newstuff-dev libkf6runner-dev libkf6notifications-dev libkf6doctools-dev \
        libkf6kirigami-dev libkf6plasma-dev libkf6screenlocker-dev \
        libkf6globalacceld-dev libplasma-activities-dev \
        wayland-protocols plasma-wayland-protocols \
        libepoxy-dev libxcb-cursor-dev libxcb-keysyms1-dev \
        libxcb-util-dev libxcb-util-wm-dev libxcb-xrm-dev \
        libdrm-dev libinput-dev libei-dev libsystemd-dev \
        libvulkan-dev liblcms2-dev libhwdata-dev libcanberra-dev \
        libxkbcommon-dev libx11-dev libxcvt-dev libdisplay-info-dev \
        libevdev-dev libqaccessibilityclient-qt6-dev 2>&1 | tail -3
fi

echo "[Karya Build] KWin kaynagi indiriliyor..."
git clone --depth=1 --branch "v$KWIN_VERSION" "$KWIN_REPO" /tmp/kwin-karya-build

cd /tmp/kwin-karya-build

echo "[Karya Build] KF6 uyumluluk yamasi uygulaniyor..."
find . -name '*.kcfg' -exec sed -i 's|type="Enum"|type="Int"|' {} +

echo "[Karya Build] Derleme basliyor..."
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF \
    -DKWIN_BUILD_KCMS=OFF \
    -DKWIN_BUILD_DECORATIONS=ON \
    -DKWIN_BUILD_TABBOX=OFF \
    -DKWIN_BUILD_OVERVIEW=OFF

cmake --build build --parallel "$(nproc)"
DESTDIR=/ cmake --install build

echo "[Karya Build] KWin wrapper olusturuluyor..."
cat > /usr/bin/kwin_karya_wrapper << 'WRAPPER'
#!/bin/bash
export KWIN_COMPOSE=O2
export KWIN_DRM_USE_EGL_STREAMS=true
export KWIN_DRM_NO_AMS=true
exec /usr/bin/kwin_wayland "$@"
WRAPPER
chmod 755 /usr/bin/kwin_karya_wrapper

echo "[Karya Build] Temizlik..."
rm -rf /tmp/kwin-karya-build

echo "[Karya Build] Tamamlandi: $(date)"
