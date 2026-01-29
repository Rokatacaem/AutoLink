from sqlalchemy import Column, Integer, String
from app.db.base_class import Base

class Customization(Base):
    id = Column(Integer, primary_key=True, index=True)
    type = Column(String, index=True, nullable=False)  # e.g., 'COLOR', 'RIM', 'INTERIOR'
    value = Column(String, nullable=False)             # e.g., '#FF0000', '20_INCH_ALLOY'
    label = Column(String, nullable=False)             # e.g., 'Red', '20" Alloy Rims'
