from typing import Optional
from datetime import datetime
from pydantic import BaseModel, field_validator

# Shared properties
class VehicleBase(BaseModel):
    vin: Optional[str] = None
    brand: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    nickname: Optional[str] = None

    @field_validator('year')
    @classmethod
    def validate_year(cls, v: Optional[int]) -> Optional[int]:
        if v is None:
            return v
        current_year = datetime.now().year
        if v > current_year + 1:
            raise ValueError(f"Year cannot be in the future (max {current_year + 1})")
        if v < 1900:
            raise ValueError("Year must be greater than 1900")
        return v

    @field_validator('vin')
    @classmethod
    def validate_vin(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        # Clean spaces and dashes, convert to uppercase
        clean_vin = v.replace("-", "").replace(" ", "").upper()
        if len(clean_vin) < 11 or len(clean_vin) > 17:
             raise ValueError("VIN length must be between 11 and 17 characters")
        return clean_vin

# Properties to receive on creation
class VehicleCreate(VehicleBase):
    vin: str
    year: int
    brand: str
    model: str

# Properties to receive on update
class VehicleUpdate(VehicleBase):
    pass

# Properties shared by models stored in DB
class VehicleInDBBase(VehicleBase):
    id: int
    owner_id: int

    class Config:
        from_attributes = True

# Properties to return to client
class Vehicle(VehicleInDBBase):
    pass

# Properties stored in DB
class VehicleInDB(VehicleInDBBase):
    pass
