from datetime import timedelta
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.core.config import settings
from app.core.security import create_access_token
from app.db.session import get_db
from app.crud import user as crud_user
from app.schemas.user import User, UserCreate, Token

router = APIRouter()

import logging
logger = logging.getLogger(__name__)

@router.post("/register", response_model=User, status_code=status.HTTP_201_CREATED)
def register(
    *,
    db: Session = Depends(get_db),
    user_in: UserCreate,
) -> Any:
    """
    Register new user.
    """
    logger.info(f"AUDIT[REGISTER_ATTEMPT]: Email={user_in.email}, Name={user_in.full_name}, Role={user_in.role}")
    
    try:
        user = crud_user.get_user_by_email(db, email=user_in.email)
        if user:
            logger.warning(f"AUDIT[REGISTER_FAIL]: Email={user_in.email} - User already exists")
            raise HTTPException(
                status_code=400,
                detail="A user with this email already exists.",
            )
        user = crud_user.create_user(db, user_in=user_in)
        logger.info(f"AUDIT[REGISTER_SUCCESS]: ID={user.id}, Email={user.email}")
        return user
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"AUDIT[register_CRASH]: {str(e)}")
        # TEMPORARY DEBUG: Return error in 500 response
        raise HTTPException(status_code=500, detail=f"Server Error Debug: {str(e)}")

@router.post("/login", response_model=Token)
def login(
    db: Session = Depends(get_db), 
    form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """
    OAuth2 compatible token login, get an access token for future requests.
    """
    logger.info(f"AUDIT[LOGIN_ATTEMPT]: Email={form_data.username}")
    user = crud_user.authenticate_user(
        db, email=form_data.username, password=form_data.password
    )
    if not user:
        logger.warning(f"AUDIT[LOGIN_FAIL]: Email={form_data.username} - Invalid Credentials")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    elif not user.is_active:
        logger.warning(f"AUDIT[LOGIN_FAIL]: Email={form_data.username} - Inactive User")
        raise HTTPException(status_code=400, detail="Inactive user")
    
    logger.info(f"AUDIT[LOGIN_SUCCESS]: ID={user.id}, Email={user.email}")
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        subject=user.email, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
