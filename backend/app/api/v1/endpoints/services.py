from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps

router = APIRouter()

@router.post("/", response_model=schemas.ServiceRequest)
def create_service_request(
    *,
    db: Session = Depends(deps.get_db),
    service_in: schemas.ServiceRequestCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create a new service request (Client -> Mechanic).
    """
    # 1. Validate Vehicle ownership
    vehicle = crud.vehicle.get(db=db, id=service_in.vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    if vehicle.owner_id != current_user.id:
        raise HTTPException(status_code=400, detail="Vehicle does not belong to user")
    
    # 2. Validate Mechanic existence
    mechanic = crud.mechanic.get(db=db, id=service_in.mechanic_id)
    if not mechanic:
        raise HTTPException(status_code=404, detail="Mechanic not found")

    service_request = crud.service.create_with_customer(
        db=db, obj_in=service_in, customer_id=current_user.id
    )
    return service_request

@router.get("/sent", response_model=List[schemas.ServiceRequest])
def read_sent_requests(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get requests sent by current user (Client).
    """
    return crud.service.get_multi_by_customer(
        db=db, customer_id=current_user.id, skip=skip, limit=limit
    )

@router.get("/received", response_model=List[schemas.ServiceRequest])
def read_received_requests(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get requests received by current user (Mechanic).
    """
    if current_user.role != "mechanic":
         raise HTTPException(status_code=400, detail="Only mechanics can view received requests")
    
    # Get mechanic profile id
    mechanic_profile = crud.mechanic.get_by_owner(db=db, owner_id=current_user.id)
    if not mechanic_profile:
        raise HTTPException(status_code=404, detail="Mechanic profile not found")

    return crud.service.get_multi_by_mechanic(
        db=db, mechanic_id=mechanic_profile.id, skip=skip, limit=limit
    )

@router.patch("/{id}/status", response_model=schemas.ServiceRequest)
def update_request_status(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    status_in: schemas.ServiceRequestUpdate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update request status (Mechanic only).
    """
    service_request = crud.service.get(db=db, id=id)
    if not service_request:
        raise HTTPException(status_code=404, detail="Request not found")

    # Validate Permission (Must be the assigned mechanic)
    mechanic_profile = crud.mechanic.get_by_owner(db=db, owner_id=current_user.id)
    if not mechanic_profile or service_request.mechanic_id != mechanic_profile.id:
         raise HTTPException(status_code=400, detail="Not permitted")

    service_request = crud.service.update(db=db, db_obj=service_request, obj_in=status_in)
    return service_request
