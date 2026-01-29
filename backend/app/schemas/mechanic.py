from typing import Optional
from pydantic import BaseModel

# Shared properties
class MechanicBase(BaseModel):
    shop_name: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    specialties: Optional[str] = None
    description: Optional[str] = None

# Properties to receive on creation
class MechanicCreate(MechanicBase):
    shop_name: str

# Properties to receive on update
class MechanicUpdate(MechanicBase):
    pass

# Properties shared by models stored in DB
class MechanicInDBBase(MechanicBase):
    id: int
    owner_id: int
    is_verified: bool

    class Config:
        from_attributes = True

# Properties to return to client
class Mechanic(MechanicInDBBase):
    pass

# Properties stored in DB
class MechanicInDB(MechanicInDBBase):
    pass
