from config.db import Base
from sqlalchemy import Column, Integer, ForeignKey, JSON
from sqlalchemy.orm import relationship


class Contacts(Base):
    __tablename__ = "contacts"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    contacts = Column(JSON, default={})

    user = relationship("User", back_populates="contacts")

