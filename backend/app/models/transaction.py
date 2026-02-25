import enum
from sqlalchemy import Column, Integer, String, Float, Enum, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base_class import Base

class PaymentStatus(str, enum.Enum):
    PENDING = "PENDING"
    PAID = "PAID"
    DISBURSED = "DISBURSED"
    REFUNDED = "REFUNDED"

class Transaction(Base):
    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Float, nullable=False)
    status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING, index=True)
    external_id = Column(String, unique=True, index=True, nullable=True) # MercadoPago payment ID
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Optional metadata for debugging or extra MercadoPago data
    metadata_json = Column(Text, nullable=True) 

    # Relationship to Service Request (1-to-1)
    service_request_id = Column(Integer, ForeignKey("servicerequest.id"), unique=True, nullable=False)
    service_request = relationship("ServiceRequest", back_populates="transaction")
