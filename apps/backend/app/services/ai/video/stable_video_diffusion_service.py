import logging
import io
import platform
import warnings
from typing import Union, Optional
from PIL import Image

# Suppress CUDA warnings before importing torch
warnings.filterwarnings("ignore", message=".*CUDA is not available.*")
warnings.filterwarnings("ignore", message=".*User provided device_type of 'cuda'.*")
warnings.filterwarnings("ignore", category=UserWarning, message=".*cuda.*")

import torch
from diffusers import StableVideoDiffusionPipeline
from diffusers.utils import load_image, export_to_video

from app.core.config import get_settings
from app.services.ai.video.base_video_service import BaseVideoGenerationService

logger = logging.getLogger(__name__)
settings = get_settings()


class StableVideoDiffusionService(BaseVideoGenerationService):
    """Stable Video Diffusion service for image-to-video generation."""
    
    def __init__(
        self,
        storage_path: Optional[str] = None,
        model_path: Optional[str] = None,
        device: Optional[str] = None,
        num_frames: int = 14,
        num_inference_steps: int = 25,
        motion_bucket_id: int = 127,
        fps: int = 7
    ):
        # Adjust parameters for CPU to reduce memory usage
        if device == "cpu" or (device is None and not torch.cuda.is_available()):
            # Reduce frames and steps for CPU
            if num_frames == 14:  # Only override if using default
                num_frames = 6  # Reduced from 14
            if num_inference_steps == 25:  # Only override if using default
                num_inference_steps = 15  # Reduced from 25
        """
        Initialize Stable Video Diffusion service.
        
        Args:
            storage_path: Optional local filesystem path for saving videos
            model_path: Path to model or model ID (default: "stabilityai/stable-video-diffusion-img2vid-xt")
            device: Device to run on ("cuda", "cpu", or None for auto-detect)
            num_frames: Number of frames to generate (default: 14)
            num_inference_steps: Number of denoising steps (default: 25)
            motion_bucket_id: Motion bucket ID for motion strength (default: 127)
            fps: Frames per second for output video (default: 7)
        """
        super().__init__(storage_path)
        self.model_path = model_path or getattr(settings, 'STABLE_VIDEO_DIFFUSION_MODEL_PATH', None) or "stabilityai/stable-video-diffusion-img2vid-xt"
        
        # Determine device with proper fallback
        if device:
            self.device = device
        elif platform.system() == "Darwin":  # macOS doesn't support CUDA
            self.device = "cpu"
        elif torch.cuda.is_available():
            self.device = "cuda"
        else:
            self.device = "cpu"
        
        # Ensure we never use CUDA if it's not actually available
        if self.device == "cuda" and not torch.cuda.is_available():
            logger.warning("CUDA requested but not available, falling back to CPU")
            self.device = "cpu"
        
        # Stable Video Diffusion is not suitable for CPU - it requires too much memory (~19GB+)
        # Prevent initialization on CPU to avoid confusing errors during generation
        if self.device == "cpu":
            raise ValueError(
                "Stable Video Diffusion requires a GPU and cannot run on CPU due to memory constraints. "
                "Please use one of the following alternatives:\n"
                "1. Luma Dream Machine API (requires LUMA_API_KEY) - Fastest, cloud-based\n"
                "2. AnimateDiff - May work on CPU with reduced settings\n"
                "3. Use a GPU-enabled system for Stable Video Diffusion"
            )
        
        self.num_frames = num_frames
        self.num_inference_steps = num_inference_steps
        self.motion_bucket_id = motion_bucket_id
        self.fps = fps
        self.pipeline = None
        self._load_model()
    
    def _load_model(self):
        """Load the Stable Video Diffusion model."""
        try:
            logger.info(f"Loading Stable Video Diffusion model from {self.model_path} on {self.device}")
            self.pipeline = StableVideoDiffusionPipeline.from_pretrained(
                self.model_path,
                torch_dtype=torch.float16 if self.device == "cuda" else torch.float32,
            )
            self.pipeline = self.pipeline.to(self.device)
            self.pipeline.enable_model_cpu_offload()
            logger.info("Stable Video Diffusion model loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load Stable Video Diffusion model: {str(e)}")
            raise
    
    async def generate_video(
        self,
        image: Union[bytes, str],
        prompt: str = "",
        num_frames: Optional[int] = None,
        num_inference_steps: Optional[int] = None,
        motion_bucket_id: Optional[int] = None,
        fps: Optional[int] = None,
        **kwargs
    ) -> bytes:
        """
        Generate video from image using Stable Video Diffusion.
        
        Args:
            image: Image as bytes or file path
            prompt: Text prompt (optional for Stable Video Diffusion)
            num_frames: Override default number of frames
            num_inference_steps: Override default inference steps
            motion_bucket_id: Override default motion bucket ID
            fps: Override default FPS
            **kwargs: Additional parameters
            
        Returns:
            bytes: Video file content (MP4 format)
        """
        # Validate image
        image_bytes = self._validate_image(image)
        
        # Use provided parameters or defaults
        num_frames = num_frames or self.num_frames
        num_inference_steps = num_inference_steps or self.num_inference_steps
        motion_bucket_id = motion_bucket_id or self.motion_bucket_id
        fps = fps or self.fps
        
        try:
            # Load image
            if isinstance(image, str):
                pil_image = load_image(image)
            else:
                pil_image = Image.open(io.BytesIO(image_bytes))
            
            # Convert to RGB if necessary (handles RGBA, P, etc.)
            if pil_image.mode != 'RGB':
                pil_image = pil_image.convert('RGB')
            
            # Use full resolution for GPU (CPU is not supported)
            target_size = (1024, 576)
            pil_image = pil_image.resize(target_size, Image.Resampling.LANCZOS)
            
            logger.info(f"Generating video with {num_frames} frames, {num_inference_steps} steps")
            
            # Generate video frames
            frames = self.pipeline(
                pil_image,
                decode_chunk_size=2,
                num_frames=num_frames,
                num_inference_steps=num_inference_steps,
                motion_bucket_id=motion_bucket_id,
            ).frames[0]
            
            # Export to video - export_to_video saves to file, so we use a temporary path
            import tempfile
            import os
            
            with tempfile.NamedTemporaryFile(suffix='.mp4', delete=False) as tmp_file:
                tmp_path = tmp_file.name
            
            try:
                export_to_video(frames, output_video_path=tmp_path, fps=fps)
                
                # Read video bytes from temporary file
                with open(tmp_path, "rb") as f:
                    video_bytes = f.read()
            finally:
                # Clean up temporary file
                if os.path.exists(tmp_path):
                    os.unlink(tmp_path)
            
            logger.info(f"Video generated successfully: {len(video_bytes)} bytes")
            
            # Optionally save to filesystem
            if self.storage_path:
                self._save_video(video_bytes)
            
            return video_bytes
            
        except Exception as e:
            logger.error(f"Failed to generate video with Stable Video Diffusion: {str(e)}", exc_info=True)
            raise Exception(f"Video generation failed: {str(e)}")

