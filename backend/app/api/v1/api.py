from fastapi import APIRouter
from app.api.v1.endpoints import auth

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
from app.api.v1.endpoints import users, vehicles, mechanics, services, ai
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(vehicles.router, prefix="/vehicles", tags=["vehicles"])
api_router.include_router(mechanics.router, prefix="/mechanics", tags=["mechanics"])
api_router.include_router(services.router, prefix="/services", tags=["services"])
api_router.include_router(ai.router, prefix="/ai", tags=["ai"])

# Import and include other routers here, e.g.:
# from app.api.v1.endpoints import items
# api_router.include_router(items.router, prefix="/items", tags=["items"])
