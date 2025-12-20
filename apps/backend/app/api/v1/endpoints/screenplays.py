import asyncio
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List

from app.db.session import get_db

router = APIRouter()


@router.post("/episode/{episode_id}/generate", response_model=List[str])
async def generate_screenplay(episode_id: UUID, db: Session = Depends(get_db)):
    """Generate screenplay for an episode"""
    # Simulate generation with 5 second delay
    await asyncio.sleep(5)
    # Return empty array for now
    return []

