"""remove_location_and_time_of_day_add_duration_seconds_to_scenes

Revision ID: 2cd43bfbf3fe
Revises: 90e236a7f546
Create Date: 2025-12-22 02:00:52.408738

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '2cd43bfbf3fe'
down_revision: Union[str, Sequence[str], None] = '90e236a7f546'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Add duration_seconds column
    op.add_column('scenes', sa.Column('duration_seconds', sa.Integer(), nullable=False, server_default='15'))
    
    # Remove location and time_of_day columns
    op.drop_column('scenes', 'location')
    op.drop_column('scenes', 'time_of_day')
    
    # Remove server default after data migration (if needed)
    op.alter_column('scenes', 'duration_seconds', server_default=None)


def downgrade() -> None:
    """Downgrade schema."""
    # Add back location and time_of_day columns
    op.add_column('scenes', sa.Column('location', sa.String(length=255), nullable=False, server_default=''))
    op.add_column('scenes', sa.Column('time_of_day', sa.String(length=50), nullable=False, server_default='DAY'))
    
    # Remove duration_seconds column
    op.drop_column('scenes', 'duration_seconds')
    
    # Remove server defaults
    op.alter_column('scenes', 'location', server_default=None)
    op.alter_column('scenes', 'time_of_day', server_default=None)
