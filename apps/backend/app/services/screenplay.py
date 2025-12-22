import time
import logging
from sqlalchemy.orm import Session
from typing import Optional
from uuid import UUID

from app.repositories.screenplay import ScreenplayRepository
from app.repositories.scene import SceneRepository
from app.services.story import StoryService
from app.services.ai.base_ai_service import BaseAIService
from app.schemas.screenplay import ScreenplayCreate, ScreenplayResponse, SceneCreate, SceneResponse

logger = logging.getLogger(__name__)


class ScreenplayService:
    def __init__(self, db: Session, ai_service: BaseAIService):
        self.db = db
        self.ai_service = ai_service
        self.screenplay_repository = ScreenplayRepository(db)
        self.scene_repository = SceneRepository(db)
        self.story_service = StoryService(db)
    
    async def generate_screenplay(self, episode_id: UUID) -> ScreenplayResponse:
        """
        Generate a screenplay for an episode from its story.
        
        Args:
            episode_id: The episode ID to generate screenplay for
            
        Returns:
            ScreenplayResponse with all scenes
            
        Raises:
            ValueError: If story not found or story content is empty
            Exception: If generation fails
        """
        # Get story content
        logger.debug(f"Fetching story for episode {episode_id}")
        story = self.story_service.get_story_by_episode(episode_id)
        if not story:
            logger.warning(f"Story not found for episode {episode_id}")
            raise ValueError(f"Story not found for episode {episode_id}")
        
        if not story.content or not story.content.strip():
            logger.warning(f"Story content is empty for episode {episode_id}")
            raise ValueError(f"Story content is empty for episode {episode_id}")
        
        story_length = len(story.content)
        logger.info(f"Story found for episode {episode_id}: {story_length} characters")
        
        generation_start_time = time.time()
        ai_model = getattr(self.ai_service, 'model', 'unknown')
        ai_temperature = getattr(self.ai_service, 'temperature', 0.7)
        
        logger.info(
            f"Starting AI screenplay generation for episode {episode_id} "
            f"(model: {ai_model}, temperature: {ai_temperature})"
        )
        
        try:
            # Call AI service to generate scenes
            logger.debug(f"Calling AI service to generate scenes from story")
            scenes = await self.ai_service.generate_screenplay(story.content)
            logger.info(f"AI service generated {len(scenes)} scenes")
            
            # Only create screenplay record after successful generation
            generation_time = time.time() - generation_start_time
            generation_time_seconds = round(generation_time, 2)
            scene_count = len(scenes)
            
            logger.info(
                f"Screenplay generation completed for episode {episode_id} "
                f"in {generation_time_seconds} seconds ({scene_count} scenes)"
            )
            
            # Create screenplay record with unfolded metadata
            logger.debug(f"Creating screenplay record for episode {episode_id}")
            screenplay_data = ScreenplayCreate(
                episode_id=episode_id,
                ai_model=ai_model,
                generation_time_seconds=generation_time_seconds,
                scene_count=scene_count
            )
            screenplay = self.screenplay_repository.create(screenplay_data)
            logger.info(f"Created screenplay record {screenplay.id} for episode {episode_id}")
            
            # Bulk insert scenes
            logger.debug(f"Preparing to insert {len(scenes)} scenes into database")
            scene_create_data = [
                SceneCreate(
                    screenplay_id=screenplay.id,
                    scene_number=scene.scene_number,
                    title=scene.title,
                    duration_seconds=scene.duration_seconds,
                    characters=scene.characters,
                    action=scene.action,
                    dialogue=scene.dialogue,
                    visual_notes=scene.visual_notes
                )
                for scene in scenes
            ]
            
            self.scene_repository.create_batch(scene_create_data)
            logger.info(f"Successfully inserted {len(scenes)} scenes into database")
            
            # Refresh to get updated screenplay with scenes
            screenplay = self.screenplay_repository.get_by_id(screenplay.id)
            scenes_db = self.scene_repository.get_by_screenplay_id(screenplay.id)
            
            return self._to_response(screenplay, scenes_db)
            
        except Exception as e:
            # Log error but don't create any database record
            generation_time = time.time() - generation_start_time
            logger.error(
                f"Screenplay generation failed for episode {episode_id} "
                f"after {generation_time:.2f} seconds: {str(e)}",
                exc_info=True
            )
            raise
    
    def _to_response(self, screenplay, scenes) -> ScreenplayResponse:
        """Convert database models to response schema."""
        scene_responses = [SceneResponse.model_validate(scene) for scene in scenes]
        return ScreenplayResponse(
            id=screenplay.id,
            episode_id=screenplay.episode_id,
            ai_model=screenplay.ai_model,
            generation_time_seconds=screenplay.generation_time_seconds,
            scene_count=screenplay.scene_count,
            scenes=scene_responses,
            created_at=screenplay.created_at,
            updated_at=screenplay.updated_at
        )

