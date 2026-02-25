from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps
from app.models.service import ServiceStatus
from app.models.transaction import PaymentStatus
from app.services.notification_service import notification_service

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

    previous_status = service_request.status

    service_request = crud.service.update(db=db, db_obj=service_request, obj_in=status_in)
    
    # Commission Logic: When mechanic quotes, create the Transaction with 15% platform fee
    if status_in.quote_amount is not None and service_request.status == ServiceStatus.QUOTED:
        # Check if transaction already exists (avoid duplicates)
        if not service_request.transaction:
            # 15% Platform fee
            total_amount = status_in.quote_amount * 1.15
            new_transaction = models.Transaction(
                amount=total_amount,
                status=PaymentStatus.PENDING,
                service_request_id=service_request.id
            )
            db.add(new_transaction)
            db.commit()
    
    # Reconciliation Logic: If completed, disburse the retained payment
    if previous_status != ServiceStatus.COMPLETED and service_request.status == ServiceStatus.COMPLETED:
        if service_request.transaction and service_request.transaction.status == PaymentStatus.PAID:
            service_request.transaction.status = PaymentStatus.DISBURSED
            db.add(service_request.transaction)
            db.commit()

    return service_request

@router.patch("/{id}/accept", response_model=schemas.ServiceRequest)
def accept_service_request(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Accept a service request (Mechanic only - Locking logic).
    Ensures only one mechanic can take the request.
    """
    if current_user.role != "mechanic":
         raise HTTPException(status_code=400, detail="Only mechanics can accept requests")

    mechanic_profile = crud.mechanic.get_by_owner(db=db, owner_id=current_user.id)
    if not mechanic_profile:
        raise HTTPException(status_code=404, detail="Mechanic profile not found")

    service_request = crud.service.get(db=db, id=id)
    if not service_request:
        raise HTTPException(status_code=404, detail="Request not found")

    # Locking Logic: Check if it's already taken
    if service_request.status != ServiceStatus.PENDING or service_request.mechanic_id is not None:
         raise HTTPException(status_code=409, detail="Request already accepted by another mechanic or not pending")

    # Atomically assign (Simplification, proper DB-level lock would use SELECT FOR UPDATE)
    service_request.mechanic_id = mechanic_profile.id
    service_request.status = ServiceStatus.ACCEPTED
    db.add(service_request)
    db.commit()
    db.refresh(service_request)

    # Handshake Notification: Notify the Client
    if service_request.customer and service_request.customer.fcm_token:
        # We can calculate rough ETA if we have coords, or hardcode 15 mins for now
        notification_service.send_client_acceptance_notification(
            fcm_token=service_request.customer.fcm_token,
            mechanic_name=mechanic_profile.shop_name,
            eta_minutes=15
        )

    return service_request

async def _process_feedback_analysis(db: Session, feedback_id: int, comment: str, is_accurate: bool):
    from app.services.ai_service import ai_service
    # Run AI Analysis
    ai_result = await ai_service.analyze_feedback(comment, is_accurate)
    
    # Update DB
    feedback = db.query(models.ServiceFeedback).filter(models.ServiceFeedback.id == feedback_id).first()
    if feedback:
        feedback.sentiment_score = ai_result.get("sentiment_score", 0.0)
        feedback.technical_match_score = ai_result.get("technical_match_score", 1.0)
        db.add(feedback)
        db.commit()

@router.post("/{id}/feedback", response_model=schemas.ServiceFeedbackResponse)
def submit_service_feedback(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    feedback_in: schemas.ServiceFeedbackCreate,
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Submits driver feedback for a completed service request.
    Triggers background AI evaluation on text patterns.
    """
    service_request = crud.service.get(db=db, id=id)
    if not service_request:
        raise HTTPException(status_code=404, detail="Request not found")
        
    if service_request.customer_id != current_user.id:
        raise HTTPException(status_code=400, detail="Only the driver can leave feedback")
        
    if service_request.status != ServiceStatus.COMPLETED:
        raise HTTPException(status_code=400, detail="Service must be COMPLETED to leave feedback")
        
    if service_request.feedback:
        raise HTTPException(status_code=400, detail="Feedback already submitted for this service")
        
    new_feedback = models.ServiceFeedback(
        service_request_id=service_request.id,
        rating=feedback_in.rating,
        comment=feedback_in.comment,
        is_ai_accurate=feedback_in.is_ai_accurate
    )
    
    db.add(new_feedback)
    db.commit()
    db.refresh(new_feedback)
    
    # Trigger generative AI analysis in the background
    background_tasks.add_task(
        _process_feedback_analysis, 
        db=db, 
        feedback_id=new_feedback.id, 
        comment=feedback_in.comment or "", 
        is_accurate=feedback_in.is_ai_accurate
    )

    return new_feedback

