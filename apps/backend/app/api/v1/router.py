from fastapi import APIRouter
from app.api.v1.endpoints import projects, health

api_router = APIRouter()

# Health endpoints at root level
api_router.include_router(health.router)

# API endpoints
api_router.include_router(projects.router)

