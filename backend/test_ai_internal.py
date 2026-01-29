import random
import string
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def random_string(length=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

def test_ai_flow():
    state = {}
    password = "secure_password_123"

    print("=== Testing AI Diagnosis Module ===")

    # 1. Register Client
    client_email = f"ai_user_{random_string()}@test.com"
    client.post("/api/v1/auth/register", json={"email": client_email, "password": password, "full_name": "AI User", "role": "client"})
    token = client.post("/api/v1/auth/login", data={"username": client_email, "password": password}).json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    # 2. Test Brakes Issue (Mock Logic: "freno")
    print("Testing Brakes Scenario...")
    payload = {
        "description": "Hola, tengo un problema. Al pisar el freno suena un chillido muy fuerte.",
        "locale": "es_CL"
    }
    r = client.post("/api/v1/ai/diagnose", json=payload, headers=headers)
    if r.status_code == 200:
        data = r.json()
        print(f"Response: {data['possible_cause']}")
        if "freno" in data["possible_cause"].lower() and data["suggested_category"] == "Brakes":
            print("✅ Brakes Diagnosis Verified")
        else:
            print("❌ Diagnosis mismatch")
    else:
         print(f"❌ Request failed: {r.status_code} {r.text}")

    # 3. Test Engine Issue (Mock Logic: "motor")
    print("Testing Engine Scenario...")
    payload = {
        "description": "El motor hace un ruido extraño y sale humo.",
        "locale": "es_CL"
    }
    r = client.post("/api/v1/ai/diagnose", json=payload, headers=headers)
    if r.status_code == 200:
        data = r.json()
        if data["severity"] == "CRITICAL" and data["suggested_category"] == "Engine":
            print("✅ Engine Diagnosis Verified (Critical Severity)")
        else:
            print(f"❌ Diagnosis mismatch: {data}")

    # 4. Test With Vehicle Context
    print("Testing Context Injection...")
    # Create Vehicle
    v_res = client.post("/api/v1/vehicles/", json={"vin": f"VIN{random_string()}", "brand": "Nissan", "model": "V16", "year": 2010}, headers=headers)
    vehicle_id = v_res.json()["id"]
    
    payload = {
        "description": "No arranca y la bateria parece vieja.",
        "vehicle_id": vehicle_id
    }
    r = client.post("/api/v1/ai/diagnose", json=payload, headers=headers)
    if r.status_code == 200:
        data = r.json()
        if "Nissan" in data["recommendation"] and "V16" in data["recommendation"]:
            print("✅ Context Injection Verified (Car model in recommendation)")
        else:
            print(f"❌ Context missing in recommendation: {data['recommendation']}")

if __name__ == "__main__":
    test_ai_flow()
