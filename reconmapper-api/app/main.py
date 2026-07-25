from fastapi import FastAPI
from . import models
from .database import engine
from .routers import scan
from .scheduler import start_scheduler

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(scan.router)


@app.on_event("startup")
def startup_event():
    start_scheduler()


@app.get("/")
def root():
    return {"status": "ReconMapper API running"}

