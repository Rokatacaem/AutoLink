from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps
from app.services.ai_service import ai_service

router = APIRouter()

@router.post("/diagnose", response_model=schemas.AIDiagnosticResponse)
async def diagnose_symptoms(
    *,
    db: Session = Depends(deps.get_db),
    diagnosis_in: schemas.DiagnosisRequest,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Analyze symptoms and provide a structured AI diagnosis.
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

    # Call AI Service
    result = await ai_service.generate_diagnostic_report(
        description=diagnosis_in.description,
        locale=diagnosis_in.locale,
        vehicle_context=vehicle_context
    )
    
    if diagnosis_in.auto_draft_request and diagnosis_in.vehicle_id:
        from app.schemas.service import ServiceRequestCreate
        from app.models.service import ServiceStatus
        
        # Combine the AI output into a single description context for the mechanic
        import logging
        logger = logging.getLogger(__name__)

        critical_header = ""
        if result.gravity_level.value == "Critical":
             critical_header = f"[CRITICAL SECURITY INCIDENT LOGGED IN DB]\nUser: {current_user.email} | Vehicle: {diagnosis_in.vehicle_id}\n\n"
             logger.warning(f"CRITICAL EMERGENCY TRIGGERED for user {current_user.email}")

        safety_text = f"=== Safety Protocol Issued ===\n{chr(10).join(result.safety_protocol)}\n\n" if result.safety_protocol else ""
        prevention_text = f"=== Prevention Tips ===\n{chr(10).join(result.prevention_tips)}\n\n" if result.prevention_tips else ""

        description_text = (
            f"{critical_header}"
            f"=== AI Diagnosis Summary ===\n{result.diagnosis_summary}\n\n"
            f"=== Technical Details ===\n{result.technical_details}\n\n"
            f"{safety_text}"
            f"{prevention_text}"
            f"=== Suggested Parts ===\n{', '.join(result.suggested_parts)}\n\n"
            f"=== Estimated Labor Hours ===\n{result.estimated_labor_hours} hours"
        )
        
        req_in = ServiceRequestCreate(
            description=description_text,
            vehicle_id=diagnosis_in.vehicle_id,
            mechanic_id=None # Optional, to be claimed later
        )
        
        draft_req = crud.service.create_with_customer(
            db=db,
            obj_in=req_in,
            customer_id=current_user.id
        )
        
        # We manually update to QUOTED as per MVP requirements
        draft_req.status = ServiceStatus.QUOTED
        db.commit()
    
    return result
