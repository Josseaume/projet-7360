from fastapi import APIRouter

router = APIRouter(tags=["health"])


@router.get("/health")
def health() -> dict[str, str]:
    """Permet à l'app Flutter (et au monitoring) de vérifier que l'API répond."""
    return {"status": "ok"}
