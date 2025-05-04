from fastapi import (
    APIRouter,
    Depends,
    WebSocket,
    WebSocketDisconnect,
    Request,
)
from fastapi.responses import JSONResponse

from sqlalchemy.orm import Session
from typing import Dict
from datetime import datetime

from config.db import get_db
from models.messages import Messages
from schemas.messages import (
    SendMessageSchema,
    CurrentUserMessageSchema,
    ChatUserMessageSchema,
)

from dependencies.auth import verify_token
from termcolor import colored

# ============================================================


class ConnectionManager:
    def __init__(self):
        self._active_connections: Dict[str, WebSocket] = {}

    async def connect(self, username: str, websocket: WebSocket) -> bool:
        await websocket.accept()
        self._active_connections[username] = websocket
        return True

    def disconnect(self, username: str) -> bool:
        self._active_connections.pop(username, None)
        return True

    async def send_message(self, receiver: str, message: dict) -> bool:
        print(colored(f"Sending to {receiver=}{message=}", "green"))
        if receiver in self._active_connections:
            await self._active_connections[receiver].send_json(message)
            return True
        return False


# ============================================================


class MessageService:
    def __init__(self, db: Session):
        self.db = db

    def create_message(self, sender: str, receiver: str, content: str) -> Messages:
        message = Messages(
            sender=sender,
            receiver=receiver,
            message=content,
            timestamp=datetime.utcnow(),
        )
        self.db.add(message)
        self.db.commit()
        self.db.refresh(message)
        return message

    def get_message_history(self, user1: str, user2: str, username: str):
        messages = (
            self.db.query(Messages)
            .filter(
                ((Messages.sender == user1) & (Messages.receiver == user2))
                | ((Messages.sender == user2) & (Messages.receiver == user1))
            )
            .order_by(Messages.timestamp)
            .all()
        )

        history = []
        for msg in messages:
            if msg.sender == username:
                history.append(
                    {"message": msg.message, "timestamp": msg.timestamp.isoformat()}
                )
            else:
                history.append(
                    {"response": msg.message, "timestamp": msg.timestamp.isoformat()}
                )

        return history  # ✅ Now returns a list of dicts


# ============================================================

router = APIRouter()
connection_manager = ConnectionManager()

# ============================================================


@router.websocket("/ws/{token}")
async def websocket_endpoint(
    websocket: WebSocket, token: str, db: Session = Depends(get_db)
):
    username = verify_token(token)
    print(colored(f"\n\n{username=}\n\n", "green"))

    if not username:
        await websocket.close(code=1008)
        return

    message_service = MessageService(db)
    await connection_manager.connect(username, websocket)

    try:
        while True:
            data = await websocket.receive_json()
            print(colored(f"\n\n{data=}\n\n", "green"))
            sender, receiver, content = (
                data["sender"],
                data["receiver"],
                data["message"],
            )

            message = message_service.create_message(
                sender=sender, receiver=receiver, content=content
            )

            response_data = {
                "response": message.message,
                "timestamp": message.timestamp.isoformat(),
            }
            await connection_manager.send_message(receiver, response_data)

    except WebSocketDisconnect:
        connection_manager.disconnect(username)


# ============================================================


@router.get("/messages/{user1}/{user2}")
def get_messages(
    user1: str, user2: str, request: Request, db: Session = Depends(get_db)
):
    username = verify_token(request)

    if not username or username not in [user1, user2]:
        print(f"Unauthorized access attempt by {username}")  # Debugging log
        return JSONResponse(content={"error": "Unauthorized"}, status_code=403)

    message_service = MessageService(db)

    try:
        messages = message_service.get_message_history(user1, user2, username)
        return JSONResponse(content=messages, status_code=200)
    except Exception as e:
        print(f"Error fetching chat history: {e}")  # Debugging log
        return JSONResponse(content={"error": "Internal server error"}, status_code=500)


# ============================================================


@router.post("/messages/send")
async def send_message(
    message_data: SendMessageSchema, request: Request, db: Session = Depends(get_db)
):
    username = verify_token(request)

    if not username:
        return JSONResponse(content={"error": "Unauthorized"}, status_code=403)

    message_service = MessageService(db)

    try:
        message = message_service.create_message(
            sender=username,
            receiver=message_data.receiver,
            content=message_data.message,
        )

        response_data = {
            "response": message.message,
            "timestamp": message.timestamp.isoformat(),
        }
        await connection_manager.send_message(message_data.receiver, response_data)

        return JSONResponse(content=response_data, status_code=200)

    except Exception as e:
        print(f"Error sending message: {e}")
        return JSONResponse(content={"error": "Internal server error"}, status_code=500)


# ============================================================
