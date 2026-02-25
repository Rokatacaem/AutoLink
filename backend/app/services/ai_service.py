import os
import json
import logging
import google.generativeai as genai
from typing import Optional, Dict, Any
from app.schemas.ai import AIDiagnosticResponse, UrgencyLevel

logger = logging.getLogger(__name__)


class AIService:
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            logger.warning("GEMINI_API_KEY not found. AI features will be mocked or fail.")
        else:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def generate_diagnostic_report(
        self,
        description: str,
        locale: str,
        vehicle_context: Optional[Dict[str, Any]] = None
    ) -> AIDiagnosticResponse:
        """Generates a structured diagnostic report using Gemini."""
        if not self.api_key:
            return self._mock_response()

        vehicle_str = "Unknown Vehicle"
        if vehicle_context:
            vehicle_str = (
                f"{vehicle_context.get('brand', '')} "
                f"{vehicle_context.get('model', '')} "
                f"({vehicle_context.get('year', '')})"
            )

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
            response = self.model.generate_content(prompt)
            text = response.text.strip()
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

    async def audit_service_quality(
        self,
        ai_diagnosis_summary: str,
        mechanic_report: str,
        user_comment: str,
        user_rating: int,
        is_ai_accurate: bool
    ) -> dict:
        """
        Triangular audit: compares AI diagnosis vs mechanic report vs user comment.
        
        Returns:
            technical_score (float 1.0–10.0): quality of the mechanical resolution.
            sentiment_score (float -1.0–1.0): sentiment from the user comment.
            audit_summary (str): human-readable explanation for the reputation system.
            flag_suspicious (bool): True if inconsistencies suggest unjustified charges.
        """
        if not self.api_key:
            score = min(10.0, max(1.0, float(user_rating) * 2.0))
            return {
                "technical_score": score,
                "sentiment_score": (user_rating - 3) / 2.0,
                "audit_summary": "Análisis mock — GEMINI_API_KEY no configurada.",
                "flag_suspicious": False
            }

        prompt = f"""
        Eres un Auditor de Calidad Técnica para la plataforma AutoLink de servicios mecánicos.
        Tu tarea es evaluar si el mecánico resolvió lo que la IA diagnosticó inicialmente,
        cruzando tres fuentes de información.

        === DIAGNÓSTICO INICIAL (AutoLink AI) ===
        {ai_diagnosis_summary}

        === REPORTE DEL MECÁNICO (descripción del servicio completado) ===
        {mechanic_report}

        === FEEDBACK DEL CONDUCTOR ===
        Comentario: "{user_comment}"
        Rating del conductor: {user_rating}/5
        ¿Confirmó que el diagnóstico IA fue preciso?: {is_ai_accurate}

        === TU TAREA ===
        Analiza la coherencia entre los tres textos y responde con un JSON válido:
        {{
            "technical_score": (float, de 1.0 a 10.0. 10 = mecánico resolvió exactamente lo diagnosticado. 1 = cobró sin resolver o posible fraude),
            "sentiment_score": (float, de -1.0 a 1.0. Sentimiento general del conductor),
            "audit_summary": (string, una oración explicando el score asignado),
            "flag_suspicious": (boolean, true si detectas inconsistencias graves o señales de cobro injustificado)
        }}

        CRITICAL: Output ONLY the JSON. No markdown, no texto introductorio.
        """

        try:
            response = await self.model.generate_content_async(prompt)
            text = response.text.replace("```json", "").replace("```", "").strip()
            data = json.loads(text)
            # Clamp to valid ranges
            data["technical_score"] = min(10.0, max(1.0, float(data.get("technical_score", 5.0))))
            data["sentiment_score"] = min(1.0, max(-1.0, float(data.get("sentiment_score", 0.0))))
            data["flag_suspicious"] = bool(data.get("flag_suspicious", False))
            data["audit_summary"] = str(data.get("audit_summary", "Sin resumen disponible."))
            return data
        except Exception as e:
            logger.error(f"Feedback Audit AI Analysis failed: {e}")
            score = min(10.0, max(1.0, float(user_rating) * 2.0))
            return {
                "technical_score": score,
                "sentiment_score": (user_rating - 3) / 2.0,
                "audit_summary": f"Análisis de respaldo (error IA): rating {user_rating}/5.",
                "flag_suspicious": False
            }


ai_service = AIService()
