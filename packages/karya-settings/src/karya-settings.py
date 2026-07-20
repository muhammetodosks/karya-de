#!/usr/bin/env python3
import sys, subprocess, socket
from pathlib import Path
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QLabel, QGroupBox, QComboBox, QLineEdit,
    QCheckBox, QTabWidget, QMessageBox, QSlider
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont

STYLE = """
QMainWindow { background: #1a1a2e; }
QWidget { color: white; font-size: 13px; }
QGroupBox {
    border: 1px solid #2a2a4e; border-radius: 12px;
    margin-top: 16px; padding: 16px; font-weight: bold; font-size: 14px;
}
QGroupBox::title {
    subcontrol-origin: margin; left: 12px; padding: 0 6px; color: #4a90d9;
}
QPushButton {
    background: #4a90d9; color: white; border: none;
    border-radius: 8px; padding: 10px 20px; font-size: 14px; font-weight: bold;
}
QPushButton:hover { background: #5ba0e9; }
QPushButton#danger { background: #e74c3c; }
QPushButton#danger:hover { background: #c0392b; }
QLabel#title { color: white; font-size: 24px; font-weight: bold; padding: 8px 0; }
QLabel#sub { color: rgba(255,255,255,0.5); font-size: 12px; }
QComboBox {
    background: #0f3460; color: white; border: 1px solid #2a2a4e;
    border-radius: 8px; padding: 8px 12px; font-size: 13px;
}
QLineEdit {
    background: #0f3460; color: white; border: 1px solid #2a2a4e;
    border-radius: 8px; padding: 8px 12px; font-size: 13px;
}
QTabWidget::pane { border: none; background: transparent; }
QTabBar::tab {
    background: #16213e; color: rgba(255,255,255,0.7);
    padding: 10px 20px; border-radius: 8px 8px 0 0; margin-right: 4px;
    font-weight: bold;
}
QTabBar::tab:selected { background: #0f3460; color: #4a90d9; }
QCheckBox { spacing: 8px; padding: 4px; }
QSlider::groove:horizontal {
    height: 6px; background: #2a2a4e; border-radius: 3px;
}
QSlider::handle:horizontal {
    background: #4a90d9; width: 18px; height: 18px;
    margin: -6px 0; border-radius: 9px;
}
QSlider::sub-page:horizontal { background: #4a90d9; border-radius: 3px; }
"""


class KaryaSettings(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Karya Ayarlar")
        self.resize(700, 550)
        self.setStyleSheet(STYLE)

        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setContentsMargins(20, 16, 20, 16)

        title = QLabel("Karya Ayarlar")
        title.setObjectName("title")
        layout.addWidget(title)
        sub = QLabel("Karya DE sistem ayarlari")
        sub.setObjectName("sub")
        layout.addWidget(sub)

        tabs = QTabWidget()
        tabs.addTab(self._general_tab(), "Genel")
        tabs.addTab(self._display_tab(), "Ekran")
        tabs.addTab(self._power_tab(), "Guc")
        tabs.addTab(self._privacy_tab(), "Gizlilik")
        tabs.addTab(self._about_tab(), "Hakkinda")
        layout.addWidget(tabs)

        btn_row = QHBoxLayout()
        btn_row.addStretch()
        self.status_label = QLabel("")
        self.status_label.setStyleSheet("color: #2ecc71; font-weight: bold;")
        btn_row.addWidget(self.status_label)
        save_btn = QPushButton("Ayarlari Kaydet")
        save_btn.clicked.connect(self.save_all)
        btn_row.addWidget(save_btn)
        layout.addLayout(btn_row)

    def _general_tab(self):
        w = QWidget()
        l = QVBoxLayout(w)
        l.setSpacing(8)

        g1 = QGroupBox("Makine Adi")
        g1l = QVBoxLayout(g1)
        self.hostname_input = QLineEdit()
        try:
            self.hostname_input.setText(socket.gethostname())
        except Exception:
            self.hostname_input.setText("karya-pc")
        g1l.addWidget(self.hostname_input)
        l.addWidget(g1)

        g2 = QGroupBox("Varsayilan Uygulamalar")
        g2l = QVBoxLayout(g2)
        g2l.addWidget(QLabel("Tarayici:"))
        self.browser_combo = QComboBox()
        self.browser_combo.addItems(["firefox", "google-chrome", "brave-browser", "chromium"])
        g2l.addWidget(self.browser_combo)
        g2l.addWidget(QLabel("Terminal:"))
        self.terminal_combo = QComboBox()
        self.terminal_combo.addItems(["konsole", "alacritty", "kitty", "gnome-terminal"])
        g2l.addWidget(self.terminal_combo)
        l.addWidget(g2)

        g3 = QGroupBox("Oturum")
        g3l = QVBoxLayout(g3)
        self.autologin_cb = QCheckBox("Otomatik oturum ac")
        g3l.addWidget(self.autologin_cb)
        l.addWidget(g3)

        l.addStretch()
        return w

    def _display_tab(self):
        w = QWidget()
        l = QVBoxLayout(w)

        g1 = QGroupBox("Ekran")
        g1l = QVBoxLayout(g1)
        g1l.addWidget(QLabel("Cozunurluk:"))
        self.res_combo = QComboBox()
        self.res_combo.addItems(["1920x1080", "2560x1440", "1920x1200", "1680x1050", "1366x768"])
        try:
            r = subprocess.run(["xrandr"], capture_output=True, text=True, timeout=3)
            for line in r.stdout.split("\n"):
                if "*" in line:
                    res = line.strip().split()[0]
                    idx = self.res_combo.findText(res)
                    if idx >= 0:
                        self.res_combo.setCurrentIndex(idx)
                    break
        except Exception:
            pass
        g1l.addWidget(self.res_combo)
        g1l.addWidget(QLabel("Olcekleme:"))
        self.scale_combo = QComboBox()
        self.scale_combo.addItems(["100", "125", "150", "175", "200"])
        g1l.addWidget(self.scale_combo)
        l.addWidget(g1)

        g2 = QGroupBox("Gece Modu")
        g2l = QVBoxLayout(g2)
        self.night_cb = QCheckBox("Gece modunu etkinlestir")
        g2l.addWidget(self.night_cb)
        g2l.addWidget(QLabel("Renk Sicakligi:"))
        self.temp_slider = QSlider(Qt.Orientation.Horizontal)
        self.temp_slider.setRange(3000, 6500)
        self.temp_slider.setValue(4500)
        g2l.addWidget(self.temp_slider)
        l.addWidget(g2)

        l.addStretch()
        return w

    def _power_tab(self):
        w = QWidget()
        l = QVBoxLayout(w)

        g1 = QGroupBox("Guc Profili")
        g1l = QVBoxLayout(g1)
        self.profile_combo = QComboBox()
        self.profile_combo.addItems(["performance", "balanced", "powersave"])
        self.profile_combo.setCurrentIndex(1)
        g1l.addWidget(self.profile_combo)
        l.addWidget(g1)

        g2 = QGroupBox("Ekran Kapanma")
        g2l = QVBoxLayout(g2)
        self.screen_combo = QComboBox()
        self.screen_combo.addItems(["1 min", "3 min", "5 min", "10 min", "15 min", "never"])
        g2l.addWidget(self.screen_combo)
        l.addWidget(g2)

        g3 = QGroupBox("Uyku")
        g3l = QVBoxLayout(g3)
        self.sleep_combo = QComboBox()
        self.sleep_combo.addItems(["5 min", "10 min", "15 min", "30 min", "1 hour", "never"])
        g3l.addWidget(self.sleep_combo)
        l.addWidget(g3)

        l.addStretch()
        return w

    def _privacy_tab(self):
        w = QWidget()
        l = QVBoxLayout(w)

        g1 = QGroupBox("Gizlilik")
        g1l = QVBoxLayout(g1)
        self.location_cb = QCheckBox("Konum servisleri")
        self.location_cb.setChecked(False)
        g1l.addWidget(self.location_cb)
        self.crash_cb = QCheckBox("Cokme raporu gonder")
        self.crash_cb.setChecked(True)
        g1l.addWidget(self.crash_cb)
        self.telemetry_cb = QCheckBox("Kullanim verisi gonder")
        self.telemetry_cb.setChecked(False)
        g1l.addWidget(self.telemetry_cb)
        self.recent_cb = QCheckBox("Son dosyalari hatirla")
        self.recent_cb.setChecked(True)
        g1l.addWidget(self.recent_cb)
        l.addWidget(g1)

        l.addStretch()
        return w

    def _about_tab(self):
        w = QWidget()
        l = QVBoxLayout(w)
        l.setAlignment(Qt.AlignmentFlag.AlignCenter)

        title = QLabel("Karya DE")
        title.setStyleSheet("color: #4a90d9; font-size: 32px; font-weight: bold;")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        l.addWidget(title)

        ver = QLabel("Surum 1.0.0")
        ver.setStyleSheet("color: rgba(255,255,255,0.6); font-size: 16px;")
        ver.setAlignment(Qt.AlignmentFlag.AlignCenter)
        l.addWidget(ver)

        desc = QLabel(
            "Modern Turk masaustu ortami\n"
            "Qt6 ve KDE Framework 6 uzerine insa edilmistir.\n\n"
            "Gelistirici: Karya DE Team\n"
            "Lisans: GPL v2.0"
        )
        desc.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 13px; padding: 20px;")
        desc.setAlignment(Qt.AlignmentFlag.AlignCenter)
        l.addWidget(desc)

        l.addStretch()
        return w

    def save_all(self):
        try:
            config_dir = Path.home() / ".config"
            config_dir.mkdir(parents=True, exist_ok=True)

            # Hostname
            hn = self.hostname_input.text().strip()
            if hn:
                subprocess.run(["hostnamectl", "set-hostname", hn], capture_output=True, timeout=10)

            # Profile
            profile = self.profile_combo.currentText()
            if profile == "powersave":
                subprocess.run(["powerprofilesctl", "set", "power-saver"], capture_output=True, timeout=5)
            elif profile == "performance":
                subprocess.run(["powerprofilesctl", "set", "performance"], capture_output=True, timeout=5)
            else:
                subprocess.run(["powerprofilesctl", "set", "balanced"], capture_output=True, timeout=5)

            # Display settings
            display = {
                "resolution": self.res_combo.currentText(),
                "scale": self.scale_combo.currentText(),
                "night_color": self.night_cb.isChecked(),
                "temp": self.temp_slider.value(),
            }
            (config_dir / "karya-display.conf").write_text(
                f"[Display]\nresolution={display['resolution']}\n"
                f"scale={display['scale']}\nnight_color={str(display['night_color']).lower()}\n"
                f"color_temp={display['temp']}\n"
            )

            # Power settings
            (config_dir / "karya-power.conf").write_text(
                f"[Power]\nprofile={profile}\n"
                f"screen_off={self.screen_combo.currentText()}\n"
                f"sleep={self.sleep_combo.currentText()}\n"
            )

            # Privacy settings
            privacy = {
                "location": self.location_cb.isChecked(),
                "crash_reports": self.crash_cb.isChecked(),
                "telemetry": self.telemetry_cb.isChecked(),
                "recent_files": self.recent_cb.isChecked(),
            }
            conf = "[Privacy]\n"
            for k, v in privacy.items():
                conf += f"{k}={str(v).lower()}\n"
            (config_dir / "karya-privacy.conf").write_text(conf)

            self.status_label.setText("Ayarlar kaydedildi!")
            QMessageBox.information(self, "Basarili", "Ayarlar basariyla kaydedildi.")
        except Exception as e:
            self.status_label.setText(f"Hata: {e}")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = KaryaSettings()
    window.show()
    sys.exit(app.exec())
