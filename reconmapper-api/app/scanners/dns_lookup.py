import socket


def resolve_domain(domain: str) -> dict:
    try:
        ip = socket.gethostbyname(domain)
        return {"domain": domain, "ip": ip, "resolved": True}
    except socket.gaierror:
        return {"domain": domain, "ip": None, "resolved": False}
