"""remove_unique_constraint_from_screenplays_episode_id

Revision ID: 90e236a7f546
Revises: e01ed17b60e9
Create Date: 2025-12-21 23:30:15.031130

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '90e236a7f546'
down_revision: Union[str, Sequence[str], None] = 'e01ed17b60e9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Remove unique constraint from screenplays.episode_id to allow multiple screenplays per episode
    op.drop_constraint('screenplays_episode_id_key', 'screenplays', type_='unique')


def downgrade() -> None:
    """Downgrade schema."""
    # Re-add unique constraint on screenplays.episode_id
    op.create_unique_constraint('screenplays_episode_id_key', 'screenplays', ['episode_id'])
