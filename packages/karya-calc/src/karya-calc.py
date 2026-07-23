#!/usr/bin/env python3
import sys
from decimal import Decimal, DivisionByZero, InvalidOperation
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

        self.prev = Decimal("0")
        self.op = ""
        self.reset_display = False

        buttons = [
            ("C", "clear"), ("±", "neg"), ("%", "%"), ("÷", "/"),
            ("7", "7"), ("8", "8"), ("9", "9"), ("×", "*"),
            ("4", "4"), ("5", "5"), ("6", "6"), ("−", "-"),
            ("1", "1"), ("2", "2"), ("3", "3"), ("+", "+"),
            ("", ""), ("0", "0"), (".", "."), ("=", "="),
        ]

        grid = QGridLayout()
        grid.setSpacing(6)
        r, c = 0, 0
        for text, cmd in buttons:
            if not cmd:
                c += 1
                continue
            btn = QPushButton(text)
            if cmd == "clear":
                btn.setStyleSheet(self._btn_style("#e74c3c"))
            elif cmd == "=":
                btn.setStyleSheet(self._btn_style("#27ae60"))
            elif cmd in ("+", "-", "*", "/", "%"):
                btn.setStyleSheet(self._btn_style("#4a90d9"))
            else:
                btn.setStyleSheet(self._btn_style("#16213e"))
            btn.clicked.connect(lambda _, c=cmd: self._click(c))
            grid.addWidget(btn, r, c, 1, 1)
            c += 1
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

    @staticmethod
    def _lighten(h):
        return {"#e74c3c": "#c0392b", "#27ae60": "#2ecc71",
                "#4a90d9": "#5ba0e9", "#16213e": "#0f3460"}.get(h, h)

    @staticmethod
    def _sanitize_input(val: str) -> str:
        allowed = set("0123456789.-")
        sanitized = "".join(c for c in val if c in allowed)
        if not sanitized or sanitized in ("-", "."):
            return "0"
        return sanitized

    def _click(self, cmd):
        cur = self.display.text()

        if cmd == "clear":
            self.display.setText("0")
            self.prev = Decimal("0")
            self.op = ""
            self.reset_display = False

        elif cmd == "neg":
            if cur in ("Hata", "0"):
                return
            self.display.setText(("-" + cur) if not cur.startswith("-") else cur[1:])

        elif cmd.isdigit() or cmd == ".":
            if self.reset_display or cur == "0":
                self.display.setText(cmd if cmd != "." else "0.")
                self.reset_display = False
            else:
                if cmd == "." and "." in cur:
                    return
                self.display.setText(cur + cmd)

        elif cmd in ("+", "-", "*", "/", "%"):
            safe = self._sanitize_input(cur)
            try:
                self.prev = Decimal(safe)
            except:
                self.prev = Decimal("0")
            self.op = cmd
            self.reset_display = True

        elif cmd == "=":
            if not self.op:
                return
            try:
                a = self.prev
                safe_b = self._sanitize_input(cur)
                b = Decimal(safe_b)
                ops = {
                    "+": lambda x, y: x + y,
                    "-": lambda x, y: x - y,
                    "*": lambda x, y: x * y,
                    "/": lambda x, y: x / y,
                    "%": lambda x, y: x * y / Decimal("100"),
                }
                result = ops[self.op](a, b)
                if isinstance(result, Decimal):
                    if result == result.to_integral_value():
                        self.display.setText(str(int(result)))
                    else:
                        self.display.setText(str(round(result, 10)))
            except (DivisionByZero, InvalidOperation):
                self.display.setText("Hata")
            except Exception:
                self.display.setText("Hata")
            self.op = ""
            self.reset_display = True


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = KaryaCalc()
    window.show()
    sys.exit(app.exec())
