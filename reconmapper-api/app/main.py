from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from . import models
from .database import engine
from .routers import scan
from .scheduler import start_scheduler

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# Enable CORS for frontend requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins including chhanun.site
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(scan.router)


@app.on_event("startup")
def startup_event():
    start_scheduler()


@app.get("/")
def root():
    return {"status": "ReconMapper API running"}


