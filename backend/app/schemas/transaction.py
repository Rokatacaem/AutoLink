from typing import Optional
from pydantic import BaseModel
from datetime import datetime
from app.models.transaction import PaymentStatus

class TransactionBase(BaseModel):
    amount: float
    status: Optional[PaymentStatus] = PaymentStatus.PENDING
    external_id: Optional[str] = None
    service_request_id: int

class TransactionCreate(TransactionBase):
    pass

class TransactionUpdate(TransactionBase):
    pass

class TransactionInDBBase(TransactionBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class Transaction(TransactionInDBBase):
    pass
