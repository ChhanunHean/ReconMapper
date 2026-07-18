RISKY_PORTS = {21, 23, 3306, 3389, 8080}  # FTP, Telnet, MySQL, RDP, HTTP-alt — commonly exploited if exposed


def calculate_risk(scan_result: dict) -> dict:
    if not scan_result.get("resolved") or not scan_result.get("alive"):
        return {"risk_score": 0, "risk_level": "Critical"}

    score = 100

    # SSL checks
    if not scan_result.get("ssl_valid"):
        score -= 30
    else:
        days_left = scan_result.get("ssl_days_left") or 0
        if days_left < 15:
            score -= 20
        elif days_left < 30:
            score -= 10

    # Missing security headers — each missing header costs points
    missing_headers = scan_result.get("headers_missing", [])
    score -= len(missing_headers) * 6

    # Risky open ports
    open_ports = scan_result.get("open_ports", [])
    risky_open = [p for p in open_ports if p in RISKY_PORTS]
    score -= len(risky_open) * 10

    score = max(0, min(100, score))

    if score >= 80:
        level = "Low"
    elif score >= 60:
        level = "Medium"
    elif score >= 40:
        level = "High"
    else:
        level = "Critical"

    return {"risk_score": score, "risk_level": level}
