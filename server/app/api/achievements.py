from fastapi import APIRouter, Depends
from sqlmodel import Session
from typing import List, Dict, Any
from app.core.database import get_session
from app.api.deps import get_current_user
from app.models.schemas import User

router = APIRouter()

ACHIEVEMENTS = [
    {
        "id": "first_pull",
        "title": "First Pull",
        "description": "Make your first gacha pull",
        "icon": "🎲",
        "reward": 50,
        "reward_type": "love_gems"
    },
    {
        "id": "collector_5",
        "title": "Collector",
        "description": "Collect 5 unique waifus",
        "icon": "👥",
        "reward": 100,
        "reward_type": "love_gems"
    },
    {
        "id": "date_master",
        "title": "Date Master",
        "description": "Complete 10 dates",
        "icon": "💖",
        "reward": 1000,
        "reward_type": "coins"
    },
    {
        "id": "dorm_cozy",
        "title": "Cozy Dorm",
        "description": "Reach 80 dorm comfort",
        "icon": "🏠",
        "reward": 1000,
        "reward_type": "coins"
    },
    {
        "id": "gacha_100",
        "title": "Gacha Addict",
        "description": "Make 100 gacha pulls",
        "icon": "🎰",
        "reward": 500,
        "reward_type": "love_gems"
    }
]

def check_achievements(user: User) -> List[Dict[str, Any]]:
    results = []
    for ach in ACHIEVEMENTS:
        progress = 0
        target = 1
        
        if ach["id"] == "first_pull":
            progress = user.total_pulls
            target = 1
        elif ach["id"] == "collector_5":
            progress = len(user.waifus)
            target = 5
        elif ach["id"] == "date_master":
            progress = user.total_dates
            target = 10
        elif ach["id"] == "dorm_cozy":
            progress = user.dorm.comfort_level if user.dorm else 0
            target = 80
        elif ach["id"] == "gacha_100":
            progress = user.total_pulls
            target = 100
            
        is_completed = progress >= target
        
        results.append({
            **ach,
            "progress": min(progress, target),
            "target": target,
            "completed": is_completed,
            "claimed": ach["id"] in user.claimed_achievements
        })
    return results

@router.get("/")
def get_achievements(user: User = Depends(get_current_user)) -> List[Dict[str, Any]]:
    return check_achievements(user)

from pydantic import BaseModel
from fastapi import HTTPException

class ClaimRequest(BaseModel):
    achievement_id: str

@router.post("/claim")
def claim_achievement(
    req: ClaimRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_session)
) -> Dict[str, Any]:
    achievements_status = check_achievements(user)
    ach = next((a for a in achievements_status if a["id"] == req.achievement_id), None)
    
    if not ach:
        raise HTTPException(status_code=404, detail="Achievement not found")
        
    if not ach["completed"]:
        raise HTTPException(status_code=400, detail="Achievement not completed")
        
    if ach["claimed"]:
        raise HTTPException(status_code=400, detail="Achievement already claimed")
        
    claimed = user.claimed_achievements
    claimed.append(req.achievement_id)
    user.claimed_achievements = claimed
    
    if ach["reward_type"] == "love_gems":
        user.love_gems += ach["reward"]
    elif ach["reward_type"] == "coins":
        user.coins += ach["reward"]
        
    db.add(user)
    db.commit()
    
    return {
        "success": True,
        "reward": ach["reward"],
        "reward_type": ach["reward_type"],
        "new_balance": {
            "coins": user.coins,
            "love_gems": user.love_gems
        }
    }
