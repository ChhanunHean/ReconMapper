import json
from datetime import datetime
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import ScanRequest, ScanResponse, TargetOut
from ..scanners.dns_lookup import resolve_domain
from ..scanners.ping import ping_host
from ..scanners.port_scan import scan_ports
from ..scanners.ssl_check import check_ssl
from ..scanners.header_analysis import analyze_headers
from ..risk_engine import calculate_risk
from ..models import Target
from fastapi import HTTPException
from fastapi.responses import JSONResponse


router = APIRouter()


@router.post("/scan", response_model=ScanResponse)
def scan_target(request: ScanRequest, db: Session = Depends(get_db)):
    dns_result = resolve_domain(request.domain)
    ping_result = ping_host(request.domain)
    port_result = scan_ports(dns_result["ip"])
    ssl_result = check_ssl(request.domain)
    header_result = analyze_headers(request.domain)

    combined = {
        **dns_result,
        **ping_result,
        **port_result,
        **ssl_result,
        **header_result,
    }

    risk_result = calculate_risk(combined)
    combined.update(risk_result)

    # save or update the target row
    target = db.query(Target).filter(Target.domain == request.domain).first()
    if target is None:
        target = Target(domain=request.domain)
        db.add(target)

    target.ip = combined["ip"]
    target.ping_ms = combined["ping_ms"]
    target.risk_score = combined["risk_score"]
    target.risk_level = combined["risk_level"]
    target.full_result = json.dumps(combined)
    target.last_scanned = datetime.utcnow()

    db.commit()

    return combined


@router.get("/targets", response_model=list[TargetOut])
def list_targets(db: Session = Depends(get_db)):
    return db.query(Target).all()

@router.get("/export/{target_id}")
def export_target(target_id: int, db: Session = Depends(get_db)):
    target = db.query(Target).filter(Target.id == target_id).first()
    if target is None:
        raise HTTPException(status_code=404, detail="Target not found")

    data = json.loads(target.full_result) if target.full_result else {}
    return JSONResponse(content=data)
