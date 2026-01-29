import os

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "AutoLink"
    
    # Security
    SECRET_KEY: str = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"  # Change in production!
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Database
    # Vercel/Neon provides POSTGRES_URL or DATABASE_URL. We check both.
    DATABASE_URL: str = os.getenv("POSTGRES_URL") or os.getenv("DATABASE_URL") or "sqlite:///./autolink.db"
    
    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
