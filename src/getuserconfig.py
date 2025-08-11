import os
import sys
import shutil
import platform
import subprocess
from pathlib import Path
import webbrowser

from PyQt6.QtCore import QUrl, QProcess
from PyQt6.QtGui import QDesktopServices
from PyQt6.QtWidgets import QLabel, QDialogButtonBox, QPushButton, QFileDialog

from src.config import ConfigManager


class GetUserConfig:
    def __init__(self, ui):
        self.ui = ui
        self.config = ConfigManager()
        self.config.load()

        self.ui.gitProgressingBar.hide()
        self.read_variables()
        self.setup_variables()
        self.populate_fields()
        self.setup_connections()

        self.ui.tabRow10.findChild(QPushButton).clicked.connect(self.pre_git_submission)

    def setup_variables(self):
        needs_default = False
        if self.config.get("git_is") is None:
            self.config.set("git_is", self.has_git())
            needs_default = True
        if self.config.get("os_is") is None:
            self.config.set("os_is", self.get_os())
            needs_default = True
        if self.config.get("firefox_is") is None:
            self.config.set("firefox_is", self.detect_firefox_variant())
            needs_default = True
        if self.config.get("firefox_profiles") is None:
            self.find_firefox_profiles()
            needs_default = True
        if not self.config.get("selected_profile"):
            profiles = self.config.get("firefox_profiles") or []
            self.config.set("selected_profile", profiles[-1] if profiles else "")
            needs_default = True
        if self.config.get("saved_themes") is None:
            self.config.set("saved_themes", {
                "FF-ULTIMA": "https://github.com/soulhotel/FF-ULTIMA",
                "gwfox": "https://github.com/akkva/gwfox"
            })
            needs_default = True
        for key, default_val in [
            ("selected_theme", ""),
            ("apply_userjs", "Yes"),
            ("review_userjs", "Yes"),
            ("allow_restart", "Yes"),
            ("backup_chrome", "Yes"),
        ]:
            if self.config.get(key) is None:
                self.config.set(key, default_val)
                needs_default = True
        if needs_default:
            self.config.save()
            print(f"setup_variables :: config saved to {self.config.path}")

    def read_variables(self):
        if not Path(self.config.path).exists():
            return
        keys = [
            "git_is",
            "os_is",
            "firefox_is",
            "profile_base",
            "selected_profile",
            "selected_theme",
            "apply_userjs",
            "review_userjs",
            "allow_restart",
            "backup_chrome"
        ]
        for key in keys:
            value = self.config.get(key)
            print(f"{key} :: {value}")

    # -----------------------------------------------------------------------------------------------------------
    # (re)populate ui
    # The labels are already mapped out in .ui, but I set on top of it anyway to learn..
    # -----------------------------------------------------------------------------------------------------------

    def populate_fields(self):
        self.ui.tabRow00.findChild(QLabel).setText(
            "Verify that the information below is correct, then, proceed to Git..\n"
            "If you've selected to remember choices, in Settings, gituserChrome will automatically fill choices based on that configuration..\n"
        )
        self.ui.tabRow01.findChild(QLabel).setText("git seems to be installed...")
        self.ui.tabRow02.findChild(QLabel).setText("Your operating system seems to be...")
        self.ui.os_is_dropdown.setCurrentText(self.config.get("os_is"))
        self.ui.tabRow03.findChild(QLabel).setText("Which Firefox are you theming today?")
        self.ui.firefox_is_dropdown.setCurrentText(self.config.get("firefox_is"))
        self.ui.tabRow04.findChild(QLabel).setText("Which Firefox Profile are you theming?")
        self.ui.firefox_profiles_dropdown.clear()
        self.ui.firefox_profiles_dropdown.addItems(self.config.get("firefox_profiles") or [])
        self.ui.firefox_profiles_dropdown.setCurrentText(self.config.get("selected_profile"))
        self.ui.tabRow05.findChild(QLabel).setText("Choose a userChrome theme:")
        self.ui.saved_themes_dropdown.clear()
        self.ui.saved_themes_dropdown.addItems(self.config.get("saved_themes").keys())
        self.ui.saved_themes_dropdown.setCurrentText(self.config.get("selected_theme"))
        self.ui.tabRow06.findChild(QLabel).setText("If a user.js is found, do you want to apply it?")
        self.ui.tabRow07.findChild(QLabel).setText("Do you want to review the user.js file before applying it?")
        self.ui.tabRow08.findChild(QLabel).setText("Can gituserChrome restart firefox for you (recommended)?")
        self.ui.tabRow09.findChild(QLabel).setText("If an existing chrome folder is found, back it up??")

    def get_buttonbox_choice(self, buttonbox: QDialogButtonBox) -> str:
        clicked_button = buttonbox.focusWidget()
        if clicked_button:
            return clicked_button.text()

        for role in [QDialogButtonBox.StandardButton.Ok, QDialogButtonBox.StandardButton.Yes,
                    QDialogButtonBox.StandardButton.No, QDialogButtonBox.StandardButton.Discard,
                    QDialogButtonBox.StandardButton.Help]:
            btn = buttonbox.button(role)
            if btn and btn.hasFocus():
                return btn.text()

        for btn in buttonbox.buttons():
            if btn.isEnabled() and btn.isVisible():
                return btn.text()
        return ""

    def has_git(self):
        from shutil import which
        git_installed = which("git") is not None
        ok_button = self.ui.git_is_dialog.button(QDialogButtonBox.StandardButton.Ok)
        help_button = self.ui.git_is_dialog.button(QDialogButtonBox.StandardButton.Help)

        if git_installed:
            ok_button.setEnabled(True)
            ok_button.setChecked(True)  # if checkable
            help_button.setEnabled(False)
            help_button.setChecked(False)
        else:
            ok_button.setEnabled(False)
            ok_button.setChecked(False)
            help_button.setEnabled(True)
            help_button.setChecked(True)
        print(f"has_git :: {git_installed} git_is")
        return git_installed

    def get_os(self):
        system = platform.system()
        print(f"get_os :: {system}")
        if system == "Darwin":
            return "Mac"
        elif system == "Windows":
            return "Windows"
        elif system == "Linux":
            return "Linux"
        else:
            return system

    def detect_firefox_variant(self):
        variants = [
            "firefox",
            "firefox-developer-edition",
            "firefox-nightly",
            "librewolf",
            "zen-browser",
            "floorp"
        ]
        print(f"get_variants :: {variants}")
        for variant in variants:
            if shutil.which(variant) is not None:
                pretty_names = {
                    "firefox": "Firefox",
                    "firefox-developer-edition": "Firefox Developer Edition",
                    "firefox-nightly": "Firefox Nightly",
                    "librewolf": "LibreWolf",
                    "zen-browser": "Zen Browser",
                    "floorp": "Floorp"
                }
                return pretty_names.get(variant, variant)
        return "Firefox"

    def find_firefox_profiles(self):
        system = platform.system()
        if system == "Darwin":  # macOS
            profile_base = Path.home() / "Library/Application Support/Firefox/Profiles"
        elif system == "Windows":
            appdata = os.getenv("APPDATA")
            if appdata is None:
                self.config.set("firefox_profiles", [])
                self.config.set("selected_profile", "")
                return
            profile_base = Path(appdata) / "Mozilla/Firefox/Profiles"
        else:  # Linux and others (default fallback)
            profile_base = Path.home() / ".mozilla/firefox"

        self.config.set("profile_base", str(profile_base))
        print(f"find_firefox_profiles :: {profile_base} saved..")

        if not profile_base.exists() or not profile_base.is_dir():
            self.config.set("firefox_profiles", [])
            self.config.set("selected_profile", "")
            return

        IGNORED_FOLDERS = {"Crash Reports", "Pending Pings", "Profile Groups"}
        profiles = []
        profile_dirs = []

        for entry in profile_base.iterdir():
            if entry.is_dir() and entry.name not in IGNORED_FOLDERS:
                profiles.append(entry.name)
                profile_dirs.append(entry)

        if not profile_dirs:
            self.config.set("firefox_profiles", [])
            self.config.set("selected_profile", "")
            return

        # Sort by time modified (very useful)
        sorted_profiles = sorted(profile_dirs, key=lambda p: p.stat().st_mtime, reverse=True)
        most_recent_profile = sorted_profiles[0].name
        self.config.set("firefox_profiles", profiles)
        self.config.set("selected_profile", most_recent_profile)
        print(f"find_firefox_profiles :: {profiles}")
        print(f"selected_profile :: {most_recent_profile}")

    def apply_userjs_populate(self):
        yes_btn = self.ui.apply_userjs_dialog.button(QDialogButtonBox.StandardButton.Yes)
        no_btn = self.ui.apply_userjs_dialog.button(QDialogButtonBox.StandardButton.No)
        if self.config.get("apply_userjs") == "Yes":
            yes_btn.setChecked(True)
            no_btn.setChecked(False)
        else:
            yes_btn.setChecked(False)
            no_btn.setChecked(True)

    def review_userjs_populate(self):
        yes_btn = self.ui.review_userjs_dialog.button(QDialogButtonBox.StandardButton.Yes)
        no_btn = self.ui.review_userjs_dialog.button(QDialogButtonBox.StandardButton.No)
        if self.config.get("review_userjs") == "Yes":
            yes_btn.setChecked(True)
            no_btn.setChecked(False)
        else:
            yes_btn.setChecked(False)
            no_btn.setChecked(True)

    def allow_restart_populate(self):
        yes_btn = self.ui.allow_restart_dialog.button(QDialogButtonBox.StandardButton.Yes)
        no_btn = self.ui.allow_restart_dialog.button(QDialogButtonBox.StandardButton.No)
        if self.config.get("allow_restart") == "Yes":
            yes_btn.setChecked(True)
            no_btn.setChecked(False)
        else:
            yes_btn.setChecked(False)
            no_btn.setChecked(True)

    def backup_chrome_populate(self):
        yes_btn = self.ui.backup_chrome_dialog.button(QDialogButtonBox.StandardButton.Yes)
        discard_btn = self.ui.backup_chrome_dialog.button(QDialogButtonBox.StandardButton.Discard)
        if self.config.get("backup_chrome") == "Yes":
            yes_btn.setChecked(True)
            discard_btn.setChecked(False)
        else:
            yes_btn.setChecked(False)
            discard_btn.setChecked(True)

    # Try read dialog selection and save to config
    def apply_userjs_save(self):
        yes_btn = self.ui.apply_userjs_dialog.button(QDialogButtonBox.StandardButton.Yes)
        self.config.set("apply_userjs", "Yes" if yes_btn.isChecked() else "No")

    def review_userjs_save(self):
        yes_btn = self.ui.review_userjs_dialog.button(QDialogButtonBox.StandardButton.Yes)
        self.config.set("review_userjs", "Yes" if yes_btn.isChecked() else "No")

    def allow_restart_save(self):
        yes_btn = self.ui.allow_restart_dialog.button(QDialogButtonBox.StandardButton.Yes)
        self.config.set("allow_restart", "Yes" if yes_btn.isChecked() else "No")

    def backup_chrome_save(self):
        yes_btn = self.ui.backup_chrome_dialog.button(QDialogButtonBox.StandardButton.Yes)
        self.config.set("backup_chrome", "Yes" if yes_btn.isChecked() else "Discard")


    # -----------------------------------------------------------------------------------------------------------
    # extra buttons
    # -----------------------------------------------------------------------------------------------------------

    def setup_connections(self):
        # Call this from your __init__ or wherever you connect signals
        self.ui.select_profile_folder_button.clicked.connect(self.select_profile_folder)
        self.ui.selected_theme_link_button.clicked.connect(self.open_selected_theme_link)
        self.ui.send_to_fcss_tab.clicked.connect(lambda: self.ui.mainContentTabs.setCurrentWidget(self.ui.mainContentTab2))

    def select_profile_folder(self):
        # Open folder selection dialog
        folder = QFileDialog.getExistingDirectory(None, "Select Firefox Profile Folder")

        if folder:
            folder_name = folder.split("/")[-1]
            profiles = self.config.get("firefox_profiles") or []
            # Add only if not already present
            if folder_name not in profiles:
                profiles.append(folder_name)
                self.config.set("firefox_profiles", profiles)
                # Update dropdown
                self.ui.firefox_profiles_dropdown.clear()
                self.ui.firefox_profiles_dropdown.addItems(profiles)

            # Set as currently selected
            self.ui.firefox_profiles_dropdown.setCurrentText(folder_name)
            self.config.set("selected_profile", folder_name)
            print(f"select_profile_folder :: {folder} folder path selected")
            print(f"select_profile_folder :: {folder_name} profile selected")
            self.config.save()

    def open_selected_theme_link(self):
        selected_theme = self.ui.saved_themes_dropdown.currentText()
        saved_themes = self.config.get("saved_themes") or {}
        url = saved_themes.get(selected_theme)
        if url:
            QDesktopServices.openUrl(QUrl(url))
            print(f"open_selected_theme_link :: {selected_theme} {url}")
        else:
            print(f"open_selected_theme_link :: url not found {selected_theme} {url}; setuptab1 l326")

    # -----------------------------------------------------------------------------------------------------------
    # git review
    # -----------------------------------------------------------------------------------------------------------

    def pre_git_submission(self):

        self.config.set("git_is", self.get_buttonbox_choice(self.ui.git_is_dialog))
        self.config.set("apply_userjs", self.get_buttonbox_choice(self.ui.apply_userjs_dialog))
        self.config.set("review_userjs", self.get_buttonbox_choice(self.ui.review_userjs_dialog))
        self.config.set("allow_restart", self.get_buttonbox_choice(self.ui.allow_restart_dialog))
        self.config.set("backup_chrome", self.get_buttonbox_choice(self.ui.backup_chrome_dialog))

        self.config.set("os_is", self.ui.os_is_dropdown.currentText())
        self.config.set("firefox_is", self.ui.firefox_is_dropdown.currentText())
        self.config.set("selected_profile", self.ui.firefox_profiles_dropdown.currentText())
        self.config.set("selected_theme", self.ui.saved_themes_dropdown.currentText())

        self.config.save()
        print("pre_git_submission :: config saved to", self.config.path)
        QDesktopServices.openUrl(QUrl.fromLocalFile(str(self.config.path)))
        self.ui.mainContentTabs.setCurrentWidget(self.ui.mainContentTab3)
        self.git_userchrome()

    # -----------------------------------------------------------------------------------------------------------
    # git submit
    # this functionality could technically be passed off to tab 3, but tab 3 is essentially just a global console
    # -----------------------------------------------------------------------------------------------------------

    def git_userchrome(self):
        print("checking config.. git submitted.. gitting everything ready..")

        selected_theme = self.config.get("selected_theme")
        saved_themes = self.config.get("saved_themes") or {}
        gitTheme = saved_themes.get(selected_theme, "")
        profile_base = self.config.get("profile_base")
        selected_profile = self.config.get("selected_profile")
        profile_path = str(Path(profile_base) / selected_profile)

        def normalize_yes_no(value):
            return "yes" if value == "&Yes" else "no"

        apply_userjs = normalize_yes_no(self.config.get("apply_userjs"))
        allow_restart = normalize_yes_no(self.config.get("allow_restart"))
        backup_chrome = normalize_yes_no(self.config.get("backup_chrome"))
        firefox_choice = self.config.get("firefox_is")

        system = platform.system()

        if system in ("Linux", "Darwin"):
            program = "bash"
            arguments = [
                "src/gitbash.sh",
                gitTheme,
                profile_path,
                apply_userjs,
                allow_restart,
                backup_chrome,
                str(firefox_choice),
            ]
        elif system == "Windows":
            program = "powershell.exe"
            arguments = [
                "-NoProfile",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                "src/gitpowershell.ps1",
                "-gitTheme", gitTheme,
                "-profile_path", profile_path,
                "-apply_userjs", apply_userjs,
                "-allow_restart", allow_restart,
                "-backup_chrome", backup_chrome,
                "-firefox_choice", str(firefox_choice),
            ]
        else:
            self.ui.gitConsole.appendPlainText(f"unsupported OS :: {system}")
            return

        self.process = QProcess()
        self.process.setProgram(program)
        self.process.setArguments(arguments)
        # Connect signals
        self.process.readyReadStandardOutput.connect(self.read_process_output)
        self.process.readyReadStandardError.connect(self.read_process_output)
        self.process.finished.connect(self.process_finished)
        self.process.errorOccurred.connect(self.process_error)
        # Clear console before start
        self.ui.gitConsole.clear()
        self.ui.gitConsole.appendPlainText("checking config.. git submitted.. gitting everything ready..")
        # Start async (or it hangs)
        self.ui.gitProgressingBar.show()
        self.ui.gitProgressingBar.setValue(0)
        self.process.start()

    def read_process_output(self):
        # Read stdout
        data = self.process.readAllStandardOutput().data().decode()
        if data:
            for line in data.splitlines():
                line = line.strip()
                # Update progress bar based on known echoed phrases
                if "Cloning theme repo..." in line:
                    self.ui.gitProgressingBar.setValue(15)
                elif "Clone complete." in line:
                    self.ui.gitProgressingBar.setValue(60)
                elif "Copying user.js to profile path..." in line:
                    self.ui.gitProgressingBar.setValue(65)
                elif "Restarting Firefox..." in line:
                    self.ui.gitProgressingBar.setValue(75)
                elif "Firefox should have restarted..." in line:
                    self.ui.gitProgressingBar.setValue(85)
                elif "Removing user.js..." in line:
                    self.ui.gitProgressingBar.setValue(90)
                elif line == "Done.":
                    self.ui.gitProgressingBar.setValue(100)

                self.ui.gitConsole.appendPlainText(line)

        # Read stderr
        err = self.process.readAllStandardError().data().decode()
        if err:
            for line in err.splitlines():
                self.ui.gitConsole.appendPlainText(line.strip())

    def process_finished(self, exitCode, exitStatus):
        # self.ui.gitConsole.appendPlainText(f"process finished :: exit code {exitCode}")
        self.all_done()

    def process_error(self, error):
        self.ui.gitConsole.appendPlainText(f"process error occurred :: {error}")

    def all_done(self):
        self.ui.gitProgressing.hide()
        self.ui.gitComplete.show()
        self.ui.gitProgress.setText("Enjoy the theme :)")
        # maybe add some fireworks or something idk. first application complete yay..