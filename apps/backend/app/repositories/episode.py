from sqlalchemy.orm import Session
from sqlalchemy import select
from typing import List, Optional
from uuid import UUID

from app.models.episode import Episode
from app.schemas.episode import EpisodeCreate, EpisodeUpdate


class EpisodeRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all_by_project(self, project_id: UUID) -> List[Episode]:
        result = self.db.execute(
            select(Episode)
            .where(Episode.project_id == project_id)
            .order_by(Episode.episode_number)
        )
        return list(result.scalars().all())

    def get_by_id(self, episode_id: UUID) -> Optional[Episode]:
        result = self.db.execute(
            select(Episode).where(Episode.id == episode_id)
        )
        return result.scalar_one_or_none()

    def create(self, episode_data: EpisodeCreate) -> Episode:
        episode = Episode(**episode_data.model_dump())
        self.db.add(episode)
        self.db.commit()
        self.db.refresh(episode)
        return episode

    def update(self, episode_id: UUID, episode_data: EpisodeUpdate) -> Optional[Episode]:
        episode = self.get_by_id(episode_id)
        if not episode:
            return None
        
        update_data = episode_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(episode, field, value)
        
        self.db.commit()
        self.db.refresh(episode)
        return episode

    def delete(self, episode_id: UUID) -> bool:
        episode = self.get_by_id(episode_id)
        if not episode:
            return False
        
        self.db.delete(episode)
        self.db.commit()
        return True

