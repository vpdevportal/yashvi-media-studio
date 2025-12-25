import logging
import os
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Optional, Union
from datetime import datetime

logger = logging.getLogger(__name__)


class BaseVideoGenerationService(ABC):
    """Abstract base class for video generation services."""
    
    def __init__(self, storage_path: Optional[str] = None):
        """
        Initialize the video generation service.
        
        Args:
            storage_path: Optional local filesystem path for saving videos.
                         If None, videos won't be saved to disk.
        """
        self.storage_path = storage_path
        if storage_path:
            Path(storage_path).mkdir(parents=True, exist_ok=True)
    
    @abstractmethod
    async def generate_video(
        self,
        image: Union[bytes, str],
        prompt: str,
        **kwargs
    ) -> bytes:
        """
        Generate a video from an image and prompt.
        
        Args:
            image: Image as bytes or file path (str)
            prompt: Text prompt describing the desired video/animation
            **kwargs: Additional service-specific parameters
            
        Returns:
            bytes: Video file content (MP4 format)
            
        Raises:
            ValueError: If image or prompt is invalid
            Exception: If video generation fails
        """
        pass
    
    def _validate_image(self, image: Union[bytes, str]) -> bytes:
        """
        Validate and convert image input to bytes.
        
        Args:
            image: Image as bytes or file path
            
        Returns:
            bytes: Image bytes
            
        Raises:
            ValueError: If image is invalid or file doesn't exist
        """
        if isinstance(image, str):
            if not os.path.exists(image):
                raise ValueError(f"Image file not found: {image}")
            with open(image, "rb") as f:
                return f.read()
        elif isinstance(image, bytes):
            if len(image) == 0:
                raise ValueError("Image bytes cannot be empty")
            return image
        else:
            raise ValueError(f"Invalid image type: {type(image)}. Expected bytes or str (file path)")
    
    def _validate_prompt(self, prompt: str) -> str:
        """
        Validate prompt input.
        
        Args:
            prompt: Text prompt
            
        Returns:
            str: Validated prompt
            
        Raises:
            ValueError: If prompt is invalid
        """
        if not prompt or not prompt.strip():
            raise ValueError("Prompt cannot be empty")
        return prompt.strip()
    
    def _save_video(self, video_bytes: bytes, filename: Optional[str] = None) -> Optional[str]:
        """
        Save video bytes to local filesystem if storage_path is configured.
        
        Args:
            video_bytes: Video file content
            filename: Optional filename. If None, generates timestamp-based filename.
            
        Returns:
            Optional[str]: File path if saved, None otherwise
        """
        if not self.storage_path:
            return None
        
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
            filename = f"video_{timestamp}.mp4"
        
        file_path = os.path.join(self.storage_path, filename)
        
        try:
            with open(file_path, "wb") as f:
                f.write(video_bytes)
            logger.info(f"Video saved to: {file_path}")
            return file_path
        except Exception as e:
            logger.error(f"Failed to save video to {file_path}: {str(e)}")
            raise

