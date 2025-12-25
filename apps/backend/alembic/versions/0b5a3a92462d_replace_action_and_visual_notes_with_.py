"""replace_action_and_visual_notes_with_prompt

Revision ID: 0b5a3a92462d
Revises: 1b815a8df7e3
Create Date: 2025-12-25 20:06:02.835777

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0b5a3a92462d'
down_revision: Union[str, Sequence[str], None] = '1b815a8df7e3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema: Replace action and visual_notes columns with prompt column."""
    # Add new prompt column
    op.add_column('scenes', sa.Column('prompt', sa.Text(), nullable=True))
    
    # Migrate data: Combine action and visual_notes into prompt
    # For existing rows, combine action and visual_notes
    op.execute("""
        UPDATE scenes 
        SET prompt = COALESCE(action, '') || ' ' || COALESCE(visual_notes, '')
        WHERE prompt IS NULL
    """)
    
    # Make prompt non-nullable after data migration
    op.alter_column('scenes', 'prompt', nullable=False)
    
    # Drop old columns
    op.drop_column('scenes', 'action')
    op.drop_column('scenes', 'visual_notes')


def downgrade() -> None:
    """Downgrade schema: Restore action and visual_notes columns from prompt."""
    # Add back action and visual_notes columns
    op.add_column('scenes', sa.Column('action', sa.Text(), nullable=True))
    op.add_column('scenes', sa.Column('visual_notes', sa.Text(), nullable=True))
    
    # Split prompt back into action and visual_notes (simple split - may lose some data)
    # This is a best-effort restoration
    op.execute("""
        UPDATE scenes 
        SET action = SUBSTRING(prompt FROM 1 FOR LENGTH(prompt) / 2),
            visual_notes = SUBSTRING(prompt FROM LENGTH(prompt) / 2 + 1)
        WHERE prompt IS NOT NULL
    """)
    
    # Make columns non-nullable
    op.alter_column('scenes', 'action', nullable=False)
    op.alter_column('scenes', 'visual_notes', nullable=False)
    
    # Drop prompt column
    op.drop_column('scenes', 'prompt')
