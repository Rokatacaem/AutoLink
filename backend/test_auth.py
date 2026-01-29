"""
Test script for Auth endpoints.
Usage: uvicorn app.main:app --reload
Then run this script in another terminal: python test_auth.py
"""
import requests

BASE_URL = "http://localhost:8000/api/v1"

def test_register():
    """Test user registration."""
    payload = {
        "email": "mechanic@autolink.com",
        "password": "secure_password_123",
        "full_name": "Juan Pérez",
        "role": "mechanic",
        "preferred_locale": "es_CL"
    }
    response = requests.post(f"{BASE_URL}/auth/register", json=payload)
    print(f"Register Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    return response.json()

def test_login(email: str, password: str):
    """Test user login."""
    payload = {
        "username": email,  # OAuth2 uses 'username' field
        "password": password
    }
    response = requests.post(f"{BASE_URL}/auth/login", data=payload)
    print(f"Login Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    return response.json()

if __name__ == "__main__":
    print("=== Testing AutoLink Authentication ===\n")
    
    # Test registration
    print("1. Testing Registration...")
    user = test_register()
    
    # Test login
    print("2. Testing Login...")
    token_response = test_login("mechanic@autolink.com", "secure_password_123")
    
    print("✅ All tests completed!")
    print(f"Access Token: {token_response.get('access_token', 'N/A')[:50]}...")
