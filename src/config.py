import json
from pathlib import Path
import platform
import os


def get_config_path():
    app_folder = "gituserChrome"

    if platform.system() == "Windows":
        base_dir = os.getenv("APPDATA", Path.home() / "AppData" / "Roaming")
    elif platform.system() == "Darwin":  # macOS
        base_dir = Path.home() / "Library" / "Application Support"
    else:  # Linux, BSD, etc.
        base_dir = Path.home() / ".config"

    config_dir = Path(base_dir) / app_folder
    config_dir.mkdir(parents=True, exist_ok=True)
    return config_dir / "config.json"


class ConfigManager:
    def __init__(self):
        self.path = get_config_path()
        self._cache = {}

    def load(self):
        if self.path.exists():
            try:
                with open(self.path, 'r', encoding='utf-8') as f:
                    self._cache = json.load(f)
            except json.JSONDecodeError:
                self._cache = {}  # fallback if config is corrupted
        else:
            self._cache = {}

    def save(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.path, 'w', encoding='utf-8') as f:
            json.dump(self._cache, f, indent=4)

    def get(self, key):
        return self._cache.get(key)

    def set(self, key, value):
        self._cache[key] = value
