from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.repositories.episode import EpisodeRepository
from app.schemas.episode import EpisodeCreate, EpisodeUpdate, EpisodeResponse
from app.services.story import StoryService
from app.schemas.story import StoryCreate


class EpisodeService:
    def __init__(self, db: Session):
        self.repository = EpisodeRepository(db)

    def get_episodes_by_project(self, project_id: UUID) -> List[EpisodeResponse]:
        episodes = self.repository.get_all_by_project(project_id)
        return [EpisodeResponse.model_validate(ep) for ep in episodes]

    def get_episode(self, episode_id: UUID) -> Optional[EpisodeResponse]:
        episode = self.repository.get_by_id(episode_id)
        if episode:
            return EpisodeResponse.model_validate(episode)
        return None

    def create_episode(self, episode_data: EpisodeCreate) -> EpisodeResponse:
        episode = self.repository.create(episode_data)
        episode_response = EpisodeResponse.model_validate(episode)
        
        # Auto-create empty story for the episode
        story_service = StoryService(self.repository.db)
        story_service.create_story(StoryCreate(episode_id=episode.id, content=None))
        
        return episode_response

    def update_episode(self, episode_id: UUID, episode_data: EpisodeUpdate) -> Optional[EpisodeResponse]:
        episode = self.repository.update(episode_id, episode_data)
        if episode:
            return EpisodeResponse.model_validate(episode)
        return None

    def delete_episode(self, episode_id: UUID) -> bool:
        return self.repository.delete(episode_id)

