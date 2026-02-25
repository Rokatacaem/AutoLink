from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base_class import Base

class Subscription(Base):
    id = Column(Integer, primary_key=True, index=True)
    tier_name = Column(String, nullable=False, default="BASIC") # e.g., BASIC, PRO, PREMIUM
    price_per_month = Column(Float, nullable=False, default=10.0) # Starts at 10 USD
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Expiration date for the subscription tier
    valid_until = Column(DateTime(timezone=True), nullable=True)

    mechanic_id = Column(Integer, ForeignKey("mechanic.id"), nullable=False)
    mechanic = relationship("Mechanic", back_populates="subscriptions")
