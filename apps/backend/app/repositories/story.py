from sqlalchemy.orm import Session
from sqlalchemy import select
from typing import Optional
from uuid import UUID

from app.models.story import Story
from app.schemas.story import StoryCreate, StoryUpdate


class StoryRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_episode_id(self, episode_id: UUID) -> Optional[Story]:
        result = self.db.execute(
            select(Story).where(Story.episode_id == episode_id)
        )
        return result.scalar_one_or_none()

    def create(self, story_data: StoryCreate) -> Story:
        story = Story(**story_data.model_dump())
        self.db.add(story)
        self.db.commit()
        self.db.refresh(story)
        return story

    def update(self, episode_id: UUID, story_data: StoryUpdate) -> Optional[Story]:
        story = self.get_by_episode_id(episode_id)
        if not story:
            return None
        
        update_data = story_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(story, field, value)
        
        self.db.commit()
        self.db.refresh(story)
        return story

