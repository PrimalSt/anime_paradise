from pydantic_settings import BaseSettings, SettingsConfigDict
from pathlib import Path

class Settings(BaseSettings):
    model_config = SettingsConfigDict(case_sensitive=True)

    PROJECT_NAME: str = "Anime Paradise API"
    VERSION: str = "0.1.0"
    API_PREFIX: str = "/api"
    
    SECRET_KEY: str = "anime_paradise_super_secret_jwt_key_2026_change_in_prod"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    BASE_DIR: Path = Path(__file__).resolve().parent.parent
    DATA_DIR: Path = BASE_DIR / "data"
    DATABASE_URL: str = f"sqlite:///{BASE_DIR}/anime_paradise.db"
    
    # Game Economy Defaults
    STARTING_COINS: int = 1500
    STARTING_LOVE_GEMS: int = 50
    STARTING_SOUL_SHARDS: int = 0

settings = Settings()
