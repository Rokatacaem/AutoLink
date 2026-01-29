from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class Vehicle(Base):
    id = Column(Integer, primary_key=True, index=True)
    vin = Column(String, unique=True, index=True, nullable=False)
    brand = Column(String, index=True)
    model = Column(String, index=True)
    year = Column(Integer)
    nickname = Column(String, nullable=True)
    
    owner_id = Column(Integer, ForeignKey("user.id"))
    owner = relationship("User", back_populates="vehicles")
