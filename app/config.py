"""
Application configuration from environment variables.
"""

import os
from typing import Optional
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

# Determine environment and load appropriate .env file
env = os.getenv("ENVIRONMENT", "development")

# Load environment-specific .env file if it exists
env_file_map = {
    "production": ".env.production",
    "staging": ".env.staging",
    "test": ".env.test",
    "development": ".env.local",
}

env_file = env_file_map.get(env, ".env")

# Try to load environment-specific file, fallback to .env
if os.path.exists(env_file):
    load_dotenv(env_file)
else:
    # Fallback to .env if specific file doesn't exist
    load_dotenv(".env", override=False)


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Supabase Configuration
    supabase_url: str
    supabase_anon_key: str
    supabase_service_role_key: str
    supabase_jwt_secret: str
    supabase_db_url: Optional[str] = None
    supabase_db_password: Optional[str] = None
    supabase_access_token: Optional[str] = None
    
    # JWT Configuration
    jwt_secret_key: str
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 15
    jwt_refresh_token_expire_days: int = 7
    
    # Application Configuration
    environment: str = "development"
    debug: str = "false"
    api_version: str = "v1"
    
    # CORS Configuration
    cors_origins: str = os.getenv("CORS_ORIGINS", ["http://localhost:5173, http://localhost:3000", "timelesslove.ai"])
    
    # Media Processing Configuration
    media_max_file_size_mb: int = 50
    media_max_memory_size_mb: int = 200
    media_thumbnail_size: int = 400
    media_upload_url_expires_seconds: int = 300
    media_access_url_expires_seconds: int = 3600
    
    # Storage Configuration
    storage_bucket_name: str = "memories"
    
    # Cloudflare Tunnel
    cloudflare_tunnel_token: Optional[str] = None
    
    @property
    def is_debug(self) -> bool:
        """Check if debug mode is enabled."""
        return self.debug.lower() == "true"
    
    @property
    def cors_origins_list(self) -> list[str]:
        """Get CORS origins as a list."""
        return [origin.strip() for origin in self.cors_origins.split(",")]
    
    model_config = {
        "env_file": ".env",  # Pydantic will also check this
        "case_sensitive": False,
        "extra": "ignore",
    }


# Global settings instance
_settings: Optional[Settings] = None


def get_settings() -> Settings:
    """Get or create settings instance."""
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings