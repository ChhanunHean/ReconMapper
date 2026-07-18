from sqlalchemy import Column, Integer, String, Float, DateTime, Text
from datetime import datetime
from .database import Base


class Target(Base):
    __tablename__ = "targets"

    id = Column(Integer, primary_key=True, index=True)
    domain = Column(String, unique=True, index=True)
    ip = Column(String, nullable=True)
    ping_ms = Column(Float, nullable=True)
    risk_score = Column(Integer, nullable=True)
    risk_level = Column(String, nullable=True)
    last_scanned = Column(DateTime, default=datetime.utcnow, nullable=True)
    full_result = Column(Text, nullable=True)
