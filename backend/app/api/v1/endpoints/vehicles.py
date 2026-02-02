from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.schemas.maintenance import MaintenanceCreate, MaintenanceResponse
from app.models.maintenance import MaintenanceLog
from app.api import deps

router = APIRouter()

@router.get("/", response_model=List[schemas.Vehicle])
def read_vehicles(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve vehicles.
    """
    vehicles = crud.vehicle.get_multi_by_owner(
        db=db, owner_id=current_user.id, skip=skip, limit=limit
    )
    return vehicles

@router.post("/", response_model=schemas.Vehicle)
def create_vehicle(
    *,
    db: Session = Depends(deps.get_db),
    vehicle_in: schemas.VehicleCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new vehicle.
    """
    vehicle = crud.vehicle.create_with_owner(
        db=db, obj_in=vehicle_in, owner_id=current_user.id
    )
    return vehicle

@router.get("/{id}", response_model=schemas.Vehicle)
def read_vehicle(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get vehicle by ID.
    """
    vehicle = crud.vehicle.get(db=db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    if vehicle.owner_id != current_user.id:
        raise HTTPException(status_code=400, detail="Not enough permissions")
    return vehicle

@router.delete("/{id}", response_model=schemas.Vehicle)
def delete_vehicle(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete a vehicle.
    """
    vehicle = crud.vehicle.get(db=db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    if vehicle.owner_id != current_user.id:
        raise HTTPException(status_code=400, detail="Not enough permissions")
    vehicle = crud.vehicle.remove(db=db, id=id)
    return vehicle

@router.post("/{id}/maintenance", response_model=schemas.MaintenanceResponse)
def create_maintenance_log(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    maintenance_in: schemas.MaintenanceCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Log maintenance and update vehicle health score.
    """
    vehicle = crud.vehicle.get(db=db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    if vehicle.owner_id != current_user.id:
        raise HTTPException(status_code=400, detail="Not enough permissions")

    # Create Log
    db_log = models.MaintenanceLog(
        vehicle_id=id,
        description=maintenance_in.description,
        action_taken=maintenance_in.action_taken,
        score_impact=maintenance_in.score_impact
    )
    db.add(db_log)

    # Update Vehicle Score
    # Ensure initialized
    if vehicle.health_score is None:
        vehicle.health_score = 100
        
    new_score = vehicle.health_score + maintenance_in.score_impact
    if new_score > 100:
        new_score = 100
    vehicle.health_score = new_score
    
    db.add(vehicle)
    db.commit()
    db.refresh(db_log)
    
    return db_log
