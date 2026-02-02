import requests
import time
import json

URL = "https://auto-link-steel.vercel.app/api/v1/health/status"

print(f"Checking Health Status at: {URL}")

try:
    # Retry a few times as deployment might take a moment
    for i in range(5):
        try:
            response = requests.get(URL, timeout=10)
            if response.status_code == 200:
                print("\n✅ HEALTH CHECK SUCCESS!")
                print(json.dumps(response.json(), indent=2))
                break
            else:
                print(f"Attempt {i+1}: Status {response.status_code} - {response.text}")
        except Exception as e:
            print(f"Attempt {i+1}: Failed - {e}")
        
        time.sleep(2)
        
except Exception as e:
    print(f"\n❌ FATAL ERROR: {e}")
