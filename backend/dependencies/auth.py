from fastapi import Depends, Request
from fastapi.responses import JSONResponse 

from jose import jwt, JWTError
from sqlalchemy.orm import Session

from config import settings
from config.db import get_db
from models.users import User

from typing import Optional, Union


def verify_token(request_or_token: Union[Request, str]) -> Optional[str]:
    """Returns username if valid, None if invalid"""
    if isinstance(request_or_token, str):  # Direct token string
        token = request_or_token
    else:
        auth_header = request_or_token.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return None  
        token = auth_header.split(" ")[1]

    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload.get("sub")
    except JWTError:
        return None  


def get_current_user(request: Request, db: Session = Depends(get_db)):
    """Fetches the current user from the database if token is valid"""
    username = verify_token(request)
    if not username:
        return JSONResponse(
            status_code=401, 
            content={"message": "Invalid or Expired Token"}
        )
    
    db_user = db.query(User).filter(User.username == username).first()
    if not db_user:
        return JSONResponse(
            status_code=401,
            content={"message": "Invalid token data"}
        )
    
    return db_user
