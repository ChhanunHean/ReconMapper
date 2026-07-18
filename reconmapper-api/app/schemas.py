from pydantic import BaseModel
from datetime import datetime

class ScanRequest(BaseModel):
    domain: str


class ScanResponse(BaseModel):
    domain: str
    ip: str | None
    resolved: bool
    ping_ms: float | None
    alive: bool
    open_ports: list[int]
    ssl_valid: bool
    ssl_version: str | None
    ssl_days_left: int | None
    ssl_issuer: str | None
    header_score: int
    headers_present: list[str]
    headers_missing: list[str]
    risk_score: int
    risk_level: str

class TargetOut(BaseModel):
    id: int
    domain: str
    ip: str | None
    ping_ms: float | None
    risk_score: int | None
    risk_level: str | None
    last_scanned: datetime | None

    class Config:
        from_attributes = True
