
import os
import sys
from dotenv import load_dotenv

# Ensure we can import the app module
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

load_dotenv()

try:
    from app.core.ai_client import ai_client
except ImportError as e:
    print(f"Error importing app.core.ai_client: {e}")
    sys.exit(1)

def verify():
    print("=== AI Client Verification ===")
    
    # Provider Check
    print(f"Active Provider: {ai_client.provider.upper()}")
    
    if ai_client.provider == "mock":
        print("⚠️  Warning: Using MOCK provider. To enable real AI, set GEMINI_API_KEY or OPENAI_API_KEY in .env")
    else:
        print(f"✅ Real AI Enabled ({ai_client.provider})")

    # Test Call
    description = "El auto hace un ruido raro al frenar, como un chillido metálico."
    print(f"\nTesting Diagnosis with prompt: '{description}'")
    
    result = ai_client.analyze_symptoms(description)
    
    print("\nResult:")
    print(f"  Cause: {result.get('possible_cause')}")
    print(f"  Category: {result.get('suggested_category')}")
    print(f"  Severity: {result.get('severity')}")
    print(f"  Recommendation: {result.get('recommendation')}")
    
    if ai_client.provider != "mock":
        print("\n✅ API Call Successful!")
    else:
        print("\n✅ Mock Call Successful ( deterministic result )")

if __name__ == "__main__":
    verify()
