import json
from typing import List
from openai import AsyncOpenAI
from openai import APIError

from app.core.config import get_settings
from app.services.ai.base_ai_service import BaseAIService
from app.services.ai.openai_instruction_generator import OpenAIInstructionGenerator
from app.schemas.screenplay import SceneBase

settings = get_settings()


class OpenAIService(BaseAIService):
    """OpenAI implementation of the AI service for screenplay generation."""
    
    def __init__(self):
        if not settings.OPENAI_API_KEY:
            raise ValueError("OPENAI_API_KEY is not set in configuration")
        
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.model = settings.OPENAI_MODEL
        self.temperature = settings.OPENAI_TEMPERATURE
        self.max_tokens = getattr(settings, 'OPENAI_MAX_TOKENS', 4000)
    
    async def generate_screenplay(self, story_content: str) -> List[SceneBase]:
        """
        Generate a screenplay from story content using OpenAI.
        
        Args:
            story_content: The story text to convert to screenplay
            
        Returns:
            List of SceneBase objects representing the screenplay scenes
            
        Raises:
            Exception: If generation fails
        """
        if not story_content or not story_content.strip():
            raise ValueError("Story content cannot be empty")
        
        # Create instructions and user input (story)
        instructions = OpenAIInstructionGenerator.generate_screenplay_instructions()
        user_input = f"Convert the following story into a professional screenplay:\n\n{story_content}"
        
        try:
            # Using AsyncOpenAI for native async support
            # Following OpenAI text generation best practices from https://platform.openai.com/docs/guides/text
            # Using responses.create API for text generation
            # Instructions contain format requirements, input contains the story
            # Note: Some models (like gpt-5-nano) may not support temperature or max_tokens parameters
            response = await self.client.responses.create(
                model=self.model,
                instructions=instructions,
                input=user_input
            )
            
            content = response.output_text
            import logging
            logger = logging.getLogger(__name__)
            logger.info("OpenAI screenplay generation raw output: %s", content)
            if not content:
                raise ValueError("Empty response from OpenAI")
            
            # Parse JSON response
            response_data = json.loads(content)
            
            # Extract scenes from response
            scenes_data = response_data.get("scenes", [])
            if not scenes_data:
                raise ValueError("No scenes found in AI response")
            
            # Convert to SceneBase objects
            scenes = [SceneBase(**scene_data) for scene_data in scenes_data]
            
            return scenes
            
        except APIError as e:
            raise Exception(f"OpenAI API error: {str(e)}")
        except json.JSONDecodeError as e:
            raise Exception(f"Failed to parse AI response as JSON: {str(e)}")
        except Exception as e:
            raise Exception(f"Failed to generate screenplay: {str(e)}")

