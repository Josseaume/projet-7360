from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from app.api.deps import CurrentUser, DbSession
from app.models import Item
from app.schemas import ItemIn, ItemOut, ItemUpdate

router = APIRouter(prefix="/items", tags=["items"])


def _get_owned(db: DbSession, user: CurrentUser, item_id: int) -> Item:
    item = db.get(Item, item_id)
    # 404 aussi si l'item appartient à quelqu'un d'autre : on ne révèle pas son existence.
    if item is None or item.owner_id != user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Introuvable")
    return item


@router.get("", response_model=list[ItemOut])
def list_items(
    user: CurrentUser, db: DbSession, skip: int = 0, limit: int = 50
) -> list[Item]:
    stmt = (
        select(Item)
        .where(Item.owner_id == user.id)
        .order_by(Item.created_at.desc(), Item.id.desc())
        .offset(skip)
        .limit(min(limit, 100))
    )
    return list(db.scalars(stmt))


@router.post("", response_model=ItemOut, status_code=status.HTTP_201_CREATED)
def create_item(data: ItemIn, user: CurrentUser, db: DbSession) -> Item:
    item = Item(**data.model_dump(), owner_id=user.id)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.get("/{item_id}", response_model=ItemOut)
def read_item(item_id: int, user: CurrentUser, db: DbSession) -> Item:
    return _get_owned(db, user, item_id)


@router.patch("/{item_id}", response_model=ItemOut)
def update_item(
    item_id: int, data: ItemUpdate, user: CurrentUser, db: DbSession
) -> Item:
    item = _get_owned(db, user, item_id)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(item, field, value)
    db.commit()
    db.refresh(item)
    return item


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(item_id: int, user: CurrentUser, db: DbSession) -> None:
    db.delete(_get_owned(db, user, item_id))
    db.commit()
