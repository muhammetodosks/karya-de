"""
Karya DE - Hardware Detection Service
Detects GPU, audio, network, and system info for optimal configuration.
"""

import json
import subprocess
import os
import shutil
from pathlib import Path

HARDWARE_DIR = Path("/etc/karya/hardware")


class HardwareInfo:
    def __init__(self):
        self.gpu = self._load_json("gpu.json")
        self.audio = self._load_json("audio.json")
        self.network = self._load_json("network.json")
        self.system = self._load_json("system.json")
        self.profile = self._load_json("profile.json")

    def _load_json(self, filename):
        path = HARDWARE_DIR / filename
        if path.exists():
            try:
                return json.loads(path.read_text())
            except (json.JSONDecodeError, OSError):
                return {}
        return {}

    @property
    def distro(self) -> str:
        return detect_distro()

    @property
    def distro_display(self) -> str:
        labels = {"arch": "Arch Linux", "ubuntu": "Ubuntu/Debian", "unknown": "Bilinmeyen"}
        return labels.get(self.distro, "Bilinmeyen")

    @property
    def gpu_vendor(self) -> str:
        return self.gpu.get("vendor", "unknown")

    @property
    def gpu_model(self) -> str:
        return self.gpu.get("model", "Unknown GPU")

    @property
    def is_nvidia(self) -> bool:
        return self.gpu.get("is_nvidia", False)

    @property
    def is_amd(self) -> bool:
        return self.gpu.get("is_amd", False)

    @property
    def is_intel(self) -> bool:
        return self.gpu.get("is_intel", False)

    @property
    def needs_proprietary(self) -> bool:
        return self.gpu.get("needs_proprietary_driver", False)

    @property
    def ram_mb(self) -> int:
        return self.system.get("ram_mb", 4096)

    @property
    def cpu_cores(self) -> int:
        return self.system.get("cpu_cores", 4)

    @property
    def is_laptop(self) -> bool:
        return self.system.get("is_laptop", False)

    @property
    def is_vm(self) -> bool:
        return self.system.get("is_vm", False)

    @property
    def cpu_model(self) -> str:
        return self.system.get("cpu_model", "Unknown CPU")

    @property
    def has_wifi(self) -> bool:
        return self.network.get("wifi", False)

    @property
    def has_bluetooth(self) -> bool:
        return self.network.get("bluetooth", False)

    @property
    def audio_server(self) -> str:
        return self.audio.get("server", "none")

    def get_gpu_display_text(self) -> str:
        vendor_labels = {
            "nvidia": "NVIDIA",
            "amd": "AMD",
            "intel": "Intel",
            "virtual": "Virtual Machine",
        }
        label = vendor_labels.get(self.gpu_vendor, "Unknown")
        return f"{label} - {self.gpu_model}"

    def get_performance_label(self) -> str:
        profile = self.profile.get("profile", "balanced")
        labels = {
            "lightweight": "Düşük Profil (4GB altı RAM)",
            "balanced": "Dengeli Profil",
            "performance": "Yüksek Performans",
        }
        return labels.get(profile, "Dengeli Profil")


def detect_distro() -> str:
    """Detect Linux distribution: 'arch', 'ubuntu', or 'unknown'."""
    try:
        if shutil.which("pacman"):
            return "arch"
        if shutil.which("apt"):
            return "ubuntu"
        if os.path.exists("/etc/arch-release"):
            return "arch"
        if os.path.exists("/etc/os-release"):
            with open("/etc/os-release") as f:
                data = f.read()
            if "ubuntu" in data.lower():
                return "ubuntu"
            if "debian" in data.lower():
                return "ubuntu"
            if "arch" in data.lower():
                return "arch"
    except OSError:
        pass
    return "unknown"


def run_detection():
    """Run hardware detection script and return HardwareInfo."""
    script = "/usr/lib/karya/scripts/detect-hardware.sh"
    if os.path.exists(script):
        subprocess.run(["bash", script], capture_output=True)

    # Fallback: manual detection if script fails
    HARDWARE_DIR.mkdir(parents=True, exist_ok=True)

    gpu_path = HARDWARE_DIR / "gpu.json"
    if not gpu_path.exists():
        _manual_gpu_detect()

    return HardwareInfo()


def _manual_gpu_detect():
    """Manual GPU detection fallback."""
    gpu_info = {"vendor": "unknown", "model": "Unknown", "driver": "unknown"}

    try:
        result = subprocess.run(
            ["lspci", "-nn"], capture_output=True, text=True
        )
        for line in result.stdout.split("\n"):
            if "VGA" in line or "3D" in line:
                line_lower = line.lower()
                if "nvidia" in line_lower:
                    gpu_info["vendor"] = "nvidia"
                    gpu_info["needs_proprietary_driver"] = True
                elif "amd" in line_lower or "radeon" in line_lower:
                    gpu_info["vendor"] = "amd"
                elif "intel" in line_lower:
                    gpu_info["vendor"] = "intel"
                gpu_info["model"] = line.split(":")[-1].strip()[:80]
                break
    except FileNotFoundError:
        pass

    gpu_path = HARDWARE_DIR / "gpu.json"
    gpu_path.write_text(json.dumps(gpu_info, indent=2))
