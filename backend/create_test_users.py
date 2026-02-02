
import requests
import random
import string

BASE_URL = "https://auto-link-steel.vercel.app/api/v1"

def generate_random_string(length=6):
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))

def create_user(role, name_prefix):
    suffix = generate_random_string()
    email = f"test_{role}_{suffix}@autolink.com"
    password = "TestUser@1234"
    name = f"{name_prefix} {suffix.upper()}"
    
    payload = {
        "email": email,
        "password": password,
        "full_name": name,
        "role": role
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/register", json=payload)
        if response.status_code == 201:
            print(f"[SUCCESS] Created: {email} | {password} | {role}")
            return email, password
        else:
            print(f"[FAIL] Could not create {email}: {response.text}")
            return None
    except Exception as e:
        print(f"[ERROR] {e}")
        return None

if __name__ == "__main__":
    print(">>> CREATING TEST USERS for AutoLink <<<")
    create_user("client", "Vehicle Owner")
    create_user("mechanic", "Mechanic Partner")
    create_user("client", "Second Owner")
