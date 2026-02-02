import requests
import json

URL = "https://auto-link-steel.vercel.app/docs" # Checking docs is better as it loads OpenAPI

print(f"Checking Root/Docs at: {URL}")

try:
    response = requests.get(URL, timeout=10)
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        print("✅ APP IS ALIVE (Docs loaded)")
    else:
        print(f"❌ APP IS DEAD: {response.status_code} - {response.text}")

except Exception as e:
    print(f"💥 CONNECTION FAILED: {e}")
