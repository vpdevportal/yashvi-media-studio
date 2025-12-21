import json
from typing import List
from openai import AsyncOpenAI
from openai import APIError

from app.core.config import get_settings
from app.services.ai.base_ai_service import BaseAIService
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
        instructions = self._create_system_prompt()
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
    
    def _create_system_prompt(self) -> str:
        """
        Create the system prompt (instructions) for screenplay generation.
        This contains all the instructions and format requirements.
        """
        return """You are an expert screenwriter with years of experience in film and television. Your task is to convert stories into professional, well-structured screenplays with detailed scenes, compelling dialogue, and clear visual descriptions.

INSTRUCTIONS:
1. Break the story into logical, sequential scenes
2. Each scene should be self-contained but advance the narrative
3. Include natural, character-appropriate dialogue
4. Provide detailed action descriptions that set the scene
5. Include visual notes that describe the setting, mood, and key visual elements for image generation

REQUIRED STRUCTURE FOR EACH SCENE:
- scene_number: Integer starting from 1 (sequential)
- title: Brief, descriptive title for the scene (2-5 words)
- location: Specific location where the scene takes place
- time_of_day: Either "DAY" or "NIGHT" (uppercase)
- characters: Array of character names appearing in this scene
- action: Detailed description of what happens (2-4 sentences, present tense)
- dialogue: Array of dialogue objects, each with "character" and "line" keys
- visual_notes: Comprehensive visual description including setting, mood, lighting, key objects, and composition notes for image generation

OUTPUT FORMAT (JSON):
{
  "scenes": [
    {
      "scene_number": 1,
      "title": "Opening Scene",
      "location": "A cozy living room",
      "time_of_day": "DAY",
      "characters": ["Protagonist", "Supporting Character"],
      "action": "The protagonist enters the room and notices something unusual. They approach cautiously, examining the details.",
      "dialogue": [
        {"character": "Protagonist", "line": "What's going on here?"},
        {"character": "Supporting Character", "line": "I'm not sure, but we need to find out."}
      ],
      "visual_notes": "Warm afternoon sunlight streams through large windows. The room is furnished with vintage furniture. A sense of mystery and tension. Soft shadows create depth. Key focus: the unusual object on the coffee table."
    }
  ]
}

IMPORTANT:
- Ensure all scenes are numbered sequentially
- Make dialogue natural and character-appropriate
- Visual notes should be detailed enough for image generation AI
- Maintain narrative flow between scenes
- Include all important story elements
- Always return valid JSON format"""

