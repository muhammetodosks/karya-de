# Karya DE - Ana Makefile
SHELL := /usr/bin/env bash

.PHONY: all setup build install iso clean

all: setup build

# Geliştirme ortamını kur
setup:
	@echo "=== Karya DE Geliştirme Ortamı Kurulumu ==="
	@bash scripts/setup.sh

# Tüm bileşenleri build et
build:
	@echo "=== Karya DE Build ==="
	@bash scripts/build.sh

# Sisteme kur
install:
	@echo "=== Karya DE Kurulum ==="
	@for dir in sources/*/build; do \
		if [ -d "$$dir" ]; then \
			echo "    Kurulum: $$dir"; \
			sudo cmake --install "$$dir"; \
		fi; \
	done
	@echo "    Widget'lar kuruluyor..."
	@sudo cp -r widgets/karya-hava /usr/share/plasma/plasmoids/org.karya.hava 2>/dev/null || true
	@sudo cp -r widgets/karya-namaz /usr/share/plasma/plasmoids/org.karya.namaz 2>/dev/null || true
	@sudo cp -r widgets/karya-haber /usr/share/plasma/plasmoids/org.karya.haber 2>/dev/null || true
	@echo "    Splash kuruluyor..."
	@sudo cp -r branding/splash/karya-splash /usr/share/plasma/look-and-feel/ 2>/dev/null || true
	@echo "=== Kurulum tamamlandı ==="

# ISO oluştur
iso:
	@echo "=== Karya DE ISO Oluşturuluyor ==="
	@sudo mkarchiso -v iso/releng

# Geçici dosyaları temizle
clean:
	@echo "Temizleniyor..."
	@rm -rf build/
	@for dir in sources/*/build; do \
		if [ -d "$$dir" ]; then \
			rm -rf "$$dir"; \
		fi; \
	done
	@echo "Tamam."

# OOBE'yi derle
oobe:
	@echo "OOBE derleniyor..."
	@cd packages/karya-oobe && python3 -m PyQt6.uic.pyuic -x src/karya-oobe.py 2>/dev/null || true

# Paketleri oluştur (Arch)
packages:
	@echo "PKGBUILD'lar kontrol ediliyor..."
	@for pkg in packages/*/; do \
		if [ -f "$$pkg/PKGBUILD" ]; then \
			echo "    $$pkg"; \
			cd "$$pkg" && makepkg -si --noconfirm 2>/dev/null || true; \
		fi; \
	done
