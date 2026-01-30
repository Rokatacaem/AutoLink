from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db.session import get_db
from app.core.config import settings
import os

router = APIRouter()

@router.get("/status")
def health_check(db: Session = Depends(get_db)):
    """
    Diagnostic endpoint to check DB connection and configuration.
    """
    status = {
        "app": "running",
        "env": {
            "POSTGRES_URL_SET": bool(os.getenv("POSTGRES_URL")),
            "DATABASE_URL_SET": bool(os.getenv("DATABASE_URL")),
            "DB_CONFIG_URL": settings.DATABASE_URL.split("://")[0] + "://***"  # Mask credentials
        },
        "database": "unknown"
    }
    
    try:
        # Try simple query
        db.execute(text("SELECT 1"))
        status["database"] = "connected"
    except Exception as e:
        status["database"] = f"error: {str(e)}"
        
    return status
