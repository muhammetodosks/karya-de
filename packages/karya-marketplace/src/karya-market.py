#!/usr/bin/env python3
"""
Karya Market - Tema, Eklenti ve Pazaryeri Yoneticisi
KDE Plasma 6 entegrasyonlu, binlerce tema ve eklenti.
"""
import sys, os, json, subprocess, threading
from pathlib import Path
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QTabWidget, QListWidget, QListWidgetItem, QLabel,
    QLineEdit, QSplitter, QScrollArea, QGridLayout, QFrame,
    QMessageBox, QProgressBar, QDialog, QStackedWidget,
)
from PyQt6.QtCore import Qt, QThread, pyqtSignal, QSize, QTimer
from PyQt6.QtGui import QFont, QIcon, QPixmap

SCRIPT_DIR = Path(__file__).parent.parent
BACKEND_DIR = SCRIPT_DIR / "backend"
sys.path.insert(0, str(BACKEND_DIR))

from karya_theme_manager import ThemeManager
from karya_plugin_manager import PluginManager

STYLE = """
QMainWindow, QDialog { background: #1a1a2e; }
QTabWidget::pane { background: #1a1a2e; border: none; }
QTabBar::tab {
    background: #16213e; color: #8892b0; padding: 12px 24px;
    border: none; font-size: 13px; font-weight: bold;
}
QTabBar::tab:selected { background: #0f3460; color: white; border-bottom: 2px solid #4a90d9; }
QTabBar::tab:hover { background: #0f3460; color: white; }
QListWidget {
    background: #16213e; color: white; border: none;
    border-radius: 8px; padding: 4px; font-size: 13px;
}
QListWidget::item { padding: 12px; border-radius: 8px; margin: 2px; }
QListWidget::item:selected { background: #4a90d9; color: white; }
QListWidget::item:hover { background: #0f3460; }
QLineEdit {
    background: #0f3460; color: white; border: none;
    border-radius: 8px; padding: 10px 16px; font-size: 14px;
}
QPushButton {
    background: #4a90d9; color: white; border: none;
    border-radius: 8px; padding: 8px 20px; font-size: 13px; font-weight: bold;
}
QPushButton:hover { background: #5ba0e9; }
QPushButton#installBtn { background: #27ae60; }
QPushButton#installBtn:hover { background: #2ecc71; }
QPushButton#removeBtn { background: #e74c3c; }
QPushButton#removeBtn:hover { background: #c0392b; }
QPushButton#applyBtn { background: #6c5ce7; }
QPushButton#applyBtn:hover { background: #7c6cf7; }
QPushButton#searchBtn { background: #f39c12; }
QPushButton#searchBtn:hover { background: #e67e22; }
QLabel#header { color: #4a90d9; font-size: 18px; font-weight: bold; }
QLabel#subtitle { color: #8892b0; font-size: 12px; }
QLabel#itemTitle { color: white; font-size: 14px; font-weight: bold; }
QLabel#itemDesc { color: #8892b0; font-size: 11px; }
QLabel#itemAuthor { color: #4a90d9; font-size: 11px; }
QProgressBar {
    background: #16213e; border: none; border-radius: 4px;
    text-align: center; color: white; font-size: 11px;
}
QProgressBar::chunk { background: #4a90d9; border-radius: 4px; }
QFrame#card {
    background: #16213e; border-radius: 12px; padding: 12px;
}
"""

TAB_ICONS = {
    "Temalar": "\U0001F3A8",
    "Eklentiler": "\U0001F50C",
    "Pazaryeri": "\U0001F6D2",
    "Yuklu": "\u2699",
}


class InstallWorker(QThread):
    finished = pyqtSignal(dict)

    def __init__(self, manager, method, *args):
        super().__init__()
        self.manager = manager
        self.method = method
        self.args = args

    def run(self):
        result = getattr(self.manager, self.method)(*self.args)
        self.finished.emit(result)


class ThemeCard(QFrame):
    def __init__(self, data, parent=None):
        super().__init__(parent)
        self.data = data
        self.setObjectName("card")
        self.setup_ui()

    def setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setSpacing(4)

        title = QLabel(self.data.get("title", self.data["name"]))
        title.setObjectName("itemTitle")
        layout.addWidget(title)

        desc = QLabel(self.data.get("description", ""))
        desc.setObjectName("itemDesc")
        desc.setWordWrap(True)
        layout.addWidget(desc)

        row = QHBoxLayout()
        author = QLabel(self.data.get("author", ""))
        author.setObjectName("itemAuthor")
        row.addWidget(author)
        row.addStretch()

        badge = QLabel(self.data.get("type", "").upper())
        badge.setStyleSheet(
            "background: #0f3460; color: #4a90d9; padding: 2px 8px; border-radius: 4px; font-size: 10px;")
        row.addWidget(badge)
        layout.addLayout(row)


class KaryaMarket(QMainWindow):
    def __init__(self):
        super().__init__()
        self.theme_manager = ThemeManager()
        self.plugin_manager = PluginManager()
        self.setWindowTitle("Karya Market")
        self.resize(960, 640)
        self.setStyleSheet(STYLE)

        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setSpacing(8)
        layout.setContentsMargins(16, 16, 16, 16)

        header = QLabel("Karya Market")
        header.setObjectName("header")
        layout.addWidget(header)

        subtitle = QLabel("Tema, Eklenti ve Pazaryeri - KDE Plasma 6")
        subtitle.setObjectName("subtitle")
        layout.addWidget(subtitle)

        self.tabs = QTabWidget()
        layout.addWidget(self.tabs)

        self.tabs.addTab(self._build_themes_tab(), "\U0001F3A8  Temalar")
        self.tabs.addTab(self._build_plugins_tab(), "\U0001F50C  Eklentiler")
        self.tabs.addTab(self._build_store_tab(), "\U0001F6D2  Pazaryeri")
        self.tabs.addTab(self._build_installed_tab(), "\u2699  Y\u00fckl\u00fcler")

    # ================ TAB 1: THEMES ================
    def _build_themes_tab(self):
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("background: transparent; border: none;")

        container = QWidget()
        layout = QVBoxLayout(container)
        layout.setSpacing(12)

        # Theme type selector
        type_row = QHBoxLayout()
        self.theme_type_filter = "plasma"
        for ttype in ["plasma", "kwin", "icons", "color", "sddm", "splash", "cursor", "wallpaper"]:
            btn = QPushButton(ttype.capitalize())
            btn.clicked.connect(lambda _, t=ttype: self._load_themes(t))
            btn.setFixedHeight(32)
            btn.setStyleSheet(
                "background: #0f3460; color: #8892b0; font-size: 11px; padding: 4px 12px;")
            type_row.addWidget(btn)
        type_row.addStretch()
        layout.addLayout(type_row)

        self.theme_grid = QGridLayout()
        self.theme_grid.setSpacing(8)
        layout.addLayout(self.theme_grid)
        layout.addStretch()

        scroll.setWidget(container)
        self._load_themes("plasma")
        return scroll

    def _load_themes(self, theme_type):
        self._clear_grid(self.theme_grid)
        themes = self.theme_manager.list_installed(theme_type)
        if not themes:
            label = QLabel("Henuz tema yuklu degil. Pazaryeri'nden yukleyebilirsiniz.")
            label.setObjectName("itemDesc")
            self.theme_grid.addWidget(label, 0, 0)

        row, col = 0, 0
        for t in themes:
            card = ThemeCard(t)
            btn_row = QHBoxLayout()

            apply_btn = QPushButton("Uygula")
            apply_btn.setObjectName("applyBtn")
            apply_btn.setFixedHeight(28)
            apply_btn.clicked.connect(lambda _, tt=theme_type, n=t["name"]:
                                      self._apply_theme(tt, n))
            btn_row.addWidget(apply_btn)

            remove_btn = QPushButton("Kaldir")
            remove_btn.setObjectName("removeBtn")
            remove_btn.setFixedHeight(28)
            remove_btn.clicked.connect(lambda _, tt=theme_type, n=t["name"]:
                                       self._uninstall_theme(tt, n))
            btn_row.addWidget(remove_btn)

            card.layout().addLayout(btn_row)
            self.theme_grid.addWidget(card, row, col)
            col += 1
            if col >= 3:
                col = 0
                row += 1

    # ================ TAB 2: PLUGINS ================
    def _build_plugins_tab(self):
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("background: transparent; border: none;")

        container = QWidget()
        layout = QVBoxLayout(container)
        layout.setSpacing(12)

        type_row = QHBoxLayout()
        for ptype in ["kwin-script", "plasmoid", "kwin-effect", "krunner", "karya-extension"]:
            btn = QPushButton(ptype.replace("-", " ").title())
            btn.clicked.connect(lambda _, t=ptype: self._load_plugins(t))
            btn.setFixedHeight(32)
            btn.setStyleSheet(
                "background: #0f3460; color: #8892b0; font-size: 11px; padding: 4px 12px;")
            type_row.addWidget(btn)
        type_row.addStretch()
        layout.addLayout(type_row)

        self.plugin_grid = QGridLayout()
        self.plugin_grid.setSpacing(8)
        layout.addLayout(self.plugin_grid)
        layout.addStretch()

        scroll.setWidget(container)
        self._load_plugins("kwin-script")
        return scroll

    def _load_plugins(self, ptype):
        self._clear_grid(self.plugin_grid)
        plugins = self.plugin_manager.list_installed(ptype)
        if not plugins:
            label = QLabel("Henuz eklenti yuklu degil. Pazaryeri'nden yukleyebilirsiniz.")
            label.setObjectName("itemDesc")
            self.plugin_grid.addWidget(label, 0, 0)

        row, col = 0, 0
        for p in plugins:
            card = ThemeCard(p)
            btn_row = QHBoxLayout()

            toggle_text = "Devre Disi" if p.get("enabled", True) else "Aktif Et"
            toggle_btn = QPushButton(toggle_text)
            toggle_btn.setObjectName("applyBtn")
            toggle_btn.setFixedHeight(28)
            toggle_btn.clicked.connect(lambda _, pt=ptype, n=p["name"], e=p.get("enabled", True):
                                       self._toggle_plugin(pt, n, not e))
            btn_row.addWidget(toggle_btn)

            remove_btn = QPushButton("Kaldir")
            remove_btn.setObjectName("removeBtn")
            remove_btn.setFixedHeight(28)
            remove_btn.clicked.connect(lambda _, pt=ptype, n=p["name"]:
                                       self._uninstall_plugin(pt, n))
            btn_row.addWidget(remove_btn)

            card.layout().addLayout(btn_row)
            self.plugin_grid.addWidget(card, row, col)
            col += 1
            if col >= 3:
                col = 0
                row += 1

    # ================ TAB 3: STORE ================
    def _build_store_tab(self):
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("background: transparent; border: none;")

        container = QWidget()
        layout = QVBoxLayout(container)
        layout.setSpacing(12)

        # Search bar
        search_row = QHBoxLayout()
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Tema veya eklenti ara (binlerce secenek)...")
        search_row.addWidget(self.search_input)

        search_btn = QPushButton("Ara")
        search_btn.setObjectName("searchBtn")
        search_btn.clicked.connect(self._do_search)
        search_row.addWidget(search_btn)
        layout.addLayout(search_row)

        # Category buttons
        cat_row = QHBoxLayout()
        for cat_id, cat_data in self.theme_manager.get_store_collections().items():
            btn = QPushButton(cat_data["title"])
            btn.clicked.connect(lambda _, c=cat_id: self._load_collection(c))
            btn.setFixedHeight(32)
            btn.setStyleSheet(
                "background: #0f3460; color: #8892b0; font-size: 11px; padding: 4px 12px;")
            cat_row.addWidget(btn)
        cat_row.addStretch()
        layout.addLayout(cat_row)

        # Plugin collections
        plugin_cat_row = QHBoxLayout()
        store_data = self.plugin_manager.list_store()
        for cat_id, cat_data in store_data.items():
            btn = QPushButton(cat_data["title"])
            btn.clicked.connect(lambda _, c=cat_id: self._load_plugin_collection(c))
            btn.setFixedHeight(32)
            btn.setStyleSheet(
                "background: #16213e; color: #6c5ce7; font-size: 11px; padding: 4px 12px;")
            plugin_cat_row.addWidget(btn)
        plugin_cat_row.addStretch()
        layout.addLayout(plugin_cat_row)

        self.store_grid = QGridLayout()
        self.store_grid.setSpacing(8)
        layout.addLayout(self.store_grid)
        layout.addStretch()

        scroll.setWidget(container)
        self._load_store_default()
        return scroll

    def _load_store_default(self):
        self._clear_grid(self.store_grid)
        collections = self.theme_manager.get_store_collections()
        row = 0
        for cat_id, cat_data in collections.items():
            title = QLabel(cat_data["title"])
            title.setObjectName("itemTitle")
            self.store_grid.addWidget(title, row, 0, 1, 3)
            row += 1

            for item in cat_data["items"]:
                card = ThemeCard(item)
                btn = QPushButton("Yukle" if not item["installed"] else "Yuklu")
                btn.setObjectName("installBtn" if not item["installed"] else "applyBtn")
                btn.setFixedHeight(28)
                if not item["installed"]:
                    btn.clicked.connect(lambda _, n=item["name"], t=cat_data["type"]:
                                       self._install_store_item(n, t))
                card.layout().addWidget(btn)
                self.store_grid.addWidget(card, row, 0, 1, 3)
                row += 1

    def _load_collection(self, cat_id):
        self._clear_grid(self.store_grid)
        collections = self.theme_manager.get_store_collections()
        data = collections.get(cat_id, {})
        title = QLabel(data.get("title", cat_id))
        title.setObjectName("itemTitle")
        self.store_grid.addWidget(title, 0, 0, 1, 3)

        for i, item in enumerate(data.get("items", []), 1):
            card = ThemeCard(item)
            btn = QPushButton("Yukle" if not item["installed"] else "Yuklu")
            btn.setObjectName("installBtn" if not item["installed"] else "applyBtn")
            btn.setFixedHeight(28)
            if not item["installed"]:
                btn.clicked.connect(lambda _, n=item["name"], t=data["type"]:
                                   self._install_store_item(n, t))
            card.layout().addWidget(btn)
            self.store_grid.addWidget(card, i, 0, 1, 3)

    def _load_plugin_collection(self, cat_id):
        self._clear_grid(self.store_grid)
        store_data = self.plugin_manager.list_store()
        data = store_data.get(cat_id, {})
        title = QLabel(data.get("title", cat_id))
        title.setObjectName("itemTitle")
        self.store_grid.addWidget(title, 0, 0, 1, 3)

        for i, item in enumerate(data.get("items", []), 1):
            card = ThemeCard(item)
            btn = QPushButton("Yukle" if not item["installed"] else "Yuklu")
            btn.setObjectName("installBtn" if not item["installed"] else "applyBtn")
            btn.setFixedHeight(28)
            if not item["installed"]:
                btn.clicked.connect(lambda _, n=item["name"]:
                                   QMessageBox.information(self, "Bilgi",
                                       f"{n} yuklemesi KDE Store uzerinden yapilacak."))
            card.layout().addWidget(btn)
            self.store_grid.addWidget(card, i, 0, 1, 3)

    def _do_search(self):
        query = self.search_input.text().strip()
        if not query:
            return
        self._clear_grid(self.store_grid)
        title = QLabel(f"\"{query}\" icin sonuclar:")
        title.setObjectName("itemTitle")
        self.store_grid.addWidget(title, 0, 0, 1, 3)

        results = self.theme_manager.search_store(query)
        for i, r in enumerate(results[:20], 1):
            item_data = {
                "name": r.get("name", "Bilinmiyor"),
                "title": r.get("title", r.get("name", "Bilinmiyor")),
                "description": r.get("description", "")[:80],
                "author": r.get("author", {}).get("name", ""),
                "type": r.get("category", "unknown"),
            }
            card = ThemeCard(item_data)
            self.store_grid.addWidget(card, i, 0, 1, 3)

    # ================ TAB 4: INSTALLED ================
    def _build_installed_tab(self):
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("background: transparent; border: none;")

        container = QWidget()
        layout = QVBoxLayout(container)
        layout.setSpacing(8)

        title = QLabel("Yuklu Bilesenler")
        title.setObjectName("itemTitle")
        layout.addWidget(title)

        refresh_btn = QPushButton("Yenile")
        refresh_btn.clicked.connect(self._refresh_installed)
        layout.addWidget(refresh_btn)

        self.installed_grid = QGridLayout()
        self.installed_grid.setSpacing(8)
        layout.addLayout(self.installed_grid)
        layout.addStretch()

        scroll.setWidget(container)
        self._refresh_installed()
        return scroll

    def _refresh_installed(self):
        self._clear_grid(self.installed_grid)
        all_themes = self.theme_manager.list_installed()
        all_plugins = self.plugin_manager.list_installed()
        all_items = all_themes + all_plugins

        if not all_items:
            label = QLabel("Henuz hicbir sey yuklu degil.")
            label.setObjectName("itemDesc")
            self.installed_grid.addWidget(label, 0, 0)
            return

        row = 0
        for item in all_items:
            card = ThemeCard(item)
            type_badge = QLabel(item.get("type", "").upper())
            type_badge.setStyleSheet(
                "background: #0f3460; color: #4a90d9; padding: 2px 8px; border-radius: 4px; font-size: 10px;")
            card.layout().addWidget(type_badge)
            self.installed_grid.addWidget(card, row, 0, 1, 3)
            row += 1

    # ================ ACTIONS ================
    def _apply_theme(self, theme_type, name):
        result = self.theme_manager.apply_theme(theme_type, name)
        if result.get("success"):
            QMessageBox.information(self, "Uygulandi",
                f"{name} temasi uygulandi. Tam etki icin oturumu kapatip acin.")
        else:
            QMessageBox.warning(self, "Hata", "Tema uygulanamadi.")

    def _uninstall_theme(self, theme_type, name):
        reply = QMessageBox.question(self, "Kaldir",
            f"{name} kaldirilsin mi?", QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            self.theme_manager.uninstall_theme(theme_type, name)
            self._load_themes(theme_type)

    def _toggle_plugin(self, ptype, name, enable):
        self.plugin_manager.toggle_plugin(ptype, name, enable)
        self._load_plugins(ptype)

    def _uninstall_plugin(self, ptype, name):
        reply = QMessageBox.question(self, "Kaldir",
            f"{name} kaldirilsin mi?", QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            self.plugin_manager.uninstall_plugin(ptype, name)
            self._load_plugins(ptype)

    def _install_store_item(self, name, theme_type):
        QMessageBox.information(self, "KDE Store",
            f"{name} KDE Store uzerinden yuklenecek. KDE Store hesabinizla giris yapmaniz gerekebilir.\n\n"
            "Yukleme tamamlandiktan sonra \"Yukluler\" sekmesinden yonelebilirsiniz.")

    @staticmethod
    def _clear_grid(grid):
        while grid.count():
            item = grid.takeAt(0)
            if item.widget():
                item.widget().deleteLater()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = KaryaMarket()
    window.show()
    sys.exit(app.exec())
