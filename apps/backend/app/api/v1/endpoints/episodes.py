from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.db.session import get_db
from app.services.episode import EpisodeService
from app.schemas.episode import EpisodeCreate, EpisodeUpdate, EpisodeResponse

router = APIRouter()


@router.get("/project/{project_id}", response_model=List[EpisodeResponse])
def get_episodes_by_project(project_id: UUID, db: Session = Depends(get_db)):
    """Get all episodes for a project"""
    service = EpisodeService(db)
    return service.get_episodes_by_project(project_id)


@router.get("/{episode_id}", response_model=EpisodeResponse)
def get_episode(episode_id: UUID, db: Session = Depends(get_db)):
    """Get a specific episode by ID"""
    service = EpisodeService(db)
    episode = service.get_episode(episode_id)
    if not episode:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Episode not found"
        )
    return episode


@router.post("/", response_model=EpisodeResponse, status_code=status.HTTP_201_CREATED)
def create_episode(episode_data: EpisodeCreate, db: Session = Depends(get_db)):
    """Create a new episode"""
    service = EpisodeService(db)
    return service.create_episode(episode_data)


@router.patch("/{episode_id}", response_model=EpisodeResponse)
def update_episode(episode_id: UUID, episode_data: EpisodeUpdate, db: Session = Depends(get_db)):
    """Update an episode"""
    service = EpisodeService(db)
    episode = service.update_episode(episode_id, episode_data)
    if not episode:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Episode not found"
        )
    return episode


@router.delete("/{episode_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_episode(episode_id: UUID, db: Session = Depends(get_db)):
    """Delete an episode"""
    service = EpisodeService(db)
    if not service.delete_episode(episode_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Episode not found"
        )

