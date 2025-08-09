from PyQt6.QtCore import QUrl
from PyQt6.QtWidgets import QLineEdit
import re

from src.config import ConfigManager


class KindofAWebBrowser:
    def __init__(self, ui):
        self.ui = ui
        self.config = ConfigManager()
        self.config.load()

        self.saved_themes = self.config.get('saved_themes') or {}

        self.urlbar = self.ui.BrowserUrlBar
        self.urlbar.returnPressed.connect(self.navigate_to_url)

        self.ui.buttonHome.clicked.connect(self.go_home)
        self.ui.buttonBack.clicked.connect(self.go_back)
        self.ui.buttonForward.clicked.connect(self.go_forward)
        self.ui.buttonReload.clicked.connect(self.reload_page)
        self.ui.buttonSelect.clicked.connect(self.save_current_theme)

        self.ui.fcsBrowser.urlChanged.connect(self.update_urlbar)
        self.home_url = "https://firefoxcss-store.github.io/"
        self.go_home()

        self.theme_dropdown = self.ui.saved_themes_dropdown

    def navigate_to_url(self):
        url_text = self.urlbar.text().strip()
        if url_text:
            if not re.match(r'^[a-zA-Z]+://', url_text):
                url_text = "https://" + url_text
            url = QUrl(url_text)
            if url.isValid():
                self.ui.fcsBrowser.setUrl(url)

    def go_home(self):
        self.ui.fcsBrowser.setUrl(QUrl(self.home_url))

    def go_back(self):
        self.ui.fcsBrowser.back()

    def go_forward(self):
        self.ui.fcsBrowser.forward()

    def reload_page(self):
        self.ui.fcsBrowser.reload()

    def update_urlbar(self, url: QUrl):
        self.urlbar.blockSignals(True)
        self.urlbar.setText(url.toString())
        self.urlbar.blockSignals(False)

    def save_current_theme(self):
        current_url = self.ui.fcsBrowser.url().toString().strip()
        if not current_url:
            print("save_current_theme: invalid url; setuptab2 l60")
            return
        allowed_hosts = {
            "github.com",
            "codeberg.org",
            "gitlab.com"
        }
        if "://" in current_url:
            host_part = current_url.split("://", 1)[1]
        else:
            host_part = current_url
        host = host_part.split("/", 1)[0].lower()
        if host not in allowed_hosts:
            print(f"save_current_theme: {allowed_host} failure; setuptab2 l74")
            return
        # i hate this
        match = re.search(r'/([^/]+)/?$', current_url)
        if not match:
            print("save_current_theme: theme name extraction failed; setuptab2 l80")
            return
        theme_name = match.group(1)
        if theme_name in self.saved_themes:
            print("save_current_theme: theme already saved; setuptab2 l86")
            return

        # Save it
        self.saved_themes[theme_name] = current_url
        self.config.set('saved_themes', self.saved_themes)
        self.config.save()

        self.theme_dropdown.addItem(theme_name)
        self.theme_dropdown.setCurrentText(theme_name)
        print(f"save_current_theme :: {current_url}")
        print(f"selected_theme :: {theme_name}")

