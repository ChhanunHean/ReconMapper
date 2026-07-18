import urllib.request
import urllib.error

SECURITY_HEADERS = [
    "Strict-Transport-Security",
    "Content-Security-Policy",
    "X-Frame-Options",
    "X-Content-Type-Options",
    "Referrer-Policy",
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

        return {
            "header_score": header_score,
            "headers_present": present,
            "headers_missing": missing,
        }

    except (urllib.error.URLError, TimeoutError, Exception):
        return {
            "header_score": 0,
            "headers_present": [],
            "headers_missing": SECURITY_HEADERS,
        }
