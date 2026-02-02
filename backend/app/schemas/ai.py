from typing import Optional, List
from enum import Enum
from pydantic import BaseModel, Field

class UrgencyLevel(str, Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"
    CRITICAL = "Critical"

class Fault(BaseModel):
    issue: str
    severity: UrgencyLevel
    description: Optional[str] = None

class DiagnosisRequest(BaseModel):
    description: str = Field(..., min_length=10, description="Description of the vehicle symptoms")
    vehicle_id: Optional[int] = None
    locale: Optional[str] = "es_CL"

class AIDiagnosticResponse(BaseModel):
    health_score: int = Field(..., ge=0, le=100, description="Overall health score of the vehicle (0-100)")
    urgency_level: UrgencyLevel
    faults: List[Fault]
    recommended_actions: List[str]

# Legacy/Alternative response for backward compatibility if needed, 
# or we can remove DiagnosisResponse if it's not used elsewhere.
# Keeping DiagnosisResponse as a subset or alias if implementation requires.

