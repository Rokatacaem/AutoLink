import enum
from sqlalchemy import Column, Integer, String, ForeignKey, Enum, DateTime, Text
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
    mechanic_id = Column(Integer, ForeignKey("mechanic.id"), nullable=False)
    vehicle_id = Column(Integer, ForeignKey("vehicle.id"), nullable=False)

    customer = relationship("User", back_populates="service_requests")
    mechanic = relationship("Mechanic", back_populates="service_requests")
    vehicle = relationship("Vehicle")
