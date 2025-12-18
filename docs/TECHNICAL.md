# Yashvi Media Studio - Technical Documentation

## Architecture Overview

This project uses a **Turborepo** monorepo structure with:

- **Frontend/Mobile**: Flutter (cross-platform - iOS, Android, Web, Desktop)
- **Backend**: FastAPI (Python)

## Project Structure

```
yashvi-media-studio/
├── apps/
│   ├── frontend/           # Flutter frontend (iOS, Android, Web, Desktop)
│   └── backend/            # FastAPI backend (see Backend Architecture below)
├── packages/               # Shared packages (if needed)
├── docs/                   # Documentation
├── turbo.json              # Turborepo configuration
├── package.json            # Root package.json for Turborepo
├── Dockerfile              # Production Docker image
├── .env                    # Environment variables
└── README.md
```

## Backend Architecture

The backend follows a clean layered architecture pattern:

```
apps/backend/
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── endpoints/
│   │       │   ├── health.py       # Health check endpoints
│   │       │   └── projects.py     # Project CRUD endpoints
│   │       └── router.py           # API router
│   ├── core/
│   │   └── config.py               # Settings/configuration
│   ├── db/
│   │   ├── base.py                 # Base model exports
│   │   └── session.py              # Database session management
│   ├── models/
│   │   └── project.py              # SQLAlchemy ORM models
│   ├── repositories/
│   │   └── project.py              # Data access layer
│   ├── schemas/
│   │   └── project.py              # Pydantic request/response schemas
│   ├── services/
│   │   └── project.py              # Business logic layer
│   └── main.py                     # FastAPI app entry point
├── requirements.txt
└── package.json
```

### Layer Responsibilities

| Layer | Purpose |
|-------|---------|
| **API (endpoints)** | HTTP request handling, routing, input validation |
| **Services** | Business logic, orchestration |
| **Repositories** | Data access, database operations |
| **Models** | SQLAlchemy ORM entity definitions |
| **Schemas** | Pydantic DTOs for API request/response |
| **Core** | Configuration, settings, utilities |

## Technology Stack

### Frontend - Flutter
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: TBD (Riverpod/Bloc/Provider)
- **Platforms**: iOS, Android, Web, macOS, Windows, Linux

### Backend - FastAPI
- **Framework**: FastAPI
- **Language**: Python 3.13+
- **Database**: PostgreSQL
- **ORM**: SQLAlchemy 2.0
- **Database Driver**: psycopg3
- **Validation**: Pydantic v2
- **Authentication**: JWT-based auth (TBD)

## Getting Started

### Prerequisites
- Node.js 18+ (for Turborepo)
- Flutter SDK 3.x
- Python 3.11+
- pnpm (recommended) or npm

### Installation

```bash
# Install dependencies
pnpm install

# Run all apps in development
pnpm dev

# Run specific app
pnpm dev --filter=frontend
pnpm dev --filter=backend
```

### Flutter App Setup

```bash
cd apps/frontend
flutter pub get
flutter run
```

### FastAPI Setup

```bash
cd apps/backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Turborepo Commands

| Command | Description |
|---------|-------------|
| `pnpm build` | Build all apps |
| `pnpm dev` | Start all apps in dev mode |
| `pnpm lint` | Lint all apps |
| `pnpm test` | Run tests across all apps |

## API Documentation

FastAPI provides automatic API documentation:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Environment Variables

### Backend (.env)
```
DATABASE_URL=postgresql://user:pass@localhost:5432/yashvi_media
SECRET_KEY=your-secret-key
DEBUG=true
```

### Flutter (.env)
```
API_BASE_URL=http://localhost:8000
```

## Development Workflow

1. Create feature branch from `main`
2. Make changes in respective app directory
3. Run `pnpm lint` and `pnpm test`
4. Submit PR for review

## Deployment

TBD - Add deployment instructions for:
- Flutter apps (App Store, Play Store, Web hosting)
- FastAPI backend (Docker, cloud providers)


