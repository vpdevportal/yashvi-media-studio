from uuid import UUID
from typing import Optional
from sqlalchemy.orm import Session
from app.repositories.project import ProjectRepository
from app.models.project import Project
from app.schemas.project import ProjectCreate, ProjectUpdate


class ProjectService:
    def __init__(self, db: Session):
        self.repository = ProjectRepository(db)

    def get_projects(self, skip: int = 0, limit: int = 100) -> list[Project]:
        return self.repository.get_all(skip=skip, limit=limit)

    def get_project(self, project_id: UUID) -> Optional[Project]:
        return self.repository.get_by_id(project_id)

    def create_project(self, project_data: ProjectCreate) -> Project:
        return self.repository.create(project_data)

    def update_project(self, project_id: UUID, project_data: ProjectUpdate) -> Optional[Project]:
        return self.repository.update(project_id, project_data)

    def delete_project(self, project_id: UUID) -> bool:
        return self.repository.delete(project_id)

