from app.db.session import engine
from app.db.base import Base

def init():
    print("Creating tables...")
    Base.metadata.create_all(bind=engine)
    print("Tables created.")
    
    from sqlalchemy.orm import Session
    from app.models.customization import Customization
    
    session = Session(bind=engine)
    
    # Check if customizations exist
    if session.query(Customization).first() is None:
        print("Seeding initial customizations...")
        initial_data = [
            # Colors
            Customization(type="COLOR", value="#FF0000", label="Red"),
            Customization(type="COLOR", value="#0000FF", label="Blue"),
            Customization(type="COLOR", value="#000000", label="Black"),
            Customization(type="COLOR", value="#FFFFFF", label="White"),
            Customization(type="COLOR", value="#C0C0C0", label="Silver"),
            
            # Rims
            Customization(type="RIM", value="16_STEEL", label="16\" Steel"),
            Customization(type="RIM", value="18_ALLOY", label="18\" Alloy"),
            Customization(type="RIM", value="20_PERFORMANCE", label="20\" Performance"),
            
            # Interior
            Customization(type="INTERIOR", value="LEATHER_BLACK", label="Black Leather"),
            Customization(type="INTERIOR", value="FABRIC_GREY", label="Grey Fabric"),
        ]
        session.add_all(initial_data)
        session.commit()
        print("Customizations loaded.")
    else:
        print("Customizations already loaded.")
    session.close()

if __name__ == "__main__":
    init()
