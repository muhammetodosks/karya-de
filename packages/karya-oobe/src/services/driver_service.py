"""
Karya DE - Driver Installer Service
"""

import subprocess
import os
from pathlib import Path


class DriverInstaller:
    DRIVER_MAP = {
        "nvidia-proprietary": {
            "pacman": ["nvidia", "nvidia-utils", "nvidia-dkms", "nvidia-settings",
                       "lib32-nvidia-utils"],
            "apt": ["nvidia-driver", "nvidia-utils", "nvidia-settings"],
            "config": "nvidia.conf",
        },
        "nvidia-nouveau": {
            "pacman": ["xf86-video-nouveau"],
            "apt": ["xserver-xorg-video-nouveau"],
            "config": "nouveau.conf",
        },
        "nvidia-optimus": {
            "pacman": ["nvidia", "nvidia-utils", "nvidia-prime",
                       "optimus-manager"],
            "apt": ["nvidia-driver", "nvidia-prime", "nvidia-optimus"],
            "config": "optimus.conf",
        },
        "amd-amdgpu": {
            "pacman": ["xf86-video-amdgpu", "mesa", "mesa-utils",
                       "lib32-mesa", "vulkan-radeon", "lib32-vulkan-radeon"],
            "apt": ["xserver-xorg-video-amdgpu", "mesa-utils",
                    "mesa-vulkan-drivers"],
            "config": "amd.conf",
        },
        "amd-pro": {
            "pacman": ["amdgpu-pro-install"],
            "apt": ["amdgpu-pro"],
            "config": "amd-pro.conf",
        },
        "intel-modesetting": {
            "pacman": ["xf86-video-intel", "mesa-utils",
                       "vulkan-intel", "lib32-vulkan-intel"],
            "apt": ["xserver-xorg-video-intel", "mesa-utils",
                    "mesa-vulkan-drivers"],
            "config": "intel.conf",
        },
        "intel-legacy": {
            "pacman": ["xf86-video-intel-legacy"],
            "apt": ["xserver-xorg-video-intel-legacy"],
            "config": "intel-legacy.conf",
        },
        "modesetting": {
            "pacman": [],
            "apt": [],
            "config": "modesetting.conf",
        },
        "virtual": {
            "pacman": ["virtualbox-guest-utils", "xf86-video-vmware"],
            "apt": ["virtualbox-guest-x11", "xserver-xorg-video-vmware"],
            "config": "virtual.conf",
        },
    }

    @staticmethod
    def get_driver_info(driver_id: str) -> dict:
        return DriverInstaller.DRIVER_MAP.get(driver_id, {"pacman": [], "apt": [], "config": "modesetting.conf"})

    @staticmethod
    def install(driver_id: str) -> bool:
        info = DriverInstaller.get_driver_info(driver_id)
        pkgs = info.get("pacman", [])

        if not pkgs:
            return True

        try:
            result = subprocess.run(
                ["pacman", "-S", "--noconfirm"] + pkgs,
                capture_output=True, text=True, timeout=300
            )
            if result.returncode == 0:
                return True

            # Try apt fallback
            apt_pkgs = info.get("apt", [])
            if apt_pkgs:
                result = subprocess.run(
                    ["apt", "install", "-y"] + apt_pkgs,
                    capture_output=True, text=True, timeout=300
                )
                return result.returncode == 0
            return False
        except subprocess.TimeoutExpired:
            return False

    @staticmethod
    def apply_xorg_config(driver_id: str):
        config_file = DriverInstaller.get_driver_info(driver_id).get("config", "modesetting.conf")
        src = Path(f"/usr/share/karya/hardware/profiles/{config_file}")
        dst = Path("/etc/X11/xorg.conf.d/10-karya-gpu.conf")

        dst.parent.mkdir(parents=True, exist_ok=True)

        if src.exists():
            dst.write_text(src.read_text())
        else:
            # Generic config
            dst.write_text(
                'Section "Device"\n'
                '    Identifier  "Karya GPU"\n'
                '    Driver      "modesetting"\n'
                '    Option      "TearFree" "true"\n'
                '    Option      "DRI" "3"\n'
                'EndSection\n'
            )

    @staticmethod
    def needs_vulkan(driver_id: str) -> bool:
        return driver_id in ("amd-amdgpu", "intel-modesetting", "nvidia-proprietary")
