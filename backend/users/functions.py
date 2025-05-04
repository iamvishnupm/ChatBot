from datetime import datetime, timedelta
from jose import JWTError, jwt 
from passlib.context import CryptContext

from sqlalchemy.orm import Session
from models.users import User 
from schemas.users import UserCreate 
from config import settings

from termcolor import colored

pass_context = CryptContext( schemes=["bcrypt"], deprecated="auto" )

def hash_password( password: str ) -> str:
    return pass_context.hash(password)

def verify_password( plain_password : str, hashed_password : str ) -> bool :
    return pass_context.verify( plain_password, hashed_password )

def create_access_token( data : dict, expiry_time : timedelta = None ):
    to_encode = data.copy()
    exp_time = datetime.now() + ( expiry_time or settings.TOKEN_EXP )
    to_encode.update({"exp" : exp_time})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM) 

def create_user( user : UserCreate, db : Session ):
    hashed_password = hash_password(user.password)
    db_user = User( username=user.username, email=user.email, password=hashed_password )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return db_user