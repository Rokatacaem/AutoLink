"""Add health_score and maintenance_logs

Revision ID: manual_health_maintenance
Revises: 918bd8cdded9
Create Date: 2026-02-02 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'manual_health_maintenance'
down_revision = '918bd8cdded9'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add health_score to vehicle
    op.add_column('vehicle', sa.Column('health_score', sa.Integer(), nullable=True))
    op.execute("UPDATE vehicle SET health_score = 100 WHERE health_score IS NULL")

    # Create maintenance_logs table
    op.create_table('maintenance_logs',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('vehicle_id', sa.Integer(), nullable=False),
        sa.Column('description', sa.String(), nullable=False),
        sa.Column('action_taken', sa.String(), nullable=False),
        sa.Column('score_impact', sa.Integer(), nullable=False),
        sa.Column('timestamp', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.ForeignKeyConstraint(['vehicle_id'], ['vehicle.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_maintenance_logs_id'), 'maintenance_logs', ['id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_maintenance_logs_id'), table_name='maintenance_logs')
    op.drop_table('maintenance_logs')
    op.drop_column('vehicle', 'health_score')
