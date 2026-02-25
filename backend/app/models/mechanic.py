import enum
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class MechanicSpecialty(str, enum.Enum):
    ELECTRICAL = "ELECTRICAL"
    MECHANICAL_ENGINE = "MECHANICAL_ENGINE"
    BRAKES = "BRAKES"
    TIRES = "TIRES"
    COOLING_SYSTEM = "COOLING_SYSTEM"

class Mechanic(Base):
    id = Column(Integer, primary_key=True, index=True)
    shop_name = Column(String, index=True, nullable=False)
    address = Column(String, nullable=True)
    phone = Column(String, nullable=True)
    specialties = Column(String, nullable=True) # Kept as String for multiple, but values should match MechanicSpecialty
    is_verified = Column(Boolean, default=False)
    description = Column(Text, nullable=True)
    
    owner_id = Column(Integer, ForeignKey("user.id"), unique=True, nullable=False)
    owner = relationship("User", back_populates="mechanic_profile")
    service_requests = relationship("ServiceRequest", back_populates="mechanic")
    subscriptions = relationship("Subscription", back_populates="mechanic")
