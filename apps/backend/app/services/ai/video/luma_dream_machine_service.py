import logging
import base64
import io
import asyncio
from typing import Union, Optional
from PIL import Image
import httpx
from datetime import datetime

from app.core.config import get_settings
from app.services.ai.video.base_video_service import BaseVideoGenerationService

logger = logging.getLogger(__name__)
settings = get_settings()


class LumaDreamMachineService(BaseVideoGenerationService):
    """Luma Dream Machine service for image-to-video generation via API."""
    
    def __init__(
        self,
        storage_path: Optional[str] = None,
        api_key: Optional[str] = None,
        api_url: Optional[str] = None,
        timeout: int = 300
    ):
        """
        Initialize Luma Dream Machine service.
        
        Args:
            storage_path: Optional local filesystem path for saving videos
            api_key: Luma API key (default: from settings)
            api_url: Luma API endpoint URL (default: from settings or "https://api.lumalabs.ai/v1/generations")
            timeout: Request timeout in seconds (default: 300)
        """
        super().__init__(storage_path)
        self.api_key = api_key or getattr(settings, 'LUMA_API_KEY', None)
        self.api_url = api_url or getattr(settings, 'LUMA_API_URL', None) or "https://api.lumalabs.ai/v1/generations"
        self.timeout = timeout
        
        if not self.api_key:
            raise ValueError("LUMA_API_KEY is required for Luma Dream Machine service")
    
    def _encode_image(self, image_bytes: bytes) -> str:
        """
        Encode image bytes to base64 string.
        
        Args:
            image_bytes: Image file content
            
        Returns:
            str: Base64 encoded image string
        """
        return base64.b64encode(image_bytes).decode('utf-8')
    
    def _prepare_image(self, image: Union[bytes, str]) -> bytes:
        """
        Prepare and validate image for API upload.
        
        Args:
            image: Image as bytes or file path
            
        Returns:
            bytes: Image bytes
        """
        image_bytes = self._validate_image(image)
        
        # Ensure image is in a format Luma accepts (JPEG/PNG)
        try:
            pil_image = Image.open(io.BytesIO(image_bytes))
            # Convert to RGB if necessary
            if pil_image.mode != 'RGB':
                pil_image = pil_image.convert('RGB')
            
            # Save to bytes as JPEG
            output = io.BytesIO()
            pil_image.save(output, format='JPEG', quality=95)
            return output.getvalue()
        except Exception as e:
            logger.warning(f"Could not process image, using original: {str(e)}")
            return image_bytes
    
    async def generate_video(
        self,
        image: Union[bytes, str],
        prompt: str,
        aspect_ratio: str = "16:9",
        duration: int = 5,
        **kwargs
    ) -> bytes:
        """
        Generate video from image and prompt using Luma Dream Machine API.
        
        Args:
            image: Image as bytes or file path
            prompt: Text prompt describing the desired video
            aspect_ratio: Video aspect ratio (default: "16:9")
            duration: Video duration in seconds (default: 5)
            **kwargs: Additional parameters
            
        Returns:
            bytes: Video file content (MP4 format)
        """
        # Validate inputs
        image_bytes = self._validate_image(image)
        prompt = self._validate_prompt(prompt)
        
        # Prepare image
        processed_image = self._prepare_image(image_bytes)
        image_base64 = self._encode_image(processed_image)
        
        try:
            logger.info(f"Submitting video generation request to Luma API with prompt: {prompt[:50]}...")
            
            # Create request payload
            payload = {
                "prompt": prompt,
                "image": image_base64,
                "aspect_ratio": aspect_ratio,
                "duration": duration
            }
            
            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            }
            
            # Submit generation request
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    self.api_url,
                    json=payload,
                    headers=headers
                )
                response.raise_for_status()
                
                result = response.json()
                generation_id = result.get("id")
                
                if not generation_id:
                    raise Exception("No generation ID returned from Luma API")
                
                logger.info(f"Generation submitted, ID: {generation_id}")
                
                # Poll for completion
                video_url = await self._poll_for_completion(client, generation_id, headers)
                
                # Download video
                logger.info(f"Downloading video from: {video_url}")
                video_response = await client.get(video_url, headers=headers)
                video_response.raise_for_status()
                video_bytes = video_response.content
                
                logger.info(f"Video generated successfully: {len(video_bytes)} bytes")
                
                # Optionally save to filesystem
                if self.storage_path:
                    self._save_video(video_bytes)
                
                return video_bytes
                
        except httpx.HTTPStatusError as e:
            logger.error(f"Luma API HTTP error: {e.response.status_code} - {e.response.text}")
            raise Exception(f"Luma API error: {e.response.status_code} - {e.response.text}")
        except httpx.RequestError as e:
            logger.error(f"Luma API request error: {str(e)}")
            raise Exception(f"Luma API request failed: {str(e)}")
        except Exception as e:
            logger.error(f"Failed to generate video with Luma Dream Machine: {str(e)}", exc_info=True)
            raise Exception(f"Video generation failed: {str(e)}")
    
    async def _poll_for_completion(
        self,
        client: httpx.AsyncClient,
        generation_id: str,
        headers: dict,
        max_attempts: int = 60,
        poll_interval: int = 5
    ) -> str:
        """
        Poll Luma API for generation completion.
        
        Args:
            client: HTTP client
            generation_id: Generation ID to poll
            headers: Request headers
            max_attempts: Maximum polling attempts (default: 60)
            poll_interval: Seconds between polls (default: 5)
            
        Returns:
            str: URL of completed video
            
        Raises:
            Exception: If generation fails or times out
        """
        status_url = f"{self.api_url}/{generation_id}"
        
        for attempt in range(max_attempts):
            try:
                response = await client.get(status_url, headers=headers)
                response.raise_for_status()
                
                result = response.json()
                status = result.get("status")
                
                if status == "completed":
                    video_url = result.get("video_url")
                    if not video_url:
                        raise Exception("Video URL not found in completed generation")
                    return video_url
                elif status == "failed":
                    error = result.get("error", "Unknown error")
                    raise Exception(f"Video generation failed: {error}")
                elif status in ["pending", "processing"]:
                    logger.info(f"Generation {generation_id} status: {status} (attempt {attempt + 1}/{max_attempts})")
                    await asyncio.sleep(poll_interval)
                else:
                    logger.warning(f"Unknown status: {status}")
                    await asyncio.sleep(poll_interval)
                    
            except httpx.HTTPStatusError as e:
                logger.error(f"Error polling generation status: {e.response.status_code} - {e.response.text}")
                raise Exception(f"Failed to check generation status: {e.response.status_code}")
            except Exception as e:
                if "failed" in str(e).lower():
                    raise
                logger.warning(f"Error polling (attempt {attempt + 1}): {str(e)}")
                await asyncio.sleep(poll_interval)
        
        raise Exception(f"Video generation timed out after {max_attempts * poll_interval} seconds")

