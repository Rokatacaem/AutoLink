from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class MaintenanceBase(BaseModel):
    description: String
    action_taken: String
    score_impact: int

class MaintenanceCreate(MaintenanceBase):
    pass

class MaintenanceResponse(MaintenanceBase):
    id: int
    vehicle_id: int
    timestamp: datetime

    class Config:
        from_attributes = True
