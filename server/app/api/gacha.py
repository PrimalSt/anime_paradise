from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from sqlmodel import Session, select
from typing import List, Dict, Any
from app.core.database import get_session
from app.api.deps import get_current_user
from app.models.schemas import User, UserPity
from app.services.gacha_service import gacha_service
from app.services.catalog_service import catalog

router = APIRouter(prefix="/gacha", tags=["Gacha"])

class RollRequest(BaseModel):
    case_id: str
    count: int = 1

@router.get("/cases")
def list_cases():
    return list(catalog.cases.values())

@router.post("/roll")
@router.post("/pull")
def roll_case(
    req: RollRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    if req.count not in [1, 10]:
        req.count = 1
    result = gacha_service.roll_case(session, user, req.case_id, count=req.count)
    user.daily_cases_opened += 1
    user.total_pulls += 1
    session.add(user)
    session.commit()
    return result

@router.get("/pity")
def get_pity_status(
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    stmt = select(UserPity).where(UserPity.user_id == user.id)
    records = session.exec(stmt).all()
    return {
        r.case_id: {
            "pull_count": r.pull_count,
            "sr_pity_count": r.sr_pity_count
        } for r in records
    }
