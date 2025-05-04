from fastapi import FastAPI

from routes import auth, song

from database import engine

from models.base import Base

app = FastAPI()

app.include_router(router=auth.router,prefix='/auth')
app.include_router(router=song.router,prefix='/song')


Base.metadata.create_all(engine)