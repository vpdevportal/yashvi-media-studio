"""unfold_generation_metadata_into_separate_columns

Revision ID: 1b815a8df7e3
Revises: 34fb6dc7fe6d
Create Date: 2025-12-22 08:06:49.002390

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = '1b815a8df7e3'
down_revision: Union[str, Sequence[str], None] = '34fb6dc7fe6d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Add new columns
    op.add_column('screenplays', sa.Column('ai_model', sa.String(length=100), nullable=True))
    op.add_column('screenplays', sa.Column('generation_time_seconds', sa.Integer(), nullable=True))
    op.add_column('screenplays', sa.Column('scene_count', sa.Integer(), nullable=True))
    
    # Migrate data from generation_metadata JSON to new columns
    # Using raw SQL to extract JSON values
    # Note: generation_time_seconds may be a decimal, so cast to NUMERIC first, then round to INTEGER
    op.execute("""
        UPDATE screenplays
        SET 
            ai_model = generation_metadata->>'ai_model',
            generation_time_seconds = CAST(ROUND(CAST(generation_metadata->>'generation_time_seconds' AS NUMERIC)) AS INTEGER),
            scene_count = CAST(generation_metadata->>'scene_count' AS INTEGER)
        WHERE generation_metadata IS NOT NULL
    """)
    
    # Remove the generation_metadata column
    op.drop_column('screenplays', 'generation_metadata')


def downgrade() -> None:
    """Downgrade schema."""
    # Add back generation_metadata column
    op.add_column('screenplays', sa.Column('generation_metadata', postgresql.JSON(astext_type=sa.Text()), nullable=True))
    
    # Migrate data back to JSON
    op.execute("""
        UPDATE screenplays
        SET generation_metadata = json_build_object(
            'ai_model', ai_model,
            'generation_time_seconds', generation_time_seconds,
            'scene_count', scene_count
        )
        WHERE ai_model IS NOT NULL OR generation_time_seconds IS NOT NULL OR scene_count IS NOT NULL
    """)
    
    # Remove the new columns
    op.drop_column('screenplays', 'scene_count')
    op.drop_column('screenplays', 'generation_time_seconds')
    op.drop_column('screenplays', 'ai_model')
