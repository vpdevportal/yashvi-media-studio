from uuid import UUID
from typing import Optional
from sqlalchemy.orm import Session
from app.models.project import Project
from app.schemas.project import ProjectCreate, ProjectUpdate


class ProjectRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all(self, skip: int = 0, limit: int = 100) -> list[Project]:
        return (
            self.db.query(Project)
            .order_by(Project.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_by_id(self, project_id: UUID) -> Optional[Project]:
        return self.db.query(Project).filter(Project.id == project_id).first()

    def create(self, project_data: ProjectCreate) -> Project:
        project = Project(**project_data.model_dump())
        self.db.add(project)
        self.db.commit()
        self.db.refresh(project)
        return project

    def update(self, project_id: UUID, project_data: ProjectUpdate) -> Optional[Project]:
        project = self.get_by_id(project_id)
        if not project:
            return None
        
        update_data = project_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(project, key, value)
        
        self.db.commit()
        self.db.refresh(project)
        return project

    def delete(self, project_id: UUID) -> bool:
        project = self.get_by_id(project_id)
        if not project:
            return False
        
        self.db.delete(project)
        self.db.commit()
        return True

