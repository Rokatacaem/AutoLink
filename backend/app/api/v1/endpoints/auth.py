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

from google.oauth2 import id_token
from google.auth.transport import requests
from app.schemas.user import SocialLoginRequest

@router.post("/social-login", response_model=Token)
def social_login(
    payload: SocialLoginRequest,
    db: Session = Depends(get_db)
) -> Any:
    """
    Social Login (Google/Apple).
    Verifies ID Token and returns JWT Access Token.
    """
    email = None
    name = None
    
    if payload.provider == "google":
        try:
            if payload.id_token:
                # Verify the ID token
                idinfo = id_token.verify_oauth2_token(
                    payload.id_token, 
                    requests.Request(), 
                    settings.GOOGLE_CLIENT_ID
                )
                email = idinfo['email']
                name = idinfo.get('name')
            elif payload.access_token:
                # Verify Access Token via Google API
                import requests as req
                resp = req.get(f"https://www.googleapis.com/oauth2/v3/tokeninfo?access_token={payload.access_token}")
                if resp.status_code != 200:
                    raise ValueError("Invalid Access Token")
                
                token_info = resp.json()
                email = token_info.get('email')
                # If email is not in tokeninfo, we might need to fetch userinfo
                if not email:
                     user_resp = req.get(
                         "https://www.googleapis.com/oauth2/v3/userinfo", 
                         headers={"Authorization": f"Bearer {payload.access_token}"}
                     )
                     if user_resp.status_code == 200:
                         user_info = user_resp.json()
                         email = user_info.get('email')
                         name = user_info.get('name')
                
            else:
                raise ValueError("Either id_token or access_token must be provided")

        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid Google Token: {str(e)}",
            )
    else:
        raise HTTPException(status_code=400, detail="Provider not supported yet")

    if not email:
        raise HTTPException(status_code=400, detail="Email not found in token")

    # JIT Provisioning
    user = crud_user.get_user_by_email(db, email=email)
    if not user:
        # Create new user
        user_in = UserCreate(
            email=email,
            full_name=name or email.split("@")[0],
            password=None # Social user has no password
        )
        user = crud_user.create_user(db, user_in=user_in)
    
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")

    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        subject=user.email, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
