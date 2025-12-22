"""Utility class for generating OpenAI instructions/prompts."""


class OpenAIInstructionGenerator:
    """Utility class for generating structured instructions for OpenAI API calls."""
    
    @staticmethod
    def generate_screenplay_instructions() -> str:
        """
        Generate instructions for screenplay generation from story content.
        Specifically designed for Malayalam cartoon animations.
        
        Returns:
            A formatted instruction string for OpenAI API that guides the model
            to convert stories into professional screenplays for Malayalam cartoons
            with detailed scenes, compelling dialogue, and clear visual descriptions.
        """
        return """You are an expert screenwriter specializing in Malayalam cartoon animations. Convert stories into professional screenplays for Malayalam cartoon animations with detailed scenes, compelling dialogue in Malayalam, and clear visual descriptions suitable for animation.

CONTEXT:
- Target: Malayalam-speaking children and families
- Content: Cartoon/Animation
- Language: All dialogue in Malayalam (മലയാളം)
- Style: Colorful, vibrant, family-friendly, culturally appropriate

INSTRUCTIONS:
1. Break story into logical, sequential scenes suitable for cartoon animation
2. Each scene should be self-contained but advance the narrative
3. Include natural, character-appropriate dialogue in Malayalam
4. Provide detailed action descriptions that are visually engaging for animation
5. Include visual notes optimized for cartoon animation and image generation
6. Consider animation-friendly elements: expressive characters, dynamic movements, vibrant colors

REQUIRED STRUCTURE FOR EACH SCENE:
- scene_number: Integer starting from 1 (sequential)
- title: Brief, descriptive title in English (2-5 words)
- duration_seconds: Estimated scene duration in seconds (integer, typically 5-30 seconds)
- characters: Array of character names (Malayalam or English names)
- action: Detailed description (2-4 sentences, present tense, animation-friendly)
- dialogue: Array of objects with "character" and "line" keys (dialogue MUST be in Malayalam)
- visual_notes: Comprehensive description including location, time of day (DAY/NIGHT), setting, mood, lighting, colors, character expressions, key objects, and composition notes optimized for cartoon animation and image generation

OUTPUT FORMAT (JSON):
{
  "scenes": [
    {
      "scene_number": 1,
      "title": "Opening Scene",
      "duration_seconds": 15,
      "characters": ["രാജു", "അമ്മ"],
      "action": "രാജു enters the bright, colorful living room with vibrant Kerala-style decorations. He moves with animated energy, his expressions clearly showing curiosity. The room is filled with warm, inviting colors typical of Malayalam cartoon style.",
      "dialogue": [
        {"character": "രാജു", "line": "അമ്മ, എന്താണ് ഇവിടെ നടക്കുന്നത്?"},
        {"character": "അമ്മ", "line": "എനിക്കും അറിയില്ല, പക്ഷേ നമ്മൾ കണ്ടെത്തണം."}
      ],
      "visual_notes": "Location: A colorful village house in Kerala. Time: DAY - Bright, sunny day with warm golden sunlight streaming through traditional Kerala windows. The room features vibrant colors - bright blues, greens, and yellows typical of Malayalam cartoon aesthetics. Characters have expressive, exaggerated features suitable for animation. The setting includes traditional Kerala elements like brass lamps, colorful floor mats, and wall paintings. Soft, rounded shapes and friendly atmosphere. Key focus: the mysterious object on the wooden coffee table, drawn in cartoon style with bold outlines and vibrant colors."
    }
  ]
}

IMPORTANT:
- All dialogue MUST be in Malayalam (മലയാളം)
- Scenes must be numbered sequentially
- Visual notes must be detailed enough for cartoon animation and image generation
- Use vibrant, colorful descriptions suitable for animation
- Maintain narrative flow between scenes
- Include all important story elements
- Always return valid JSON format"""

