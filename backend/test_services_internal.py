import random
import string
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def random_string(length=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

def test_service_flow():
    state = {}
    password = "secure_password_123"

    print("=== Testing Service Module ===")

    # 1. Setup Mechanic
    mech_email = f"mech_{random_string()}@test.com"
    client.post("/api/v1/auth/register", json={"email": mech_email, "password": password, "full_name": "Mike Mech", "role": "mechanic"})
    mech_token = client.post("/api/v1/auth/login", data={"username": mech_email, "password": password}).json()["access_token"]
    mech_headers = {"Authorization": f"Bearer {mech_token}"}
    
    # Create Mechanic Profile
    r = client.post("/api/v1/mechanics/me", json={"shop_name": "Mike's Shop"}, headers=mech_headers)
    state["mechanic_id"] = r.json()["id"]
    print(f"✅ Setup Mechanic (ID: {state['mechanic_id']})")

    # 2. Setup Client & Vehicle
    client_email = f"client_{random_string()}@test.com"
    client.post("/api/v1/auth/register", json={"email": client_email, "password": password, "full_name": "Charlie Client", "role": "client"})
    client_token = client.post("/api/v1/auth/login", data={"username": client_email, "password": password}).json()["access_token"]
    client_headers = {"Authorization": f"Bearer {client_token}"}

    # Create Vehicle
    r = client.post("/api/v1/vehicles/", json={"vin": f"VIN{random_string()}", "brand": "Toyota", "model": "Corolla", "year": 2018}, headers=client_headers)
    state["vehicle_id"] = r.json()["id"]
    print(f"✅ Setup Client & Vehicle (ID: {state['vehicle_id']})")

    # 3. Create Service Request (Client -> Mechanic)
    req_payload = {
        "description": "Strange noise in engine",
        "vehicle_id": state["vehicle_id"],
        "mechanic_id": state["mechanic_id"]
    }
    r = client.post("/api/v1/services/", json=req_payload, headers=client_headers)
    if r.status_code == 200:
        state["request_id"] = r.json()["id"]
        print("✅ Client created Service Request")
    else:
        print(f"❌ Create Request failed: {r.text}")
        return

    # 4. Mechanic Views Request
    r = client.get("/api/v1/services/received", headers=mech_headers)
    items = r.json()
    if any(i["id"] == state["request_id"] for i in items):
         print("✅ Mechanic sees incoming request")
    else:
         print("❌ Mechanic inbox missing request")

    # 5. Mechanic Updates Status (ACCEPTED)
    r = client.patch(f"/api/v1/services/{state['request_id']}/status", json={"status": "ACCEPTED"}, headers=mech_headers)
    if r.status_code == 200 and r.json()["status"] == "ACCEPTED":
        print("✅ Mechanic Accepted request")
    else:
        print(f"❌ Update Status failed: {r.text}")

    # 6. Client Checks Status
    r = client.get("/api/v1/services/sent", headers=client_headers)
    items = r.json()
    req = next((i for i in items if i["id"] == state["request_id"]), None)
    if req and req["status"] == "ACCEPTED":
        print("✅ Client sees ACCEPTED status")
    else:
        print(f"❌ Client status check failed: {req}")

if __name__ == "__main__":
    test_service_flow()
