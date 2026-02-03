from sqlalchemy import Boolean, Column, Integer, String, Enum, Float
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import enum

class UserRole(str, enum.Enum):
    CLIENT = "client"
    MECHANIC = "mechanic"
    ADMIN = "admin"

class User(Base):
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=True) # Nullable for Social Login users
    is_active = Column(Boolean(), default=True)
    is_superuser = Column(Boolean(), default=False)
    
    # Critical AutoLink Fields
    role = Column(Enum(UserRole), default=UserRole.CLIENT)
    preferred_locale = Column(String, default="es_CL")  # i18n
    
    # Critical Geo Fields (Mechanics/Users)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    is_online = Column(Boolean(), default=False)

    vehicles = relationship("Vehicle", back_populates="owner")
    mechanic_profile = relationship("Mechanic", back_populates="owner", uselist=False)
    service_requests = relationship("ServiceRequest", back_populates="customer")
