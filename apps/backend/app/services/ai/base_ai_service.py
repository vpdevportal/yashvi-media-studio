from abc import ABC, abstractmethod
from typing import List
from app.schemas.screenplay import SceneBase


class BaseAIService(ABC):
    """Abstract base class for AI services that generate screenplays from stories."""
    
    @abstractmethod
    async def generate_screenplay(self, story_content: str) -> List[SceneBase]:
        """
        Generate a screenplay (list of scenes) from story content.
        
        Args:
            story_content: The story text to convert to screenplay
            
        Returns:
            List of SceneBase objects representing the screenplay scenes
            
        Raises:
            Exception: If generation fails
        """
        pass

