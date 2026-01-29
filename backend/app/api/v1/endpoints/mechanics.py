from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps

router = APIRouter()

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
