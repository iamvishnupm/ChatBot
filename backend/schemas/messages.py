from pydantic import BaseModel
from datetime import datetime
from typing import List, Union


class GetMessageSchema(BaseModel):
    id: int
    sender: str
    receiver: str
    message: str
    timestamp: datetime

    class Config:
        from_attributes = True


class SendMessageSchema(BaseModel):
    receiver: str
    message: str


class CurrentUserMessageSchema(BaseModel):
    message: str
    timestamp: str


class ChatUserMessageSchema(BaseModel):
    response: str
    timestamp: str


ChatHistorySchema = List[Union[CurrentUserMessageSchema, ChatUserMessageSchema]]
