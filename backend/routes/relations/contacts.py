from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse

from config.db import get_db 
from models.contacts import Contacts
from models.users import User 
from schemas.contacts import ContactSchema
from dependencies.auth import get_current_user

import json

router = APIRouter(prefix="/contacts", tags=["contacts"])

@router.get("/")
def get_contacts(
        user: User = Depends(get_current_user),
        db: Session = Depends(get_db) 
    ):

    user_contacts = db.query(Contacts).filter(
        Contacts.user_id == user.id
    ).first()

    if not user_contacts:
        return JSONResponse(
            status_code = 200,
            content = { 'contacts' : {} }
        )

    return JSONResponse(
        status_code = 200,
        content = {
            'contacts' : user_contacts.contacts
        }
    )
    

@router.post("/add")
def add_contact(
        contact_data : ContactSchema,
        current_user: User = Depends(get_current_user),
        db: Session = Depends(get_db)
    ):

    user_entry = db.query(User).filter(User.username == contact_data.username).first()

    if not user_entry:
        return JSONResponse(
            status_code = 404,
            content = {"message":"User Not Found"}
        )
    
    # contacts of current_user
    user_contacts = db.query(Contacts).filter(Contacts.user_id == current_user.id).first()

    if not user_contacts:
        user_contacts = Contacts( user_id = current_user.id, contacts={} )
        db.add(user_contacts)
        db.commit()
        db.refresh(user_contacts)


    if contact_data.username in user_contacts.contacts:
        return JSONResponse(
            status_code=400,
            content={"message":"Contact Already Exist"}
        ) 
    
    user_contacts.contacts[contact_data.username] = contact_data.name

    flag_modified(user_contacts, "contacts")

    db.commit()
    db.refresh(user_contacts)

    return JSONResponse(
        status_code=200,
        content={
            "message" : "Contact Added Successfully",
            "contacts" : user_contacts.contacts
        }
    )