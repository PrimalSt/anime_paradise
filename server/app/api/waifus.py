from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlmodel import Session, select
from typing import List, Dict, Any
from app.core.database import get_session
from app.api.deps import get_current_user
from app.models.schemas import User, UserWaifu
from app.services.catalog_service import catalog
from app.services.waifu_service import waifu_service

router = APIRouter(prefix="/waifus", tags=["Waifus"])

class FeedRequest(BaseModel):
    item_id: str

class EquipOutfitRequest(BaseModel):
    outfit_id: str

class UnlockOutfitRequest(BaseModel):
    outfit_id: str
    cost: int = 50

class ClaimMilestoneRequest(BaseModel):
    milestone_level: int

@router.get("/catalog")
def get_full_catalog():
    return list(catalog.characters.values())

@router.get("/")
def get_user_waifus(
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    stmt = select(UserWaifu).where(UserWaifu.user_id == user.id)
    records = session.exec(stmt).all()
    results = []

    for w in records:
        template = catalog.get_character(w.character_id)
        results.append({
            "id": w.id,
            "character_id": w.character_id,
            "stars": w.stars,
            "affection_points": w.affection_points,
            "affection_level": w.affection_level,
            "is_favorite": bool(w.is_favorite),
            "claimed_milestones": w.claimed_milestones,
            "hunger": w.hunger,
            "mood": w.mood,
            "current_outfit_id": w.current_outfit_id,
            "unlocked_outfits": w.unlocked_outfits,
            "cgs_unlocked": w.cgs_unlocked,
            "dates_completed": w.dates_completed,
            "last_fed": w.last_fed.isoformat() if w.last_fed else None,
            "last_headpat": w.last_headpat.isoformat() if w.last_headpat else None,
            "obtained_at": w.obtained_at.isoformat(),
            "template": template
        })
    return results

@router.post("/{waifu_id}/headpat")
def headpat_waifu(
    waifu_id: int,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return waifu_service.headpat(session, user, waifu_id)

@router.post("/{waifu_id}/feed")
def feed_waifu(
    waifu_id: int,
    req: FeedRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return waifu_service.feed(session, user, waifu_id, req.item_id)

@router.post("/{waifu_id}/equip-outfit")
def equip_outfit(
    waifu_id: int,
    req: EquipOutfitRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return waifu_service.equip_outfit(session, user, waifu_id, req.outfit_id)

@router.post("/{waifu_id}/unlock-outfit")
def unlock_outfit(
    waifu_id: int,
    req: UnlockOutfitRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return waifu_service.unlock_outfit_with_shards(session, user, waifu_id, req.outfit_id, req.cost)

@router.post("/{waifu_id}/favorite")
def toggle_favorite(
    waifu_id: int,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return waifu_service.toggle_favorite(session, user, waifu_id)

@router.post("/{waifu_id}/ascend")
def ascend_waifu(
    waifu_id: int,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return waifu_service.ascend_waifu(session, user, waifu_id)

@router.post("/{waifu_id}/claim-milestone")
def claim_milestone(
    waifu_id: int,
    req: ClaimMilestoneRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return waifu_service.claim_milestone(session, user, waifu_id, req.milestone_level)
