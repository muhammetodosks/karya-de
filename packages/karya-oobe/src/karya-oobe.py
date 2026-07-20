#!/usr/bin/env python3
"""
Karya DE - First Run Setup Wizard (OOBE)
Hardware-aware, multi-step setup wizard for Karya Desktop Environment.
"""

import sys
import os
import subprocess
import json
from pathlib import Path

# Ensure OOBE services package is on path
_oobe_services = Path("/usr/lib/karya/oobe")
if _oobe_services.exists() and str(_oobe_services) not in sys.path:
    sys.path.insert(0, str(_oobe_services))

from PyQt6.QtWidgets import (
    QApplication, QWizard, QWizardPage, QVBoxLayout, QHBoxLayout,
    QLabel, QComboBox, QCheckBox, QRadioButton, QButtonGroup,
    QGroupBox, QPushButton, QProgressBar, QGridLayout, QLineEdit,
    QTextEdit, QWidget, QSpacerItem, QSizePolicy, QScrollArea,
    QStackedWidget, QFrame
)
from PyQt6.QtCore import Qt, QTimer, QSize, pyqtSignal
from PyQt6.QtGui import QFont, QPixmap, QPalette, QColor, QIcon

from services.hardware_service import run_detection, HardwareInfo
from services.driver_service import DriverInstaller
from services.config_service import ConfigWriter


# ==============================================================
# STYLESHEET
# ==============================================================
KARYA_STYLE = """
QWidget {
    background-color: #1a1a2e;
    color: #ffffff;
    font-family: 'Noto Sans', 'DejaVu Sans', sans-serif;
}

QWizard {
    background-color: #1a1a2e;
}

QPushButton {
    background-color: #4a90d9;
    color: white;
    border: none;
    padding: 10px 28px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: bold;
}
QPushButton:hover {
    background-color: #5ba0e9;
}
QPushButton:disabled {
    background-color: #2a2a4e;
    color: #666;
}
QPushButton#installBtn {
    background-color: #27ae60;
    font-size: 16px;
    padding: 14px 40px;
}
QPushButton#installBtn:hover {
    background-color: #2ecc71;
}
QPushButton#skipBtn {
    background-color: transparent;
    border: 1px solid #555;
}
QPushButton#skipBtn:hover {
    background-color: rgba(255,255,255,0.05);
}

QLabel#titleLabel {
    font-size: 26px;
    font-weight: bold;
    color: #ffffff;
    padding: 10px 0;
}
QLabel#subtitleLabel {
    font-size: 14px;
    color: rgba(255,255,255,0.6);
    padding: 0 0 20px 0;
}
QLabel#sectionLabel {
    font-size: 16px;
    font-weight: bold;
    color: #4a90d9;
    padding: 15px 0 5px 0;
}

QRadioButton, QCheckBox {
    color: white;
    padding: 10px;
    spacing: 12px;
    font-size: 14px;
    border-radius: 8px;
}
QRadioButton:hover, QCheckBox:hover {
    background-color: rgba(74, 144, 217, 0.1);
}
QRadioButton::indicator, QCheckBox::indicator {
    width: 20px;
    height: 20px;
}

QComboBox {
    background-color: #0f3460;
    color: white;
    border: 1px solid #2a2a4e;
    border-radius: 8px;
    padding: 10px 16px;
    font-size: 14px;
}
QComboBox:hover {
    border-color: #4a90d9;
}
QComboBox::drop-down {
    border: none;
    width: 30px;
}
QComboBox QAbstractItemView {
    background-color: #0f3460;
    color: white;
    selection-background-color: #4a90d9;
    border-radius: 8px;
}

QGroupBox {
    border: 1px solid #2a2a4e;
    border-radius: 12px;
    margin-top: 20px;
    padding: 20px;
    font-size: 14px;
    font-weight: bold;
}
QGroupBox::title {
    subcontrol-origin: margin;
    left: 16px;
    padding: 0 8px;
}

QProgressBar {
    border: none;
    background-color: rgba(255,255,255,0.1);
    border-radius: 8px;
    height: 16px;
    text-align: center;
    color: white;
    font-size: 12px;
}
QProgressBar::chunk {
    background-color: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 #4a90d9, stop:1 #6c5ce7);
    border-radius: 8px;
}

QTextEdit, QLineEdit {
    background-color: #0f3460;
    color: white;
    border: 1px solid #2a2a4e;
    border-radius: 8px;
    padding: 10px;
    font-size: 14px;
}
"""


# ==============================================================
# WIZARD PAGES
# ==============================================================

class WelcomePage(QWizardPage):
    def __init__(self, hw_info: HardwareInfo):
        super().__init__()
        self.hw = hw_info

        layout = QVBoxLayout()
        layout.setSpacing(16)

        title = QLabel("Karya DE'ye Hos Geldiniz!")
        title.setObjectName("titleLabel")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title)

        subtitle = QLabel(
            "Karya Desktop Environment, modern ve hizli bir Turk masaustu deneyimidir.\n"
            "Bu sihirbaz, sisteminizi otomatik olarak taniyip en uygun ayarlari yapacak."
        )
        subtitle.setObjectName("subtitleLabel")
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        subtitle.setWordWrap(True)
        layout.addWidget(subtitle)

        # Hardware summary card
        card = QFrame()
        card.setStyleSheet("""
            QFrame {
                background-color: rgba(15, 52, 96, 0.5);
                border: 1px solid rgba(74, 144, 217, 0.3);
                border-radius: 12px;
                padding: 20px;
            }
        """)
        card_layout = QVBoxLayout(card)

        hw_title = QLabel("Algilanan Sistem Bilgisi")
        hw_title.setObjectName("sectionLabel")
        card_layout.addWidget(hw_title)

        grid = QGridLayout()
        grid.setSpacing(8)

        rows = [
            ("Islemci", self.hw.cpu_model, self.hw.cpu_cores),
            ("Bellek", f"{self.hw.ram_mb} MB", None),
            ("GPU", self.hw.get_gpu_display_text(), None),
            ("Ses", self.hw.audio_server, None),
            ("Wifi", "Var" if self.hw.has_wifi else "Yok", None),
            ("Bluetooth", "Var" if self.hw.has_bluetooth else "Yok", None),
            ("Laptop", "Evet" if self.hw.is_laptop else "Hayir", None),
            ("Dagitim", self.hw.distro_display, None),
        ]

        for i, (label, value, extra) in enumerate(rows):
            lbl = QLabel(f"  {label}:")
            lbl.setStyleSheet("color: rgba(255,255,255,0.6); font-size: 13px; padding: 4px;")
            val = QLabel(value)
            val.setStyleSheet("color: white; font-size: 13px; font-weight: bold;")
            grid.addWidget(lbl, i, 0)
            grid.addWidget(val, i, 1)

        card_layout.addLayout(grid)
        layout.addWidget(card)

        self.setLayout(layout)


class GpuSelectionPage(QWizardPage):
    def __init__(self, hw_info: HardwareInfo):
        super().__init__()
        self.hw = hw_info
        self.selected_driver = ""
        self.button_group = QButtonGroup(self)

        layout = QVBoxLayout()

        title = QLabel("GPU Surucu Secimi")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Sisteminizde algilanan GPU'ya gore surucu onerileri:")
        subtitle.setObjectName("subtitleLabel")
        subtitle.setWordWrap(True)
        layout.addWidget(subtitle)

        detected_label = QLabel(f"Algilanan: {self.hw.get_gpu_display_text()}")
        detected_label.setStyleSheet("color: #4a90d9; font-size: 14px; font-weight: bold; padding: 8px;")
        layout.addWidget(detected_label)

        driver_options = self._get_driver_options()
        for opt_id, name, desc, recommended in driver_options:
            rb = QRadioButton(f"  {name}")
            rb.setProperty("driver_name", opt_id)
            rb.setToolTip(desc)

            rb_desc = QLabel(desc)
            rb_desc.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px; padding-left: 32px;")
            rb_desc.setWordWrap(True)

            rb_widget = QWidget()
            rb_layout = QVBoxLayout(rb_widget)
            rb_layout.setContentsMargins(0, 0, 0, 0)
            rb_layout.setSpacing(0)
            rb_layout.addWidget(rb)
            rb_layout.addWidget(rb_desc)

            self.button_group.addButton(rb)
            layout.addWidget(rb_widget)

            if recommended:
                rec_label = QLabel("  ONERILEN")
                rec_label.setStyleSheet("color: #2ecc71; font-size: 11px; font-weight: bold; padding-left: 32px;")
                layout.addWidget(rec_label)
                rb.setChecked(True)

        # OpenGL sürümü seçimi
        gl_group = QGroupBox("OpenGL Ayarlari")
        gl_layout = QVBoxLayout(gl_group)

        self.gl_modern = QRadioButton("OpenGL 3.1+ (Modern, Onerilen)")
        self.gl_legacy = QRadioButton("OpenGL 2.1 (Eski GPU'lar icin)")
        self.gl_software = QRadioButton("Software Rendering (Cok eski sistemler)")
        gl_layout.addWidget(self.gl_modern)
        gl_layout.addWidget(self.gl_legacy)
        gl_layout.addWidget(self.gl_software)
        self.gl_modern.setChecked(True)
        layout.addWidget(gl_group)

        layout.addStretch()
        self.setLayout(layout)

    def _get_driver_options(self):
        vendor = self.hw.gpu_vendor
        options = []

        if vendor == "nvidia":
            options.append(("nvidia-proprietary", "NVIDIA Proprietary Driver",
                           "En iyi performans ve oyun destegi. Tum NVIDIA GPU'lar icin onerilir.", True))
            options.append(("nvidia-nouveau", "Nouveau (Acik Kaynak)",
                           "Acik kaynakli NVIDIA driver. Daha dusuk performans ancak uyumluluk yuksek.", False))
            options.append(("nvidia-optimus", "NVIDIA Optimus (Laptop HD)",
                           "Harici NVIDIA + Dahili Intel GPU gecisli laptoplar icin.", False))

        elif vendor == "amd":
            options.append(("amd-amdgpu", "AMDGPU (Acik Kaynak, Onerilen)",
                           "En guncel AMD GPU destegi, Vulkan destegi var.", True))
            options.append(("amd-pro", "AMDGPU-PRO (Proprietary)",
                           "Resmi AMD kapali kaynak driver. Profesyonel uygulamalar icin.", False))

        elif vendor == "intel":
            options.append(("intel-modesetting", "Modesetting Driver (Onerilen)",
                           "Modern Intel GPU'lar icin en iyi secenek.", True))
            options.append(("intel-legacy", "Intel Legacy Driver",
                           "Eski Intel GPU'lar icin (GMA serisi).", False))

        else:
            options.append(("modesetting", "Modesetting (Genel, Onerilen)",
                           "Her GPU ile calisan genel surucu.", True))

        # Herkese acik
        if not any("virtual" in o[0] for o in options):
            options.append(("virtual", "Virtual Machine Driver",
                           "Sanal makine icin optimize driver (VBox/Guest).", vendor == "virtual"))

        return options

    def get_selected_driver(self):
        btn = self.button_group.checkedButton()
        if btn:
            return btn.property("driver_name")
        return "modesetting"


class LayoutPage(QWizardPage):
    def __init__(self, hw_info: HardwareInfo):
        super().__init__()
        self.hw = hw_info
        self.layout_group = QButtonGroup(self)

        layout = QVBoxLayout()

        title = QLabel("Masaustu Duzeni")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Tercih ettiginiz masaustu duzenini secin:")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        if self.hw.ram_mb < 4096 or self.hw.is_vm:
            warn = QLabel("Dusuk sistem kaynagi tespit edildi. Minimal duzen onerilir.")
            warn.setStyleSheet("color: #f39c12; font-size: 12px; font-weight: bold; padding: 8px;")
            layout.addWidget(warn)

        layouts = [
            ("karya-modern", "Karya Modern (Onerilen)",
             "Ust panel + alt dock. Modern, sade ve kullanisli. 4GB+ RAM onerilir.",
             True),
            ("karya-classic", "Karya Classic",
             "Tek alt panel, Windows benzeri duzen. Dusuk kaynak tuketimi.",
             self.hw.ram_mb < 4096),
            ("karya-macos", "Karya macOS Style",
             "Ust menu cubugu + alt dock. macOS kullanicilari icin.",
             False),
            ("karya-minimal", "Karya Minimal",
             "Sadece panel, dock yok. En dusuk kaynak tuketimi.",
             self.hw.is_vm),
        ]

        for lid, name, desc, recommended in layouts:
            rb = QRadioButton(f"  {name}")
            rb.setProperty("layout_id", lid)
            rb.setToolTip(desc)

            desc_label = QLabel(desc)
            desc_label.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px; padding-left: 32px;")
            desc_label.setWordWrap(True)

            widget = QWidget()
            wl = QVBoxLayout(widget)
            wl.setContentsMargins(0, 0, 0, 0)
            wl.setSpacing(0)
            wl.addWidget(rb)
            wl.addWidget(desc_label)

            self.layout_group.addButton(rb)
            layout.addWidget(widget)

            if recommended:
                rec = QLabel("  ONERILEN")
                rec.setStyleSheet("color: #2ecc71; font-size: 11px; font-weight: bold; padding-left: 32px;")
                layout.addWidget(rec)
                rb.setChecked(True)

        layout.addStretch()
        self.setLayout(layout)

    def get_selected_layout(self):
        btn = self.layout_group.checkedButton()
        return btn.property("layout_id") if btn else "karya-modern"


class ComponentsPage(QWizardPage):
    def __init__(self, hw_info: HardwareInfo):
        super().__init__()
        self.hw = hw_info

        layout = QVBoxLayout()

        title = QLabel("Bilesen Ayarlari")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Hangi ozellikleri etkinlestirmek istediginizi secin:\n"
                         "(Performans dusuk sistemlerde bazi ozellikler otomatik kapatilacak)")
        subtitle.setObjectName("subtitleLabel")
        subtitle.setWordWrap(True)
        layout.addWidget(subtitle)

        # Performans karti
        perf_card = QFrame()
        perf_card.setStyleSheet("""
            QFrame {
                background-color: rgba(39, 174, 96, 0.15);
                border: 1px solid rgba(39, 174, 96, 0.3);
                border-radius: 12px;
                padding: 12px;
            }
        """)
        perf_layout = QVBoxLayout(perf_card)
        perf_label = QLabel(f"Profil: {self.hw.get_performance_label()}")
        perf_label.setStyleSheet("color: #2ecc71; font-size: 14px; font-weight: bold;")
        perf_layout.addWidget(perf_label)
        layout.addWidget(perf_card)

        # Bilesenler
        components = [
            ("tiling", "Otomatik Doseme (Auto Tiling)", "Pencereleri otomatik duzenler (Meta+T)",
             True, self.hw.ram_mb >= 2048),
            ("glassmorphism", "Glassmorphism Efekti", "Pencerelere cam efekti ekler (GPU gerekli)",
             self.hw.gpu_vendor != "virtual", self.hw.gpu_vendor != "intel" or self.hw.ram_mb >= 4096),
            ("animations", "Gelismis Animasyonlar", "Pencere acma/kapama efektleri",
             True, self.hw.ram_mb >= 3072),
            ("blur", "Pencere Bulaniklastirma", "Arkaplan bulaniklastirma efekti",
             self.hw.gpu_vendor != "virtual", self.hw.ram_mb >= 4096),
            ("hotcorners", "Sicak Koseler", "Koselere fare ile islem atama",
             True, True),
            ("nightcolor", "Gece Modu (Night Color)", "Otomatik renk sicakligi ayari (39.0N 35.0D)",
             True, True),
        ]

        self.checkboxes = {}
        for cid, name, desc, default, enabled in components:
            cb = QCheckBox(f"  {name}")
            cb.setToolTip(desc)
            cb.setChecked(default if enabled else False)
            cb.setEnabled(enabled)
            self.checkboxes[cid] = cb

            desc_label = QLabel(desc)
            desc_label.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px; padding-left: 36px;")
            desc_label.setWordWrap(True)

            if not enabled:
                info = QLabel("  (Sistem bu ozellik icin yetersiz)")
                info.setStyleSheet("color: #e74c3c; font-size: 11px; padding-left: 36px;")

            widget = QWidget()
            wl = QVBoxLayout(widget)
            wl.setContentsMargins(0, 0, 0, 0)
            wl.setSpacing(0)
            wl.addWidget(cb)
            wl.addWidget(desc_label)
            if not enabled:
                wl.addWidget(info)

            layout.addWidget(widget)

        layout.addStretch()
        self.setLayout(layout)

    def get_components(self):
        return {cid: cb.isChecked() for cid, cb in self.checkboxes.items()}


class UserPage(QWizardPage):
    def __init__(self):
        super().__init__()

        layout = QVBoxLayout()

        title = QLabel("Kullanici Bilgileri")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Sistem kullanicisi olusturun (istege bagli):")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        form = QGridLayout()
        form.setSpacing(12)

        form.addWidget(QLabel("Kullanici Adi:"), 0, 0)
        self.username_input = QLineEdit()
        self.username_input.setPlaceholderText("ornek: kullanici")
        form.addWidget(self.username_input, 0, 1)

        form.addWidget(QLabel("Tam Ad:"), 1, 0)
        self.realname_input = QLineEdit()
        self.realname_input.setPlaceholderText("ornek: Ad Soyad")
        form.addWidget(self.realname_input, 1, 1)

        form.addWidget(QLabel("Sifre:"), 2, 0)
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.EchoMode.Password)
        form.addWidget(self.password_input, 2, 1)

        form.addWidget(QLabel("Sifre Tekrar:"), 3, 0)
        self.password_confirm = QLineEdit()
        self.password_confirm.setEchoMode(QLineEdit.EchoMode.Password)
        form.addWidget(self.password_confirm, 3, 1)

        layout.addLayout(form)

        self.auto_login = QCheckBox("Ortam baslatildiginda otomatik oturum ac")
        self.auto_login.setChecked(True)
        layout.addWidget(self.auto_login)

        self.set_theme = QCheckBox("Karya varsayilan temasini uygula")
        self.set_theme.setChecked(True)
        layout.addWidget(self.set_theme)

        layout.addStretch()
        self.setLayout(layout)

    def get_user_info(self):
        return {
            "username": self.username_input.text().strip(),
            "realname": self.realname_input.text().strip(),
            "password": self.password_input.text(),
            "autologin": self.auto_login.isChecked(),
            "set_theme": self.set_theme.isChecked(),
        }


class ThemePage(QWizardPage):
    def __init__(self, hw_info: HardwareInfo):
        super().__init__()
        self.hw = hw_info

        layout = QVBoxLayout()

        title = QLabel("Tema Secimi")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Karya DE'nin gorunumunu ozellestirin:")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        # Renk temasi
        theme_group = QGroupBox("Renk Temasi")
        theme_layout = QVBoxLayout(theme_group)
        self.theme_group = QButtonGroup(self)

        themes = [
            ("karya-dark", "Karya Dark (Onerilen)", "Koyu tema, goz yormaz, pil tasarrufu saglar", True),
            ("karya-light", "Karya Light", "Acik tema, aydinlik ortamlar icin", False),
            ("karya-blue", "Karya Blue", "Mavi agirlikli ozel tema", False),
            ("system", "Sistem Temasi", "Isletim sisteminin varsayilan temasini kullan", False),
        ]
        for tid, name, desc, rec in themes:
            rb = QRadioButton(f"  {name}")
            rb.setProperty("theme", tid)
            self.theme_group.addButton(rb)
            rb_layout = QVBoxLayout()
            rbw = QWidget()
            rbw.setLayout(rb_layout)
            rb_layout.setContentsMargins(0, 0, 0, 0)
            rb_layout.addWidget(rb)
            dl = QLabel(desc)
            dl.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px; padding-left: 32px;")
            rb_layout.addWidget(dl)
            theme_layout.addWidget(rbw)
            if rec:
                rb.setChecked(True)
                rl = QLabel("  ONERILEN")
                rl.setStyleSheet("color: #2ecc71; font-size: 11px; font-weight: bold; padding-left: 32px;")
                theme_layout.addWidget(rl)
        layout.addWidget(theme_group)

        # Vurgu rengi
        accent_group = QGroupBox("Vurgu Rengi")
        accent_layout = QVBoxLayout(accent_group)
        self.accent_group = QButtonGroup(self)
        accents = [("blue", "Mavi", True), ("purple", "Mor"), ("green", "Yesil"),
                    ("red", "Kirmizi"), ("orange", "Turuncu"), ("pink", "Pembe")]
        for aid, name, *rec in accents:
            rb = QRadioButton(f"  {name}")
            rb.setProperty("accent", aid)
            self.accent_group.addButton(rb)
            accent_layout.addWidget(rb)
            if rec and rec[0]:
                rb.setChecked(True)
        layout.addWidget(accent_group)

        # Efektler
        effects_group = QGroupBox("Goruntu Efektleri")
        effects_layout = QVBoxLayout(effects_group)
        self.glass_check = QCheckBox("  Glassmorphism (Cam Efekti) - GPU gerektirir")
        self.glass_check.setChecked(self.hw.gpu_vendor not in ("virtual", "intel"))
        effects_layout.addWidget(self.glass_check)
        self.blur_check = QCheckBox("  Pencere Bulaniklastirma - 4GB+ RAM onerilir")
        self.blur_check.setChecked(self.hw.ram_mb >= 4096)
        effects_layout.addWidget(self.blur_check)
        self.anim_check = QCheckBox("  Gelismis Animasyonlar")
        self.anim_check.setChecked(True)
        effects_layout.addWidget(self.anim_check)
        layout.addWidget(effects_group)

        layout.addStretch()
        self.setLayout(layout)

    def get_config(self) -> dict:
        theme_btn = self.theme_group.checkedButton()
        accent_btn = self.accent_group.checkedButton()
        return {
            "theme": theme_btn.property("theme") if theme_btn else "karya-dark",
            "accent": accent_btn.property("accent") if accent_btn else "blue",
            "glassmorphism": self.glass_check.isChecked(),
            "blur": self.blur_check.isChecked(),
            "animations": self.anim_check.isChecked(),
        }


class DefaultAppsPage(QWizardPage):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout()

        title = QLabel("Varsayilan Uygulamalar")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Karya DE'de kullanilacak varsayilan uygulamalari secin:")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        # Web tarayici
        layout.addWidget(self._section_label("Web Tarayici"))
        self.browser_combo = QComboBox()
        self.browser_combo.addItems([
            "Firefox (Onerilen)", "Google Chrome", "Brave", "Microsoft Edge", "Chromium"
        ])
        self.browser_combo.setCurrentIndex(0)
        layout.addWidget(self.browser_combo)

        # Terminal
        layout.addWidget(self._section_label("Terminal Emulatoru"))
        self.terminal_combo = QComboBox()
        self.terminal_combo.addItems([
            "Konsole (Onerilen)", "Alacritty", "Kitty", "GNOME Terminal", "Terminator"
        ])
        self.terminal_combo.setCurrentIndex(0)
        layout.addWidget(self.terminal_combo)

        # Dosya yoneticisi
        layout.addWidget(self._section_label("Dosya Yoneticisi"))
        self.fm_combo = QComboBox()
        self.fm_combo.addItems([
            "Dolphin (Onerilen)", "Nautilus", "Thunar", "Nemo", "PCManFM"
        ])
        self.fm_combo.setCurrentIndex(0)
        layout.addWidget(self.fm_combo)

        # Metin editoru
        layout.addWidget(self._section_label("Metin Editoru"))
        self.editor_combo = QComboBox()
        self.editor_combo.addItems([
            "Kate (Onerilen)", "VS Code", "Gedit", "Vim", "Nano"
        ])
        self.editor_combo.setCurrentIndex(0)
        layout.addWidget(self.editor_combo)

        # Muzik calar
        layout.addWidget(self._section_label("Muzik Calar"))
        self.music_combo = QComboBox()
        self.music_combo.addItems([
            "Elisa (Onerilen)", "Spotify", "Rhythmbox", "Clementine", "VLC"
        ])
        self.music_combo.setCurrentIndex(0)
        layout.addWidget(self.music_combo)

        layout.addStretch()
        self.setLayout(layout)

    def _section_label(self, text):
        lbl = QLabel(text)
        lbl.setObjectName("sectionLabel")
        return lbl

    def get_config(self) -> dict:
        return {
            "browser": self.browser_combo.currentText().split(" (")[0].lower(),
            "terminal": self.terminal_combo.currentText().split(" (")[0].lower(),
            "file_manager": self.fm_combo.currentText().split(" (")[0].lower(),
            "text_editor": self.editor_combo.currentText().split(" (")[0].lower(),
            "music_player": self.music_combo.currentText().split(" (")[0].lower(),
        }


class DevToolsPage(QWizardPage):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout()

        title = QLabel("Gelistirme Araclari")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Kurmak istediginiz gelistirme araclarini secin:")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        tools = [
            ("git", "Git", "Versiyon kontrol sistemi", True),
            ("python", "Python + Pip", "Python 3 ve paket yoneticisi", True),
            ("nodejs", "Node.js + NPM", "JavaScript runtime ve paket yoneticisi", False),
            ("docker", "Docker", "Container platformu", False),
            ("vscode", "VS Code", "Microsoft'un populer editoru", False),
            ("gcc", "GCC/Clang", "C/C++ derleyici", True),
            ("cmake", "CMake", "Build sistemi", True),
            ("postman", "Postman/Insomnia", "API test araci", False),
            ("neovim", "Neovim", "Modern terminal editoru", False),
            ("jdk", "Java JDK", "Java gelistirme kiti", False),
        ]

        self.tool_checks = {}
        for tid, name, desc, default in tools:
            cb = QCheckBox(f"  {name}")
            cb.setChecked(default)
            cb.setToolTip(desc)
            self.tool_checks[tid] = cb
            layout.addWidget(cb)
            dl = QLabel(desc)
            dl.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px; padding-left: 36px;")
            layout.addWidget(dl)

        layout.addStretch()
        self.setLayout(layout)

    def get_config(self) -> dict:
        return {tid: cb.isChecked() for tid, cb in self.tool_checks.items()}


class GamingPage(QWizardPage):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout()

        title = QLabel("Oyun Kurulumu")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Oyun platformu ve araclarini secin:")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        tools = [
            ("steam", "Steam", "Valve'in oyun platformu. Binlerce oyun.", False),
            ("lutris", "Lutris", "Oyun yoneticisi. Windows oyunlarini calistirir.", False),
            ("gamemode", "GameMode", "FPS optimize eden sistem araci", True),
            ("mangohud", "MangoHud", "Oyun ici FPS/sistem monitoru", False),
            ("proton", "Proton GE", "Geli�tirilmis Proton (Steam oyunlari icin)", False),
            ("wine", "Wine", "Windows uygulamalarini calistirma katmani", False),
            ("heroic", "Heroic Launcher", "Epic/GOG oyun launcheri", False),
        ]

        self.game_checks = {}
        for gid, name, desc, default in tools:
            cb = QCheckBox(f"  {name}")
            cb.setChecked(default)
            cb.setToolTip(desc)
            self.game_checks[gid] = cb
            layout.addWidget(cb)
            dl = QLabel(desc)
            dl.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px; padding-left: 36px;")
            layout.addWidget(dl)

        # Performans modu
        perf_group = QGroupBox("Oyun Performansi")
        perf_layout = QVBoxLayout(perf_group)
        self.game_mode_cb = QCheckBox("Oyun Modu (Govde atamasi + CPU governor)")
        self.game_mode_cb.setChecked(True)
        perf_layout.addWidget(self.game_mode_cb)
        self.realtime_cb = QCheckBox("Gerçek Zamanli Oncelik (Oyunlara CPU onceligi)")
        self.realtime_cb.setChecked(False)
        perf_layout.addWidget(self.realtime_cb)
        layout.addWidget(perf_group)

        layout.addStretch()
        self.setLayout(layout)

    def get_config(self) -> dict:
        return {
            "tools": {gid: cb.isChecked() for gid, cb in self.game_checks.items()},
            "game_mode": self.game_mode_cb.isChecked(),
            "realtime_priority": self.realtime_cb.isChecked(),
        }


class PrivacyPage(QWizardPage):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout()

        title = QLabel("Gizlilik Ayarlari")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Karya DE'nin gizlilik tercihlerini yapilandirin:")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        # Gizlilik secenekleri
        items = [
            ("location", "Konum Servisleri", "Uygulamalarin konumunuza erismesine izin ver", False),
            ("crash", "C2a Raporu Gonder", "Karya DE cokmelerinde anonim rapor gonder", True),
            ("telemetry", "Kullanim Verisi", "Anonim kullanim istatistigi gonder", False),
            ("recent", "Son Dosyalari Hatirla", "Acilan dosyalari kaydet", True),
            ("search", "Dosya Icerigini Indexle", "Hizli arama icin dosya iceriklerini tara", True),
        ]
        self.privacy_checks = {}
        for pid, name, desc, default in items:
            cb = QCheckBox(f"  {name}")
            cb.setChecked(default)
            cb.setToolTip(desc)
            self.privacy_checks[pid] = cb
            layout.addWidget(cb)
            dl = QLabel(desc)
            dl.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px; padding-left: 36px;")
            layout.addWidget(dl)

        # Hostname
        hostname_group = QGroupBox("Makine Adi (Hostname)")
        hostname_layout = QVBoxLayout(hostname_group)
        self.hostname_input = QLineEdit()
        import socket
        default_host = socket.gethostname() or "karya-pc"
        self.hostname_input.setText(default_host)
        self.hostname_input.setPlaceholderText("ornek: karya-laptop")
        hostname_layout.addWidget(self.hostname_input)
        hl = QLabel("Bu isim ag uzerinde gorunecektir")
        hl.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px;")
        hostname_layout.addWidget(hl)
        layout.addWidget(hostname_group)

        layout.addStretch()
        self.setLayout(layout)

    def get_config(self) -> dict:
        return {
            "location": self.privacy_checks["location"].isChecked(),
            "crash_reports": self.privacy_checks["crash"].isChecked(),
            "telemetry": self.privacy_checks["telemetry"].isChecked(),
            "recent_files": self.privacy_checks["recent"].isChecked(),
            "search_index": self.privacy_checks["search"].isChecked(),
            "hostname": self.hostname_input.text().strip() or "karya-pc",
        }


class DisplayPage(QWizardPage):
    def __init__(self, hw_info: HardwareInfo):
        super().__init__()
        self.hw = hw_info

        layout = QVBoxLayout()

        title = QLabel("Ekran Ayarlari")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Ekran cozunurluk ve olcekleme tercihleri:")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        # Cozunurluk
        layout.addWidget(self._sl("Cozunurluk"))
        self.res_combo = QComboBox()
        # Try to detect native resolution
        try:
            res = subprocess.run(
                ["xrandr"], capture_output=True, text=True, timeout=5
            )
            native = "1920x1080"
            for line in res.stdout.split("\n"):
                if " connected" in line and "x" in line:
                    import re
                    m = re.search(r'(\d+x\d+)', line.split("connected")[1] if "connected" in line else line)
                    if m:
                        native = m.group(1)
                    break
            self.res_combo.addItems([
                f"{native} (Native, Onerilen)",
                "2560x1440", "1920x1200", "1920x1080",
                "1680x1050", "1600x900", "1440x900",
                "1366x768", "1280x720"
            ])
            # Select native
            for i in range(self.res_combo.count()):
                if native in self.res_combo.itemText(i):
                    self.res_combo.setCurrentIndex(i)
                    break
        except Exception:
            self.res_combo.addItems(["1920x1080 (Onerilen)", "2560x1440", "1920x1200",
                                     "1680x1050", "1366x768"])
        layout.addWidget(self.res_combo)

        # Olcekleme
        layout.addWidget(self._sl("Olcekleme (Scale)"))
        self.scale_combo = QComboBox()
        scales = ["%%100 (Onerilen)", "%%125", "%%150", "%%175", "%%200"]
        self.scale_combo.addItems(scales)
        if self.hw.is_laptop or self.hw.gpu_vendor in ("intel",):
            self.scale_combo.setCurrentIndex(1)
        layout.addWidget(self.scale_combo)

        # Yenileme hizi
        layout.addWidget(self._sl("Yenileme Hizi"))
        self.refresh_combo = QComboBox()
        self.refresh_combo.addItems(["60 Hz (Onerilen)", "75 Hz", "120 Hz", "144 Hz", "165 Hz", "240 Hz"])
        layout.addWidget(self.refresh_combo)

        # DPI
        self.dpi_spin = QGroupBox("DPI Ayari")
        dpi_layout = QVBoxLayout(self.dpi_spin)
        self.dpi_check = QCheckBox("Otomatik DPI algilama (Onerilen)")
        self.dpi_check.setChecked(True)
        dpi_layout.addWidget(self.dpi_check)
        layout.addWidget(self.dpi_spin)

        # Coklu ekran
        multi_group = QGroupBox("Coklu Ekran")
        multi_layout = QVBoxLayout(multi_group)
        self.mirror_cb = QCheckBox("Ekranlari yansit (Mirror)")
        self.extend_cb = QCheckBox("Ekranlari genislet (Extended - Onerilen)")
        self.extend_cb.setChecked(True)
        multi_layout.addWidget(self.mirror_cb)
        multi_layout.addWidget(self.extend_cb)
        layout.addWidget(multi_group)

        layout.addStretch()
        self.setLayout(layout)

    def _sl(self, text):
        lbl = QLabel(text)
        lbl.setObjectName("sectionLabel")
        return lbl

    def get_config(self) -> dict:
        res_text = self.res_combo.currentText()
        res = res_text.split(" ")[0] if "(" in res_text else res_text
        return {
            "resolution": res,
            "scale": self.scale_combo.currentText().replace("%%", "").split(" ")[0],
            "refresh": self.refresh_combo.currentText().split(" ")[0],
            "auto_dpi": self.dpi_check.isChecked(),
            "mirror": self.mirror_cb.isChecked(),
            "extend": self.extend_cb.isChecked(),
        }


class PowerPage(QWizardPage):
    def __init__(self, hw_info: HardwareInfo):
        super().__init__()
        self.hw = hw_info

        layout = QVBoxLayout()

        title = QLabel("Guc Ayarlari")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        subtitle = QLabel("Guc yonetimi ve pil tercihleri:")
        subtitle.setObjectName("subtitleLabel")
        layout.addWidget(subtitle)

        # Guc profili
        profile_group = QGroupBox("Guc Profili")
        profile_layout = QVBoxLayout(profile_group)
        self.profile_group = QButtonGroup(self)
        profiles = [
            ("performance", "Performans", "Maksimum hiz, pil omru onemsiz", not self.hw.is_laptop),
            ("balanced", "Dengeli (Onerilen)", "Performans ve pil omru arasinda denge", True),
            ("powersave", "Guc Tasarrufu", "Pil omrunu uzat, dusuk performans", self.hw.is_laptop),
        ]
        for pid, name, desc, rec in profiles:
            rb = QRadioButton(f"  {name}")
            rb.setProperty("profile", pid)
            self.profile_group.addButton(rb)
            profile_layout.addWidget(rb)
            dl = QLabel(desc)
            dl.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 12px; padding-left: 32px;")
            profile_layout.addWidget(dl)
            if rec:
                rb.setChecked(True)
        layout.addWidget(profile_group)

        # Ekran kapanma
        screen_group = QGroupBox("Ekran Kapanma")
        screen_layout = QVBoxLayout(screen_group)
        self.screen_off_combo = QComboBox()
        self.screen_off_combo.addItems([
            "1 dakika", "3 dakika", "5 dakika (Onerilen)",
            "10 dakika", "15 dakika", "30 dakika", "Hic kapatma"
        ])
        self.screen_off_combo.setCurrentIndex(2)
        screen_layout.addWidget(QLabel("Ekran kapanma suresi:"))
        screen_layout.addWidget(self.screen_off_combo)
        layout.addWidget(screen_group)

        # Uyku
        sleep_group = QGroupBox("Uyku Ayarlari")
        sleep_layout = QVBoxLayout(sleep_group)
        self.sleep_combo = QComboBox()
        self.sleep_combo.addItems([
            "5 dakika", "10 dakika", "15 dakika (Onerilen)",
            "30 dakika", "1 saat", "Hic uyuma"
        ])
        self.sleep_combo.setCurrentIndex(2)
        sleep_layout.addWidget(QLabel("Uykuya gecme suresi:"))
        sleep_layout.addWidget(self.sleep_combo)

        if self.hw.is_laptop:
            self.lid_cb = QCheckBox("Kulak kapagini kapatinca uykuya gec (Laptop)")
            self.lid_cb.setChecked(True)
            sleep_layout.addWidget(self.lid_cb)

        layout.addWidget(sleep_group)

        # Pil
        if self.hw.is_laptop:
            battery_group = QGroupBox("Pil Tasarrufu")
            battery_layout = QVBoxLayout(battery_group)
            self.dim_cb = QCheckBox("Pilde ekran karart")
            self.dim_cb.setChecked(True)
            battery_layout.addWidget(self.dim_cb)
            self.battery_perf_cb = QCheckBox("Pilde performansi dusur")
            self.battery_perf_cb.setChecked(True)
            battery_layout.addWidget(self.battery_perf_cb)
            layout.addWidget(battery_group)

        layout.addStretch()
        self.setLayout(layout)

    def get_config(self) -> dict:
        profile_btn = self.profile_group.checkedButton()
        result = {
            "power_profile": profile_btn.property("profile") if profile_btn else "balanced",
            "screen_off": self.screen_off_combo.currentIndex(),
            "sleep": self.sleep_combo.currentIndex(),
        }
        if self.hw.is_laptop:
            result["lid_sleep"] = getattr(self, 'lid_cb', None) and self.lid_cb.isChecked()
            result["dim_battery"] = getattr(self, 'dim_cb', None) and self.dim_cb.isChecked()
            result["battery_perf"] = getattr(self, 'battery_perf_cb', None) and self.battery_perf_cb.isChecked()
        return result


class PreviewPage(QWizardPage):
    def __init__(self):
        super().__init__()

        layout = QVBoxLayout()

        title = QLabel("Secimlerinizin Ozeti")
        title.setObjectName("titleLabel")
        layout.addWidget(title)

        self.summary_text = QTextEdit()
        self.summary_text.setReadOnly(True)
        self.summary_text.setStyleSheet("""
            QTextEdit {
                background-color: rgba(15, 52, 96, 0.3);
                border: 1px solid #2a2a4e;
                border-radius: 12px;
                padding: 16px;
                font-size: 13px;
                line-height: 1.6;
            }
        """)
        layout.addWidget(self.summary_text)

        note = QLabel("Kurulumu baslatmak icin 'Kur' butonuna tiklayin.")
        note.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 13px; padding: 10px;")
        note.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(note)

        self.setLayout(layout)

    def set_summary(self, data: dict):
        lines = []
        for section, items in data.items():
            lines.append(f"<h3 style='color: #4a90d9;'>{section}</h3>")
            for key, value in items.items():
                color = "#2ecc71" if value else "#e74c3c"
                if isinstance(value, bool):
                    value_str = "<span style='color: {}; font-weight: bold;'>{}</span>".format(
                        color, "Evet" if value else "Hayir")
                else:
                    value_str = str(value)
                lines.append(f"  <b>{key}:</b> {value_str}")
            lines.append("<br>")
        self.summary_text.setHtml("<br>".join(lines))


class InstallPage(QWizardPage):
    install_complete = pyqtSignal()

    def __init__(self):
        super().__init__()

        layout = QVBoxLayout()

        self.status_label = QLabel("Kurulum hazirlaniyor...")
        self.status_label.setObjectName("titleLabel")
        self.status_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.status_label)

        self.progress = QProgressBar()
        self.progress.setRange(0, 100)
        layout.addWidget(self.progress)

        self.log_output = QTextEdit()
        self.log_output.setReadOnly(True)
        self.log_output.setMaximumHeight(200)
        self.log_output.setStyleSheet("""
            QTextEdit {
                background-color: #0d0d1a;
                color: #4a90d9;
                border: 1px solid #2a2a4e;
                border-radius: 8px;
                padding: 12px;
                font-family: monospace;
                font-size: 12px;
            }
        """)
        layout.addWidget(self.log_output)

        self.setLayout(layout)

    def log(self, message: str):
        self.log_output.append(f"> {message}")
        QApplication.processEvents()

    def run_installation(self, config: dict):
        steps = [
            ("Donanim algilaniyor...", 3, self._detect_hardware),
            ("Suruculer kuruluyor...", 8, self._install_drivers),
            ("Tema uygulaniyor...", 15, self._apply_theme),
            ("Varsayilan uygulamalar ayarlaniyor...", 20, self._set_default_apps),
            ("Gelistirme araclari kuruluyor...", 28, self._install_dev_tools),
            ("Oyun araclari kuruluyor...", 35, self._install_gaming),
            ("Gizlilik ayarlari yapiliyor...", 42, self._apply_privacy),
            ("Ekran ayarlari uygulaniyor...", 50, self._apply_display),
            ("Guc yonetimi ayarlaniyor...", 55, self._apply_power),
            ("Sistem yapilandiriliyor...", 62, self._configure_system),
            ("KWin ayarlari uygulaniyor...", 70, self._configure_kwin),
            ("Panel duzeni ayarlaniyor...", 78, self._configure_panel),
            ("Bilesenler etkinlestiriliyor...", 85, self._enable_components),
            ("Kullanici olusturuluyor...", 92, self._create_user),
            ("Temizlik yapiliyor...", 97, self._cleanup),
            ("Tamamlandi!", 100, None),
        ]

        for label, progress, func in steps:
            self.status_label.setText(label)
            self.progress.setValue(progress)
            self.log(f"[{progress}%] {label}")
            QApplication.processEvents()

            if func:
                try:
                    func(config)
                except Exception as e:
                    self.log(f"  HATA: {e}")

            QTimer.singleShot(200, lambda: None)

        self.install_complete.emit()

    def _detect_hardware(self, config):
        subprocess.run(["bash", "/usr/lib/karya/scripts/detect-hardware.sh"],
                       capture_output=True)

    def _install_drivers(self, config):
        driver = config.get("driver", "auto")
        subprocess.run(["bash", "/usr/lib/karya/scripts/install-drivers.sh", driver],
                       capture_output=True, timeout=300)

    def _apply_theme(self, config):
        theme = config.get("theme", {})
        ConfigWriter.write_theme(theme)

    def _set_default_apps(self, config):
        apps = config.get("default_apps", {})
        ConfigWriter.write_default_apps(apps)

    def _install_dev_tools(self, config):
        tools = config.get("dev_tools", {})
        ConfigWriter.install_packages(tools, "dev")

    def _install_gaming(self, config):
        gaming = config.get("gaming", {})
        ConfigWriter.install_packages(gaming.get("tools", {}), "gaming")
        if gaming.get("game_mode"):
            ConfigWriter.enable_game_mode()
        if gaming.get("realtime_priority"):
            ConfigWriter.enable_realtime_priority()

    def _apply_privacy(self, config):
        privacy = config.get("privacy", {})
        ConfigWriter.write_privacy(privacy)
        if privacy.get("hostname"):
            ConfigWriter.set_hostname(privacy["hostname"])

    def _apply_display(self, config):
        display = config.get("display", {})
        ConfigWriter.write_display_settings(display)

    def _apply_power(self, config):
        power = config.get("power", {})
        ConfigWriter.write_power_settings(power)

    def _configure_system(self, config):
        ConfigWriter.write_kdeglobals(config)
        ConfigWriter.write_environment(config)

    def _configure_kwin(self, config):
        ConfigWriter.write_kwinrc(config)

    def _configure_panel(self, config):
        layout = config.get("layout", "karya-modern")
        ConfigWriter.write_panel_layout(layout)

    def _enable_components(self, config):
        components = config.get("components", {})
        ConfigWriter.write_components(components)

    def _create_user(self, config):
        user_info = config.get("user", {})
        if user_info.get("username"):
            ConfigWriter.create_user(
                user_info["username"],
                user_info["realname"],
                user_info["password"],
                user_info.get("autologin", False),
            )

    def _cleanup(self, config):
        Path(config.get("lock_file", "/tmp/karya-oobe-done")).touch()


# ==============================================================
# MAIN WIZARD
# ==============================================================

class KaryaSetupWizard(QWizard):
    def __init__(self, hw_info: HardwareInfo):
        super().__init__()
        self.hw = hw_info
        self.setWindowTitle("Karya DE - Kurulum Sihirbazi")
        self.setMinimumSize(720, 600)
        self.setStyleSheet(KARYA_STYLE)

        self.welcome_page = WelcomePage(hw_info)
        self.gpu_page = GpuSelectionPage(hw_info)
        self.layout_page = LayoutPage(hw_info)
        self.components_page = ComponentsPage(hw_info)
        self.theme_page = ThemePage(hw_info)
        self.default_apps_page = DefaultAppsPage()
        self.dev_tools_page = DevToolsPage()
        self.gaming_page = GamingPage()
        self.privacy_page = PrivacyPage()
        self.display_page = DisplayPage(hw_info)
        self.power_page = PowerPage(hw_info)
        self.user_page = UserPage()
        self.preview_page = PreviewPage()
        self.install_page = InstallPage()

        self.addPage(self.welcome_page)
        self.addPage(self.gpu_page)
        self.addPage(self.layout_page)
        self.addPage(self.components_page)
        self.addPage(self.theme_page)
        self.addPage(self.default_apps_page)
        self.addPage(self.dev_tools_page)
        self.addPage(self.gaming_page)
        self.addPage(self.privacy_page)
        self.addPage(self.display_page)
        self.addPage(self.power_page)
        self.addPage(self.user_page)
        self.addPage(self.preview_page)
        self.addPage(self.install_page)

        self.setStartId(0)

        # Button customization
        self.setButtonLayout([
            QWizard.WizardButton.Stretch,
            QWizard.WizardButton.BackButton,
            QWizard.WizardButton.NextButton,
            QWizard.WizardButton.FinishButton,
            QWizard.WizardButton.CancelButton,
        ])

        finish_btn = self.button(QWizard.WizardButton.FinishButton)
        if finish_btn:
            finish_btn.setText("Kur")
            finish_btn.setObjectName("installBtn")

        self.button(QWizard.WizardButton.CancelButton).setObjectName("skipBtn")
        self.button(QWizard.WizardButton.CancelButton).setText("Atla (Skip)")

        # Signals
        self.install_page.install_complete.connect(self._on_install_complete)
        self.currentIdChanged.connect(self._on_page_changed)

    def _on_page_changed(self, page_id):
        if self.page(page_id) == self.preview_page:
            self._update_preview()

    def _update_preview(self):
        config = self._collect_config()
        theme = config.get("theme", {})
        apps = config.get("default_apps", {})
        dev = config.get("dev_tools", {})
        gaming = config.get("gaming", {})
        privacy = config.get("privacy", {})
        disp = config.get("display", {})
        power = config.get("power", {})

        preview_data = {
            "GPU Surucusu": {
                "Secilen Surucu": config["driver"],
                "GPU Modeli": self.hw.get_gpu_display_text(),
            },
            "Masaustu Duzeni": {
                "Duzen": config["layout"],
            },
            "Tema": {
                "Renk Temasi": theme.get("theme", "karya-dark"),
                "Vurgu Rengi": theme.get("accent", "blue"),
                "Glassmorphism": theme.get("glassmorphism", False),
                "Blur": theme.get("blur", False),
                "Animasyon": theme.get("animations", True),
            },
            "Varsayilan Uygulamalar": {
                "Tarayici": apps.get("browser", "firefox"),
                "Terminal": apps.get("terminal", "konsole"),
                "Dosya Yoneticisi": apps.get("file_manager", "dolphin"),
                "Metin Editoru": apps.get("text_editor", "kate"),
                "Muzik": apps.get("music_player", "elisa"),
            },
            "Gelistirme Araclari": {
                "Git": dev.get("git", False),
                "Python": dev.get("python", False),
                "Node.js": dev.get("nodejs", False),
                "Docker": dev.get("docker", False),
                "VS Code": dev.get("vscode", False),
                "GCC/Clang": dev.get("gcc", False),
            },
            "Oyun": {
                "Steam": gaming.get("tools", {}).get("steam", False),
                "Lutris": gaming.get("tools", {}).get("lutris", False),
                "GameMode": gaming.get("tools", {}).get("gamemode", False),
                "Oyun Modu": gaming.get("game_mode", False),
            },
            "Gizlilik": {
                "Konum": privacy.get("location", False),
                "C2k Raporu": privacy.get("crash_reports", True),
                "Telemetri": privacy.get("telemetry", False),
                "Dosya Index": privacy.get("search_index", True),
                "Makine Adi": privacy.get("hostname", "karya-pc"),
            },
            "Ekran": {
                "Cozunurluk": disp.get("resolution", "1920x1080"),
                "Olcekleme": f"{disp.get('scale', '100')}%%",
                "Yenileme": f"{disp.get('refresh', '60')} Hz",
            },
            "Guc": {
                "Profil": power.get("power_profile", "balanced"),
                "Ekran Kapanma": f"{power.get('screen_off', 2)}. sirada",
                "Uyku": f"{power.get('sleep', 2)}. sirada",
            },
            "Bilesenler": {
                "Auto Tiling": config["components"].get("tiling", False),
                "Glassmorphism": config["components"].get("glassmorphism", False),
                "Animasyonlar": config["components"].get("animations", False),
                "Pencere Bulanik": config["components"].get("blur", False),
                "Sicak Koseler": config["components"].get("hotcorners", False),
                "Gece Modu": config["components"].get("nightcolor", False),
            },
            "Kullanici": {
                "Kullanici Adi": config["user"].get("username", "Belirtilmedi"),
                "Otomatik Giris": config["user"].get("autologin", False),
            },
            "Sistem": {
                "Dagitim": self.hw.distro_display,
                "Profil": self.hw.get_performance_label(),
                "RAM": f"{self.hw.ram_mb} MB",
                "CPU": f"{self.hw.cpu_model} ({self.hw.cpu_cores} cekirdek)",
            },
        }
        self.preview_page.set_summary(preview_data)

    def _collect_config(self) -> dict:
        return {
            "driver": self.gpu_page.get_selected_driver(),
            "layout": self.layout_page.get_selected_layout(),
            "components": self.components_page.get_components(),
            "theme": self.theme_page.get_config(),
            "default_apps": self.default_apps_page.get_config(),
            "dev_tools": self.dev_tools_page.get_config(),
            "gaming": self.gaming_page.get_config(),
            "privacy": self.privacy_page.get_config(),
            "display": self.display_page.get_config(),
            "power": self.power_page.get_config(),
            "user": self.user_page.get_user_info(),
            "lock_file": str(Path.home() / ".config" / "karya-first-run.lock"),
        }

    def _on_install_complete(self):
        self.install_page.status_label.setText("Kurulum tamamlandi! Keyfini cikarin.")
        self.install_page.progress.setValue(100)
        finish_btn = self.button(QWizard.WizardButton.FinishButton)
        if finish_btn:
            finish_btn.setText("Kapat")

    def initializePage(self, page_id):
        super().initializePage(page_id)
        if self.page(page_id) == self.install_page:
            config = self._collect_config()
            QTimer.singleShot(500,
                lambda: self.install_page.run_installation(config))


# ==============================================================
# ENTRY POINT
# ==============================================================

def main():
    # Check if already run
    lock = Path.home() / ".config" / "karya-first-run.lock"
    if lock.exists():
        print("[Karya OOBE] Zaten calistirilmis. Atlaniyor.")
        return

    app = QApplication(sys.argv)
    app.setApplicationName("Karya DE Kurulum Sihirbazi")
    app.setOrganizationName("KaryaDE")

    # Donanim algilama
    hw = run_detection()

    wizard = KaryaSetupWizard(hw)
    result = wizard.exec()

    if result == QWizard.DialogCode.Accepted:
        lock.parent.mkdir(parents=True, exist_ok=True)
        lock.touch()
        print("[Karya OOBE] Kurulum basariyla tamamlandi.")
    else:
        print("[Karya OOBE] Kurulum iptal edildi.")


if __name__ == "__main__":
    main()
