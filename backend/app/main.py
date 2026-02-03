from fastapi import FastAPI
from app.core.config import settings
from app.api.v1.api import api_router
from app.db.session import engine
from app.db.base import Base

# HOTFIX: Create tables on startup is removed. Use Alembic for migrations.
# Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Logging Configuration
import logging
from logging.handlers import RotatingFileHandler
import os
import sys

# Ensure logs are written to the backend directory
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
log_file_path = os.path.join(BASE_DIR, "backend_server.log")

handlers = [logging.StreamHandler(sys.stdout)]

# File logging removed for Vercel compatibility (Read-only filesystem)
# handlers = [logging.StreamHandler(sys.stdout)] is sufficient for Vercel logs

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=handlers
)

import hashlib

logger = logging.getLogger("uvicorn")
logger.info(f"SECRET_KEY_SHA256: {hashlib.sha256(settings.SECRET_KEY.encode()).hexdigest()}")

app.include_router(api_router, prefix=settings.API_V1_STR)

# CORS Configuration
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows all origins (for mobile/local testing)
    allow_credentials=True,
    allow_methods=["*"], # Allows all methods
    allow_headers=["*"], # Allows all headers
)

@app.get("/")
def root():
    return {"message": "Welcome to AutoLink API"}
