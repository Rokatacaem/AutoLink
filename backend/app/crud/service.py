from typing import List

from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.service import ServiceRequest
from app.schemas.service import ServiceRequestCreate, ServiceRequestUpdate

class CRUDServiceRequest(CRUDBase[ServiceRequest, ServiceRequestCreate, ServiceRequestUpdate]):
    def create_with_customer(
        self, db: Session, *, obj_in: ServiceRequestCreate, customer_id: int
    ) -> ServiceRequest:
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.model(**obj_in_data, customer_id=customer_id)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_multi_by_customer(
        self, db: Session, *, customer_id: int, skip: int = 0, limit: int = 100
    ) -> List[ServiceRequest]:
        return (
            db.query(self.model)
            .filter(ServiceRequest.customer_id == customer_id)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_multi_by_mechanic(
        self, db: Session, *, mechanic_id: int, skip: int = 0, limit: int = 100
    ) -> List[ServiceRequest]:
        return (
            db.query(self.model)
            .filter(ServiceRequest.mechanic_id == mechanic_id)
            .offset(skip)
            .limit(limit)
            .all()
        )

service = CRUDServiceRequest(ServiceRequest)
