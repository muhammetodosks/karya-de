#!/usr/bin/env python3
import sys, os, subprocess, threading
from pathlib import Path
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLineEdit, QListWidget, QLabel, QPushButton, QListWidgetItem
)
from PyQt6.QtCore import Qt, QTimer, pyqtSignal, QObject
from PyQt6.QtGui import QFont

STYLE = """
QMainWindow { background: #1a1a2e; }
QLineEdit {
    background: #0f3460; color: white; border: none;
    border-radius: 12px; padding: 14px 18px; font-size: 16px;
}
QLineEdit:focus { border: 2px solid #4a90d9; }
QListWidget {
    background: transparent; color: white; border: none;
    font-size: 14px; outline: none;
}
QListWidget::item {
    padding: 12px 16px; border-radius: 8px; margin: 2px;
}
QListWidget::item:selected {
    background: #4a90d9; color: white;
}
QListWidget::item:hover {
    background: #0f3460;
}
QLabel#title {
    color: #4a90d9; font-size: 18px; font-weight: bold; padding: 8px;
}
QLabel#hint {
    color: rgba(255,255,255,0.4); font-size: 12px; padding: 4px;
}
QPushButton {
    background: transparent; color: white; border: 1px solid #4a90d9;
    border-radius: 8px; padding: 6px 14px; font-size: 12px;
}
QPushButton:hover { background: rgba(74,144,217,0.2); }
"""


class SearchWorker(QObject):
    results_ready = pyqtSignal(list)

    def search(self, query, paths, max_results=30):
        results = []
        if not query or len(query) < 2:
            self.results_ready.emit(results)
            return
        q = query.lower()
        try:
            # Search PATH binaries
            path_dirs = os.environ.get("PATH", "/usr/bin:/usr/local/bin").split(":")
            for d in path_dirs:
                if len(results) >= max_results:
                    break
                try:
                    for f in os.listdir(d):
                        if len(results) >= max_results:
                            break
                        if q in f.lower() and not f.startswith("."):
                            fp = os.path.join(d, f)
                            results.append(("app", f, fp, "Uygulama"))
                except PermissionError:
                    pass

            # Search home directories
            home = str(Path.home())
            for base in paths:
                if len(results) >= max_results:
                    break
                base_path = os.path.join(home, base)
                if not os.path.exists(base_path):
                    continue
                try:
                    for root, dirs, files in os.walk(base_path):
                        if len(results) >= max_results:
                            break
                        for f in files:
                            if len(results) >= max_results:
                                break
                            if q in f.lower() and not f.startswith("."):
                                fp = os.path.join(root, f)
                                size = os.path.getsize(fp) if os.path.exists(fp) else 0
                                label = f"{size // 1024} KB" if size < 1024 * 1024 else f"{size // 1024 // 1024} MB"
                                results.append(("file", f, fp, label))
                except PermissionError:
                    pass
        except Exception:
            pass
        self.results_ready.emit(results[:max_results])


class KaryaSearch(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Karya Ara")
        self.resize(600, 450)
        self.setStyleSheet(STYLE)

        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setSpacing(8)
        layout.setContentsMargins(16, 16, 16, 16)

        title = QLabel("Karya Ara")
        title.setObjectName("title")
        layout.addWidget(title)

        search_row = QHBoxLayout()
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Uygulama veya dosya ara...")
        self.search_input.setFont(QFont("Noto Sans", 16))
        self.search_input.textChanged.connect(self.on_text_changed)
        search_row.addWidget(self.search_input)
        layout.addLayout(search_row)

        hint = QLabel("En az 2 karakter yazin. Enter ile ilk sonucu acin.")
        hint.setObjectName("hint")
        layout.addWidget(hint)

        self.results_list = QListWidget()
        self.results_list.itemDoubleClicked.connect(self.open_result)
        self.results_list.itemActivated.connect(self.open_result)
        layout.addWidget(self.results_list)

        self.worker = SearchWorker()
        self.worker.results_ready.connect(self.show_results)
        self.search_timer = QTimer()
        self.search_timer.setSingleShot(True)
        self.search_timer.timeout.connect(self.do_search)

        self.search_thread = None

    def on_text_changed(self, text):
        self.search_timer.start(200)

    def do_search(self):
        query = self.search_input.text().strip()
        if len(query) < 2:
            self.results_list.clear()
            return
        paths = ["Desktop", "Documents", "Downloads", ".local/share"]
        import threading
        t = threading.Thread(target=self.worker.search, args=(query, paths))
        t.start()

    def show_results(self, results):
        self.results_list.clear()
        for rtype, name, path, desc in results:
            icon = "🔧" if rtype == "app" else "📄"
            text = f"{icon} {name}"
            item = QListWidgetItem(text)
            item.setToolTip(path)
            item.setData(Qt.ItemDataRole.UserRole, (rtype, path))
            self.results_list.addItem(item)

    def open_result(self, item):
        data = item.data(Qt.ItemDataRole.UserRole)
        if not data:
            return
        rtype, path = data
        try:
            if rtype == "app":
                subprocess.Popen([path], start_new_session=True)
            else:
                subprocess.Popen(["xdg-open", path], start_new_session=True)
        except Exception:
            pass


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = KaryaSearch()
    window.show()
    sys.exit(app.exec())
