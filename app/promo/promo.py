import json
import shutil
from pathlib import Path
import platform
import os

from PyQt6.QtWidgets import QLabel
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QPixmap

def get_pconfig_path():
    app_folder = "gituserChrome"
    if platform.system() == "Windows":
        base_dir = os.getenv("APPDATA", Path.home() / "AppData" / "Roaming")
    elif platform.system() == "Darwin":  # macOS
        base_dir = Path.home() / "Library" / "Application Support"
    else:
        base_dir = Path.home() / ".config"
    pconfig_dir = Path(base_dir) / app_folder
    pconfig_dir.mkdir(parents=True, exist_ok=True)
    config_path = pconfig_dir / "promo.json"
    if not config_path.exists():
        script_dir = Path(__file__).parent.resolve()
        default_promo = script_dir / "promo.json"
        if default_promo.exists():
            shutil.copy2(default_promo, config_path)
            # print(f"promo.json -> {config_path}")
        else:
            print(f"promo.json missing from {default_promo}")
    return config_path

class BannerManager:
    def __init__(self, stacked_widget, banner_labels):
        config_path = get_pconfig_path()
        self.stacked_widget = stacked_widget
        self.banner_labels = banner_labels

        self.banner_images = []
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                promo_list = data.get("promo", [])
                promo_list_sorted = sorted(promo_list, key=lambda x: int(x.get("placement", 0)))
                for promo_item in promo_list_sorted:
                    banner_image = promo_item.get("banner_image")
                    if banner_image:
                        self.banner_images.append(banner_image)
        except Exception as e:
            print(f"promo.json banner retrieval failed: {e}")
            self.banner_images = [
                ":/resources/banner/brand banner.png",
                ":/resources/banner/fcss banner.png",
                ":/resources/banner/ffultima banner.png",
                ":/resources/banner/reddit banner.png"
            ]

        # Load pixmaps
        self.pixmaps = [QPixmap(path) for path in self.banner_images]
        self.current_index = 0
        self.timer = QTimer()
        self.timer.timeout.connect(self.next_banner)
        self.timer.start(9000) # rotate

    def next_banner(self):
        self.current_index = (self.current_index + 1) % len(self.banner_labels)
        self.stacked_widget.setCurrentIndex(self.current_index)

    def previous_banner(self):
        self.current_index = (self.current_index - 1) % len(self.banner_labels)
        self.stacked_widget.setCurrentIndex(self.current_index)