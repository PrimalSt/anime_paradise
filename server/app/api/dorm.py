from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlmodel import Session
from typing import List, Dict, Any
from app.core.database import get_session
from app.api.deps import get_current_user
from app.models.schemas import User
from app.services.dorm_service import dorm_service

router = APIRouter(prefix="/dorm", tags=["Dorm"])

class LayoutRequest(BaseModel):
    furniture_layout: List[Dict[str, Any]]

class AssignRequest(BaseModel):
    waifu_ids: List[str]

class ThemeRequest(BaseModel):
    theme: str

@router.get("/")
def get_dorm(
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    dorm = dorm_service.get_or_create_dorm(session, user)
    pending_coins = dorm_service.calculate_pending_income(dorm)
    coins_per_minute = 2 + (dorm.comfort_level * 0.1) + (len(dorm.assigned_waifus) * 1.5)

    return {
        "id": dorm.id,
        "comfort_level": dorm.comfort_level,
        "comfort_tier": dorm_service.get_comfort_tier(dorm.comfort_level),
        "coins_per_minute": round(coins_per_minute, 2),
        "furniture_layout": dorm.furniture_layout,
        "assigned_waifus": dorm.assigned_waifus,
        "pending_coins": pending_coins,
        "theme": getattr(dorm, "theme", "bg_dorm_room") or "bg_dorm_room",
        "last_income_collected": dorm.last_income_collected.isoformat(),
        "last_cleaned": dorm.last_cleaned.isoformat() if getattr(dorm, "last_cleaned", None) else None,
        "max_capacity": 4
    }

@router.post("/collect")
def collect_income(
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    result = dorm_service.collect_income(session, user)
    user.daily_dorm_collects += 1
    session.add(user)
    session.commit()
    return result

@router.post("/layout")
def update_layout(
    req: LayoutRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return dorm_service.update_layout(session, user, req.furniture_layout)

@router.post("/assign")
def assign_waifus(
    req: AssignRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return dorm_service.assign_waifus(session, user, req.waifu_ids)

@router.post("/theme")
def set_theme(
    req: ThemeRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return dorm_service.set_theme(session, user, req.theme)

@router.post("/clean")
def clean_dorm(
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return dorm_service.clean_dorm(session, user)

