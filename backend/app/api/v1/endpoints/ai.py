from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps
from app.core.ai_client import ai_client

router = APIRouter()

@router.post("/diagnose", response_model=schemas.DiagnosisResponse)
def diagnose_symptoms(
    *,
    db: Session = Depends(deps.get_db),
    diagnosis_in: schemas.DiagnosisRequest,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Analyze symptoms and provide a pre-diagnosis (Projected for AI integration).
    """
    vehicle_context = None
    if diagnosis_in.vehicle_id:
        vehicle = crud.vehicle.get(db=db, id=diagnosis_in.vehicle_id)
        if not vehicle:
            raise HTTPException(status_code=404, detail="Vehicle not found")
        if vehicle.owner_id != current_user.id:
             raise HTTPException(status_code=400, detail="Vehicle does not belong to user")
        
        vehicle_context = {
            "brand": vehicle.brand,
            "model": vehicle.model,
            "year": vehicle.year,
            "vin": vehicle.vin
        }

    # Call AI Client
    result = ai_client.analyze_symptoms(
        description=diagnosis_in.description,
        locale=diagnosis_in.locale,
        vehicle_context=vehicle_context
    )
    
    return result
