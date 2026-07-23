#!/usr/bin/env python3
"""
Karya Market - Plugin Manager
KWin script/efekt ve Karya widget/extension yonetimi.
KDE Plasma 6'nin plugin sistemine entegre.
"""
import os, sys, json, shutil, subprocess, tempfile, zipfile
from pathlib import Path
from datetime import datetime

PLUGIN_TYPES = {
    "kwin-script": {
        "system": "/usr/share/kwin/scripts",
        "user": "~/.local/share/kwin/scripts",
        "ext": ".js",
    },
    "kwin-effect": {
        "system": "/usr/lib/qt6/plugins/kwin/effects",
        "user": "~/.local/share/kwin/effects",
        "ext": ".so",
    },
    "plasmoid": {
        "system": "/usr/share/plasma/plasmoids",
        "user": "~/.local/share/plasma/plasmoids",
        "ext": "",
    },
    "krunner": {
        "system": "/usr/share/plasma/krunner",
        "user": "~/.local/share/plasma/krunner",
        "ext": ".so",
    },
    "karya-extension": {
        "system": "/usr/lib/karya/extensions",
        "user": "~/.local/share/karya/extensions",
        "ext": ".py",
    },
    "kwinscript": {
        "system": "/usr/share/kwin/scripts",
        "user": "~/.local/share/kwin/scripts",
        "ext": ".js",
    },
    "wallpaper": {
        "system": "/usr/share/plasma/wallpapers",
        "user": "~/.local/share/plasma/wallpapers",
        "ext": "",
    },
}


class PluginManager:
    def __init__(self):
        self.cache_dir = Path.home() / ".cache" / "karya-market"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.db_file = self.cache_dir / "plugins.json"
        self._load_db()

    def _load_db(self):
        if self.db_file.exists():
            try:
                self.db = json.loads(self.db_file.read_text())
            except:
                self.db = {"installed": []}
        else:
            self.db = {"installed": []}

    def _save_db(self):
        self.db_file.write_text(json.dumps(self.db, indent=2))

    def list_installed(self, plugin_type=None):
        results = []
        for ptype, pdirs in PLUGIN_TYPES.items():
            if plugin_type and ptype != plugin_type:
                continue
            base = Path(pdirs["user"]).expanduser()
            if not base.exists():
                continue

            for item in sorted(base.iterdir()):
                if item.name.startswith("."):
                    continue
                metadata = self._read_plugin_metadata(item, ptype)
                results.append({
                    "type": ptype,
                    "name": item.name,
                    "path": str(item),
                    "title": metadata.get("Name", item.name),
                    "author": metadata.get("Author", ""),
                    "version": metadata.get("Version", "1.0"),
                    "description": metadata.get("Comment", ""),
                    "enabled": self._is_plugin_enabled(ptype, item.name),
                })
        return results

    def _read_plugin_metadata(self, plugin_path, ptype):
        metadata = {}
        for meta_file in ["metadata.json", "metadata.desktop", "main.xml"]:
            mpath = plugin_path / meta_file if plugin_path.is_dir() else plugin_path.parent / meta_file
            if mpath and mpath.exists():
                try:
                    if meta_file.endswith(".json"):
                        metadata.update(json.loads(mpath.read_text()))
                    elif meta_file.endswith(".desktop"):
                        for line in mpath.read_text().splitlines():
                            if "=" in line and not line.startswith("["):
                                k, v = line.split("=", 1)
                                metadata[k.strip()] = v.strip()
                except:
                    pass
        return metadata

    def _is_plugin_enabled(self, ptype, name):
        if ptype in ("kwin-script", "kwinscript"):
            try:
                result = subprocess.run(
                    ["kwriteconfig6", "--file", "kwinrc",
                     "--group", "Plugins", "--key", f"{name}Enabled"],
                    capture_output=True, text=True, timeout=10)
                return result.stdout.strip() == "true"
            except:
                pass
        return True

    def install_plugin(self, source, plugin_type, name=None):
        temp_dir = None
        try:
            if source.startswith(("http://", "https://")):
                temp_dir = Path(tempfile.mkdtemp())
                archive = self.cache_dir / "plugin_download.tmp"
                subprocess.run(["curl", "-sLo", str(archive), source],
                               check=True, timeout=120)

                extract_dir = temp_dir / "plugin"
                extract_dir.mkdir()
                if zipfile.is_zipfile(archive):
                    with zipfile.ZipFile(archive) as z:
                        z.extractall(extract_dir)
                else:
                    shutil.unpack_archive(str(archive), extract_dir)
                archive.unlink(missing_ok=True)
                source_path = extract_dir
            else:
                source_path = Path(source)

            if not source_path.exists():
                return {"success": False, "error": "Source not found"}

            target_base = Path(PLUGIN_TYPES[plugin_type]["user"]).expanduser()
            target_base.mkdir(parents=True, exist_ok=True)

            if name:
                target_dir = target_base / name
            else:
                target_dir = target_base / source_path.name

            if target_dir.exists():
                shutil.rmtree(target_dir)

            shutil.copytree(source_path, target_dir)
            self._register_install(plugin_type, target_dir.name, str(target_dir))
            self._enable_plugin(plugin_type, target_dir.name)

            return {"success": True, "name": target_dir.name, "path": str(target_dir)}
        except Exception as e:
            return {"success": False, "error": str(e)}
        finally:
            if temp_dir and temp_dir.exists():
                shutil.rmtree(str(temp_dir))

    def _register_install(self, ptype, name, path):
        entry = {"type": ptype, "name": name, "path": path,
                 "installed_at": datetime.now().isoformat()}
        self.db["installed"] = [e for e in self.db["installed"]
                                if not (e["type"] == ptype and e["name"] == name)]
        self.db["installed"].append(entry)
        self._save_db()

    def _enable_plugin(self, ptype, name):
        if ptype in ("kwin-script", "kwinscript"):
            try:
                subprocess.run(["kwriteconfig6", "--file", "kwinrc",
                                "--group", "Plugins",
                                "--key", f"{name}Enabled",
                                "--type", "bool", "true"], check=False, timeout=10)
                # Reload KWin
                subprocess.run(["qdbus6", "org.kde.KWin", "/KWin", "reconfigure"],
                               check=False, timeout=10)
            except:
                pass

    def uninstall_plugin(self, ptype, name):
        target = Path(PLUGIN_TYPES[ptype]["user"]).expanduser() / name
        if target.exists():
            shutil.rmtree(target)
        self.db["installed"] = [e for e in self.db["installed"]
                                if not (e["type"] == ptype and e["name"] == name)]
        self._save_db()
        return {"success": True}

    def toggle_plugin(self, ptype, name, enable=True):
        if ptype in ("kwin-script", "kwinscript"):
            try:
                subprocess.run(["kwriteconfig6", "--file", "kwinrc",
                                "--group", "Plugins",
                                "--key", f"{name}Enabled",
                                "--type", "bool",
                                "true" if enable else "false"],
                               check=False, timeout=10)
                subprocess.run(["qdbus6", "org.kde.KWin", "/KWin", "reconfigure"],
                               check=False, timeout=10)
            except:
                pass
        return {"success": True, "enabled": enable}

    def list_store(self, plugin_type=None):
        """Return curated plugin collections."""
        kwin_scripts = [
            {"name": "Karya Tiling", "type": "kwin-script",
             "desc": "Karya DE otomatik döşeme sistemi",
             "author": "Karya Team", "version": "1.0", "installed": True},
            {"name": "Force Blur", "type": "kwin-script",
             "desc": "Tüm pencerelere blur efekti uygula",
             "author": "KDE Community", "version": "1.2", "installed": False},
            {"name": "Sticky Window Snapping", "type": "kwin-script",
             "desc": "Gelişmiş pencere yakalama",
             "author": "KDE Community", "version": "2.1", "installed": False},
            {"name": "Window Titlebar Buttons", "type": "kwin-script",
             "desc": "Özelleştirilebilir başlık çubuğu butonları",
             "author": "KDE Community", "version": "1.5", "installed": False},
            {"name": "Polonium", "type": "kwin-script",
             "desc": "Auto tiling for KWin wayland",
             "author": "zeroxfourtyeight", "version": "0.8", "installed": False},
            {"name": "Krohnkite", "type": "kwin-script",
             "desc": "Dynamic tiling script for KWin",
             "author": "esjeon", "version": "0.9", "installed": False},
        ]

        plasmoids = [
            {"name": "Karya Hava", "type": "plasmoid",
             "desc": "Hava durumu bildirimi", "author": "Karya Team",
             "version": "1.0", "installed": True},
            {"name": "Karya Namaz", "type": "plasmoid",
             "desc": "Namaz vakitleri", "author": "Karya Team",
             "version": "1.0", "installed": True},
            {"name": "Karya Haber", "type": "plasmoid",
             "desc": "Son haberler", "author": "Karya Team",
             "version": "1.0", "installed": True},
            {"name": "Karya Sistem", "type": "plasmoid",
             "desc": "Sistem monitörü", "author": "Karya Team",
             "version": "1.0", "installed": True},
        ]

        karya_extensions = [
            {"name": "Karya SPEED", "type": "karya-extension",
             "desc": "Performans ayar motoru", "author": "Karya Team",
             "version": "1.0", "installed": True},
            {"name": "Karya Glassmorphism", "type": "kwin-effect",
             "desc": "Buzlu cam efekti", "author": "Karya Team",
             "version": "1.0", "installed": True},
            {"name": "Karya Sentinel", "type": "karya-extension",
             "desc": "7/24 güvenlik izleme", "author": "Karya Team",
             "version": "1.0", "installed": True},
        ]

        collections = {
            "kwin-scripts": {"title": "KWin Scripts", "type": "kwin-script",
                             "items": kwin_scripts},
            "plasmoids": {"title": "Plasma Widgets", "type": "plasmoid",
                          "items": plasmoids},
            "karya-extensions": {"title": "Karya Eklentileri", "type": "karya-extension",
                                 "items": karya_extensions},
        }

        if plugin_type:
            for key, col in collections.items():
                if col["type"] == plugin_type:
                    return col
            return {"title": "", "type": plugin_type, "items": []}

        return collections


if __name__ == "__main__":
    pm = PluginManager()
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "list":
            results = pm.list_installed(sys.argv[2] if len(sys.argv) > 2 else None)
            print(json.dumps(results, indent=2))
        elif cmd == "install" and len(sys.argv) >= 4:
            result = pm.install_plugin(sys.argv[2], sys.argv[3],
                                       sys.argv[4] if len(sys.argv) > 4 else None)
            print(json.dumps(result))
        elif cmd == "uninstall" and len(sys.argv) >= 4:
            result = pm.uninstall_plugin(sys.argv[2], sys.argv[3])
            print(json.dumps(result))
        elif cmd == "toggle" and len(sys.argv) >= 4:
            enable = sys.argv[3].lower() == "true"
            result = pm.toggle_plugin(sys.argv[2], sys.argv[4] if len(sys.argv) > 4 else None, enable)
            print(json.dumps(result))
        elif cmd == "store":
            results = pm.list_store(sys.argv[2] if len(sys.argv) > 2 else None)
            print(json.dumps(results, indent=2))
        else:
            print("Usage: plugin-manager <list|install|uninstall|toggle|store>")
    else:
        print(json.dumps(pm.list_store(), indent=2))
