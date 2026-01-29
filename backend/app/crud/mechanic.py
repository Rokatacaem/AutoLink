from typing import List, Optional

from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.mechanic import Mechanic
from app.schemas.mechanic import MechanicCreate, MechanicUpdate

class CRUDMechanic(CRUDBase[Mechanic, MechanicCreate, MechanicUpdate]):
    def create_with_owner(
        self, db: Session, *, obj_in: MechanicCreate, owner_id: int
    ) -> Mechanic:
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.model(**obj_in_data, owner_id=owner_id)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_by_owner(
        self, db: Session, *, owner_id: int
    ) -> Optional[Mechanic]:
        return (
            db.query(self.model)
            .filter(Mechanic.owner_id == owner_id)
            .first()
        )

mechanic = CRUDMechanic(Mechanic)
