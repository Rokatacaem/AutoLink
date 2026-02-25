from typing import Optional
from datetime import datetime
from pydantic import BaseModel
from app.models.service import ServiceStatus

# Shared properties
class ServiceRequestBase(BaseModel):
    description: Optional[str] = None
    scheduled_date: Optional[datetime] = None

# Properties to receive on creation
class ServiceRequestCreate(ServiceRequestBase):
    description: str
    vehicle_id: int
    mechanic_id: Optional[int] = None

# Properties to receive on update (e.g. status change)
class ServiceRequestUpdate(ServiceRequestBase):
    status: Optional[ServiceStatus] = None
    quote_amount: Optional[float] = None

# Properties shared by models stored in DB
class ServiceRequestInDBBase(ServiceRequestBase):
    id: int
    status: ServiceStatus
    created_at: datetime
    customer_id: int
    mechanic_id: Optional[int] = None
    vehicle_id: int

    class Config:
        from_attributes = True

# Properties to return to client
class ServiceRequest(ServiceRequestInDBBase):
    pass

class ServiceFeedbackCreate(BaseModel):
    rating: int
    comment: Optional[str] = None
    is_ai_accurate: bool = True

class ServiceFeedbackResponse(ServiceFeedbackCreate):
    id: int
    service_request_id: int
    sentiment_score: Optional[float] = None
    technical_match_score: Optional[float] = None
    created_at: datetime
    
    class Config:
        from_attributes = True
