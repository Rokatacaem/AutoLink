import random
import string
from datetime import datetime
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def random_string(length=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

def test_vehicle_flow():
    email = f"{random_string()}@example.com"
    password = "testpassword123"
    
    print(f"Testing with user: {email}")

    # 1. Register & Login
    client.post("/api/v1/auth/register", json={
        "email": email, "password": password, "full_name": "Test User", "role": "client"
    })
    login_res = client.post("/api/v1/auth/login", data={"username": email, "password": password})
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Auth success")

    # 2. Create Vehicle (Valid)
    vehicle_in = {
        "vin": " 1hg-cv16-52-ja000001 ", # messy input
        "brand": "Honda",
        "model": "Civic",
        "year": 2020,
        "nickname": "Daily Driver"
    }
    r = client.post("/api/v1/vehicles/", json=vehicle_in, headers=headers)
    if r.status_code != 200:
        print(f"❌ Create Vehicle failed: {r.status_code} {r.text}")
        return
    v_data = r.json()
    if v_data["vin"] == "1HGCV1652JA000001":
        print("✅ Create Vehicle success (VIN cleaned)")
    else:
        print(f"❌ VIN Cleaning failed: {v_data['vin']}")
    
    vehicle_id = v_data["id"]

    # 3. List Vehicles
    r = client.get("/api/v1/vehicles/", headers=headers)
    items = r.json()
    if len(items) >= 1 and items[0]["id"] == vehicle_id:
        print("✅ List Vehicles success")
    else:
        print(f"❌ List Vehicles failed: {len(items)} items found")

    # 4. Create Vehicle (Future Year - Fail)
    future_year = datetime.now().year + 2
    r = client.post("/api/v1/vehicles/", json={
        "vin": "1HGCV1652JA000002", "brand": "X", "model": "Y", "year": future_year
    }, headers=headers)
    if r.status_code == 422:
        print("✅ Validation Future Year success (Rejected)")
    else:
        print(f"❌ Validation Future Year failed. Status: {r.status_code}")

    # 5. Get Detail
    r = client.get(f"/api/v1/vehicles/{vehicle_id}", headers=headers)
    if r.status_code == 200 and r.json()["id"] == vehicle_id:
        print("✅ Get Detail success")
    else:
        print(f"❌ Get Detail failed")

    # 6. Delete
    r = client.delete(f"/api/v1/vehicles/{vehicle_id}", headers=headers)
    if r.status_code == 200:
        print("✅ Delete success")
    else:
        print(f"❌ Delete failed: {r.status_code}")

    # 7. Get Detail (404)
    r = client.get(f"/api/v1/vehicles/{vehicle_id}", headers=headers)
    if r.status_code == 404:
        print("✅ Verify Deletion success (404 returned)")
    else:
        print(f"❌ Verify Deletion failed. Status: {r.status_code}")

if __name__ == "__main__":
    test_vehicle_flow()
