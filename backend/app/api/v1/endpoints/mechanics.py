from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps
from app.services.notification_service import notification_service
from pydantic import BaseModel

router = APIRouter()

class LocationUpdate(BaseModel):
    lat: float
    lon: float

@router.get("/", response_model=List[schemas.Mechanic])
def read_mechanics(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve all mechanics (search).
    """
    mechanics = crud.mechanic.get_multi(db=db, skip=skip, limit=limit)
    return mechanics

import math

def haversine(lat1, lon1, lat2, lon2):
    from math import radians, cos, sin, asin, sqrt
    if None in [lat1, lon1, lat2, lon2]:
        return float('inf')
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    dlon = lon2 - lon1 
    dlat = lat2 - lat1 
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a)) 
    r = 6371 # Radius of earth in kilometers
    return c * r

@router.get("/nearest_by_specialty", response_model=List[schemas.Mechanic])
def get_nearest_by_specialty(
    lat: float,
    lon: float,
    specialty: str,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve nearest 3 online mechanics by specialty.
    """
    # Fetch all mechanics. Filtering in DB is ideal, but for MVP Python filter is robust regardless of SQLite/Postgres dialect.
    mechanics = crud.mechanic.get_multi(db=db, limit=1000)
    
    eligible = []
    for m in mechanics:
        if m.owner and m.owner.is_online:
            # Check specialty (comma separated string)
            if m.specialties and specialty in m.specialties:
                # Calculate distance
                dist = haversine(lat, lon, m.owner.latitude, m.owner.longitude)
                eligible.append((dist, m))
                
    # Sort by distance
    eligible.sort(key=lambda x: x[0])
    
    top_3 = []
    
    for dist, mechanic in eligible[:3]:
        top_3.append(mechanic)
        
        # Trigger FCM Notification asynchronously or directly
        if mechanic.owner.fcm_token:
            notification_service.send_urgency_notification(
                fcm_token=mechanic.owner.fcm_token,
                specialty=specialty,
                distance_km=dist
            )
            
    # Return top 3
    return top_3

@router.post("/me", response_model=schemas.Mechanic)
def create_mechanic_profile(
    *,
    db: Session = Depends(deps.get_db),
    mechanic_in: schemas.MechanicCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create or update own mechanic profile.
    """
    if current_user.role != "mechanic" and current_user.role != "admin":
         raise HTTPException(status_code=400, detail="User must be a mechanic to create a profile")

    mechanic = crud.mechanic.get_by_owner(db=db, owner_id=current_user.id)
    if mechanic:
         raise HTTPException(status_code=400, detail="Profile already exists")
    
    mechanic = crud.mechanic.create_with_owner(
        db=db, obj_in=mechanic_in, owner_id=current_user.id
    )
    return mechanic

@router.get("/me", response_model=schemas.Mechanic)
def read_my_mechanic_profile(
    *,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get current user's mechanic profile.
    """
    mechanic = crud.mechanic.get_by_owner(db=db, owner_id=current_user.id)
    if not mechanic:
        raise HTTPException(status_code=404, detail="Mechanic profile not found")
    return mechanic

@router.patch("/me/location", response_model=dict)
def update_mechanic_location(
    *,
    db: Session = Depends(deps.get_db),
    location_in: LocationUpdate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update mechanic's real-time geographical location. 
    Intended to be called every ~30 seconds by the mechanic's app.
    """
    if current_user.role != "mechanic":
         raise HTTPException(status_code=400, detail="Only mechanics can update this location")

    # Update User's coordinates
    # Using raw SQL or fast update since this is high frequency
    current_user.latitude = location_in.lat
    current_user.longitude = location_in.lon
    current_user.is_online = True
    db.add(current_user)
    db.commit()
    
    return {"status": "ok", "lat": location_in.lat, "lon": location_in.lon}
