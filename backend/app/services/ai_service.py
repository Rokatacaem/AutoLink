import os
import json
import logging
import google.generativeai as genai
from typing import Optional, Dict, Any, List
from app.schemas.ai import AIDiagnosticResponse, UrgencyLevel, Fault

logger = logging.getLogger(__name__)

class AIService:
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            logger.warning("GEMINI_API_KEY not found. AI features will be mocked or fail.")
        else:
            genai.configure(api_key=self.api_key)
            # Use a model appropriate for structured data extraction
            self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def generate_diagnostic_report(self, description: str, locale: str, vehicle_context: Optional[Dict[str, Any]] = None) -> AIDiagnosticResponse:
        """
        Generates a structured diagnostic report using Gemini.
        """
        # Fallback to mock if no key
        if not self.api_key:
             return self._mock_response()

        vehicle_str = "Unknown Vehicle"
        if vehicle_context:
            vehicle_str = f"{vehicle_context.get('brand', '')} {vehicle_context.get('model', '')} ({vehicle_context.get('year', '')})"

        prompt = f"""
        Eres el "AutoLink Safety Advisor", un experto automotriz enfocado en la SEGURIDAD DEL CONDUCTOR.
        Analiza los síntomas para el vehículo especificado.
        
        Vehicle: {vehicle_str}
        Symptoms: "{description}"
        Locale: {locale} (Es vital que la respuesta sea en este idioma/región)

        Tu respuesta DEBE seguir estrictamente esta estructura para el dictamen hacia el conductor:
        1. Evaluar si la falla es de Peligro Crítico (Fuego, Frenos cortados, Riesgo de choque mortal).
        2. Determinar pasos Inmediatos de Seguridad y de Prevención.
        3. Explicar la falla de forma sencilla y generar los detalles técnicos para el mecánico.

        Tonalidad de Safety Advisor: Profesional, calmado y directo. Cero tecnicismos en las secciones de seguridad del cliente.

        Return a VALID JSON object matching the following structure exactly:
        {{
            "diagnosis_summary": (string, Explicación empática y sencilla para el cliente),
            "safety_protocol": [(string, lista de 2 pasos críticos de seguridad inmediata)],
            "prevention_tips": [(string, lista de acciones que NO debe hacer para evitar agravar el daño)],
            "gravity_level": (string, MUST be exactly one of: "Low", "Medium", "High", "Critical"),
            "technical_details": (string, Instrucciones técnicas avanzadas SOLO para el mecánico),
            "suggested_parts": [(string, lista de repuestos probables)],
            "estimated_labor_hours": (float, tiempo estimado de reparación en horas),
            "required_specialty": (string, MUST be exactly one of: "ELECTRICAL", "MECHANICAL_ENGINE", "BRAKES", "TIRES", "COOLING_SYSTEM")
        }}
        
        CRITICAL: Output ONLY the JSON. No markdown code blocks, no intro text.
        """

        try:
            # We use async generation if available, or wrap synchronous call.
            # verify verify genai async support or loop run_in_executor if needed.
            # standard google-generativeai is synchronous but fast.
            # For strict asyncio in FastAPI, we should run this in a threadpool if it blocks.
            # However, for simplicity here we call it directly as it's often HTTP based.
            response = self.model.generate_content(prompt)
            
            text = response.text.strip()
            # Sanitize markdown if present (common thinking block or formatting)
            if text.startswith("```json"):
                text = text[7:]
            elif text.startswith("```"):
                text = text[3:]
            if text.endswith("```"):
                text = text[:-3]
            text = text.strip()
            
            data = json.loads(text)
            return AIDiagnosticResponse(**data)
            
        except Exception as e:
            logger.error(f"AI Generation failed: {e}")
            return self._mock_response()

    def _mock_response(self) -> AIDiagnosticResponse:
        from app.models.mechanic import MechanicSpecialty
        return AIDiagnosticResponse(
            diagnosis_summary="Simulated AI Diagnosis: The check engine light issue is likely related to sensors.",
            safety_protocol=["Enciende las luces de emergencia", "Estaciónate a la derecha"],
            prevention_tips=["No abras la tapa del motor si ves humo"],
            gravity_level=UrgencyLevel.CRITICAL,
            technical_details="OBD2 scan required. Possible O2 sensor failure or loose fuel cap.",
            suggested_parts=["O2 Sensor", "Spark Plugs"],
            estimated_labor_hours=1.5,
            required_specialty=MechanicSpecialty.MECHANICAL_ENGINE
        )

    async def analyze_feedback(self, comment: str, is_accurate: bool) -> dict:
        """
        Takes user feedback and evaluates:
        - sentiment_score (-1.0 to 1.0)
        - technical_match_score (0.0 to 1.0)
        """
        if not comment:
            return {"sentiment_score": 0.0, "technical_match_score": 1.0 if is_accurate else 0.0}
        
        prompt = f"""
        Act as a Quality Assurance AI. Analyze the following feedback from a driver about an AutoLink mechanic service and the previous AI diagnosis.
        Was the AI diagnosis accurate according to the user? {is_accurate}
        User Comment: "{comment}"

        Output ONLY a valid JSON with:
        {{
            "sentiment_score": (float, from -1.0 for very angry/negative to 1.0 for very happy/positive),
            "technical_match_score": (float, from 0.0 for completely wrong AI diagnosis to 1.0 for perfect match)
        }}
        """
        try:
            response = await self.model.generate_content_async(prompt)
            text = response.text.replace("```json", "").replace("```", "").strip()
            data = json.loads(text)
            return data
        except Exception as e:
            logger.error(f"Feedback AI Analysis failed: {e}")
            return {"sentiment_score": 0.0, "technical_match_score": 1.0 if is_accurate else 0.0}

ai_service = AIService()
