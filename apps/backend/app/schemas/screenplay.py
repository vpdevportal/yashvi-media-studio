from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List, Dict
from uuid import UUID


class SceneBase(BaseModel):
    """Base scene schema with all scene fields."""
    scene_number: int
    title: str
    location: str
    time_of_day: str  # DAY/NIGHT
    characters: List[str]
    action: str  # Scene description
    dialogue: List[Dict[str, str]]  # Array of {character, line} objects
    visual_notes: str  # For image generation


class SceneCreate(SceneBase):
    """Schema for creating a scene (includes screenplay_id)."""
    screenplay_id: UUID


class SceneResponse(SceneBase):
    """Schema for scene response (includes id and timestamps)."""
    id: UUID
    screenplay_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ScreenplayBase(BaseModel):
    """Base screenplay schema."""
    status: str = "pending"  # pending, generating, completed, failed
    generation_metadata: Optional[Dict] = None


class ScreenplayCreate(ScreenplayBase):
    """Schema for creating a screenplay."""
    episode_id: UUID


class ScreenplayResponse(ScreenplayBase):
    """Schema for screenplay response (includes id, episode_id, scenes, and timestamps)."""
    id: UUID
    episode_id: UUID
    scenes: List[SceneResponse]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

