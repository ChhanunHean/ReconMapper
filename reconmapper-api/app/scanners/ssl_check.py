import ssl
import socket
from datetime import datetime


def check_ssl(domain: str, port: int = 443, timeout: float = 3.0) -> dict:
    try:
        context = ssl.create_default_context()
        with socket.create_connection((domain, port), timeout=timeout) as sock:
            with context.wrap_socket(sock, server_hostname=domain) as ssock:
                cert = ssock.getpeercert()
                version = ssock.version()

        expiry_str = cert.get("notAfter")
        expiry_date = datetime.strptime(expiry_str, "%b %d %H:%M:%S %Y %Z")
        days_left = (expiry_date - datetime.utcnow()).days

        issuer = dict(x[0] for x in cert.get("issuer", []))

        return {
            "ssl_valid": True,
            "ssl_version": version,
            "ssl_days_left": days_left,
            "ssl_issuer": issuer.get("organizationName", issuer.get("commonName", "Unknown")),
        }

    except Exception:
        return {
            "ssl_valid": False,
            "ssl_version": None,
            "ssl_days_left": None,
            "ssl_issuer": None,
        }
