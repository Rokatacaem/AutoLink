"""make password nullable

Revision ID: 123456789abc
Revises: e7bf638
Create Date: 2026-02-03 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '123456789abc'
down_revision = 'manual_health_maintenance_add_health_and_logs' # Assuming this is the latest applied or 'head'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Make hashed_password nullable
    op.alter_column('user', 'hashed_password',
               existing_type=sa.VARCHAR(),
               nullable=True)


def downgrade() -> None:
    # CAUTION: This might fail if there are users with null passwords
    op.alter_column('user', 'hashed_password',
               existing_type=sa.VARCHAR(),
               nullable=False)
