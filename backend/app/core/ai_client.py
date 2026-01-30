
import os
import json
import logging
from typing import Dict, Any, Optional
from dotenv import load_dotenv

load_dotenv()

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Providers
PROVIDER_GEMINI = "gemini"
PROVIDER_OPENAI = "openai"
PROVIDER_MOCK = "mock"

class AutoLinkAI:
    def __init__(self):
        self.provider = PROVIDER_MOCK
        self.gemini_key = os.getenv("GEMINI_API_KEY")
        self.openai_key = os.getenv("OPENAI_API_KEY")

        if self.gemini_key:
            import google.generativeai as genai
            genai.configure(api_key=self.gemini_key)
            self.gemini_model = genai.GenerativeModel('gemini-flash-latest')
            self.provider = PROVIDER_GEMINI
            logger.info("AI Provider: Google Gemini initialized")
        
        elif self.openai_key:
            from openai import OpenAI
            self.openai_client = OpenAI(api_key=self.openai_key)
            self.provider = PROVIDER_OPENAI
            logger.info("AI Provider: OpenAI initialized")
        
        else:
            logger.warning("AI Provider: No API keys found. Using Mock mode.")

    def analyze_symptoms(self, description: str, locale: str = "es_CL", vehicle_context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Analyze symptoms using the configured AI provider.
        Fallback to Mock if provider fails or is not configured.
        """
        try:
            if self.provider == PROVIDER_GEMINI:
                return self._analyze_gemini(description, locale, vehicle_context)
            elif self.provider == PROVIDER_OPENAI:
                return self._analyze_openai(description, locale, vehicle_context)
            else:
                return self._mock_analyze(description, locale, vehicle_context)
        except Exception as e:
            logger.error(f"AI Analysis Failed ({self.provider}): {e}")
            return self._mock_analyze(description, locale, vehicle_context)

    def _build_prompt(self, description: str, locale: str, vehicle_context: Optional[Dict[str, Any]]) -> str:
        vehicle_str = "Unknown Vehicle"
        if vehicle_context:
            vehicle_str = f"{vehicle_context.get('brand', '')} {vehicle_context.get('model', '')} ({vehicle_context.get('year', '')})"

        return f"""
        Act as an expert automotive mechanic AI. 
        Analyze the following problem description considering the vehicle context.
        
        Vehicle: {vehicle_str}
        Description: "{description}"
        Locale: {locale}

        Output explicitly and ONLY a valid JSON object with the following schema:
        {{
            "possible_cause": "Short technical cause (2-5 words)",
            "severity": "LOW, MEDIUM, HIGH, or CRITICAL",
            "suggested_category": "Brakes, Engine, Transmission, Electrical, Suspension, Body, or General",
            "confidence": 0.1 to 1.0 (float),
            "recommendation": "Actionable advice for the driver, in the same language as the locale ({locale}). Max 20 words."
        }}
        """

    def _analyze_gemini(self, description: str, locale: str, vehicle_context: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        prompt = self._build_prompt(description, locale, vehicle_context)
        response = self.gemini_model.generate_content(prompt)
        
        # Clean response (remove ```json ... ``` code blocks if present)
        text = response.text.strip()
        if text.startswith("```json"):
            text = text[7:-3].strip()
        elif text.startswith("```"):
            text = text[3:-3].strip()
            
        return json.loads(text)

    def _analyze_openai(self, description: str, locale: str, vehicle_context: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        prompt = self._build_prompt(description, locale, vehicle_context)
        response = self.openai_client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"}
        )
        return json.loads(response.choices[0].message.content)

    def _mock_analyze(self, description: str, locale: str, vehicle_context: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Mock implementation (Fallback)
        """
        logger.info("Using Mock Analysis Logic")
        desc_lower = description.lower()
        
        # Default response
        response = {
            "possible_cause": "Unknown Issue / Ruido desconocido",
            "severity": "LOW",
            "suggested_category": "General Inspection",
            "confidence": 0.5,
            "recommendation": "Visit a mechanic for a general check-up."
        }
        
        # Simple keywords
        if any(w in desc_lower for w in ["freno", "brake", "chillido", "squek"]):
             response.update({
                "possible_cause": "Worn Brake Pads",
                "severity": "HIGH",
                "suggested_category": "Brakes",
                "confidence": 0.9,
                "recommendation": "Check brake pads immediately."
            })
        elif any(w in desc_lower for w in ["motor", "engine", "humo", "smoke", "calienta"]):
             response.update({
                "possible_cause": "Engine Overheating",
                "severity": "CRITICAL",
                "suggested_category": "Engine",
                "confidence": 0.85,
                "recommendation": "Stop vehicle safely. Check coolant."
            })
        elif any(w in desc_lower for w in ["bateria", "battery", "arranca", "start"]):
             response.update({
                "possible_cause": "Battery/Alternator Issue",
                "severity": "MEDIUM",
                "suggested_category": "Electrical",
                "confidence": 0.8,
                "recommendation": "Check battery voltage or jump start."
            })

        if locale.startswith("es"):
            # Simple manual translation for mock
            if response["possible_cause"] == "Worn Brake Pads":
                 response["possible_cause"] = "Pastillas de Freno Desgastadas"
                 response["recommendation"] = "Revise frenos inmediatamente."
            if response["possible_cause"] == "Engine Overheating":
                 response["possible_cause"] = "Sobrecalentamiento Motor"
                 response["recommendation"] = "Detenga el auto. Revise refrigerante."
            if response["possible_cause"] == "Battery/Alternator Issue":
                 response["possible_cause"] = "Falla Batería/Alternador"
                 response["recommendation"] = "Revise voltaje o puenteé batería."
        
        return response

ai_client = AutoLinkAI()
