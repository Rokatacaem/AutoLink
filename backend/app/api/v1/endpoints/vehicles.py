from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
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
