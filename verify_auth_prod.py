import requests
import json
import random
import string

BASE_URL = "https://auto-link-steel.vercel.app/api/v1"

def print_banner(text):
    print(f"\n{'='*50}")
    print(f" {text}")
    print(f"{'='*50}")

def generate_random_email():
    random_str = ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))
    return f"test_user_{random_str}@example.com"

def test_login(email, password, description):
    print(f"\n>>> TESTING LOGIN: {description}")
    print(f"Credentials: {email} / {password}")
    
    url = f"{BASE_URL}/auth/login"
    payload = {
        "username": email,
        "password": password
    }
    
    try:
        response = requests.post(url, data=payload) # Form-encoded by default in requests for 'data'
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ LOGIN SUCCESS")
            print(f"Token: {response.json().get('access_token')[:20]}...")
            return True
        else:
            print(f"❌ LOGIN FAILED: {response.text}")
            return False
            
    except Exception as e:
        print(f"💥 EXCEPTION: {e}")
        return False

def test_register(email, password, name, role, description):
    print(f"\n>>> TESTING REGISTER: {description}")
    print(f"Data: {email} | {name} | {role}")
    
    url = f"{BASE_URL}/auth/register"
    payload = {
        "email": email,
        "password": password,
        "full_name": name,
        "role": role
    }
    headers = {"Content-Type": "application/json"}
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 201:
            print("✅ REGISTER SUCCESS")
            print(f"Response: {json.dumps(response.json(), indent=2)}")
            return True
        else:
            print(f"❌ REGISTER FAILED: {response.text}")
            return False
            
    except Exception as e:
        print(f"💥 EXCEPTION: {e}")
        return False

def run_suite():
    print_banner("AUTOLINK PRODUCTION AUTH VERIFICATION")
    
    # 1. Test Existing Account (Assuming client1@test.com exists from screenshots)
    test_login("client1@test.com", "123456", "Existing User (from previous screenshots)")
    
    # 2. Test New Account Creation
    new_email = generate_random_email()
    new_pass = "Test@1234"
    if test_register(new_email, new_pass, "Automated Tester", "client", "New Random User"):
        # 3. Login with New Account
        test_login(new_email, new_pass, "Login with Newly Created User")
        
        # 4. Try Registering Same User Again (Should Fail)
        test_register(new_email, new_pass, "Automated Tester", "client", "Duplicate User Registration")
        
    # 5. Test Invalid Password
    test_login(new_email, "WrongPass123", "Invalid Password Attempt")

if __name__ == "__main__":
    run_suite()
