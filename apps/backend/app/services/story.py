from sqlalchemy.orm import Session
from typing import Optional
from uuid import UUID

from app.repositories.story import StoryRepository
from app.schemas.story import StoryCreate, StoryUpdate, StoryResponse


class StoryService:
    def __init__(self, db: Session):
        self.repository = StoryRepository(db)

    def get_story_by_episode(self, episode_id: UUID) -> Optional[StoryResponse]:
        story = self.repository.get_by_episode_id(episode_id)
        if story:
            return StoryResponse.model_validate(story)
        return None

    def get_or_create_story(self, episode_id: UUID) -> StoryResponse:
        """Get story by episode ID, creating it if it doesn't exist"""
        story = self.repository.get_by_episode_id(episode_id)
        if story:
            return StoryResponse.model_validate(story)
        # Create if doesn't exist
        story_data = StoryCreate(episode_id=episode_id, content=None)
        return self.create_story(story_data)

    def create_story(self, story_data: StoryCreate) -> StoryResponse:
        story = self.repository.create(story_data)
        return StoryResponse.model_validate(story)

    def update_story(self, episode_id: UUID, story_data: StoryUpdate) -> Optional[StoryResponse]:
        story = self.repository.update(episode_id, story_data)
        if story:
            return StoryResponse.model_validate(story)
        return None

