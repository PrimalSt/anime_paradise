from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlmodel import Session
from app.core.database import get_session
from app.core.security import decode_access_token
from app.models.schemas import User

security_bearer = HTTPBearer(auto_error=True)

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security_bearer),
    session: Session = Depends(get_session)
) -> User:
    token = credentials.credentials
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Недействительный или истёкший токен авторизации",
            headers={"WWW-Authenticate": "Bearer"},
        )
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Не удалось определить пользователя из токена",
            headers={"WWW-Authenticate": "Bearer"},
        )
    user = session.get(User, int(user_id))
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь не найден",
        )

    # Perform daily reset check
    from datetime import datetime, timezone
    now = datetime.now(timezone.utc)
    last_reset = user.last_quest_reset
    if last_reset and last_reset.tzinfo is None:
        last_reset = last_reset.replace(tzinfo=timezone.utc)
        
    if not last_reset or last_reset.date() < now.date():
        user.daily_dates = 0
        user.daily_dorm_collects = 0
        user.daily_cases_opened = 0
        user.quests_claimed_json = '[]'
        user.last_quest_reset = now
        session.add(user)
        session.commit()
        session.refresh(user)

    return user
