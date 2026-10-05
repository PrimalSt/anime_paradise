from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlmodel import Session
from datetime import datetime, timezone
import json
from app.core.database import get_session
from app.api.deps import get_current_user
from app.models.schemas import User

router = APIRouter(prefix="/quests", tags=["Quests"])

DAILY_QUESTS = [
    {"id": "daily_date_1", "type": "date", "target": 1, "reward_coins": 100, "reward_gems": 5, "desc": "Провести 1 свидание"},
    {"id": "daily_dorm_2", "type": "dorm", "target": 2, "reward_coins": 150, "reward_gems": 10, "desc": "Собрать доход в общежитии 2 раза"},
    {"id": "daily_gacha_1", "type": "gacha", "target": 1, "reward_coins": 0, "reward_gems": 20, "desc": "Открыть 1 кейс в гаче"},
]

@router.get("/")
def get_quests(user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    claimed = []
    try:
        claimed = json.loads(user.quests_claimed_json)
    except:
        pass

    quests = []
    for q in DAILY_QUESTS:
        progress = 0
        if q["type"] == "date":
            progress = user.daily_dates
        elif q["type"] == "dorm":
            progress = user.daily_dorm_collects
        elif q["type"] == "gacha":
            progress = user.daily_cases_opened

        completed = progress >= q["target"]
        is_claimed = q["id"] in claimed

        quests.append({
            "id": q["id"],
            "desc": q["desc"],
            "target": q["target"],
            "progress": progress,
            "completed": completed,
            "claimed": is_claimed,
            "reward_coins": q["reward_coins"],
            "reward_gems": q["reward_gems"]
        })
    return quests

class ClaimRequest(BaseModel):
    quest_id: str

@router.post("/claim")
def claim_quest(req: ClaimRequest, user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    claimed = []
    try:
        claimed = json.loads(user.quests_claimed_json)
    except:
        pass

    if req.quest_id in claimed:
        raise HTTPException(status_code=400, detail="Награда уже получена")

    quest = next((q for q in DAILY_QUESTS if q["id"] == req.quest_id), None)
    if not quest:
        raise HTTPException(status_code=404, detail="Квест не найден")

    progress = 0
    if quest["type"] == "date":
        progress = user.daily_dates
    elif quest["type"] == "dorm":
        progress = user.daily_dorm_collects
    elif quest["type"] == "gacha":
        progress = user.daily_cases_opened

    if progress < quest["target"]:
        raise HTTPException(status_code=400, detail="Квест еще не выполнен")

    user.coins += quest["reward_coins"]
    user.love_gems += quest["reward_gems"]
    claimed.append(req.quest_id)
    user.quests_claimed_json = json.dumps(claimed)

    session.add(user)
    session.commit()
    session.refresh(user)

    return {
        "message": f"Награда получена: {quest['reward_coins']} монет, {quest['reward_gems']} кристаллов",
        "new_balance": {
            "coins": user.coins,
            "love_gems": user.love_gems
        }
    }
