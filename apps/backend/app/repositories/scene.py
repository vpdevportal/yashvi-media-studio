from sqlalchemy.orm import Session
from sqlalchemy import select
from typing import Optional, List
from uuid import UUID

from app.models.screenplay import Scene
from app.schemas.screenplay import SceneCreate, SceneBase


class SceneRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_screenplay_id(self, screenplay_id: UUID) -> List[Scene]:
        result = self.db.execute(
            select(Scene).where(Scene.screenplay_id == screenplay_id).order_by(Scene.scene_number)
        )
        return list(result.scalars().all())

    def get_by_id(self, scene_id: UUID) -> Optional[Scene]:
        result = self.db.execute(
            select(Scene).where(Scene.id == scene_id)
        )
        return result.scalar_one_or_none()

    def create(self, scene_data: SceneCreate) -> Scene:
        scene = Scene(**scene_data.model_dump())
        self.db.add(scene)
        self.db.commit()
        self.db.refresh(scene)
        return scene

    def create_batch(self, scenes_data: List[SceneCreate]) -> List[Scene]:
        """Bulk insert scenes for a screenplay."""
        scenes = [Scene(**scene_data.model_dump()) for scene_data in scenes_data]
        self.db.add_all(scenes)
        self.db.commit()
        for scene in scenes:
            self.db.refresh(scene)
        return scenes

    def update(self, scene_id: UUID, scene_data: SceneBase) -> Optional[Scene]:
        scene = self.get_by_id(scene_id)
        if not scene:
            return None
        
        update_data = scene_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(scene, field, value)
        
        self.db.commit()
        self.db.refresh(scene)
        return scene

    def delete(self, scene_id: UUID) -> bool:
        scene = self.get_by_id(scene_id)
        if not scene:
            return False
        
        self.db.delete(scene)
        self.db.commit()
        return True

