import random
from typing import List, Dict, Any, Tuple
from sqlmodel import Session, select
from fastapi import HTTPException
from app.models.schemas import User, UserWaifu, UserPity
from app.services.catalog_service import catalog

SHARD_REWARDS = {
    "UR": 50,
    "SSR": 25,
    "SR": 10,
    "R": 3,
    "N": 1
}

class GachaService:
    def roll_case(self, session: Session, user: User, case_id: str, count: int = 1) -> Dict[str, Any]:
        case_data = catalog.get_case(case_id)
        if not case_data:
            raise HTTPException(status_code=404, detail="Case not found")

        total_cost = case_data["cost_per_pull"] * count
        currency = case_data["currency"]

        if currency == "coins":
            if user.coins < total_cost:
                raise HTTPException(status_code=400, detail="Недостаточно монет")
            user.coins -= total_cost
        elif currency == "love_gems":
            if user.love_gems < total_cost:
                raise HTTPException(status_code=400, detail="Недостаточно кристаллов любви")
            user.love_gems -= total_cost
        else:
            raise HTTPException(status_code=400, detail="Неверная валюта кейса")

        # Fetch or initialize pity record
        statement = select(UserPity).where(UserPity.user_id == user.id, UserPity.case_id == case_id)
        pity = session.exec(statement).first()
        if not pity:
            pity = UserPity(user_id=user.id, case_id=case_id, pull_count=0, sr_pity_count=0)
            session.add(pity)

        # Existing waifus for this user
        waifu_stmt = select(UserWaifu).where(UserWaifu.user_id == user.id)
        user_waifus = {w.character_id: w for w in session.exec(waifu_stmt).all()}

        drops = []
        shards_gained_total = 0

        pool_chars = [catalog.get_character(cid) for cid in case_data["pool"] if catalog.get_character(cid)]
        featured_ids = set(case_data.get("featured", []))
        pity_limit = case_data["pity_limit"]

        for _ in range(count):
            pity.pull_count += 1
            pity.sr_pity_count += 1

            # Determine rolled rarity
            rolled_rarity = self._determine_rarity(case_data["rates"], pity.pull_count, pity.sr_pity_count, pity_limit)

            # Filter pool by rarity
            matching_chars = [c for c in pool_chars if c["rarity"] == rolled_rarity]
            if not matching_chars:
                # Hierarchical fallback: find nearest available tier (lower first, then higher)
                rarity_tiers = ["N", "R", "SR", "SSR", "UR"]
                try:
                    curr_idx = rarity_tiers.index(rolled_rarity)
                except ValueError:
                    curr_idx = 1
                fallback_chars = []
                for idx in range(curr_idx - 1, -1, -1):
                    cand = [c for c in pool_chars if c["rarity"] == rarity_tiers[idx]]
                    if cand:
                        fallback_chars = cand
                        break
                if not fallback_chars:
                    for idx in range(curr_idx + 1, len(rarity_tiers)):
                        cand = [c for c in pool_chars if c["rarity"] == rarity_tiers[idx]]
                        if cand:
                            fallback_chars = cand
                            break
                matching_chars = fallback_chars if fallback_chars else pool_chars

            # Weight featured characters higher
            chosen_char = self._pick_character(matching_chars, featured_ids)
            char_id = chosen_char["id"]
            actual_rarity = chosen_char.get("rarity", rolled_rarity)

            # Reset pity if actual UR/SSR/SR dropped
            if actual_rarity in ["UR", "SSR"]:
                pity.pull_count = 0
            if actual_rarity in ["UR", "SSR", "SR"]:
                pity.sr_pity_count = 0

            is_duplicate = char_id in user_waifus
            shards_awarded = 0
            star_level = 1

            if is_duplicate:
                waifu_record = user_waifus[char_id]
                shards_awarded = SHARD_REWARDS.get(actual_rarity, 3)
                shards_gained_total += shards_awarded
                user.soul_shards += shards_awarded
                if waifu_record.stars < 5:
                    waifu_record.stars += 1
                star_level = waifu_record.stars
            else:
                new_waifu = UserWaifu(
                    user_id=user.id,
                    character_id=char_id,
                    stars=1,
                    affection_level=1,
                    affection_points=0,
                    hunger=100,
                    mood=100
                )
                session.add(new_waifu)
                user_waifus[char_id] = new_waifu

            drops.append({
                "character": chosen_char,
                "is_duplicate": is_duplicate,
                "shards_awarded": shards_awarded,
                "star_level": star_level
            })

        session.add(user)
        session.add(pity)
        session.commit()
        session.refresh(user)

        return {
            "drops": drops,
            "new_balance": {
                "coins": user.coins,
                "love_gems": user.love_gems,
                "soul_shards": user.soul_shards
            },
            "pity": {
                "pull_count": pity.pull_count,
                "sr_pity_count": pity.sr_pity_count,
                "pity_limit": pity_limit
            },
            "shards_gained_total": shards_gained_total
        }

    def _determine_rarity(self, rates: dict, pull_count: int, sr_pity_count: int, pity_limit: int) -> str:
        # Hard pity check for SSR/UR
        if pull_count >= pity_limit:
            return "UR" if random.random() < 0.2 else "SSR"

        # 10-pull pity for SR+
        is_sr_guaranteed = sr_pity_count >= 10

        ur_rate = rates.get("UR", 0.01)
        ssr_rate = rates.get("SSR", 0.05)
        sr_rate = rates.get("SR", 0.15)
        r_rate = rates.get("R", 0.79)
        n_rate = rates.get("N", 0.0)

        if is_sr_guaranteed:
            # Force at least SR
            total_high = ur_rate + ssr_rate + sr_rate
            if total_high <= 0:
                total_high = 0.21
            scaled_rand = random.random() * total_high
            if scaled_rand < ur_rate:
                return "UR"
            elif scaled_rand < (ur_rate + ssr_rate):
                return "SSR"
            else:
                return "SR"

        rand_val = random.random()
        cumulative = 0.0
        for rarity, rate in [("UR", ur_rate), ("SSR", ssr_rate), ("SR", sr_rate), ("R", r_rate), ("N", n_rate)]:
            cumulative += rate
            if rand_val <= cumulative:
                return rarity

        return "R"

    def _pick_character(self, candidates: List[dict], featured_ids: set) -> dict:
        weights = []
        for c in candidates:
            if c["id"] in featured_ids:
                weights.append(3.0)  # 3x boost for rate-up characters
            else:
                weights.append(1.0)
        return random.choices(candidates, weights=weights, k=1)[0]

gacha_service = GachaService()
