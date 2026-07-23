#!/usr/bin/env bash
# Karya DE - AppArmor Profil Yukleyici
set -euo pipefail

APPARMOR_DIR="/etc/apparmor.d"
PROFILE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Karya DE AppArmor Profil Yukleme ==="

for profile in "$PROFILE_DIR"/*; do
    local name
    name=$(basename "$profile")
    [[ "$name" == "install.sh" || "$name" == "README.md" ]] && continue
    [[ ! -f "$profile" ]] && continue

    echo "  [+] Yukleniyor: $name"
    install -Dm644 "$profile" "$APPARMOR_DIR/$name"

    if command -v apparmor_parser &>/dev/null; then
        apparmor_parser -r "$APPARMOR_DIR/$name" 2>/dev/null || \
        apparmor_parser -a "$APPARMOR_DIR/$name" 2>/dev/null || \
        echo "  [!] $name yuklenemedi (parser hatasi)"
    fi
done

echo "=== Tamamlandi ==="
