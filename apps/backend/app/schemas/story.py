from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from uuid import UUID


class StoryBase(BaseModel):
    content: Optional[str] = None


class StoryCreate(StoryBase):
    episode_id: UUID


class StoryUpdate(BaseModel):
    content: Optional[str] = None


class StoryResponse(StoryBase):
    id: UUID
    episode_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

