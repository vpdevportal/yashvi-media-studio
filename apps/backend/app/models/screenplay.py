import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSON
from sqlalchemy.orm import relationship

from app.models.project import Base


class Screenplay(Base):
    __tablename__ = "screenplays"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    episode_id = Column(UUID(as_uuid=True), ForeignKey("episodes.id", ondelete="CASCADE"), nullable=False)
    ai_model = Column(String(100), nullable=True)  # AI model used for generation
    generation_time_seconds = Column(Integer, nullable=True)  # Time taken to generate in seconds
    scene_count = Column(Integer, nullable=True)  # Number of scenes generated
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    episode = relationship("Episode", back_populates="screenplays")
    scenes = relationship("Scene", back_populates="screenplay", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Screenplay for episode {self.episode_id}>"


class Scene(Base):
    __tablename__ = "scenes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    screenplay_id = Column(UUID(as_uuid=True), ForeignKey("screenplays.id", ondelete="CASCADE"), nullable=False)
    scene_number = Column(Integer, nullable=False)
    title = Column(String(255), nullable=False)
    duration_seconds = Column(Integer, nullable=False)  # Estimated scene duration in seconds
    characters = Column(JSON, nullable=False)  # Array of character names
    action = Column(Text, nullable=False)  # Scene description
    dialogue = Column(JSON, nullable=False)  # Array of {character, line} objects
    visual_notes = Column(Text, nullable=False)  # For image generation (includes location and time of day)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    screenplay = relationship("Screenplay", back_populates="scenes")

    def __repr__(self):
        return f"<Scene {self.scene_number}: {self.title}>"

