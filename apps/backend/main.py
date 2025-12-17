from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Yashvi Media Studio API",
    description="Backend API for Yashvi Media Studio",
    version="1.0.0"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"message": "Welcome to Yashvi Media Studio API"}


@app.get("/ping")
async def ping():
    return {"status": "ok", "message": "pong"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}

