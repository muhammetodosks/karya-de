"""
Karya DE - Configuration Writer Service
"""

import os
import subprocess
import json
from pathlib import Path

HOME = Path.home()
CONFIG = HOME / ".config"


class ConfigWriter:

    @staticmethod
    def write_kdeglobals(config: dict):
        """Write KDE global settings."""
        path = CONFIG / "kdeglobals"
        path.parent.mkdir(parents=True, exist_ok=True)

        content = f"""[General]
ColorScheme=karya-dark
Name=karya-dark
font=Noto Sans,10,-1,5,50,0,0,0,0,0
fixedFont=Hack,9,-1,5,50,0,0,0,0,0
toolBarFont=Noto Sans,9,-1,5,50,0,0,0,0,0
menuFont=Noto Sans,10,-1,5,50,0,0,0,0,0
smallestReadableFont=Noto Sans,8,-1,5,50,0,0,0,0,0
widgetStyle=Breeze
shadeSortColumn=true

[Icons]
Theme=karya-icons

[Theme]
name=karya-de

[KDE]
SingleClick=false
ShowDeleteCommand=true
ShowHiddenFiles=false
"""
        path.write_text(content)

    @staticmethod
    def write_environment(config: dict):
        """Write environment variables."""
        path = CONFIG / "environment"
        path.parent.mkdir(parents=True, exist_ok=True)

        content = """# Karya DE Environment
export XDG_CURRENT_DESKTOP=Karya
export XDG_SESSION_DESKTOP=Karya
export XDG_MENU_PREFIX=karya-
export GTK_THEME=Karya-dark:dark
export QT_STYLE_OVERRIDE=Breeze
export QT_QPA_PLATFORMTHEME=kde
export QT_AUTO_SCREEN_SCALE_FACTOR=1
"""
        # GPU-specific env vars
        driver = config.get("driver", "")
        if "nvidia" in driver:
            content += """
# NVIDIA specific
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
"""
        elif "amd" in driver:
            content += """
# AMD specific
export RADV_PERFTEST=aco
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
"""
        path.write_text(content)

    @staticmethod
    def write_kwinrc(config: dict):
        """Write KWin configuration with hardware-optimized settings."""
        path = CONFIG / "kwinrc"
        path.parent.mkdir(parents=True, exist_ok=True)

        components = config.get("components", {})
        driver = config.get("driver", "")
        profile = "balanced"

        # Determine compositor backend
        if "virtual" in driver:
            backend = "xrender"
            unsafe = True
        elif "nvidia" in driver:
            backend = "opengl"
            unsafe = False
        elif "intel" in driver:
            backend = "opengl"
            unsafe = False
        else:
            backend = "opengl"
            unsafe = False

        anim_duration = "150" if components.get("animations", True) else "0"
        blur_val = "true" if components.get("blur", True) else "false"
        night_color = "true" if components.get("nightcolor", True) else "false"

        nvidia_egl = "KWIN_DRM_USE_EGL_STREAMS=true\n" if "nvidia" in driver else ""
        nvidia_noams = "KWIN_DRM_NO_AMS=true\n" if "nvidia" in driver else ""

        content = f"""[Compositing]
Backend={backend}
Enabled=true
OpenGLIsUnsafe={str(unsafe).lower()}
AnimationsDuration={anim_duration}
MaxFps=60
{nvidia_egl}{nvidia_noams}

[MouseBindings]
CommandAllKey=Meta
CommandAll1=Move

[Script-karya-glassmorphism]
enabled={str(components.get("glassmorphism", True)).lower()}
blurRadius=12
opacity=0.75

[KaryaTiling]
Enabled={str(components.get("tiling", True)).lower()}
Layout=master-stack
Gap=4
AutoTileOnStart=true
KeyboardShortcut=Meta+T
CycleLayoutShortcut=Meta+Shift+T

[NightColor]
Active={night_color}
Latitude=39.0
Longitude=35.0
AutoLocation=true
Timing=Auto

[TabBox]
ShowTabBox=false
Layout=thumbnail_grid

[Windows]
Placement=Centered
FocusPolicy=ClickToFocus
TitlebarDoubleClickCommand=Maximize
"""
        path.write_text(content)

    @staticmethod
    def write_panel_layout(layout_id: str):
        """Write panel layout configuration."""
        layouts = {
            "karya-modern": {
                "top": ["kickoff", "icontasks", "spacer", "systemtray", "clock"],
                "bottom": ["dock"],
                "top_height": 36,
                "bottom_height": 48,
                "top_floating": False,
                "bottom_floating": True,
                "bottom_autohide": True,
            },
            "karya-classic": {
                "top": [],
                "bottom": ["kickoff", "icontasks", "spacer", "systemtray", "clock"],
                "bottom_height": 40,
                "bottom_floating": False,
                "bottom_autohide": False,
            },
            "karya-macos": {
                "top": ["appmenu", "clock", "spacer", "systemtray"],
                "bottom": ["dock"],
                "top_height": 28,
                "bottom_height": 52,
                "top_floating": False,
                "bottom_floating": True,
                "bottom_autohide": False,
            },
            "karya-minimal": {
                "top": [],
                "bottom": ["kickoff", "icontasks", "spacer", "systemtray", "clock"],
                "bottom_height": 36,
                "bottom_floating": False,
                "bottom_autohide": False,
            },
        }

        layout = layouts.get(layout_id, layouts["karya-modern"])
        path = CONFIG / "plasma-org.kde.plasma.desktop-appletsrc"
        path.parent.mkdir(parents=True, exist_ok=True)

        content = "[Containments][1]\n"
        content += "activityId=\n"
        content += "containmentType=panel\n"
        content += f"formFactor=2\n"
        content += f"location=4  # top\n"
        content += f"screen=0\n"
        content += f"lastScreen=0\n"
        content += "plugin=org.kde.plasma.folder\n"

        path.write_text(content)

    @staticmethod
    def write_components(components: dict):
        """Write component enable/disable configuration."""
        path = CONFIG / "karya-components.conf"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(components, indent=2))

    @staticmethod
    def create_user(username: str, realname: str, password: str, autologin: bool):
        """Create a system user."""
        if not username:
            return

        try:
            # Check if user exists
            result = subprocess.run(["id", username], capture_output=True)
            if result.returncode == 0:
                return

            # Create user
            args = ["useradd", "-m", "-G", "wheel,audio,video,storage,power",
                    "-s", "/bin/bash"]
            if realname:
                args += ["-c", realname]
            args.append(username)

            subprocess.run(args, check=True)

            # Set password
            if password:
                proc = subprocess.Popen(["passwd", username],
                                        stdin=subprocess.PIPE,
                                        stderr=subprocess.PIPE)
                proc.communicate(input=f"{password}\n{password}\n".encode())

            # Autologin
            if autologin:
                sddm_conf_dir = Path("/etc/sddm.conf.d")
                sddm_conf_dir.mkdir(parents=True, exist_ok=True)
                autologin_cfg = sddm_conf_dir / "karya-autologin.conf"
                content = f"""[Autologin]
User={username}
Session=karya-wayland.desktop
Relogin=true
"""
                autologin_cfg.write_text(content)

        except (subprocess.CalledProcessError, PermissionError):
            pass
