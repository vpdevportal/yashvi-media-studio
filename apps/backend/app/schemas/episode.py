from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from uuid import UUID


class EpisodeBase(BaseModel):
    title: str
    description: Optional[str] = None
    episode_number: int
    status: str = "draft"


class EpisodeCreate(EpisodeBase):
    project_id: UUID


class EpisodeUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    episode_number: Optional[int] = None
    status: Optional[str] = None


class EpisodeResponse(EpisodeBase):
    id: UUID
    project_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

