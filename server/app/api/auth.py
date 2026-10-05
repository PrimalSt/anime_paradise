from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlmodel import Session, select
from datetime import datetime, timezone
import uuid
from app.core.database import get_session
from app.core.security import get_password_hash, verify_password, create_access_token
from app.models.schemas import User, DormState
from app.api.deps import get_current_user

router = APIRouter(prefix="/auth", tags=["Auth"])

class AuthRequest(BaseModel):
    username: str
    password: str

class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    username: str
    coins: int
    love_gems: int
    soul_shards: int
    is_guest: bool

@router.post("/register", response_model=AuthResponse)
def register(data: AuthRequest, session: Session = Depends(get_session)):
    stmt = select(User).where(User.username == data.username)
    existing = session.exec(stmt).first()
    if existing:
        raise HTTPException(status_code=400, detail="Пользователь с таким именем уже существует")

    if len(data.password) < 4:
        raise HTTPException(status_code=400, detail="Пароль должен содержать не менее 4 символов")

    user = User(
        username=data.username,
        hashed_password=get_password_hash(data.password),
        coins=1500,
        love_gems=50,
        soul_shards=0,
        is_guest=False
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    dorm = DormState(user_id=user.id, comfort_level=20)
    session.add(dorm)
    session.commit()

    token = create_access_token({"sub": str(user.id)})
    return AuthResponse(
        access_token=token,
        user_id=user.id,
        username=user.username,
        coins=user.coins,
        love_gems=user.love_gems,
        soul_shards=user.soul_shards,
        is_guest=user.is_guest
    )

@router.post("/login", response_model=AuthResponse)
def login(data: AuthRequest, session: Session = Depends(get_session)):
    stmt = select(User).where(User.username == data.username)
    user = session.exec(stmt).first()
    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Неверное имя пользователя или пароль")

    user.last_online = datetime.now(timezone.utc)
    session.add(user)
    session.commit()

    token = create_access_token({"sub": str(user.id)})
    return AuthResponse(
        access_token=token,
        user_id=user.id,
        username=user.username,
        coins=user.coins,
        love_gems=user.love_gems,
        soul_shards=user.soul_shards,
        is_guest=user.is_guest
    )

@router.post("/guest", response_model=AuthResponse)
def guest_login(session: Session = Depends(get_session)):
    random_id = uuid.uuid4().hex[:8]
    guest_username = f"Guest_{random_id}"
    guest_password = uuid.uuid4().hex

    user = User(
        username=guest_username,
        hashed_password=get_password_hash(guest_password),
        coins=2000,
        love_gems=60,
        soul_shards=0,
        is_guest=True
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    dorm = DormState(user_id=user.id, comfort_level=20)
    session.add(dorm)
    session.commit()

    token = create_access_token({"sub": str(user.id)})
    return AuthResponse(
        access_token=token,
        user_id=user.id,
        username=user.username,
        coins=user.coins,
        love_gems=user.love_gems,
        soul_shards=user.soul_shards,
        is_guest=user.is_guest
    )

@router.get("/me")
def get_me(user: User = Depends(get_current_user)):
    now = datetime.now(timezone.utc)
    can_claim = True
    last_bonus = user.last_daily_bonus
    if last_bonus:
        if last_bonus.tzinfo is None:
            last_bonus = last_bonus.replace(tzinfo=timezone.utc)
        if last_bonus.date() == now.date():
            can_claim = False

    return {
        "id": user.id,
        "username": user.username,
        "coins": user.coins,
        "love_gems": user.love_gems,
        "soul_shards": user.soul_shards,
        "is_guest": user.is_guest,
        "created_at": user.created_at.isoformat(),
        "can_claim_daily_bonus": can_claim
    }

@router.post("/daily-bonus")
def claim_daily_bonus(user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    now = datetime.now(timezone.utc)
    last_bonus = user.last_daily_bonus
    if last_bonus:
        if last_bonus.tzinfo is None:
            last_bonus = last_bonus.replace(tzinfo=timezone.utc)
        if last_bonus.date() == now.date():
            raise HTTPException(status_code=400, detail="Уже получено сегодня")
    
    user.last_daily_bonus = now
    user.love_gems += 100
    session.add(user)
    session.commit()
    
    return {
        "message": "Ежедневный бонус получен: 100 кристаллов!",
        "love_gems": user.love_gems,
        "coins": user.coins,
        "soul_shards": user.soul_shards
    }
