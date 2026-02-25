import enum
from sqlalchemy import Column, Integer, String, ForeignKey, Enum, DateTime, Text, Boolean, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base_class import Base

class ServiceStatus(str, enum.Enum):
    PENDING = "PENDING"
    QUOTED = "QUOTED"
    ACCEPTED = "ACCEPTED"
    REJECTED = "REJECTED"
    COMPLETED = "COMPLETED"
    CANCELED = "CANCELED"

class ServiceRequest(Base):
    id = Column(Integer, primary_key=True, index=True)
    description = Column(Text, nullable=False)
    status = Column(Enum(ServiceStatus), default=ServiceStatus.PENDING, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    scheduled_date = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    customer_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    mechanic_id = Column(Integer, ForeignKey("mechanic.id"), nullable=True)
    vehicle_id = Column(Integer, ForeignKey("vehicle.id"), nullable=False)

    customer = relationship("User", back_populates="service_requests")
    mechanic = relationship("Mechanic", back_populates="service_requests")
    vehicle = relationship("Vehicle")
    transaction = relationship("Transaction", back_populates="service_request", uselist=False)
    feedback = relationship("ServiceFeedback", back_populates="service_request", uselist=False)


class ServiceFeedback(Base):
    id = Column(Integer, primary_key=True, index=True)
    service_request_id = Column(Integer, ForeignKey("servicerequest.id"), nullable=False, unique=True)
    rating = Column(Integer, nullable=False) # 1 to 5
    comment = Column(Text, nullable=True)
    is_ai_accurate = Column(Boolean, default=True)
    
    # AI Analysis fields
    sentiment_score = Column(Float, nullable=True)         # -1.0 to 1.0
    technical_match_score = Column(Float, nullable=True)   # 0.0 to 1.0
    audit_summary = Column(Text, nullable=True)            # AI explanation of the score

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    service_request = relationship("ServiceRequest", back_populates="feedback")
