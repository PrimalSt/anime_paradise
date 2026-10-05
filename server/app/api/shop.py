from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlmodel import Session, select
from typing import List, Dict, Any
from app.core.database import get_session
from app.api.deps import get_current_user
from app.models.schemas import User, UserInventory
from app.services.catalog_service import catalog

router = APIRouter(prefix="/shop", tags=["Shop"])

class BuyRequest(BaseModel):
    item_id: str
    quantity: int = 1

@router.get("/catalog")
def get_shop_catalog():
    return {
        "items": list(catalog.items.values()),
        "furniture": list(catalog.furniture.values())
    }

@router.get("/inventory")
def get_user_inventory(
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    stmt = select(UserInventory).where(UserInventory.user_id == user.id)
    records = session.exec(stmt).all()
    results = []
    for r in records:
        info = catalog.get_item(r.item_id) or catalog.get_furniture(r.item_id)
        results.append({
            "id": r.id,
            "item_id": r.item_id,
            "item_type": r.item_type,
            "quantity": r.quantity,
            "details": info
        })
    return results

@router.post("/buy")
def buy_item(
    req: BuyRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    if req.quantity <= 0:
        req.quantity = 1

    item_info = catalog.get_item(req.item_id)
    is_furniture = False
    if not item_info:
        item_info = catalog.get_furniture(req.item_id)
        is_furniture = True

    if not item_info:
        raise HTTPException(status_code=404, detail="Товар не найден в магазине")

    price_total = item_info.get("price", 100) * req.quantity
    currency = item_info.get("currency", "coins")

    if currency == "coins":
        if user.coins < price_total:
            raise HTTPException(status_code=400, detail="Недостаточно монет")
        user.coins -= price_total
    elif currency == "love_gems":
        if user.love_gems < price_total:
            raise HTTPException(status_code=400, detail="Недостаточно кристаллов любви")
        user.love_gems -= price_total
    else:
        raise HTTPException(status_code=400, detail="Неверная валюта товара")

    # Add to inventory
    inv_stmt = select(UserInventory).where(
        UserInventory.user_id == user.id,
        UserInventory.item_id == req.item_id
    )
    existing_item = session.exec(inv_stmt).first()
    if existing_item:
        existing_item.quantity += req.quantity
        session.add(existing_item)
    else:
        new_inv = UserInventory(
            user_id=user.id,
            item_id=req.item_id,
            item_type="furniture" if is_furniture else item_info.get("type", "food"),
            quantity=req.quantity
        )
        session.add(new_inv)

    session.add(user)
    session.commit()
    session.refresh(user)

    return {
        "success": True,
        "item_id": req.item_id,
        "quantity": req.quantity,
        "new_balance": {
            "coins": user.coins,
            "love_gems": user.love_gems
        }
    }
