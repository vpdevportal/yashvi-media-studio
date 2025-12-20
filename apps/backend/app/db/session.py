from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
import os

# Require DATABASE_URL environment variable
if not settings.DATABASE_URL:
    raise ValueError(
        "DATABASE_URL environment variable is required. "
        "Please set it in your deployment environment (e.g., Coolify environment variables)."
    )

DATABASE_URL = settings.DATABASE_URL.replace("postgres://", "postgresql+psycopg://")

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

