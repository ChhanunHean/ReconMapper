import subprocess
import re
import platform


def ping_host(domain: str) -> dict:
    system = platform.system().lower()

    if system == "windows":
        cmd = ["ping", "-n", "1", "-w", "2000", domain]
    else:
        cmd = ["ping", "-c", "1", "-W", "2000", domain]

    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=5
        )
        if result.returncode != 0:
            return {"ping_ms": None, "alive": False}

        if system == "windows":
            match = re.search(r"time[=<]\s*(\d+)ms", result.stdout)
        else:
            match = re.search(r"time=([\d.]+)", result.stdout)

        ping_ms = float(match.group(1)) if match else None
        return {"ping_ms": ping_ms, "alive": True}

    except (subprocess.TimeoutExpired, Exception):
        return {"ping_ms": None, "alive": False}
