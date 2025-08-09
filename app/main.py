from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6.QtCore import QSettings, QResource, QFile, QTextStream, QPropertyAnimation, QEasingCurve, QUrl
from PyQt6.QtGui import QDesktopServices
import sys

QResource.registerResource("ui/resources.rcc")

from ui.mainwindowui import Ui_MainWindow
from src.getuserconfig import GetUserConfig
from src.kindofawebbrowser import KindofAWebBrowser
from src.gitconsole import GitConsoleSimulation
from promo.promo import BannerManager

# init main window

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.load_stylesheet("ui/mainwindow.qss")
        self.settings = QSettings(QSettings.Format.IniFormat,
                                QSettings.Scope.UserScope,
                                "gituserChrome")
        self.tab3 = GitConsoleSimulation(self.ui)
        self.setup_tab_manager = GetUserConfig(self.ui)
        self.tab2 = KindofAWebBrowser(self.ui)
        self.banner_manager = BannerManager(
            self.ui.stackedWidget,
            [
                self.ui.banner_0,
                self.ui.banner_1,
                self.ui.banner_2,
                self.ui.banner_3
            ]
        )
        geometry = self.settings.value("geometry", b"")
        if geometry:
            self.restoreGeometry(geometry)
        window_state = self.settings.value("windowState", b"")
        if window_state:
            self.restoreState(window_state)
        sidebar_visible = self.settings.value("sidebarVisible", "true") == "true"
        self.sidebar_expanded = sidebar_visible
        if not sidebar_visible:
            self.ui.sidebar.setMaximumWidth(0)
            self.ui.sidebar.show()
        else:
            self.ui.sidebar.setMaximumWidth(self.ui.sidebar.sizeHint().width())
        self.ui.mainContentTabs.setTabVisible(
            self.ui.mainContentTabs.indexOf(self.ui.mainContentTabSettings),
            False
        )

        # connect functionality to ui

        self.ui.buttonToggleSidebar.clicked.connect(self.toggle_sidebar)
        self.ui.buttonToggleConsole.clicked.connect(self.toggle_console)
        self.ui.buttonLink2Tab1.clicked.connect(lambda: self.ui.mainContentTabs.setCurrentWidget(self.ui.mainContentTab1))
        self.ui.buttonLink2Tab2.clicked.connect(lambda: self.ui.mainContentTabs.setCurrentWidget(self.ui.mainContentTab2))
        self.ui.buttonLink2Tab3.clicked.connect(lambda: self.ui.mainContentTabs.setCurrentWidget(self.ui.mainContentTab3))
        self.ui.buttonLink2TabSettings.clicked.connect(lambda: self.ui.mainContentTabs.setCurrentWidget(self.ui.mainContentTabSettings))
        self.ui.buttonLink2TabSettings.clicked.connect(self.show_settings_tab)
        self.ui.buttonSave.clicked.connect(self.hide_settings_tab)
        self.ui.sidebarHeaderBranding.clicked.connect(lambda: QDesktopServices.openUrl(QUrl("https://github.com/soulhotel/git-userChrome")))
        self.ui.buttonLink2g.clicked.connect(lambda: QDesktopServices.openUrl(QUrl("https://github.com/soulhotel/git-userChrome")))
        self.ui.buttonLink2r.clicked.connect(lambda: QDesktopServices.openUrl(QUrl("https://www.reddit.com/r/FirefoxCSS/")))

    # define functionalities

    def load_stylesheet(self, path):
        file = QFile(path)
        if file.open(QFile.OpenModeFlag.ReadOnly | QFile.OpenModeFlag.Text):
            stream = QTextStream(file)
            self.setStyleSheet(stream.readAll())
            file.close()

    def closeEvent(self, event):
        self.settings.setValue("geometry", self.saveGeometry())
        self.settings.setValue("windowState", self.saveState())
        self.settings.setValue("sidebarVisible", self.ui.sidebar.isVisible())
        super().closeEvent(event)

    def toggle_sidebar(self):
        self.animate_sidebar()

    def animate_sidebar(self, duration=120):
        sidebar = self.ui.sidebar
        start_width = sidebar.width()
        if self.sidebar_expanded:
            end_width = 0
        else:
            end_width = sidebar.sizeHint().width()

        if not sidebar.isVisible():
            sidebar.show()

        animation = QPropertyAnimation(sidebar, b"maximumWidth")
        animation.setDuration(duration)
        animation.setStartValue(start_width)
        animation.setEndValue(end_width)
        animation.setEasingCurve(QEasingCurve.Type.InOutCubic)

        def on_finished():
            sidebar.setVisible(end_width > 0)
            self.sidebar_expanded = not self.sidebar_expanded

        animation.finished.connect(on_finished)
        animation.start()
        self._sidebar_animation = animation

    def toggle_console(self):
        if self.ui.gitConsole.isVisible():
            self.ui.gitConsole.hide()
        else:
            self.ui.gitConsole.show()

    def show_settings_tab(self):
        index = self.ui.mainContentTabs.indexOf(self.ui.mainContentTabSettings)
        self.ui.mainContentTabs.setTabVisible(index, True)
        self.ui.mainContentTabs.setCurrentIndex(index)

    def hide_settings_tab(self):
        index = self.ui.mainContentTabs.indexOf(self.ui.mainContentTabSettings)
        self.ui.mainContentTabs.setTabVisible(index, False)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
