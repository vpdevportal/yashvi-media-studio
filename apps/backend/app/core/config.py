import os
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    APP_NAME: str = "Yashvi Media Studio API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    DATABASE_URL: str = ""
    
    # OpenAI Configuration
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-5-nano"  # Default model for screenplay generation
    OPENAI_TEMPERATURE: float = 0.7
    OPENAI_MAX_TOKENS: int = 4000  # Maximum tokens for response
    
    # Video Generation Configuration
    VIDEO_GENERATION_SERVICE: str = "luma_dream_machine"  # Options: stable_video_diffusion, animatediff, luma_dream_machine
    VIDEO_STORAGE_PATH: str = ""  # Local filesystem path for video storage (optional)
    
    # Stable Video Diffusion Configuration
    STABLE_VIDEO_DIFFUSION_MODEL_PATH: str = ""  # Model path or HuggingFace model ID (optional, uses default if empty)
    
    # AnimateDiff Configuration
    ANIMATEDIFF_MODEL_PATH: str = ""  # Base model path or HuggingFace model ID (optional, uses default if empty)
    ANIMATEDIFF_MOTION_ADAPTER_PATH: str = ""  # Motion adapter path or HuggingFace model ID (optional, uses default if empty)
    
    # Luma Dream Machine Configuration
    LUMA_API_KEY: str = ""  # Luma API key for Dream Machine
    LUMA_API_URL: str = ""  # Luma API endpoint URL (optional, uses default if empty)
    
    # CORS
    CORS_ORIGINS: list[str] = ["*"]
    
    class Config:
        env_file = "../../.env"
        env_file_encoding = "utf-8"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()

