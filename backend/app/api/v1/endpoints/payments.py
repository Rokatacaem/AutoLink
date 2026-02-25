import logging
from typing import Any, Dict
from fastapi import APIRouter, Depends, HTTPException, Request, BackgroundTasks
from sqlalchemy.orm import Session
from app.api import deps
from app import models, schemas
from app.models.transaction import PaymentStatus

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/webhook")
async def mercado_pago_webhook(
    request: Request,
    background_tasks: BackgroundTasks,
    db: Session = Depends(deps.get_db)
) -> Any:
    """
    Webhook endpoint to receive payment notifications from Mercado Pago.
    """
    payload = await request.json()
    logger.info(f"Received MP Webhook: {payload}")

    # Standard Mercado Pago webhook payload contains:
    # "action": "payment.created" or "payment.updated"
    # "data": {"id": "123456789"}
    # For MVP, we'll extract the external_id and fetch the transaction to update its status.
    # We simulate the reconciliation logic here.
    
    action = payload.get("action")
    data = payload.get("data", {})
    external_id = str(data.get("id"))

    if not action or not external_id:
        return {"status": "ignored", "reason": "missing required fields"}

    if action.startswith("payment."):
        # Pass to background task to process asynchronously to return 200 OK fast to MP
        background_tasks.add_task(process_payment_notification, external_id, db)
    
    return {"status": "received"}

def process_payment_notification(external_id: str, db: Session):
    """
    Process the payment notification from MP asynchronously.
    """
    # 1. Look up the transaction by external_id
    transaction = db.query(models.Transaction).filter(models.Transaction.external_id == external_id).first()
    
    if not transaction:
        logger.warning(f"Transaction not found for external_id: {external_id}")
        return

    # For MVP, we simulate that a payment created/updated webhook means PAID (Retention)
    # In production, we'd make an API call back to MP (e.g., requests.get(f"https://api.mercadopago.com/v1/payments/{external_id}", headers=...))
    # to verify the status is "approved".
    logger.info(f"Simulating payment verification for {external_id}...")
    
    if transaction.status == PaymentStatus.PENDING:
        transaction.status = PaymentStatus.PAID
        db.commit()
        db.refresh(transaction)
        logger.info(f"Transaction ID {transaction.id} updated to PAID.")
        
        # Optionally, update the generic ServiceRequest status if we want to move it from ACCEPTED to "IN_PROGRESS" upon payment hold
        # For this requirement: "El pago se procesa al inicio de la asistencia (Retención)"
