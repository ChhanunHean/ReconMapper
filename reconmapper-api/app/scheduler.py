import time
import json
import threading
from datetime import datetime
from sqlalchemy.orm import Session
from .database import SessionLocal
from .models import Target
from .scanners.dns_lookup import resolve_domain
from .scanners.ping import ping_host
from .scanners.port_scan import scan_ports
from .scanners.ssl_check import check_ssl
from .scanners.header_analysis import analyze_headers
from .scanners.location import get_ip_location
from .risk_engine import calculate_risk

def scan_single_target(db: Session, domain: str):
    try:
        # Run all scanners in sequence
        dns_result = resolve_domain(domain)
        ping_result = ping_host(domain)
        port_result = scan_ports(dns_result.get("ip"))
        ssl_result = check_ssl(domain)
        header_result = analyze_headers(domain)
        location_result = get_ip_location(dns_result.get("ip"))

        combined = {
            **dns_result,
            **ping_result,
            **port_result,
            **ssl_result,
            **header_result,
            "location": location_result,
        }


        # Calculate risk updates
        risk_result = calculate_risk(combined)
        combined.update(risk_result)

        # Update the database record
        target = db.query(Target).filter(Target.domain == domain).first()
        if target:
            target.ip = combined.get("ip")
            target.ping_ms = combined.get("ping_ms")
            target.risk_score = combined.get("risk_score")
            target.risk_level = combined.get("risk_level")
            target.full_result = json.dumps(combined)
            target.last_scanned = datetime.utcnow()
            db.commit()
            print(f"[Scheduler] Auto-scanned {domain}: risk {target.risk_level} ({target.risk_score})")
    except Exception as e:
        db.rollback()
        print(f"[Scheduler] Failed to scan {domain}: {e}")

def scheduler_loop():
    print("[Scheduler] Background auto-scanner thread starting...")
    # Sleep first to allow server boot-up/initial setup
    time.sleep(10)
    while True:
        try:
            db = SessionLocal()
            try:
                targets = db.query(Target).all()
                if targets:
                    print(f"[Scheduler] Starting periodic scan loop for {len(targets)} targets...")
                    for target in targets:
                        scan_single_target(db, target.domain)
            finally:
                db.close()
        except Exception as e:
            print(f"[Scheduler] Loop encountered an error: {e}")
        # Wait 60 seconds (1 minute) before scanning again
        time.sleep(60)

def start_scheduler():
    thread = threading.Thread(target=scheduler_loop, daemon=True)
    thread.start()
