from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class Mechanic(Base):
    id = Column(Integer, primary_key=True, index=True)
    shop_name = Column(String, index=True, nullable=False)
    address = Column(String, nullable=True)
    phone = Column(String, nullable=True)
    specialties = Column(String, nullable=True) # Stored as comma-separated string for simplicity in MVP
    is_verified = Column(Boolean, default=False)
    description = Column(Text, nullable=True)
    
    owner_id = Column(Integer, ForeignKey("user.id"), unique=True, nullable=False)
    owner = relationship("User", back_populates="mechanic_profile")
    service_requests = relationship("ServiceRequest", back_populates="mechanic")
