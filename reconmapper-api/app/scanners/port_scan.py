import socket

COMMON_PORTS = [21, 22, 25, 53, 80, 110, 143, 443, 3306, 3389, 8080]


def scan_ports(ip: str, ports: list[int] = COMMON_PORTS, timeout: float = 0.5) -> dict:
    if not ip:
        return {"open_ports": []}

    open_ports = []
    for port in ports:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((ip, port))
        if result == 0:
            open_ports.append(port)
        sock.close()

    return {"open_ports": open_ports}
