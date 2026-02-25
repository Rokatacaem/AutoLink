"""
Vercel Serverless Entry Point.
Vercel supports ASGI natively — we expose the FastAPI app directly.
Mangum is NOT used here (it is for AWS Lambda, not Vercel).
"""
import sys
import os

# Add the backend root to the path so `app` package resolves correctly
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.main import app
