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
from diffusers import AnimateDiffPipeline, DDIMScheduler, MotionAdapter
from diffusers.utils import export_to_video
from peft import PeftModel
from transformers import CLIPTextModel, CLIPTokenizer

from app.core.config import get_settings
from app.services.ai.video.base_video_service import BaseVideoGenerationService

logger = logging.getLogger(__name__)
settings = get_settings()


class AnimateDiffService(BaseVideoGenerationService):
    """AnimateDiff service for image-to-video generation with animation."""
    
    def __init__(
        self,
        storage_path: Optional[str] = None,
        model_path: Optional[str] = None,
        motion_adapter_path: Optional[str] = None,
        device: Optional[str] = None,
        num_frames: int = 16,
        num_inference_steps: int = 50,
        guidance_scale: float = 7.5,
        fps: int = 8
    ):
        """
        Initialize AnimateDiff service.
        
        Args:
            storage_path: Optional local filesystem path for saving videos
            model_path: Path to base model or model ID (default: "runwayml/stable-diffusion-v1-5")
            motion_adapter_path: Path to motion adapter or model ID (default: "guoyww/animatediff-motion-adapter-v1-5-2")
            device: Device to run on ("cuda", "cpu", or None for auto-detect)
            num_frames: Number of frames to generate (default: 16)
            num_inference_steps: Number of denoising steps (default: 50)
            guidance_scale: Guidance scale for classifier-free guidance (default: 7.5)
            fps: Frames per second for output video (default: 8)
        """
        super().__init__(storage_path)
        self.model_path = model_path or getattr(settings, 'ANIMATEDIFF_MODEL_PATH', None) or "runwayml/stable-diffusion-v1-5"
        self.motion_adapter_path = motion_adapter_path or getattr(settings, 'ANIMATEDIFF_MOTION_ADAPTER_PATH', None) or "guoyww/animatediff-motion-adapter-v1-5-2"
        
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
        
        self.num_frames = num_frames
        self.num_inference_steps = num_inference_steps
        self.guidance_scale = guidance_scale
        self.fps = fps
        self.pipeline = None
        self._load_model()
    
    def _load_model(self):
        """Load the AnimateDiff model and motion adapter."""
        try:
            logger.info(f"Loading AnimateDiff model from {self.model_path} on {self.device}")
            
            # Load motion adapter
            motion_adapter = MotionAdapter.from_pretrained(self.motion_adapter_path)
            
            # Load scheduler
            scheduler = DDIMScheduler(
                num_train_timesteps=1000,
                beta_start=0.00085,
                beta_end=0.012,
                beta_schedule="linear",
                steps_offset=1,
                clip_sample=False,
                set_alpha_to_one=False,
            )
            
            # Load pipeline
            self.pipeline = AnimateDiffPipeline.from_pretrained(
                self.model_path,
                motion_adapter=motion_adapter,
                scheduler=scheduler,
                torch_dtype=torch.float16 if self.device == "cuda" else torch.float32,
            )
            self.pipeline = self.pipeline.to(self.device)
            self.pipeline.enable_model_cpu_offload()
            logger.info("AnimateDiff model loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load AnimateDiff model: {str(e)}")
            raise
    
    async def generate_video(
        self,
        image: Union[bytes, str],
        prompt: str,
        num_frames: Optional[int] = None,
        num_inference_steps: Optional[int] = None,
        guidance_scale: Optional[float] = None,
        fps: Optional[int] = None,
        negative_prompt: Optional[str] = None,
        **kwargs
    ) -> bytes:
        """
        Generate animated video from image and prompt using AnimateDiff.
        
        Args:
            image: Image as bytes or file path
            prompt: Text prompt describing the desired animation
            num_frames: Override default number of frames
            num_inference_steps: Override default inference steps
            guidance_scale: Override default guidance scale
            fps: Override default FPS
            negative_prompt: Optional negative prompt
            **kwargs: Additional parameters
            
        Returns:
            bytes: Video file content (MP4 format)
        """
        # Validate inputs
        image_bytes = self._validate_image(image)
        prompt = self._validate_prompt(prompt)
        
        # Use provided parameters or defaults
        num_frames = num_frames or self.num_frames
        num_inference_steps = num_inference_steps or self.num_inference_steps
        guidance_scale = guidance_scale or self.guidance_scale
        fps = fps or self.fps
        negative_prompt = negative_prompt or "bad quality, worse quality"
        
        try:
            # Load image
            if isinstance(image, str):
                pil_image = Image.open(image)
            else:
                pil_image = Image.open(io.BytesIO(image_bytes))
            
            # Resize image to model requirements (512x512 or 768x768)
            # AnimateDiff typically works with square images
            size = 512  # Can be adjusted based on model
            pil_image = pil_image.resize((size, size), Image.Resampling.LANCZOS)
            
            logger.info(f"Generating animated video with prompt: {prompt[:50]}...")
            logger.info(f"Parameters: {num_frames} frames, {num_inference_steps} steps, guidance={guidance_scale}")
            
            # Generate video frames
            output = self.pipeline(
                prompt=prompt,
                image=pil_image,
                num_frames=num_frames,
                num_inference_steps=num_inference_steps,
                guidance_scale=guidance_scale,
                negative_prompt=negative_prompt,
            )
            
            frames = output.frames[0]
            
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
            
            logger.info(f"Animated video generated successfully: {len(video_bytes)} bytes")
            
            # Optionally save to filesystem
            if self.storage_path:
                self._save_video(video_bytes)
            
            return video_bytes
            
        except Exception as e:
            logger.error(f"Failed to generate video with AnimateDiff: {str(e)}", exc_info=True)
            raise Exception(f"Video generation failed: {str(e)}")

