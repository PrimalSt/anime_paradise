import pytest
from sqlmodel import Session, SQLModel, create_engine
from app.models.schemas import User, UserWaifu, UserPity
from app.services.gacha_service import gacha_service
from app.services.waifu_service import waifu_service
from app.services.dorm_service import dorm_service
from app.services.dating_service import dating_service
from app.services.catalog_service import catalog

def test_monte_carlo_gacha():
    test_engine = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(test_engine)

    with Session(test_engine) as session:
        user = User(
            username="test_gacha_master",
            hashed_password="hashed_test_pass",
            coins=1000000,
            love_gems=10000,
            soul_shards=0
        )
        session.add(user)
        session.commit()
        session.refresh(user)

        total_pulls = 1000
        rarity_counts = {"UR": 0, "SSR": 0, "SR": 0, "R": 0, "N": 0}
        duplicates_count = 0

        # Roll 100 times x10
        for _ in range(100):
            res = gacha_service.roll_case(session, user, "standard_banner", count=10)
            for drop in res["drops"]:
                rarity = drop["character"]["rarity"]
                rarity_counts[rarity] += 1
                if drop["is_duplicate"]:
                    duplicates_count += 1

        print("\n--- Gacha Simulation Results (1000 pulls) ---")
        for r, cnt in rarity_counts.items():
            print(f"{r}: {cnt} ({cnt / total_pulls * 100:.2f}%)")
        print(f"Duplicates: {duplicates_count}")
        print(f"Final Soul Shards: {user.soul_shards}")

        # Check guarantees
        assert rarity_counts["SSR"] + rarity_counts["UR"] > 0, "Must drop at least one SSR/UR with pity"
        assert rarity_counts["SR"] >= 100, "10-pull pity guarantees at least one SR per 10-pull"
        assert user.soul_shards > 0, "Duplicates should reward soul shards"

        # Statistical rate sanity checks (1000 pulls on standard banner)
        assert 3 <= rarity_counts["UR"] <= 40, f"UR rate outlier: {rarity_counts['UR']}"
        assert 30 <= rarity_counts["SSR"] <= 100, f"SSR rate outlier: {rarity_counts['SSR']}"
        assert rarity_counts["UR"] + rarity_counts["SSR"] <= 120, f"UR+SSR corrupted drop rate: {rarity_counts['UR'] + rarity_counts['SSR']}"

def test_waifu_care_and_dating_flow():
    test_engine = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(test_engine)

    with Session(test_engine) as session:
        user = User(
            username="date_tester",
            hashed_password="hashed_test_pass",
            coins=5000,
            love_gems=100,
            soul_shards=0
        )
        session.add(user)
        session.commit()
        session.refresh(user)

        # Give user Raiden
        waifu = UserWaifu(
            user_id=user.id,
            character_id="raiden_genshin",
            stars=1,
            affection_level=1,
            affection_points=0,
            hunger=50,
            mood=50
        )
        session.add(waifu)
        session.commit()
        session.refresh(waifu)

        # 1. Headpat test
        hp_res = waifu_service.headpat(session, user, waifu.id)
        assert hp_res["success"] is True
        assert waifu.mood > 50
        assert waifu.affection_points > 0

        # 2. Dating test (start date in sakura park)
        date_start = dating_service.start_date(session, user, waifu.id, "sakura_park")
        assert "narrative_text" in date_start
        assert len(date_start["choices"]) > 0

        # Pick choice 0 (romantic choice)
        choice_res = dating_service.submit_choice(
            session, user, waifu.id, "sakura_park", date_start["node_id"], 0
        )
        assert choice_res["affection_gain"] > 0

        # Pick second choice leading to end
        end_res = dating_service.submit_choice(
            session, user, waifu.id, "sakura_park", choice_res["node_id"], 0
        )
        assert end_res["is_end"] is True
        assert end_res["cg_unlocked"] is True
        assert len(waifu.cgs_unlocked) > 0

        # 3. Dorm test
        dorm = dorm_service.get_or_create_dorm(session, user)
        dorm_service.assign_waifus(session, user, ["raiden_genshin"])
        assert "raiden_genshin" in dorm.assigned_waifus

if __name__ == "__main__":
    test_monte_carlo_gacha()
    test_waifu_care_and_dating_flow()
    print("All tests passed successfully!")
