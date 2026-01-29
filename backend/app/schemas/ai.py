from typing import Optional, List
from pydantic import BaseModel, Field

class DiagnosisRequest(BaseModel):
    description: str = Field(..., min_length=10, description="Description of the vehicle symptoms")
    vehicle_id: Optional[int] = None
    locale: Optional[str] = "es_CL"

class DiagnosisResponse(BaseModel):
    possible_cause: str
    severity: str  # LOW, MEDIUM, HIGH, CRITICAL
    suggested_category: str # e.g., "Brakes", "Engine", "Suspension"
    confidence: float
    recommendation: str
