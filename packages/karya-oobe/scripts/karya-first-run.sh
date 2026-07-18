#!/usr/bin/env bash
# Karya DE - First Run Script
# ~/.config/karya-first-run.lock kontrolü yapar, OOBE'yi başlatır.

LOCK_FILE="$HOME/.config/karya-first-run.lock"
OOBE_BIN="/usr/bin/karya-oobe"

# Zaten çalıştıysa atla
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi

# OOBE var mı kontrol et
if [ ! -x "$OOBE_BIN" ]; then
    echo "karya-oobe bulunamadı, atlanıyor."
    touch "$LOCK_FILE"
    exit 0
fi

# 2 saniye bekle (masaüstünün tam yüklenmesi için)
sleep 2

# OOBE'yi başlat
"$OOBE_BIN"

# Lock dosyası oluştur
touch "$LOCK_FILE"
