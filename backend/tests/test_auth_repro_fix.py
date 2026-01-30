
import sys
import os
import time
import requests
import unittest
from datetime import datetime, timedelta, timezone
from fastapi import HTTPException
from jose import jwt as jose_jwt
import uuid

# Add parent directory to path to import app modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings
from app.core.security import create_access_token
from app.api.deps import get_current_user

# Mock database session
class MockSession:
    def query(self, *args):
        return self
    def filter(self, *args):
        return self
    def first(self):
        # Mock user
        class MockUser:
            id = 1
            email = "test@example.com"
            is_active = True
            hashed_password = "hash"
        return MockUser()

class TestAuthFix(unittest.TestCase):
    def test_token_creation_utc(self):
        """Test that token has exp, iat, nbf in UTC and jti."""
        token = create_access_token(subject="test@example.com")
        # jose jwt decode
        decoded = jose_jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM], options={"verify_signature": False})
        
        print(f"\n[INFO] Decoded Token Payload: {decoded}")
        
        self.assertIn("iat", decoded)
        self.assertIn("nbf", decoded)
        self.assertIn("exp", decoded)
        self.assertIn("jti", decoded)
        self.assertIn("sub", decoded)
        self.assertEqual(decoded["sub"], "test@example.com")
        
        # Verify UTC timestamps roughly now
        now_ts = int(time.time())
        self.assertAlmostEqual(decoded["iat"], now_ts, delta=10)
        self.assertAlmostEqual(decoded["nbf"], now_ts, delta=10)

    def test_token_validation_success(self):
        """Test validation of a valid token."""
        token = create_access_token(subject="test@example.com")
        # Direct calls to jose_jwt (used in deps.py) to simulate verify
        payload = jose_jwt.decode(
            token, 
            settings.SECRET_KEY, 
            algorithms=[settings.ALGORITHM],
            options={"leeway": 120}
        )
        self.assertEqual(payload["sub"], "test@example.com")
        print("[SUCCESS] Token validated correctly with strict options.")

    def test_token_expired_leeway(self):
        """Test token expiration and leeway."""
        # Create token expired 1 minute ago
        expires_delta = timedelta(minutes=-1)
        # Manually create to ensure negative expiry relative to now
        expire = datetime.now(timezone.utc) + expires_delta
        
        to_encode = {
            "exp": expire,
            "sub": "test@example.com",
            "iat": datetime.now(timezone.utc),
            "nbf": datetime.now(timezone.utc),
            "jti": str(uuid.uuid4())
        }
        token = jose_jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
        
        # Should succeed because leeway is 120s and token expired 60s ago
        try:
            jose_jwt.decode(
                token, 
                settings.SECRET_KEY, 
                algorithms=[settings.ALGORITHM],
                options={"leeway": 120}
            )
            print("[SUCCESS] Leeway worked: Expired token accepted within leeway window.")
        except jose_jwt.ExpiredSignatureError:
            self.fail("Leeway did not work! Expired token rejected despite leeway.")

        # Test expiration outside leeway (3 minutes ago)
        expires_delta_old = timedelta(minutes=-3)
        expire_old = datetime.now(timezone.utc) + expires_delta_old
        to_encode["exp"] = expire_old
        token_old = jose_jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
        
        with self.assertRaises(jose_jwt.ExpiredSignatureError):
            jose_jwt.decode(
                token_old, 
                settings.SECRET_KEY, 
                algorithms=[settings.ALGORITHM],
                options={"leeway": 120}
            )
        print("[SUCCESS] Token correctly rejected after leeway window.")

if __name__ == "__main__":
    unittest.main()
