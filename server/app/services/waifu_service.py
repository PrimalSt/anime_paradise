from datetime import datetime, timedelta, timezone
from typing import Dict, Any, Optional
from sqlmodel import Session, select
from fastapi import HTTPException
from app.models.schemas import User, UserWaifu, UserInventory
from app.services.catalog_service import catalog

AFFECTION_THRESHOLDS = [0, 50, 120, 220, 350, 500, 700, 950, 1250, 1600]

class WaifuService:
    def headpat(self, session: Session, user: User, waifu_id: int) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        now = datetime.now(timezone.utc)
        if waifu.last_headpat:
            delta = now - waifu.last_headpat
            if delta < timedelta(minutes=5):
                wait_seconds = int(300 - delta.total_seconds())
                raise HTTPException(
                    status_code=429,
                    detail=f"Погладить можно снова через {wait_seconds} сек."
                )

        waifu.last_headpat = now
        waifu.mood = min(100, waifu.mood + 20)
        affection_gain = 15
        waifu.affection_points += affection_gain
        self._check_level_up(waifu)

        session.add(waifu)
        session.commit()
        session.refresh(waifu)

        char_template = catalog.get_character(waifu.character_id)
        reply = char_template["dialogues"].get("headpat", "Спасибо за ласку!") if char_template else "Спасибо!"

        return {
            "success": True,
            "waifu": waifu,
            "affection_gain": affection_gain,
            "reply": reply,
            "mood": waifu.mood,
            "affection_level": waifu.affection_level
        }

    def feed(self, session: Session, user: User, waifu_id: int, item_id: str) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        inv_stmt = select(UserInventory).where(
            UserInventory.user_id == user.id,
            UserInventory.item_id == item_id
        )
        inv_item = session.exec(inv_stmt).first()
        if not inv_item or inv_item.quantity <= 0:
            raise HTTPException(status_code=400, detail="У вас нет этого блюда в инвентаре")

        food_data = catalog.get_item(item_id)
        if not food_data:
            raise HTTPException(status_code=404, detail="Предмет не найден в каталоге")

        inv_item.quantity -= 1
        if inv_item.quantity == 0:
            session.delete(inv_item)
        else:
            session.add(inv_item)

        char_template = catalog.get_character(waifu.character_id)
        is_favorite = False
        if char_template and item_id in char_template.get("favorite_food", []):
            is_favorite = True

        hunger_restore = food_data.get("hunger_restore", 30)
        base_affection = food_data.get("affection_bonus", 15)
        affection_gain = base_affection * 2 if is_favorite else base_affection

        waifu.hunger = min(100, waifu.hunger + hunger_restore)
        waifu.affection_points += affection_gain
        waifu.last_fed = datetime.now(timezone.utc)
        self._check_level_up(waifu)

        session.add(waifu)
        session.commit()
        session.refresh(waifu)

        reply = char_template["dialogues"].get("feed", "Очень вкусно!") if char_template else "Спасибо за еду!"

        return {
            "success": True,
            "is_favorite": is_favorite,
            "affection_gain": affection_gain,
            "hunger": waifu.hunger,
            "affection_level": waifu.affection_level,
            "reply": reply
        }

    def equip_outfit(self, session: Session, user: User, waifu_id: int, outfit_id: str) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        if outfit_id not in waifu.unlocked_outfits:
            raise HTTPException(status_code=400, detail="Этот наряд ещё не разблокирован")

        waifu.current_outfit_id = outfit_id
        session.add(waifu)
        session.commit()
        session.refresh(waifu)

        return {"success": True, "current_outfit_id": waifu.current_outfit_id}

    def unlock_outfit_with_shards(self, session: Session, user: User, waifu_id: int, outfit_id: str, cost: int = 50) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        char_template = catalog.get_character(waifu.character_id)
        if char_template:
            valid_outfit_ids = {o["id"] for o in char_template.get("outfits", [])}
            if outfit_id not in valid_outfit_ids:
                raise HTTPException(status_code=400, detail="Наряд не найден у этого персонажа")

        if outfit_id in waifu.unlocked_outfits:
            raise HTTPException(status_code=400, detail="Наряд уже открыт")

        if user.soul_shards < cost:
            raise HTTPException(status_code=400, detail="Недостаточно осколков души")

        user.soul_shards -= cost
        outfits = waifu.unlocked_outfits
        outfits.append(outfit_id)
        waifu.unlocked_outfits = outfits
        waifu.current_outfit_id = outfit_id

        session.add(user)
        session.add(waifu)
        session.commit()
        session.refresh(waifu)
        session.refresh(user)

        return {
            "success": True,
            "unlocked_outfits": waifu.unlocked_outfits,
            "current_outfit_id": waifu.current_outfit_id,
            "soul_shards": user.soul_shards
        }

    def toggle_favorite(self, session: Session, user: User, waifu_id: int) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        waifu.is_favorite = not bool(waifu.is_favorite)
        session.add(waifu)
        session.commit()
        session.refresh(waifu)

        return {
            "success": True,
            "waifu_id": waifu.id,
            "is_favorite": waifu.is_favorite
        }

    def ascend_waifu(self, session: Session, user: User, waifu_id: int) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        if waifu.stars >= 5:
            raise HTTPException(status_code=400, detail="Достигнут максимальный ранг звёзд (5★)!")

        costs = {1: 30, 2: 60, 3: 120, 4: 250}
        cost = costs.get(waifu.stars, 100)

        if user.soul_shards < cost:
            raise HTTPException(
                status_code=400,
                detail=f"Недостаточно осколков души (требуется {cost} 🔮, у вас {user.soul_shards})"
            )

        user.soul_shards -= cost
        waifu.stars += 1

        session.add(user)
        session.add(waifu)
        session.commit()
        session.refresh(waifu)
        session.refresh(user)

        return {
            "success": True,
            "stars": waifu.stars,
            "soul_shards": user.soul_shards,
            "message": f"Звёздный ранг возвышен до {waifu.stars}★! Характеристики усилены."
        }

    def claim_milestone(self, session: Session, user: User, waifu_id: int, milestone_level: int) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        rewards = {
            2: 50,
            3: 100,
            4: 150,
            5: 250
        }

        if milestone_level not in rewards:
            raise HTTPException(status_code=400, detail="Неверный этап привязанности")

        if waifu.affection_level < milestone_level:
            raise HTTPException(
                status_code=400,
                detail=f"Требуется уровень привязанности {milestone_level} (текущий {waifu.affection_level})"
            )

        claimed = waifu.claimed_milestones
        if milestone_level in claimed:
            raise HTTPException(status_code=400, detail="Награда за этот этап уже получена")

        gems = rewards[milestone_level]
        claimed.append(milestone_level)
        waifu.claimed_milestones = claimed
        user.love_gems += gems

        session.add(user)
        session.add(waifu)
        session.commit()
        session.refresh(waifu)
        session.refresh(user)

        return {
            "success": True,
            "milestone_level": milestone_level,
            "gems_awarded": gems,
            "love_gems": user.love_gems,
            "claimed_milestones": waifu.claimed_milestones
        }

    def _check_level_up(self, waifu: UserWaifu):
        for lvl, threshold in enumerate(AFFECTION_THRESHOLDS, start=1):
            if waifu.affection_points >= threshold:
                waifu.affection_level = lvl
            else:
                break

waifu_service = WaifuService()
