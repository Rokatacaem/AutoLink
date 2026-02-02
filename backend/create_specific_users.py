
import requests
import time

BASE_URL = "https://auto-link-steel.vercel.app/api/v1"

USERS = [
    {"email": "cliente10@autolink.cl", "password": "password123", "name": "Cliente 10", "role": "client"},
    {"email": "cliente11@autolink.cl", "password": "password123", "name": "Cliente 11", "role": "client"},
    {"email": "mecanico10@autolink.cl", "password": "password123", "name": "Mecanico 10", "role": "mechanic", "specialty": "Frenos"},
    {"email": "mecanico11@autolink.cl", "password": "password123", "name": "Mecanico 11", "role": "mechanic", "specialty": "Motor"},
]

def create_user(user_data):
    email = user_data["email"]
    password = user_data["password"]
    role = user_data["role"]
    
    print(f"Processing {email}...")

    # 1. Register
    payload = {
        "email": email,
        "password": password,
        "full_name": user_data["name"],
        "role": role
    }
    
    # We ignore 400 if user likely exists, but try login anyway
    r = requests.post(f"{BASE_URL}/auth/register", json=payload)
    if r.status_code == 201:
        print(f"  ✅ Registered")
    elif r.status_code == 400 and "already exists" in r.text:
         print(f"  ℹ️ User exists")
    else:
        print(f"  ❌ Registration Failed: {r.text}")
        return

    # 2. Login (to get token for further setup)
    r = requests.post(f"{BASE_URL}/auth/login", data={"username": email, "password": password})
    if r.status_code != 200:
        print(f"  ❌ Login Failed: {r.text}")
        return
    
    token = r.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 3. If Mechanic, Create Profile
    if role == "mechanic":
        # Check if profile exists
        r = requests.get(f"{BASE_URL}/mechanics/me", headers=headers)
        if r.status_code == 404:
            # Create Profile
            profile_data = {
                "specialty": user_data.get("specialty", "General"),
                "address": "Calle Ficticia 123, Santiago",
                "phone": "+56912345678"
            }
            r = requests.post(f"{BASE_URL}/mechanics/me", json=profile_data, headers=headers)
            if r.status_code == 200:
                print(f"  ✅ Mechanic Profile Created")
            else:
                print(f"  ❌ Profile Creation Failed: {r.text}")
        else:
             print(f"  ℹ️ Mechanic Profile exists")

if __name__ == "__main__":
    print(">>> GENERATING USERS <<<")
    for u in USERS:
        create_user(u)
        time.sleep(1) # Polite delay
    print("Done.")
