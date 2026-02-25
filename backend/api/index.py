"""
Vercel Serverless Entry Point.
Mangum wraps the FastAPI ASGI app so Vercel can invoke it as a standard
serverless function handler.
"""
import sys
import os

# Add the backend root to the path so `app` package resolves correctly
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from mangum import Mangum
from app.main import app

handler = Mangum(app, lifespan="off")
