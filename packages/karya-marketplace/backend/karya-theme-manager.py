#!/usr/bin/env python3
"""
Karya Market - Theme Manager
KDE Plasma 6 tema yönetim sistemi.
Desteklenen tema tipleri: Plasma, KWin, Icon, SDDM, Splash, Color, Cursor, Aurorae
"""
import os, sys, json, shutil, subprocess, tempfile, zipfile
from pathlib import Path
from datetime import datetime

THEME_DIRS = {
    "plasma":        "/usr/share/plasma/desktoptheme",
    "kwin":          "/usr/share/kwin/decorations",
    "icons":         "/usr/share/icons",
    "sddm":          "/usr/share/sddm/themes",
    "splash":        "/usr/share/plasma/splashes",
    "color":         "/usr/share/color-schemes",
    "cursor":        "/usr/share/icons",
    "aurorae":       "/usr/share/kwin/decorations",
    "wallpaper":     "/usr/share/wallpapers",
}

USER_THEME_DIRS = {
    "plasma":        "~/.local/share/plasma/desktoptheme",
    "kwin":          "~/.local/share/kwin/decorations",
    "icons":         "~/.local/share/icons",
    "splash":        "~/.local/share/plasma/splashes",
    "color":         "~/.local/share/color-schemes",
    "cursor":        "~/.local/share/icons",
    "aurorae":       "~/.local/share/kwin/decorations",
    "wallpaper":     "~/.local/share/wallpapers",
}

STORE_API = "https://api.kde-look.org/v1"


class ThemeManager:
    def __init__(self):
        self.cache_dir = Path.home() / ".cache" / "karya-market"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.db_file = self.cache_dir / "themes.json"
        self._load_db()

    def _load_db(self):
        if self.db_file.exists():
            try:
                self.db = json.loads(self.db_file.read_text())
            except:
                self.db = {"installed": [], "sources": []}
        else:
            self.db = {"installed": [], "sources": []}

    def _save_db(self):
        self.db_file.write_text(json.dumps(self.db, indent=2))

    def list_installed(self, theme_type=None):
        """List installed themes with metadata."""
        results = []
        dirs = THEME_DIRS if os.geteuid() == 0 else USER_THEME_DIRS

        for ttype, tdir in dirs.items():
            if theme_type and ttype != theme_type:
                continue
            path = Path(tdir).expanduser()
            if not path.exists():
                continue
            for item in sorted(path.iterdir()):
                if item.is_dir() and not item.name.startswith("."):
                    metadata = self._read_metadata(item)
                    results.append({
                        "type": ttype,
                        "name": item.name,
                        "path": str(item),
                        "title": metadata.get("Name", item.name),
                        "author": metadata.get("Author", ""),
                        "version": metadata.get("Version", "1.0"),
                        "description": metadata.get("Comment", ""),
                        "kind": metadata.get("Type", ttype),
                    })
        return results

    def _read_metadata(self, theme_path):
        metadata = {}
        for meta_file in ["metadata.desktop", "metadata.json", "index.theme"]:
            mpath = theme_path / meta_file
            if mpath.exists():
                try:
                    if meta_file.endswith(".json"):
                        metadata.update(json.loads(mpath.read_text()))
                    elif meta_file.endswith(".desktop"):
                        for line in mpath.read_text().splitlines():
                            if "=" in line and not line.startswith("["):
                                k, v = line.split("=", 1)
                                metadata[k.strip()] = v.strip()
                    elif meta_file.endswith(".theme"):
                        for line in mpath.read_text().splitlines():
                            if "=" in line and not line.startswith("["):
                                k, v = line.split("=", 1)
                                metadata[k.strip()] = v.strip()
                except:
                    pass
        return metadata

    def install_theme(self, source, theme_type, name=None):
        """Install a theme from URL, file, or directory."""
        temp_dir = None
        try:
            if source.startswith(("http://", "https://")):
                temp_dir = Path(tempfile.mkdtemp())
                dest = temp_dir / "theme"
                self._download_extract(source, dest)
                source_path = dest
            else:
                source_path = Path(source)

            if not source_path.exists():
                return {"success": False, "error": "Source not found"}

            target_base = Path(USER_THEME_DIRS[theme_type]).expanduser()
            target_base.mkdir(parents=True, exist_ok=True)

            if name:
                target_dir = target_base / name
            else:
                target_dir = target_base / source_path.name

            if target_dir.exists():
                shutil.rmtree(target_dir)

            shutil.copytree(source_path, target_dir)
            self._register_install(theme_type, target_dir.name, str(target_dir))

            return {"success": True, "name": target_dir.name, "path": str(target_dir)}
        except Exception as e:
            return {"success": False, "error": str(e)}
        finally:
            if temp_dir and temp_dir.exists():
                shutil.rmtree(str(temp_dir))

    def _download_extract(self, url, dest):
        dest.mkdir(parents=True, exist_ok=True)
        archive = self.cache_dir / "download.tmp"
        subprocess.run(["curl", "-sL", "-o", str(archive), url], check=True, timeout=120)

        if zipfile.is_zipfile(archive):
            with zipfile.ZipFile(archive) as z:
                z.extractall(dest)
        elif archive.suffix == ".tar.gz" or archive.suffix == ".tgz":
            subprocess.run(["tar", "xzf", str(archive), "-C", str(dest)], check=True)
        elif archive.suffix == ".tar.xz":
            subprocess.run(["tar", "xJf", str(archive), "-C", str(dest)], check=True)
        else:
            shutil.unpack_archive(str(archive), str(dest))

        archive.unlink(missing_ok=True)

    def _register_install(self, theme_type, name, path):
        entry = {"type": theme_type, "name": name, "path": path,
                 "installed_at": datetime.now().isoformat()}
        self.db["installed"] = [e for e in self.db["installed"]
                                if not (e["type"] == theme_type and e["name"] == name)]
        self.db["installed"].append(entry)
        self._save_db()

    def uninstall_theme(self, theme_type, name):
        target = Path(USER_THEME_DIRS[theme_type]).expanduser() / name
        if target.exists():
            shutil.rmtree(target)
        self.db["installed"] = [e for e in self.db["installed"]
                                if not (e["type"] == theme_type and e["name"] == name)]
        self._save_db()
        return {"success": True}

    def apply_theme(self, theme_type, name):
        """Apply a theme via KDE Plasma 6 config tools."""
        cmds = {
            "plasma": ["lookandfeeltool", "-a", name],
            "color":  ["plasma-apply-colorscheme", name],
            "kwin":   ["kwriteconfig6", "--file", "kwinrc",
                       "--group", "org.kde.kdecoration2",
                       "--key", "theme", name],
        }

        if theme_type in cmds:
            try:
                subprocess.run(cmds[theme_type], check=False, timeout=30)
            except:
                pass

        # Apply via DBus for live effect
        if theme_type == "plasma":
            try:
                subprocess.run(["plasma-apply-desktoptheme", name], check=False, timeout=15)
            except:
                pass
        elif theme_type == "icons":
            try:
                subprocess.run(["plasma-apply-icontheme", name], check=False, timeout=15)
            except:
                pass

        return {"success": True, "applied": theme_type, "name": name}

    def search_store(self, query, theme_type=None, page=1):
        """Search KDE Store API."""
        results = []
        search_urls = []

        if theme_type:
            type_ids = {"plasma": 105, "kwin": 131, "icons": 132,
                        "sddm": 119, "splash": 109, "color": 109,
                        "cursor": 131, "wallpaper": 107, "aurorae": 131}
            tid = type_ids.get(theme_type, 105)
            search_urls.append(
                f"{STORE_API}/content/data?page={page}&search={query}&categories={tid}")
        else:
            for tid in [105, 131, 132, 119, 109, 107]:
                search_urls.append(
                    f"{STORE_API}/content/data?page={page}&search={query}&categories={tid}")

        for url in search_urls:
            try:
                result = subprocess.run(
                    ["curl", "-s", url],
                    capture_output=True, text=True, timeout=15)
                if result.returncode == 0:
                    data = json.loads(result.stdout)
                    results.extend(data.get("content", []))
            except:
                pass

        return results[:50]

    def get_store_collections(self):
        """Return curated theme collections."""
        return {
            "plasma-themes": {
                "title": "Populer Plasma Temalari",
                "type": "plasma",
                "items": [
                    {"name": "Breeze", "author": "KDE", "desc": "Varsayilan KDE temasi",
                     "url": "", "installed": True},
                    {"name": "Breeze Dark", "author": "KDE", "desc": "Koyu KDE temasi",
                     "url": "", "installed": True},
                ]
            },
            "kwin-themes": {
                "title": "KWin Pencere Dekorasyonlari",
                "type": "kwin",
                "items": [
                    {"name": "Breeze", "author": "KDE", "desc": "Varsayilan KWin dekorasyonu",
                     "url": "", "installed": True},
                    {"name": "Karya Frost", "author": "Karya Team", "desc": "Buzlu cam efekti",
                     "url": "", "installed": False},
                ]
            },
            "icon-themes": {
                "title": "ikon Temalari",
                "type": "icons",
                "items": [
                    {"name": "breeze-icons", "author": "KDE", "desc": "Varsayilan ikon seti",
                     "url": "", "installed": True},
                    {"name": "Papirus", "author": "Papirus Team", "desc": "Modern ikon seti",
                     "url": "", "installed": False},
                    {"name": "Tela Circle", "author": "Vinceliuice",
                     "desc": "Yuvarlak ikonlar", "url": "", "installed": False},
                ]
            },
        }


if __name__ == "__main__":
    tm = ThemeManager()
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "list":
            results = tm.list_installed(sys.argv[2] if len(sys.argv) > 2 else None)
            print(json.dumps(results, indent=2))
        elif cmd == "install" and len(sys.argv) >= 4:
            result = tm.install_theme(sys.argv[2], sys.argv[3],
                                      sys.argv[4] if len(sys.argv) > 4 else None)
            print(json.dumps(result))
        elif cmd == "uninstall" and len(sys.argv) >= 4:
            result = tm.uninstall_theme(sys.argv[2], sys.argv[3])
            print(json.dumps(result))
        elif cmd == "apply" and len(sys.argv) >= 4:
            result = tm.apply_theme(sys.argv[2], sys.argv[3])
            print(json.dumps(result))
        elif cmd == "search":
            results = tm.search_store(" ".join(sys.argv[2:]))
            print(json.dumps(results, indent=2))
        else:
            print("Usage: theme-manager <list|install|uninstall|apply|search>")
    else:
        print(json.dumps(tm.get_store_collections(), indent=2))
