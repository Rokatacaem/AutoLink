import requests
import json
import random
import string
import time

BASE_URL = "http://localhost:8000/api/v1"

def print_banner(text):
    print(f"\n{'='*50}")
    print(f" {text}")
    print(f"{'='*50}")

def generate_random_email():
    random_str = ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))
    return f"local_test_{random_str}@example.com"

def test_login(email, password, description):
    print(f"\n>>> TESTING LOGIN: {description}")
    print(f"Credentials: {email} / {password}")
    
    url = f"{BASE_URL}/auth/login"
    payload = {
        "username": email,
        "password": password
    }
    
    try:
        response = requests.post(url, data=payload)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ LOGIN SUCCESS")
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
            return True
        else:
            print(f"❌ REGISTER FAILED: {response.text}")
            return False
            
    except Exception as e:
        print(f"💥 EXCEPTION: {e}")
        return False

def run_suite():
    print_banner("AUTOLINK LOCAL AUTH VERIFICATION & LOG GENERATION")
    
    # Wait for server to definitely be up
    print("Waiting for server to be ready...")
    time.sleep(2)

    # 1. Register a new random user
    new_email = generate_random_email()
    new_pass = "TestLocal@123"
    
    if test_register(new_email, new_pass, "Local Tester", "client", "New Random User"):
        # 2. Login with that user
        test_login(new_email, new_pass, "Login with Newly Created User")
        
        # 3. Fail Login (Wrong Password)
        test_login(new_email, "WrongPass", "Invalid Password Attempt")
        
    # 4. Fail Register (Duplicate) - run again with same email
    test_register(new_email, new_pass, "Local Tester", "client", "Duplicate User Registration")

if __name__ == "__main__":
    run_suite()
