import logging
from typing import Optional

from app.core.config import get_settings
from app.services.ai.video.base_video_service import BaseVideoGenerationService
from app.services.ai.video.stable_video_diffusion_service import StableVideoDiffusionService
from app.services.ai.video.animatediff_service import AnimateDiffService
from app.services.ai.video.luma_dream_machine_service import LumaDreamMachineService

logger = logging.getLogger(__name__)
settings = get_settings()


class VideoGenerationServiceFactory:
    """Factory for creating video generation service instances."""
    
    SERVICE_TYPES = {
        "stable_video_diffusion": StableVideoDiffusionService,
        "animatediff": AnimateDiffService,
        "luma_dream_machine": LumaDreamMachineService,
    }
    
    @classmethod
    def create_service(
        cls,
        service_type: Optional[str] = None,
        storage_path: Optional[str] = None,
        **kwargs
    ) -> BaseVideoGenerationService:
        """
        Create a video generation service instance.
        
        Args:
            service_type: Type of service to create. Options:
                - "stable_video_diffusion"
                - "animatediff"
                - "luma_dream_machine"
                If None, uses VIDEO_GENERATION_SERVICE from settings.
            storage_path: Optional storage path for videos.
                         If None, uses VIDEO_STORAGE_PATH from settings.
            **kwargs: Additional service-specific configuration parameters
        
        Returns:
            BaseVideoGenerationService: Instance of the requested service
            
        Raises:
            ValueError: If service_type is invalid
            Exception: If service initialization fails
        """
        # Get service type from parameter or settings
        if service_type is None:
            service_type = getattr(settings, 'VIDEO_GENERATION_SERVICE', 'luma_dream_machine')
        
        service_type = service_type.lower()
        
        if service_type not in cls.SERVICE_TYPES:
            available = ", ".join(cls.SERVICE_TYPES.keys())
            raise ValueError(
                f"Invalid service type: {service_type}. "
                f"Available types: {available}"
            )
        
        # Get storage path from parameter or settings
        if storage_path is None:
            storage_path = getattr(settings, 'VIDEO_STORAGE_PATH', None)
        
        # Get service class
        service_class = cls.SERVICE_TYPES[service_type]
        
        try:
            logger.info(f"Creating {service_type} video generation service")
            
            # Create service instance with storage_path and any additional kwargs
            service = service_class(storage_path=storage_path, **kwargs)
            
            logger.info(f"Successfully created {service_type} service")
            return service
            
        except ValueError as e:
            # Re-raise ValueError as-is (these are configuration errors)
            logger.error(f"Configuration error for {service_type} service: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Failed to create {service_type} service: {str(e)}", exc_info=True)
            raise
    
    @classmethod
    def get_available_services(cls) -> list[str]:
        """
        Get list of available service types.
        
        Returns:
            list[str]: List of available service type names
        """
        return list(cls.SERVICE_TYPES.keys())
    
    @classmethod
    def is_service_available(cls, service_type: str) -> bool:
        """
        Check if a service type is available.
        
        Args:
            service_type: Service type to check
            
        Returns:
            bool: True if service type is available
        """
        return service_type.lower() in cls.SERVICE_TYPES

