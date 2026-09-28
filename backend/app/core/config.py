from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuration lue depuis les variables d'environnement / le fichier .env."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "7360 API"
    api_prefix: str = "/api/v1"
    cors_origins: str = "*"

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


settings = Settings()
