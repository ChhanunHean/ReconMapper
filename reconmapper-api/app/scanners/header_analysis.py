import urllib.request
import urllib.error

SECURITY_HEADERS = [
    "Strict-Transport-Security",
    "Content-Security-Policy",
    "X-Frame-Options",
    "X-Content-Type-Options",
    "Referrer-Policy",
    "Permissions-Policy",
    "X-XSS-Protection",
    "Cross-Origin-Opener-Policy",
    "Cross-Origin-Resource-Policy",
]


def analyze_headers(domain: str, timeout: float = 3.0) -> dict:
    url = f"https://{domain}"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "ReconMapper/1.0"})
        with urllib.request.urlopen(req, timeout=timeout) as response:
            headers = response.headers

        present = [h for h in SECURITY_HEADERS if headers.get(h)]
        missing = [h for h in SECURITY_HEADERS if not headers.get(h)]
        header_score = round((len(present) / len(SECURITY_HEADERS)) * 100)

        # 1. Extract Server Version
        server = headers.get("Server", "Unknown")

        # 2. Extract Tech Stack
        x_powered = headers.get("X-Powered-By")
        tech_list = []
        if x_powered:
            tech_list.append(x_powered)
        
        cookie_header = headers.get("Set-Cookie", "")
        if "PHPSESSID" in cookie_header:
            tech_list.append("PHP")
        if "JSESSIONID" in cookie_header:
            tech_list.append("Java / JSP")
        if "laravel_session" in cookie_header:
            tech_list.append("Laravel")
        if "django" in cookie_header or "sessionid" in cookie_header:
            tech_list.append("Python")
        
        tech_stack = ", ".join(tech_list) if tech_list else "Unknown"

        # 3. Detect WAF (Web Application Firewall)
        waf = "None detected"
        server_lower = server.lower()
        if "cloudflare" in server_lower or "cf-ray" in headers:
            waf = "Cloudflare"
        elif "sucuri" in headers or "x-sucuri-id" in headers:
            waf = "Sucuri"
        elif "incapsula" in headers or "x-cdn" in headers:
            waf = "Imperva / Incapsula"
        elif "wordfence" in cookie_header:
            waf = "Wordfence WAF"
        elif "cloudfront" in server_lower or headers.get("Via", "").lower().find("cloudfront") != -1:
            waf = "AWS CloudFront"

        return {
            "header_score": header_score,
            "headers_present": present,
            "headers_missing": missing,
            "server": server,
            "tech_stack": tech_stack,
            "waf": waf,
        }

    except (urllib.error.URLError, TimeoutError, Exception):
        return {
            "header_score": 0,
            "headers_present": [],
            "headers_missing": SECURITY_HEADERS,
            "server": "Unknown",
            "tech_stack": "Unknown",
            "waf": "None detected",
        }

