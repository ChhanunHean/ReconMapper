import urllib.request
import json

def get_ip_location(ip: str) -> str:
    if not ip:
        return "Unknown"
    try:
        url = f"http://ip-api.com/json/{ip}"
        req = urllib.request.Request(url, headers={"User-Agent": "ReconMapper/1.0"})
        with urllib.request.urlopen(req, timeout=3.0) as response:
            data = json.loads(response.read().decode())
            if data.get("status") == "success":
                country = data.get("country", "")
                city = data.get("city", "")
                if city and country:
                    return f"{city}, {country}"
                return country or "Unknown"
    except Exception:
        pass
    return "Unknown"
