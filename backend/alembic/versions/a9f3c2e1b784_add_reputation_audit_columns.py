"""Add reputation_score and audit_summary columns

Revision ID: a9f3c2e1b784
Revises: ed88fe0b364e
Create Date: 2026-02-25 19:55:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a9f3c2e1b784'
down_revision: Union[str, Sequence[str], None] = 'ed88fe0b364e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add reputation engine columns to mechanic and audit_summary to servicefeedback."""

    # --- Mechanic: Reputation Engine ---
    with op.batch_alter_table('mechanic', schema=None) as batch_op:
        batch_op.add_column(sa.Column(
            'reputation_score', sa.Float(), nullable=False, server_default='5.0'
        ))
        batch_op.add_column(sa.Column(
            'total_jobs_completed', sa.Integer(), nullable=False, server_default='0'
        ))

    # --- ServiceFeedback: AI Audit Summary ---
    with op.batch_alter_table('servicefeedback', schema=None) as batch_op:
        batch_op.add_column(sa.Column(
            'audit_summary', sa.Text(), nullable=True
        ))


def downgrade() -> None:
    """Remove reputation engine columns."""
    with op.batch_alter_table('servicefeedback', schema=None) as batch_op:
        batch_op.drop_column('audit_summary')

    with op.batch_alter_table('mechanic', schema=None) as batch_op:
        batch_op.drop_column('total_jobs_completed')
        batch_op.drop_column('reputation_score')
