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
            ("Donanim algilaniyor...", 5, self._detect_hardware),
            ("Suruculer kuruluyor...", 20, self._install_drivers),
            ("Sistem yapilandiriliyor...", 40, self._configure_system),
            ("KWin ayarlari uygulaniyor...", 55, self._configure_kwin),
            ("Panel duzeni ayarlaniyor...", 70, self._configure_panel),
            ("Bilesenler etkinlestiriliyor...", 80, self._enable_components),
            ("Kullanici olusturuluyor...", 90, self._create_user),
            ("Temizlik yapiliyor...", 95, self._cleanup),
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
        self.user_page = UserPage()
        self.preview_page = PreviewPage()
        self.install_page = InstallPage()

        self.addPage(self.welcome_page)
        self.addPage(self.gpu_page)
        self.addPage(self.layout_page)
        self.addPage(self.components_page)
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
        preview_data = {
            "GPU Surucusu": {
                "Secilen Surucu": config["driver"],
                "GPU Modeli": self.hw.get_gpu_display_text(),
            },
            "Masaustu Duzeni": {
                "Duzen": config["layout"],
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
