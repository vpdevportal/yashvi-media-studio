from functools import lru_cache
from app.core.config import get_settings
from app.services.ai.base_ai_service import BaseAIService
from app.services.ai.openai_service import OpenAIService

settings = get_settings()


@lru_cache()
def get_ai_service() -> BaseAIService:
    """
    Dependency function to get the AI service instance.
    Currently returns OpenAI service, but can be easily switched via environment variables.
    """
    # For now, always use OpenAI. In the future, can switch based on config:
    # if settings.AI_PROVIDER == "claude":
    #     return ClaudeService()
    # elif settings.AI_PROVIDER == "openai":
    #     return OpenAIService()
    return OpenAIService()

