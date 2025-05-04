from config.db import Base
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"

    id = Column( Integer, primary_key=True, index=True, autoincrement=True )
    username = Column( String(50), unique=True, nullable=False )
    email =  Column( String(255),  unique=True, nullable=False )
    password = Column( String(255), unique=False, nullable=False )

    contacts = relationship(
        "Contacts", back_populates="user",
        uselist=False, 
        cascade="all, delete-orphan"
    )

