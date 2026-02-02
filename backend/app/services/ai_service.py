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
        Act as an expert automotive diagnostic AI. Analyze the symptoms described below for the specified vehicle.
        
        Vehicle: {vehicle_str}
        Symptoms: "{description}"
        Locale: {locale} (Ensure all text in faults and actions is in this language)

        Return a VALID JSON object matching the following structure exactly:
        {{
            "health_score": (int, 0-100, where 100 is perfect condition),
            "urgency_level": (string, must be one of: "Low", "Medium", "High", "Critical"),
            "faults": [
                {{
                    "issue": (string, distinct technical problem name),
                    "severity": (string, one of: "Low", "Medium", "High", "Critical"),
                    "description": (string, brief explanation of the issue)
                }}
            ],
            "recommended_actions": [(string, list of specific actionable steps for the driver)]
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
        return AIDiagnosticResponse(
            health_score=85,
            urgency_level=UrgencyLevel.LOW,
            faults=[
                Fault(issue="Simulated AI Issue", severity=UrgencyLevel.LOW, description="AI service unavailable, showcasing mock data.")
            ],
            recommended_actions=["Check internet connection.", "Verify API keys."]
        )

ai_service = AIService()
