import init 

init.setup_project_root()

# ==================================


from config.db import Base, engine
from fastapi import FastAPI
from routes.auth import users
from routes.relations import contacts
from routes.messaging import messages

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(users.router)
app.include_router(contacts.router)
app.include_router(messages.router)

@app.get('/')
def root():
    return "Root Page"
