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
	@sudo cp -r widgets/karya-sistem /usr/share/plasma/plasmoids/org.karya.sistem 2>/dev/null || true
	@echo "    Splash kuruluyor..."
	@sudo cp -r branding/splash/karya-splash /usr/share/plasma/splashes/ 2>/dev/null || true
	@echo "    Duvarkagidi kuruluyor..."
	@sudo mkdir -p /usr/share/wallpapers/ 2>/dev/null || true
	@sudo cp branding/wallpapers/karya-default.jpg /usr/share/wallpapers/ 2>/dev/null || true
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
	@echo "OOBE kontrol ediliyor..."
	@python3 -c "from PyQt6 import QtWidgets; print('PyQt6 OK')" 2>/dev/null || echo "PyQt6 yuklu degil"

# Paketleri oluştur (Arch)
packages:
	@echo "PKGBUILD'lar kontrol ediliyor..."
	@for pkg in packages/*/; do \
		if [ -f "$$pkg/PKGBUILD" ]; then \
			echo "    $$pkg"; \
			cd "$$pkg" && makepkg -si --noconfirm 2>/dev/null || true; \
		fi; \
	done

# .deb paketi oluştur (Ubuntu)
deb:
	@echo "=== Karya DE .deb Paketi ==="
	@chmod 755 debian/rules debian/karya-de.postinst debian/karya-de.postrm
	@if command -v dpkg-buildpackage &>/dev/null; then \
		dpkg-buildpackage -b -us -uc; \
		echo ".deb paketi olusturuldu."; \
	else \
		echo "dpkg-dev paketi gerekli: sudo apt install dpkg-dev"; \
		exit 1; \
	fi

# Karya uygulamalarını test et
test-apps:
	@echo "Karya uygulamalari test ediliyor..."
	@for app in karya-calc karya-notes karya-search karya-settings; do \
		if [ -f "packages/$$app/src/$$app.py" ]; then \
			python3 -c "import ast; ast.parse(open('packages/$$app/src/$$app.py').read()); print(f'  $$app: OK')"; \
		else \
			echo "  $$app: bulunamadi"; \
		fi; \
	done
