from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID

from app.db.session import get_db
from app.services.story import StoryService
from app.schemas.story import StoryCreate, StoryUpdate, StoryResponse

router = APIRouter()


@router.get("/episode/{episode_id}", response_model=StoryResponse)
def get_story_by_episode(episode_id: UUID, db: Session = Depends(get_db)):
    """Get story by episode ID, creating it if it doesn't exist"""
    service = StoryService(db)
    return service.get_or_create_story(episode_id)


@router.post("/", response_model=StoryResponse, status_code=status.HTTP_201_CREATED)
def create_story(story_data: StoryCreate, db: Session = Depends(get_db)):
    """Create a new story"""
    service = StoryService(db)
    return service.create_story(story_data)


@router.patch("/episode/{episode_id}", response_model=StoryResponse)
def update_story(episode_id: UUID, story_data: StoryUpdate, db: Session = Depends(get_db)):
    """Update story content"""
    service = StoryService(db)
    story = service.update_story(episode_id, story_data)
    if not story:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Story not found"
        )
    return story

