from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from datetime import datetime, timezone
import json

def utc_now() -> datetime:
    return datetime.now(timezone.utc)

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(unique=True, index=True)
    hashed_password: str
    coins: int = Field(default=1500)
    love_gems: int = Field(default=50)
    soul_shards: int = Field(default=0)
    is_guest: bool = Field(default=False)
    created_at: datetime = Field(default_factory=utc_now)
    last_online: datetime = Field(default_factory=utc_now)
    last_daily_bonus: Optional[datetime] = Field(default=None)

    daily_dates: int = Field(default=0)
    daily_dorm_collects: int = Field(default=0)
    daily_cases_opened: int = Field(default=0)
    quests_claimed_json: str = Field(default='[]')
    last_quest_reset: datetime = Field(default_factory=utc_now)
    total_pulls: int = Field(default=0)
    total_dates: int = Field(default=0)
    claimed_achievements_json: str = Field(default='[]')

    waifus: List["UserWaifu"] = Relationship(back_populates="owner")
    pities: List["UserPity"] = Relationship(back_populates="owner")
    inventory: List["UserInventory"] = Relationship(back_populates="owner")
    dorm: Optional["DormState"] = Relationship(back_populates="owner")

    @property
    def claimed_achievements(self) -> List[str]:
        try:
            return json.loads(self.claimed_achievements_json)
        except Exception:
            return []

    @claimed_achievements.setter
    def claimed_achievements(self, val: List[str]):
        self.claimed_achievements_json = json.dumps(val)

class UserWaifu(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    character_id: str = Field(index=True)
    stars: int = Field(default=1)
    affection_points: int = Field(default=0)
    affection_level: int = Field(default=1)
    is_favorite: bool = Field(default=False)
    claimed_milestones_json: str = Field(default='[]')
    hunger: int = Field(default=100)
    mood: int = Field(default=100)
    current_outfit_id: str = Field(default="default")
    unlocked_outfits_json: str = Field(default='["default"]')
    cgs_unlocked_json: str = Field(default='[]')
    dates_completed: int = Field(default=0)
    last_fed: Optional[datetime] = None
    last_headpat: Optional[datetime] = None
    obtained_at: datetime = Field(default_factory=utc_now)

    owner: Optional[User] = Relationship(back_populates="waifus")

    @property
    def is_fav(self) -> bool:
        return bool(self.is_favorite)

    @property
    def claimed_milestones(self) -> List[int]:
        try:
            return json.loads(self.claimed_milestones_json)
        except Exception:
            return []

    @claimed_milestones.setter
    def claimed_milestones(self, val: List[int]):
        self.claimed_milestones_json = json.dumps(val)

    @property
    def unlocked_outfits(self) -> List[str]:
        try:
            return json.loads(self.unlocked_outfits_json)
        except Exception:
            return ["default"]

    @unlocked_outfits.setter
    def unlocked_outfits(self, val: List[str]):
        self.unlocked_outfits_json = json.dumps(val)

    @property
    def cgs_unlocked(self) -> List[str]:
        try:
            return json.loads(self.cgs_unlocked_json)
        except Exception:
            return []

    @cgs_unlocked.setter
    def cgs_unlocked(self, val: List[str]):
        self.cgs_unlocked_json = json.dumps(val)

class UserPity(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    case_id: str = Field(index=True)
    pull_count: int = Field(default=0)
    sr_pity_count: int = Field(default=0)

    owner: Optional[User] = Relationship(back_populates="pities")

class UserInventory(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    item_id: str = Field(index=True)
    item_type: str = Field(default="food")
    quantity: int = Field(default=1)

    owner: Optional[User] = Relationship(back_populates="inventory")

class DormState(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", unique=True, index=True)
    comfort_level: int = Field(default=10)
    furniture_layout_json: str = Field(default='[]')
    assigned_waifus_json: str = Field(default='[]')
    theme: str = Field(default="bg_dorm_room")
    last_income_collected: datetime = Field(default_factory=utc_now)
    last_cleaned: Optional[datetime] = Field(default=None)

    owner: Optional[User] = Relationship(back_populates="dorm")

    @property
    def furniture_layout(self) -> List[dict]:
        try:
            return json.loads(self.furniture_layout_json)
        except Exception:
            return []

    @furniture_layout.setter
    def furniture_layout(self, val: List[dict]):
        self.furniture_layout_json = json.dumps(val)

    @property
    def assigned_waifus(self) -> List[str]:
        try:
            return json.loads(self.assigned_waifus_json)
        except Exception:
            return []

    @assigned_waifus.setter
    def assigned_waifus(self, val: List[str]):
        self.assigned_waifus_json = json.dumps(val)
