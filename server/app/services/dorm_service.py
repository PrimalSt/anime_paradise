from datetime import datetime, timezone
from typing import Dict, Any, List
from sqlmodel import Session, select
from fastapi import HTTPException
from app.models.schemas import User, DormState, UserWaifu
from app.services.catalog_service import catalog

class DormService:
    def get_or_create_dorm(self, session: Session, user: User) -> DormState:
        stmt = select(DormState).where(DormState.user_id == user.id)
        dorm = session.exec(stmt).first()
        if not dorm:
            dorm = DormState(
                user_id=user.id,
                comfort_level=20,
                furniture_layout_json='[]',
                assigned_waifus_json='[]',
                last_income_collected=datetime.now(timezone.utc)
            )
            session.add(dorm)
            session.commit()
            session.refresh(dorm)
        return dorm

    def calculate_pending_income(self, dorm: DormState) -> int:
        now = datetime.now(timezone.utc)
        # Ensure last_income_collected has timezone
        last_collected = dorm.last_income_collected
        if last_collected.tzinfo is None:
            last_collected = last_collected.replace(tzinfo=timezone.utc)
        seconds_passed = (now - last_collected).total_seconds()
        seconds_capped = min(seconds_passed, 43200)

        coins_per_minute = 2 + (dorm.comfort_level * 0.1) + (len(dorm.assigned_waifus) * 1.5)
        earned = int((seconds_capped / 60.0) * coins_per_minute)
        return max(0, earned)

    def collect_income(self, session: Session, user: User) -> Dict[str, Any]:
        dorm = self.get_or_create_dorm(session, user)
        earned = self.calculate_pending_income(dorm)

        user.coins += earned
        dorm.last_income_collected = datetime.now(timezone.utc)

        session.add(user)
        session.add(dorm)
        session.commit()
        session.refresh(user)
        session.refresh(dorm)

        return {
            "coins_collected": earned,
            "new_balance": user.coins,
            "last_collected": dorm.last_income_collected.isoformat()
        }

    def update_layout(self, session: Session, user: User, furniture_layout: List[dict]) -> Dict[str, Any]:
        dorm = self.get_or_create_dorm(session, user)

        total_comfort = 10
        for item in furniture_layout:
            furn_id = item.get("id")
            furn_info = catalog.get_furniture(furn_id)
            if furn_info:
                total_comfort += furn_info.get("comfort", 10)

        dorm.furniture_layout = furniture_layout
        dorm.comfort_level = total_comfort

        session.add(dorm)
        session.commit()
        session.refresh(dorm)

        return {
            "success": True,
            "comfort_level": dorm.comfort_level,
            "furniture_layout": dorm.furniture_layout
        }

    def assign_waifus(self, session: Session, user: User, waifu_ids: List[str]) -> Dict[str, Any]:
        if len(waifu_ids) > 4:
            raise HTTPException(status_code=400, detail="В комнате может жить максимум 4 персонажа")

        dorm = self.get_or_create_dorm(session, user)
        dorm.assigned_waifus = waifu_ids

        session.add(dorm)
        session.commit()
        session.refresh(dorm)

        return {
            "success": True,
            "assigned_waifus": dorm.assigned_waifus
        }

    def set_theme(self, session: Session, user: User, theme: str) -> Dict[str, Any]:
        valid_themes = ["bg_dorm_room", "bg_cozy_cafe", "bg_sakura_park", "bg_night_festival", "bg_library", "bg_banner"]
        if theme not in valid_themes:
            # Still allow if custom or starts with bg_
            if not theme.startswith("bg_") and not theme.startswith("res://"):
                raise HTTPException(status_code=400, detail="Недопустимая тема комнаты")

        dorm = self.get_or_create_dorm(session, user)
        dorm.theme = theme
        session.add(dorm)
        session.commit()
        session.refresh(dorm)

        return {
            "success": True,
            "theme": dorm.theme
        }

    def clean_dorm(self, session: Session, user: User) -> Dict[str, Any]:
        dorm = self.get_or_create_dorm(session, user)
        now = datetime.now(timezone.utc)
        cooldown_seconds = 300 # 5 minutes cooldown

        if dorm.last_cleaned:
            last_clean = dorm.last_cleaned
            if last_clean.tzinfo is None:
                last_clean = last_clean.replace(tzinfo=timezone.utc)
            delta = (now - last_clean).total_seconds()
            if delta < cooldown_seconds:
                wait_seconds = int(cooldown_seconds - delta)
                raise HTTPException(
                    status_code=429,
                    detail=f"Комната уже сияет! Следующая уборка доступна через {wait_seconds} сек."
                )

        dorm.last_cleaned = now
        coins_reward = 30 + int(dorm.comfort_level * 0.15)
        user.coins += coins_reward

        # Restore mood for assigned waifus
        assigned = dorm.assigned_waifus
        if assigned:
            stmt = select(UserWaifu).where(UserWaifu.user_id == user.id, UserWaifu.character_id.in_(assigned))
            waifus = session.exec(stmt).all()
            for w in waifus:
                w.mood = min(100, w.mood + 15)
                session.add(w)

        session.add(dorm)
        session.add(user)
        session.commit()
        session.refresh(dorm)
        session.refresh(user)

        return {
            "success": True,
            "coins_reward": coins_reward,
            "new_balance": user.coins,
            "last_cleaned": dorm.last_cleaned.isoformat(),
            "message": f"Комната сияет чистотой! +{coins_reward} монет и +15 к настроению вайфу! ✨"
        }

    @staticmethod
    def get_comfort_tier(comfort: int) -> str:
        if comfort >= 150:
            return "Королевский пентхаус 👑"
        elif comfort >= 100:
            return "Роскошные апартаменты 🌟"
        elif comfort >= 60:
            return "Просторная студия 🌸"
        elif comfort >= 35:
            return "Уютная комната 🛋️"
        else:
            return "Скромный уголок 🏠"

dorm_service = DormService()
