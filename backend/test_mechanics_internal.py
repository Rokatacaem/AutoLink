import random
import string
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def random_string(length=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

def test_mechanic_flow():
    email = f"mech_{random_string()}@autolink.com"
    password = "secure_password_123"
    
    print(f"Testing with MECHANIC user: {email}")

    # 1. Register as Mechanic
    r = client.post("/api/v1/auth/register", json={
        "email": email, "password": password, "full_name": "Joe Mechanic", "role": "mechanic"
    })
    if r.status_code != 201:
        print(f"❌ Register failed: {r.status_code} {r.text}")
        return
    
    # Login
    login_res = client.post("/api/v1/auth/login", data={"username": email, "password": password})
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Auth Mechanic success")

    # 2. Create Profile
    profile_in = {
        "shop_name": "Joe's Garage",
        "address": "123 Main St",
        "phone": "555-0101",
        "specialties": "Brakes,Engine"
    }
    r = client.post("/api/v1/mechanics/me", json=profile_in, headers=headers)
    if r.status_code != 200:
        print(f"❌ Create Profile failed: {r.status_code} {r.text}")
        return
    data = r.json()
    if data["shop_name"] == "Joe's Garage":
        print("✅ Create Profile success")

    # 3. Get My Profile
    r = client.get("/api/v1/mechanics/me", headers=headers)
    if r.status_code == 200 and r.json()["shop_name"] == "Joe's Garage":
         print("✅ Get My Profile success")
    
    # 4. Search (as Client)
    client_email = f"client_{random_string()}@autolink.com"
    client.post("/api/v1/auth/register", json={
        "email": client_email, "password": password, "full_name": "Client User", "role": "client"
    })
    l_res = client.post("/api/v1/auth/login", data={"username": client_email, "password": password})
    c_token = l_res.json()["access_token"]
    c_headers = {"Authorization": f"Bearer {c_token}"}

    r = client.get("/api/v1/mechanics/", headers=c_headers)
    items = r.json()
    found = any(m["shop_name"] == "Joe's Garage" for m in items)
    if found:
        print("✅ Search Mechanics success (Client found Mechanic)")
    else:
        print(f"❌ Search failed: Joe's Garage not found in {len(items)} items")

if __name__ == "__main__":
    test_mechanic_flow()
