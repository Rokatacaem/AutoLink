"""
Admin Telemetry Endpoint — Live Operations Map Data
GET /api/v1/admin/map-data

Returns real-time positions of online mechanics and active service requests
for the operations dashboard map.
"""
from typing import Any, List, Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app import models
from app.api import deps

router = APIRouter()


# ── Pydantic response schemas ──────────────────────────────────────────────────

class MechanicMapFeature(BaseModel):
    id: int
    name: str
    lat: Optional[float]
    lng: Optional[float]
    status: str          # "ONLINE" | "OFFLINE"
    reputation_score: float

    class Config:
        from_attributes = True


class ServiceRequestMapFeature(BaseModel):
    id: int
    customer_name: str
    lat: Optional[float]
    lng: Optional[float]
    diagnosis: str
    service_status: str  # "PENDING" | "ACCEPTED" | etc.

    class Config:
        from_attributes = True


class MapDataResponse(BaseModel):
    mechanics: List[MechanicMapFeature]
    active_requests: List[ServiceRequestMapFeature]


# ── Endpoint ───────────────────────────────────────────────────────────────────

@router.get("/map-data", response_model=MapDataResponse)
def get_map_data(
    db: Session = Depends(deps.get_db),
) -> Any:
    """
    Returns GeoJSON-like snapshot of all mechanics and active service requests
    for the Live Operations Map dashboard. No auth required for internal admin use.
    """

    # ── Mechanics ──────────────────────────────────────────────────────────────
    mechanics_db = db.query(models.Mechanic).join(
        models.User, models.Mechanic.owner_id == models.User.id
    ).all()

    mechanics_out = []
    for m in mechanics_db:
        mechanics_out.append(MechanicMapFeature(
            id=m.id,
            name=m.shop_name,
            lat=m.owner.latitude if m.owner else None,
            lng=m.owner.longitude if m.owner else None,
            status="ONLINE" if (m.owner and m.owner.is_online) else "OFFLINE",
            reputation_score=m.reputation_score or 5.0,
        ))

    # ── Active Service Requests (PENDING + ACCEPTED) ───────────────────────────
    from app.models.service import ServiceStatus
    active_requests_db = db.query(models.ServiceRequest).filter(
        models.ServiceRequest.status.in_([
            ServiceStatus.PENDING,
            ServiceStatus.ACCEPTED,
        ])
    ).join(
        models.User, models.ServiceRequest.customer_id == models.User.id
    ).limit(100).all()

    requests_out = []
    for sr in active_requests_db:
        requests_out.append(ServiceRequestMapFeature(
            id=sr.id,
            customer_name=sr.customer.full_name if sr.customer else f"Cliente #{sr.customer_id}",
            lat=sr.customer.latitude if sr.customer else None,
            lng=sr.customer.longitude if sr.customer else None,
            diagnosis=sr.description[:80] + "..." if len(sr.description) > 80 else sr.description,
            service_status=sr.status.value,
        ))

    return MapDataResponse(mechanics=mechanics_out, active_requests=requests_out)
