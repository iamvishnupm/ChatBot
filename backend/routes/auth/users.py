from sqlalchemy.orm import Session 
from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse 
from datetime import datetime, timedelta
from termcolor import colored

from  models.users import User
from schemas.users import UserCreate, UserLogin

from config.db import get_db
from users.functions import create_user, verify_password, create_access_token

router = APIRouter( prefix="/users", tags=["users"])

@router.post("/login")
def login_user( user : UserLogin, db : Session = Depends(get_db) ):

    db_user = db.query(User).filter( User.username == user.username ).first()

    if not db_user or not verify_password( user.password, db_user.password ):
        return JSONResponse( status_code=400, content="Invalid Credentials!")
    
    print(colored("\n\nPassword is correct\n\n", "yellow"))

    access_token = create_access_token(
        data = {"sub" : db_user.username},
        expiry_time = timedelta(minutes=30)
    )
   
    print(colored("\n\nAccess Token Created\n\n", "yellow"))
    
    return  { "access_token" : access_token, "token_type" : "bearer" } 
            

@router.post('/register')
def register_user( user: UserCreate, db: Session = Depends(get_db) ):

    print(colored("\n\nBeginning\n\n", "yellow"))
    print(colored(f"\n\n{db=}\n\n", "yellow"))
    print(colored(f"\n\n{user=}\n\n", "yellow"))

    existing_user = (
        db.query(User)
        .filter( (User.username == user.username) | (User.email == user.email) )
        .first()
    )

    print(colored("\n\n What Existing User\n\n", "yellow"))

    if existing_user:
        return JSONResponse(status_code=400, content="User already exist!")

    print(colored("\n\nNo Existing User\n\n", "yellow"))
    
    db_user = create_user( user, db )

    return "Register success"


