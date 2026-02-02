import requests
import json
import sys

# BASE_URL = "http://localhost:8000/api/v1" 
BASE_URL = "https://auto-link-steel.vercel.app/api/v1"

def login(email, password):
    url = f"{BASE_URL}/auth/login"
    payload = {
        "username": email,
        "password": password
    }
    
    print(f"Attempting login to {url} with {email}...")
    try:
        response = requests.post(url, data=payload) # OAuth2 form data
        
        print(f"Status Code: {response.status_code}")
        print("Response Headers:")
        for k, v in response.headers.items():
            print(f"  {k}: {v}")
            
        print("\nResponse Body:")
        try:
            print(json.dumps(response.json(), indent=2))
        except:
            print(response.text)
            
        if response.status_code == 500:
            print("\n❌ CRITICAL: Received 500 Internal Server Error")
        elif response.status_code == 200:
            print("\n✅ SUCCESS: Login working")
        else:
            print(f"\n⚠️  Received unexpected status: {response.status_code}")

    except Exception as e:
        print(f"EXCEPTION: {e}")

if __name__ == "__main__":
    email = "test_client_mjmsbx@autolink.com"
    password = "TestUser@123"
    
    if len(sys.argv) > 2:
        email = sys.argv[1]
        password = sys.argv[2]
        
    login(email, password)
