#!/usr/bin/env python3
"""Calamares module for Karya DE hardware detection and driver installation."""

import subprocess
import os


def run():
    """Detect hardware and install appropriate drivers."""
    libcalamares = None
    try:
        import libcalamares
    except ImportError:
        pass

    def progress(msg):
        if libcalamares:
            libcalamares.utils.debug(f"[Karya HW] {msg}")
        print(f"[Karya HW] {msg}")

    progress("Detecting hardware...")

    # Run hardware detection
    detect_script = "/usr/lib/karya/scripts/detect-hardware.sh"
    if os.path.exists(detect_script):
        subprocess.run(["bash", detect_script])
        progress("Hardware detection complete.")

    # Install drivers based on detection
    install_script = "/usr/lib/karya/scripts/install-drivers.sh"
    if os.path.exists(install_script):
        progress("Installing drivers...")
        subprocess.run(["bash", install_script, "auto"])
        progress("Driver installation complete.")

    # Apply hardware-specific configs
    gpu_json = "/etc/karya/hardware/gpu.json"
    if os.path.exists(gpu_json):
        import json
        with open(gpu_json) as f:
            gpu = json.load(f)
        progress(f"GPU: {gpu.get('vendor')} - {gpu.get('model')}")

    return None
