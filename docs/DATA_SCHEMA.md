# Data Schema

## Overview

The data model is centered around **Projects**, which contain **Episodes** and **Characters**.

## Entity Relationship

```
Project (1) ──── (N) Episode
   │
   └──── (N) Character
```

## Models

### Project

The main entity representing a media production.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| name | String | Project title |
| description | String? | Optional project description |
| status | Enum | `draft`, `in_progress`, `completed`, `archived` |
| created_at | DateTime | Creation timestamp |
| updated_at | DateTime | Last update timestamp |

### Episode

An episode belongs to a single project.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| project_id | UUID | Foreign key to Project |
| title | String | Episode title |
| episode_number | Integer | Episode sequence number |
| description | String? | Optional episode description |
| duration | Integer? | Duration in seconds |
| status | Enum | `draft`, `in_production`, `review`, `published` |
| created_at | DateTime | Creation timestamp |
| updated_at | DateTime | Last update timestamp |

### Character

A character belongs to a single project and can appear in multiple episodes.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| project_id | UUID | Foreign key to Project |
| name | String | Character name |
| description | String? | Character background/description |
| avatar_url | String? | URL to character image |
| voice_id | String? | Reference to voice profile |
| created_at | DateTime | Creation timestamp |
| updated_at | DateTime | Last update timestamp |

## Relationships

- **Project → Episodes**: One-to-many. A project has one or more episodes.
- **Project → Characters**: One-to-many. A project has multiple characters.
- **Episode ↔ Character**: Many-to-many (optional). Characters can appear in specific episodes.

