from typing import Dict, Any, List
from sqlmodel import Session, select
from fastapi import HTTPException
from app.models.schemas import User, UserWaifu
from app.services.catalog_service import catalog
from app.services.waifu_service import waifu_service

RELATIONSHIP_RANKS = {
    1: "Знакомая",
    2: "Приятельница",
    3: "Близкая подруга",
    4: "Возлюбленная",
    5: "Невеста",
    6: "Родственная душа",
    7: "Вечная любовь",
    8: "Пламенное сердце",
    9: "Божественная связь",
    10: "Абсолютное единство"
}

class DatingService:
    def get_locations(self) -> List[dict]:
        return catalog.dating_scripts.get("locations", [])

    def start_date(self, session: Session, user: User, waifu_id: int, location_id: str) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        char_template = catalog.get_character(waifu.character_id)
        if not char_template:
            raise HTTPException(status_code=404, detail="Шаблон персонажа не найден")

        # Check location minimum affection level
        locations = catalog.dating_scripts.get("locations", [])
        loc_meta = next((loc for loc in locations if loc.get("id") == location_id), None)
        if not loc_meta:
            raise HTTPException(status_code=404, detail="Локация для свидания не найдена")

        req_lvl = loc_meta.get("min_affection_level", 1)
        if waifu.affection_level < req_lvl:
            raise HTTPException(
                status_code=400,
                detail=f"Для этой локации требуется уровень привязанности {req_lvl} (текущий {waifu.affection_level})"
            )

        scripts = catalog.dating_scripts.get("scripts", {})
        if location_id not in scripts:
            raise HTTPException(status_code=404, detail="Сценарий для локации не найден")
        script_data = scripts[location_id]

        start_node_key = script_data.get("start_node", "sp_intro")
        node = script_data["nodes"].get(start_node_key)

        res = self._format_node(node, char_template["name"], start_node_key, location_id, waifu_id)
        res["current_affection"] = waifu.affection_points
        res["affection_level"] = waifu.affection_level
        res["rank_title"] = RELATIONSHIP_RANKS.get(waifu.affection_level, "Абсолютное единство")
        return res

    def submit_choice(self, session: Session, user: User, waifu_id: int, location_id: str, node_id: str, choice_index: int) -> Dict[str, Any]:
        waifu = session.get(UserWaifu, waifu_id)
        if not waifu or waifu.user_id != user.id:
            raise HTTPException(status_code=404, detail="Вайфу не найдена")

        char_template = catalog.get_character(waifu.character_id)
        scripts = catalog.dating_scripts.get("scripts", {})
        if location_id not in scripts:
            raise HTTPException(status_code=404, detail="Сценарий для локации не найден")
        script_data = scripts[location_id]

        current_node = script_data["nodes"].get(node_id)
        if not current_node:
            raise HTTPException(status_code=404, detail="Диалоговый узел не найден")

        choices = current_node.get("choices", [])
        if choice_index < 0 or choice_index >= len(choices):
            raise HTTPException(status_code=400, detail="Неверный выбор ответа")

        chosen_choice = choices[choice_index]
        affection_gain = chosen_choice.get("affection", 10)
        next_node_key = chosen_choice.get("next_node")

        # Award affection and check level up
        prev_level = waifu.affection_level
        waifu.affection_points += affection_gain
        waifu_service._check_level_up(waifu)
        leveled_up = waifu.affection_level > prev_level

        next_node = script_data["nodes"].get(next_node_key)
        if not next_node:
            raise HTTPException(status_code=500, detail="Следующий диалоговый узел отсутствует")

        is_end = next_node.get("is_end", False)
        cg_unlocked = False
        gems_reward = 0

        if is_end:
            waifu.dates_completed += 1
            gems_reward += 5
            user.love_gems += 5
            if next_node.get("cg_unlocked", False):
                cg_id = f"cg_{location_id}_{waifu.character_id}"
                cgs = waifu.cgs_unlocked
                if cg_id not in cgs:
                    cgs.append(cg_id)
                    waifu.cgs_unlocked = cgs
                    cg_unlocked = True
                    # Reward user with additional love gems for new memory
                    gems_reward += 10
                    user.love_gems += 10
            session.add(user)

        session.add(waifu)
        session.commit()
        session.refresh(waifu)
        session.refresh(user)

        result = self._format_node(next_node, char_template["name"], next_node_key, location_id, waifu_id)
        result["affection_gain"] = affection_gain
        result["current_affection"] = waifu.affection_points
        result["affection_level"] = waifu.affection_level
        result["prev_affection_level"] = prev_level
        result["leveled_up"] = leveled_up
        result["rank_title"] = RELATIONSHIP_RANKS.get(waifu.affection_level, "Абсолютное единство")
        result["cg_unlocked"] = cg_unlocked
        result["gems_reward"] = gems_reward
        result["dates_completed"] = waifu.dates_completed
        return result

    def _format_node(self, node: dict, waifu_name: str, node_key: str, location_id: str, waifu_id: int) -> dict:
        narrative_text = node.get("text", "").replace("{waifu_name}", waifu_name)
        speaker = node.get("speaker", "").replace("{waifu_name}", waifu_name)
        char_text = node.get("character_text", "").replace("{waifu_name}", waifu_name)

        return {
            "node_id": node_key,
            "location_id": location_id,
            "waifu_id": waifu_id,
            "narrative_text": narrative_text,
            "speaker": speaker,
            "character_text": char_text,
            "emotion": node.get("emotion", "smile"),
            "choices": node.get("choices", []),
            "is_end": node.get("is_end", False),
            "cg_unlocked": node.get("cg_unlocked", False)
        }

dating_service = DatingService()
