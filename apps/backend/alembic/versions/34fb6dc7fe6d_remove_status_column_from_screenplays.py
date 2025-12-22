"""remove_status_column_from_screenplays

Revision ID: 34fb6dc7fe6d
Revises: 2cd43bfbf3fe
Create Date: 2025-12-22 06:42:08.080686

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '34fb6dc7fe6d'
down_revision: Union[str, Sequence[str], None] = '2cd43bfbf3fe'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Remove status column from screenplays table
    op.drop_column('screenplays', 'status')


def downgrade() -> None:
    """Downgrade schema."""
    # Add back status column with default value
    op.add_column('screenplays', sa.Column('status', sa.String(length=50), nullable=False, server_default='pending'))
    op.alter_column('screenplays', 'status', server_default=None)
