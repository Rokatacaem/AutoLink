
import random
import string
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def random_string(length=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

def test_auth_flow():
    email = f"{random_string()}@example.com"
    password = "testpassword123"
    
    print(f"Testing with user: {email}")

    # 1. Register
    reg_payload = {
        "email": email,
        "password": password,
        "full_name": "Test User",
        "role": "client"
    }
    r = client.post("/api/v1/auth/register", json=reg_payload)
    if r.status_code != 201:
        print(f"Register failed: {r.status_code} {r.text}")
        return
    print("✅ Register success")

    # 2. Login
    login_payload = {
        "username": email,
        "password": password
    }
    r = client.post("/api/v1/auth/login", data=login_payload)
    if r.status_code != 200:
        print(f"Login failed: {r.status_code} {r.text}")
        return
    data = r.json()
    token = data["access_token"]
    print("✅ Login success")

    # 3. Access Protected /users/me
    headers = {"Authorization": f"Bearer {token}"}
    r = client.get("/api/v1/users/me", headers=headers)
    if r.status_code != 200:
        print(f"Access /users/me failed: {r.status_code} {r.text}")
        return
    
    user_data = r.json()
    if user_data["email"] == email:
        print("✅ Access /users/me success (User verified)")
    else:
        print(f"❌ User mismatch: {user_data['email']} != {email}")

if __name__ == "__main__":
    test_auth_flow()
