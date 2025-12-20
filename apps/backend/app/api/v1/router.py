from fastapi import APIRouter
from app.api.v1.endpoints import projects, health, episodes, stories

api_router = APIRouter()

# Health endpoints at root level
api_router.include_router(health.router)

# API endpoints
api_router.include_router(projects.router)
api_router.include_router(episodes.router, prefix="/episodes", tags=["episodes"])
api_router.include_router(stories.router, prefix="/stories", tags=["stories"])

