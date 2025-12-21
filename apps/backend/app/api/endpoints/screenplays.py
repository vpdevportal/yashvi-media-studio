import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List

from app.db.session import get_db
from app.core.dependencies import get_ai_service
from app.services.screenplay import ScreenplayService
from app.services.ai.base_ai_service import BaseAIService
from app.schemas.screenplay import SceneResponse

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/episode/{episode_id}", response_model=List[SceneResponse])
async def get_screenplay_scenes(
    episode_id: UUID,
    db: Session = Depends(get_db)
):
    """
    Get the latest screenplay scenes for an episode.
    Returns a list of scenes from the most recent screenplay.
    """
    logger.info(f"Fetching screenplay scenes for episode {episode_id}")
    
    try:
        from app.repositories.screenplay import ScreenplayRepository
        from app.repositories.scene import SceneRepository
        
        screenplay_repo = ScreenplayRepository(db)
        scene_repo = SceneRepository(db)
        
        # Get the latest screenplay for the episode
        screenplay = screenplay_repo.get_by_episode_id(episode_id)
        if not screenplay:
            logger.info(f"No screenplay found for episode {episode_id}")
            return []
        
        # Get all scenes for this screenplay
        scenes = scene_repo.get_by_screenplay_id(screenplay.id)
        scene_responses = [SceneResponse.model_validate(scene) for scene in scenes]
        
        logger.info(f"Found {len(scene_responses)} scenes for episode {episode_id}")
        return scene_responses
    except Exception as e:
        logger.error(
            f"Error fetching screenplay scenes for episode {episode_id}: {str(e)}",
            exc_info=True
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch screenplay scenes: {str(e)}"
        )


@router.post("/episode/{episode_id}/generate", response_model=List[SceneResponse])
async def generate_screenplay(
    episode_id: UUID,
    db: Session = Depends(get_db),
    ai_service: BaseAIService = Depends(get_ai_service)
):
    """
    Generate screenplay for an episode from its story.
    Returns a list of scenes.
    """
    logger.info(f"Starting screenplay generation for episode {episode_id}")
    
    try:
        service = ScreenplayService(db, ai_service)
        screenplay = await service.generate_screenplay(episode_id)
        
        scene_count = len(screenplay.scenes)
        logger.info(
            f"Successfully generated screenplay for episode {episode_id}: "
            f"{scene_count} scenes created"
        )
        
        return screenplay.scenes
    except ValueError as e:
        logger.warning(f"Screenplay generation failed for episode {episode_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        logger.error(
            f"Unexpected error during screenplay generation for episode {episode_id}: {str(e)}",
            exc_info=True
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate screenplay: {str(e)}"
        )

