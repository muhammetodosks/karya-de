#!/usr/bin/env bash
set -euo pipefail

KARYA_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCES_DIR="$KARYA_DIR/sources"
BUILD_DIR="$KARYA_DIR/build"
INSTALL_PREFIX="/usr"

mkdir -p "$BUILD_DIR"

echo "=== Karya DE Build ==="

build_component() {
    local name="$1"
    local src="$SOURCES_DIR/$name"
    local build="$src/build"
    local extra_cmake="${2:-}"

    if [ ! -d "$src" ]; then
        echo "    [!] $name kaynagi bulunamadi: $src"
        echo "    [!] 'scripts/setup.sh' calistirarak kaynaklari klonlayin."
        return 1
    fi

    echo ""
    echo ">>> Building: $name"

    mkdir -p "$build"

    # Karya patch'lerini uygula
    if [ -d "$KARYA_DIR/patches/$name" ]; then
        echo "    [+] Karya patch'leri uygulaniyor..."
        cd "$src"
        for patch in "$KARYA_DIR/patches/$name"/*.patch; do
            if [ -f "$patch" ]; then
                echo "        Uygulaniyor: $(basename $patch)"
                git apply "$patch" 2>/dev/null || patch -p1 < "$patch" 2>/dev/null || true
            fi
        done
    fi

    cd "$build"
    cmake "$src" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTING=OFF \
        $extra_cmake \
        2>&1 | tail -5

    cmake --build . --parallel "$(nproc)" 2>&1 | tail -3
    echo "    [OK] $name build tamam."
}

# Build sırası (dependency order)
build_component "kwin" "-DKWIN_BUILD_DECORATIONS=ON -DKWIN_BUILD_TABBOX=ON"
build_component "plasma-workspace" ""
build_component "plasma-desktop" ""
build_component "plasma-pa" ""
build_component "systemsettings" ""
build_component "breeze" "-DBUILD_KDE_DEFAULT=ON"
build_component "kdeplasma-addons" ""

# Karya SPEED kurulumu
echo ""
echo ">>> Installing: Karya SPEED"
bash "$KARYA_DIR/hardware/speed/speed.sh" install 2>/dev/null || true

# Karya kernel configs
echo ">>> Installing: Kernel configs"
mkdir -p "$INSTALL_PREFIX/share/karya/kernel"
cp "$KARYA_DIR/kernel/config-6.17-x86_64" "$INSTALL_PREFIX/share/karya/kernel/" 2>/dev/null || true
cp "$KARYA_DIR/kernel/config-6.17-x86_64-hardened" "$INSTALL_PREFIX/share/karya/kernel/" 2>/dev/null || true

echo ""
echo "=== Build tamamlandı ==="
echo "Kurulum için: cd <build_dir> && sudo make install"
