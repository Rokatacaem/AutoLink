from typing import Dict, Any, Optional

class AutoLinkAI:
    def __init__(self):
        # In the future, initialize OpenAI or Gemini client here
        pass

    def analyze_symptoms(self, description: str, locale: str = "es_CL", vehicle_context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Mock implementation of symptom analysis.
        Returns a deterministic diagnosis based on keywords.
        """
        desc_lower = description.lower()
        
        # Default response
        response = {
            "possible_cause": "Unknown Issue / Ruido desconocido",
            "severity": "LOW",
            "suggested_category": "General Inspection",
            "confidence": 0.5,
            "recommendation": "Visit a mechanic for a general check-up. / Visite un mecánico para revisión general."
        }

        # Mock Logic
        if "freno" in desc_lower or "brake" in desc_lower or "chillido" in desc_lower:
            response = {
                "possible_cause": "Worn Brake Pads / Pastillas de freno desgastadas",
                "severity": "HIGH",
                "suggested_category": "Brakes",
                "confidence": 0.9,
                "recommendation": "Do not drive long distances. Check brake pads immediately."
            }
        elif "motor" in desc_lower or "engine" in desc_lower or "humo" in desc_lower:
            response = {
                "possible_cause": "Potential Engine Overheating / Posible sobrecalentamiento",
                "severity": "CRITICAL",
                "suggested_category": "Engine",
                "confidence": 0.85,
                "recommendation": "Stop the vehicle safely and check coolant levels."
            }
        elif "bateria" in desc_lower or "battery" in desc_lower or "arranca" in desc_lower:
            response = {
                "possible_cause": "Dead Battery or Alternator / Batería muerta o alternador",
                "severity": "MEDIUM",
                "suggested_category": "Electrical",
                "confidence": 0.8,
                "recommendation": "Try jump-starting the car or replace battery."
            }

        # Context enrichment (Mock)
        if vehicle_context:
            response["recommendation"] += f" (Note: Applicable to {vehicle_context.get('brand')} {vehicle_context.get('model')})"

        return response

ai_client = AutoLinkAI()
