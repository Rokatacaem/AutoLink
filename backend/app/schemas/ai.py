from typing import Optional, List
from enum import Enum
from pydantic import BaseModel, Field
from app.models.mechanic import MechanicSpecialty

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
    auto_draft_request: bool = Field(default=False, description="Whether to automatically draft a Service Request")

class AIDiagnosticResponse(BaseModel):
    diagnosis_summary: str = Field(..., description="Explicación clara para el cliente")
    safety_protocol: list[str] = Field(default=[], description="Pasos inmediatos de resguardo")
    prevention_tips: list[str] = Field(default=[], description="Qué no hacer para agravar la falla")
    gravity_level: UrgencyLevel = Field(default=UrgencyLevel.LOW, description="Gravedad del incidente (Low, Medium, High, Critical)")
    technical_details: str = Field(..., description="Instrucciones específicas para el mecánico")
    suggested_parts: list[str] = Field(..., description="Lista de repuestos probables")
    estimated_labor_hours: float = Field(..., description="Tiempo estimado de reparación")
    required_specialty: MechanicSpecialty = Field(..., description="The main specialty required to fix the issue")

# Legacy/Alternative response for backward compatibility if needed, 
# or we can remove DiagnosisResponse if it's not used elsewhere.
# Keeping DiagnosisResponse as a subset or alias if implementation requires.

