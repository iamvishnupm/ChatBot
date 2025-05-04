from sqlalchemy import Column, Integer, String, Text, DateTime, func
from config.db import Base

class Messages(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    sender = Column(String(255), index=True)
    receiver = Column(String(255), index=True)
    message = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=func.now()) # func.now() used to get current datetime.


