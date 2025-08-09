import sys
import subprocess
import platform
from pathlib import Path
from PyQt6.QtCore import QObject, pyqtSignal, QSize, QTimer
from PyQt6.QtGui import QMovie

from src.config import ConfigManager

class EmittingStream(QObject):
    textWritten = pyqtSignal(str)

    def write(self, text):
        self.textWritten.emit(str(text))
        sys.__stdout__.write(text)

    def flush(self):
        sys.__stdout__.flush()


class GitConsoleSimulation:
    def __init__(self, ui):
        self.ui = ui
        self.config = ConfigManager()
        self.config.load()
        self.redirect_stdout_to_console()
        self.ui.gitComplete.hide()
        self.movie = QMovie(":/resources/icon/loading2.gif")
        self.movie.setScaledSize(QSize(32, 32))
        self.ui.gitgif.setMovie(self.movie)
        self.movie.start()

    def redirect_stdout_to_console(self):
        self.stdout_stream = EmittingStream()
        self.stdout_stream.textWritten.connect(self.append_to_console)
        sys.stdout = self.stdout_stream
        sys.stderr = self.stdout_stream  # optional

    def append_to_console(self, text):
        self.ui.gitConsole.appendPlainText(text.rstrip())
        self.ui.gitConsole.verticalScrollBar().setValue(
            self.ui.gitConsole.verticalScrollBar().maximum()
        )