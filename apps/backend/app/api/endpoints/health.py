from fastapi import APIRouter

router = APIRouter(tags=["health"])


@router.get("/")
async def root():
    return {"message": "Welcome to Yashvi Media Studio API"}


@router.get("/ping")
async def ping():
    return {"status": "ok", "message": "pong"}


@router.get("/health")
async def health_check():
    return {"status": "healthy"}

