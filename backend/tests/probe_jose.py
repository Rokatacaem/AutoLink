
from jose import jwt
print(f"Help for jwt.decode: {help(jwt.decode)}")
try:
    token = jwt.encode({"a":1}, "secret", algorithm="HS256")
    msg = jwt.decode(token, "secret", algorithms=["HS256"], options={"require": ["a"]})
    print("Decode with require succeeded")
except Exception as e:
    print(f"Decode with require failed: {e}")
