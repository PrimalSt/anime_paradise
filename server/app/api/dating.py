from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlmodel import Session
from app.core.database import get_session
from app.api.deps import get_current_user
from app.models.schemas import User
from app.services.dating_service import dating_service

router = APIRouter(prefix="/dating", tags=["Dating"])

class StartDateRequest(BaseModel):
    waifu_id: int
    location_id: str

class SubmitChoiceRequest(BaseModel):
    waifu_id: int
    location_id: str
    node_id: str
    choice_index: int

@router.get("/locations")
def get_locations():
    return dating_service.get_locations()

@router.post("/start")
def start_date(
    req: StartDateRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    return dating_service.start_date(session, user, req.waifu_id, req.location_id)

@router.post("/choice")
def submit_choice(
    req: SubmitChoiceRequest,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session)
):
    result = dating_service.submit_choice(
        session, user, req.waifu_id, req.location_id, req.node_id, req.choice_index
    )
    if result.get("is_end"):
        user.daily_dates += 1
        user.total_dates += 1
        session.add(user)
        session.commit()
    return result
