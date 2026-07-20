#!/usr/bin/env python3
import sys, json
from pathlib import Path
from datetime import datetime
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QListWidget, QTextEdit, QLabel, QListWidgetItem,
    QSplitter, QInputDialog, QMessageBox
)
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QFont, QIcon

STYLE = """
QMainWindow { background: #1a1a2e; }
QListWidget {
    background: #16213e; color: white; border: none;
    border-radius: 8px; padding: 4px; font-size: 13px;
    outline: none;
}
QListWidget::item {
    padding: 12px; border-radius: 8px; margin: 2px;
}
QListWidget::item:selected {
    background: #4a90d9; color: white;
}
QListWidget::item:hover {
    background: #0f3460;
}
QTextEdit {
    background: #16213e; color: white; border: none;
    border-radius: 8px; padding: 16px; font-size: 14px;
}
QPushButton {
    background: #4a90d9; color: white; border: none;
    border-radius: 8px; padding: 8px 16px; font-size: 13px; font-weight: bold;
}
QPushButton:hover { background: #5ba0e9; }
QPushButton#deleteBtn { background: #e74c3c; }
QPushButton#deleteBtn:hover { background: #c0392b; }
QLabel#title { color: #4a90d9; font-size: 16px; font-weight: bold; padding: 4px; }
"""

NOTES_DIR = Path.home() / ".local" / "share" / "karya-notes"


class KaryaNotes(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Karya Not Defteri")
        self.resize(800, 550)
        self.setStyleSheet(STYLE)
        NOTES_DIR.mkdir(parents=True, exist_ok=True)

        self.notes = []
        self.current_id = None
        self.dirty = False

        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setSpacing(8)
        layout.setContentsMargins(12, 12, 12, 12)

        title = QLabel("Karya Not Defteri")
        title.setObjectName("title")
        layout.addWidget(title)

        splitter = QSplitter(Qt.Orientation.Horizontal)

        left = QWidget()
        left_layout = QVBoxLayout(left)
        left_layout.setContentsMargins(0, 0, 4, 0)

        btn_row = QHBoxLayout()
        new_btn = QPushButton("+ Yeni Not")
        new_btn.clicked.connect(self.new_note)
        btn_row.addWidget(new_btn)
        delete_btn = QPushButton("Sil")
        delete_btn.setObjectName("deleteBtn")
        delete_btn.clicked.connect(self.delete_note)
        btn_row.addWidget(delete_btn)
        left_layout.addLayout(btn_row)

        self.note_list = QListWidget()
        self.note_list.currentRowChanged.connect(self.on_note_selected)
        left_layout.addWidget(self.note_list)
        splitter.addWidget(left)

        right = QWidget()
        right_layout = QVBoxLayout(right)
        right_layout.setContentsMargins(4, 0, 0, 0)

        self.editor = QTextEdit()
        self.editor.setPlaceholderText("Notunuzu buraya yazin...")
        self.editor.textChanged.connect(self._mark_dirty)
        right_layout.addWidget(self.editor)

        save_btn = QPushButton("Kaydet")
        save_btn.clicked.connect(self.save_current)
        right_layout.addWidget(save_btn)

        splitter.addWidget(right)
        splitter.setSizes([250, 550])
        layout.addWidget(splitter)

        self.load_notes()
        if self.notes:
            self.note_list.setCurrentRow(0)

        # Auto-save every 30 seconds
        self.save_timer = QTimer()
        self.save_timer.timeout.connect(self.auto_save)
        self.save_timer.start(30000)

    def _mark_dirty(self):
        self.dirty = True

    def load_notes(self):
        self.notes = []
        self.note_list.clear()
        for f in sorted(NOTES_DIR.glob("*.json"), reverse=True):
            try:
                data = json.loads(f.read_text())
                data["_path"] = str(f)
                self.notes.append(data)
                item = QListWidgetItem(data.get("title", "Isimsiz"))
                timestamp = data.get("updated", data.get("created", ""))
                if timestamp:
                    try:
                        dt = datetime.fromisoformat(timestamp)
                        item.setToolTip(dt.strftime("%d %B %Y %H:%M"))
                    except:
                        pass
                self.note_list.addItem(item)
            except Exception:
                pass

    def new_note(self):
        title, ok = QInputDialog.getText(self, "Yeni Not", "Not basligi:")
        if ok and title.strip():
            now = datetime.now().isoformat()
            note = {"id": str(len(self.notes) + 1), "title": title.strip(),
                    "content": "", "created": now, "updated": now}
            path = NOTES_DIR / f"note-{note['id']}.json"
            path.write_text(json.dumps(note, indent=2))
            note["_path"] = str(path)
            self.notes.insert(0, note)
            item = QListWidgetItem(note["title"])
            self.note_list.insertItem(0, item)
            self.note_list.setCurrentRow(0)

    def delete_note(self):
        if self.current_id is None:
            return
        reply = QMessageBox.question(self, "Notu Sil",
            "Bu notu silmek istediginize emin misiniz?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            for i, n in enumerate(self.notes):
                if n.get("id") == self.current_id:
                    path = Path(n["_path"])
                    if path.exists():
                        path.unlink()
                    self.notes.pop(i)
                    self.note_list.takeItem(i)
                    self.editor.clear()
                    self.current_id = None
                    break

    def on_note_selected(self, row):
        if row < 0 or row >= len(self.notes):
            return
        self.save_current()
        note = self.notes[row]
        self.current_id = note.get("id")
        self.editor.setPlainText(note.get("content", ""))
        self.dirty = False

    def save_current(self):
        if self.current_id is None or not self.dirty:
            return
        for i, n in enumerate(self.notes):
            if n.get("id") == self.current_id:
                self.notes[i]["content"] = self.editor.toPlainText()
                self.notes[i]["updated"] = datetime.now().isoformat()
                path = Path(self.notes[i]["_path"])
                path.write_text(json.dumps(self.notes[i], indent=2))
                self.dirty = False
                break

    def auto_save(self):
        if self.dirty:
            self.save_current()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = KaryaNotes()
    window.show()
    sys.exit(app.exec())
