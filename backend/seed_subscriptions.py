from app.db.session import SessionLocal
import app.db.base # Import all models to prevent SQLAlchemy mapper KeyErrors
from app.models.mechanic import Mechanic
from app.models.subscription import Subscription
from datetime import datetime, timedelta

def initialize_subscriptions():
    db = SessionLocal()
    mechanics = db.query(Mechanic).all()

    for mechanic in mechanics:
        # Check if subscription already exists
        existing_sub = db.query(Subscription).filter(Subscription.mechanic_id == mechanic.id).first()
        if not existing_sub:
            # Initialize with BASIC tier at $10/mo, valid for 30 days
            new_sub = Subscription(
                tier_name="BASIC",
                price_per_month=10.0,
                mechanic_id=mechanic.id,
                valid_until=datetime.utcnow() + timedelta(days=30)
            )
            db.add(new_sub)

    db.commit()
    print(f"Initialized subscriptions for {len(mechanics)} mechanics.")
    db.close()

if __name__ == "__main__":
    initialize_subscriptions()
