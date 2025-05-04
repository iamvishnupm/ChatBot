from pydantic import BaseModel
from typing import Dict

class ContactsTableEntry(BaseModel):
    user_id : int
    contacts : Dict[str, str] # { "username" : "saved_name" }

class ContactSchema(BaseModel):
    username : str
    name : str

