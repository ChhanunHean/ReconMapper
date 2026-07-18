from fastapi import FastAPI
from . import models
from .database import engine
from .routers import scan

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(scan.router)


@app.get("/")
def root():
    return {"status": "ReconMapper API running"}
