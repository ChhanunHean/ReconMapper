import socket

COMMON_PORTS = [
    21, 22, 23, 25, 53, 69, 80, 110, 111, 119, 123, 135, 137, 139,
    143, 161, 194, 389, 443, 445, 465, 514, 587, 631, 636, 993,
    995, 1080, 1194, 1433, 1521, 1723, 2049, 2375, 2376, 3000,
    3306, 3389, 4444, 5432, 5900, 5985, 5986, 6379, 6443, 7001,
    8080, 8443, 8888, 9000, 9090, 9092, 9200, 11211, 27017, 27018,
    50000
]

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
