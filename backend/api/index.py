"""
Vercel Serverless Entry Point.
This file re-exports the FastAPI ASGI app so Vercel can discover it
inside the required `api/` directory.
"""
import sys
import os

# Ensure the backend root is on the path so `app` package resolves correctly
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.main import app  # noqa: F401  — exposed as ASGI handler for Vercel
