from sqlalchemy.orm import Session
from sqlalchemy import select
from typing import Optional, List
from uuid import UUID

from app.models.screenplay import Screenplay
from app.schemas.screenplay import ScreenplayCreate, ScreenplayBase


class ScreenplayRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_episode_id(self, episode_id: UUID) -> Optional[Screenplay]:
        """Get the latest screenplay for an episode (most recently created)."""
        result = self.db.execute(
            select(Screenplay)
            .where(Screenplay.episode_id == episode_id)
            .order_by(Screenplay.created_at.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()
    
    def get_all_by_episode_id(self, episode_id: UUID) -> List[Screenplay]:
        """Get all screenplays for an episode, ordered by creation date (newest first)."""
        result = self.db.execute(
            select(Screenplay)
            .where(Screenplay.episode_id == episode_id)
            .order_by(Screenplay.created_at.desc())
        )
        return list(result.scalars().all())
    
    def get_by_id(self, screenplay_id: UUID) -> Optional[Screenplay]:
        """Get a screenplay by its ID."""
        result = self.db.execute(
            select(Screenplay).where(Screenplay.id == screenplay_id)
        )
        return result.scalar_one_or_none()

    def create(self, screenplay_data: ScreenplayCreate) -> Screenplay:
        screenplay = Screenplay(**screenplay_data.model_dump())
        self.db.add(screenplay)
        self.db.commit()
        self.db.refresh(screenplay)
        return screenplay

    def update(self, screenplay_id: UUID, screenplay_data: ScreenplayBase) -> Optional[Screenplay]:
        """Update a screenplay by its ID."""
        screenplay = self.get_by_id(screenplay_id)
        if not screenplay:
            return None
        
        update_data = screenplay_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(screenplay, field, value)
        
        self.db.commit()
        self.db.refresh(screenplay)
        return screenplay

    def delete(self, screenplay_id: UUID) -> bool:
        """Delete a screenplay by its ID."""
        screenplay = self.get_by_id(screenplay_id)
        if not screenplay:
            return False
        
        self.db.delete(screenplay)
        self.db.commit()
        return True

