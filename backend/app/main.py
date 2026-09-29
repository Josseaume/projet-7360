import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import models  # noqa: F401  (enregistre les tables sur Base.metadata)
from app.api.router import api_router
from app.core.config import settings
from app.db import Base, engine


@asynccontextmanager
async def lifespan(_: FastAPI):
    # Suffisant pour démarrer. Passer à Alembic dès que le schéma doit évoluer
    # sans perdre les données.
    Base.metadata.create_all(bind=engine)
    if settings.secret_key == "change-me":
        logging.getLogger("uvicorn.error").warning(
            "SECRET_KEY par défaut utilisée : à changer avant toute mise en production !"
        )
    yield


app = FastAPI(title=settings.app_name, lifespan=lifespan)

# Nécessaire pour que Flutter Web (autre port/origine) puisse appeler l'API.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.api_prefix)


@app.get("/")
def root() -> dict[str, str]:
    return {"message": f"Bienvenue sur {settings.app_name}", "docs": "/docs"}
