#!/usr/bin/env python3
import sys, math
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QGridLayout,
    QPushButton, QLineEdit, QLabel
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont

STYLE = """
QMainWindow { background: #1a1a2e; }
QLineEdit {
    background: #0f3460; color: white; border: none;
    border-radius: 12px; padding: 16px; font-size: 28px; font-weight: bold;
    text-align: right; min-height: 50px;
}
QPushButton {
    background: #16213e; color: white; border: none;
    border-radius: 12px; font-size: 20px; font-weight: bold;
    min-width: 70px; min-height: 60px;
}
QPushButton:hover { background: #0f3460; }
QPushButton:pressed { background: #4a90d9; }
QPushButton.op { background: #4a90d9; }
QPushButton.op:hover { background: #3a7bc8; }
QPushButton.equal { background: #27ae60; }
QPushButton.equal:hover { background: #2ecc71; }
QPushButton.clear { background: #e74c3c; }
QPushButton.clear:hover { background: #c0392b; }
"""

class KaryaCalc(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Karya Hesap Makinesi")
        self.setFixedSize(340, 500)
        self.setStyleSheet(STYLE)

        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setSpacing(8)
        layout.setContentsMargins(12, 12, 12, 12)

        title = QLabel("Karya Calc")
        title.setStyleSheet("color: #4a90d9; font-size: 14px; font-weight: bold; padding: 4px;")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title)

        self.display = QLineEdit("0")
        self.display.setReadOnly(True)
        self.display.setAlignment(Qt.AlignmentFlag.AlignRight)
        self.display.setFont(QFont("Noto Sans", 28, QFont.Weight.Bold))
        layout.addWidget(self.display)

        self.prev = ""
        self.op = ""
        self.reset_display = False

        buttons = [
            ("C", "clear", 1), ("±", "neg", 1), ("%", "%", 1), ("÷", "/", 1),
            ("7", "7", 1), ("8", "8", 1), ("9", "9", 1), ("×", "*", 1),
            ("4", "4", 1), ("5", "5", 1), ("6", "6", 1), ("−", "-", 1),
            ("1", "1", 1), ("2", "2", 1), ("3", "3", 1), ("+", "+", 1),
            ("0", "0", 2), (".", ".", 1), ("=", "=", 1),
        ]

        grid = QGridLayout()
        grid.setSpacing(6)
        r, c = 0, 0
        for text, cmd, span in buttons:
            btn = QPushButton(text)
            if cmd in ("clear",):
                btn.setProperty("class", "clear")
                btn.setStyleSheet(self._btn_style("#e74c3c"))
            elif cmd == "=":
                btn.setProperty("class", "equal")
                btn.setStyleSheet(self._btn_style("#27ae60"))
            elif cmd in ("+", "-", "*", "/", "%"):
                btn.setProperty("class", "op")
                btn.setStyleSheet(self._btn_style("#4a90d9"))
            else:
                btn.setStyleSheet(self._btn_style("#16213e"))
            btn.clicked.connect(lambda _, c=cmd: self._click(c))
            grid.addWidget(btn, r, c, 1, span)
            c += span
            if c >= 4:
                c = 0
                r += 1
        layout.addLayout(grid)

    def _btn_style(self, color):
        return f"""
            QPushButton {{
                background: {color}; color: white; border: none;
                border-radius: 12px; font-size: 20px; font-weight: bold;
                min-width: 70px; min-height: 60px;
            }}
            QPushButton:hover {{ background: {self._lighten(color)}; }}
        """

    def _lighten(self, h):
        return h.replace("e74c3c", "c0392b").replace("27ae60", "2ecc71").replace("4a90d9", "5ba0e9").replace("16213e", "0f3460")

    def _click(self, cmd):
        cur = self.display.text()
        if cmd.isdigit() or cmd == ".":
            if self.reset_display or cur == "0":
                self.display.setText(cmd if cmd != "." else "0.")
                self.reset_display = False
            else:
                if cmd == "." and "." in cur:
                    return
                self.display.setText(cur + cmd)
        elif cmd in ("+", "-", "*", "/", "%"):
            self.prev = cur
            self.op = cmd
            self.reset_display = True
        elif cmd == "=":
            if not self.op:
                return
            try:
                a, b = float(self.prev), float(cur)
                result = {
                    "+": a + b, "-": a - b, "*": a * b,
                    "/": a / b if b != 0 else float("inf"),
                    "%": a * b / 100
                }[self.op]
                if result == float("inf"):
                    self.display.setText("Hata")
                else:
                    self.display.setText(str(int(result) if result == int(result) else round(result, 10)))
            except Exception:
                self.display.setText("Hata")
            self.op = ""
            self.reset_display = True
        elif cmd == "clear":
            self.display.setText("0")
            self.prev = ""
            self.op = ""
        elif cmd == "neg":
            if cur == "Hata":
                return
            if cur.startswith("-"):
                self.display.setText(cur[1:])
            else:
                self.display.setText("-" + cur)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = KaryaCalc()
    window.show()
    sys.exit(app.exec())
