from typing import Generator
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from app.core.config import settings
from app.db.session import get_db
from app.models.user import User
from app.crud import user as crud_user
from app.schemas.user import TokenData

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login")

import logging
logger = logging.getLogger(__name__)

def get_current_user(
    db: Session = Depends(get_db), 
    token: str = Depends(oauth2_scheme)
) -> User:
    """Get current authenticated user from JWT token."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token, 
            settings.SECRET_KEY, 
            algorithms=[settings.ALGORITHM],
            options={"leeway": 120}  # 2 minutes leeway for clock skew
        )
        email: str = payload.get("sub")
        
        # Manual claim validation since python-jose doesn't support 'require' option
        if email is None:
            logger.warning("AUDIT[AUTH_FAIL]: Missing 'sub' claim in token")
            raise credentials_exception
        if "exp" not in payload:
             logger.warning("AUDIT[AUTH_FAIL]: Missing 'exp' claim in token")
             raise credentials_exception
        # if "iat" not in payload:
        #      logger.warning("AUDIT[AUTH_FAIL]: Missing 'iat' claim in token")
        #      raise credentials_exception
             
        token_data = TokenData(email=email)
        
        # Log successful decode for debug (remove int production if too noisy, but critical for diagnosis)
        # logger.debug(f"JWT decoded successfully. Sub: {email}")

    except jwt.ExpiredSignatureError:
        logger.warning(f"AUDIT[AUTH_FAIL]: Token expired. Token preview: {token[:10]}...")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except jwt.JWTError as e:
        logger.warning(f"AUDIT[AUTH_FAIL]: JWT validation error: {str(e)}")
        raise credentials_exception
    
    user = crud_user.get_user_by_email(db, email=token_data.email)
    if user is None:
        logger.warning(f"AUDIT[AUTH_FAIL]: User not found for email: {token_data.email}")
        raise credentials_exception
    
    if not user.is_active:
        logger.warning(f"AUDIT[AUTH_FAIL]: User inactive: {token_data.email}")
        raise HTTPException(status_code=400, detail="Inactive user")
        
    return user

def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """Ensure user is active."""
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user
