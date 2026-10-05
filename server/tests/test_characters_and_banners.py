import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine, select
from app.main import app
from app.core.database import init_db, get_session
from app.models.schemas import User, UserWaifu
from app.services.catalog_service import catalog
from app.services.gacha_service import gacha_service
from app.services.waifu_service import waifu_service

def test_catalog_characters_completeness():
    catalog.reload()
    assert len(catalog.characters) >= 25, f"Expected at least 25 characters, got {len(catalog.characters)}"

    required_dialogue_keys = {"greeting", "headpat", "feed", "level_up", "confession"}
    required_stat_keys = {"charm", "energy", "intellect"}
    valid_rarities = {"UR", "SSR", "SR", "R"}

    for cid, char in catalog.characters.items():
        assert char["id"] == cid
        assert isinstance(char["name"], str) and len(char["name"]) > 0
        assert isinstance(char["title"], str) and len(char["title"]) > 0
        assert isinstance(char["franchise"], str) and len(char["franchise"]) > 0
        assert char["rarity"] in valid_rarities, f"Invalid rarity {char['rarity']} for {cid}"
        assert isinstance(char["bio"], str) and len(char["bio"]) > 20
        assert isinstance(char["favorite_food"], list) and len(char["favorite_food"]) >= 1

        for food_id in char["favorite_food"]:
            assert food_id in catalog.items, f"Food {food_id} for {cid} not found in catalog items"

        assert isinstance(char["base_stats"], dict)
        for stat in required_stat_keys:
            assert stat in char["base_stats"]
            assert char["base_stats"][stat] > 0

        assert isinstance(char["outfits"], list) and len(char["outfits"]) >= 3
        outfit_ids = [o["id"] for o in char["outfits"]]
        assert len(outfit_ids) == len(set(outfit_ids)), f"Duplicate outfit ids for {cid}"
        assert "default" in outfit_ids

        default_outfit_obj = next(o for o in char["outfits"] if o["id"] == "default")
        assert default_outfit_obj["unlocked"] is True
        assert char["default_outfit"] == default_outfit_obj["name"]

        assert isinstance(char["dialogues"], dict)
        for d_key in required_dialogue_keys:
            assert d_key in char["dialogues"], f"Missing dialogue key {d_key} in {cid}"
            assert len(char["dialogues"][d_key]) > 0

def test_catalog_cases_and_banners_completeness():
    catalog.reload()
    assert len(catalog.cases) >= 6, f"Expected at least 6 banners, got {len(catalog.cases)}"

    expected_banner_ids = [
        "standard_banner",
        "premium_banner",
        "genshin_banner",
        "rezero_banner",
        "fantasy_magic_banner",
        "modern_romcom_banner",
        "sci_fi_destiny_banner"
    ]

    for bid in expected_banner_ids:
        assert bid in catalog.cases, f"Expected banner {bid} missing"
        case = catalog.cases[bid]
        assert case["id"] == bid
        assert len(case["name"]) > 0
        assert len(case["description"]) > 0
        assert case["currency"] in {"coins", "love_gems"}
        assert case["cost_per_pull"] > 0
        assert case["pity_limit"] > 0

        rates = case["rates"]
        total_rate = sum(rates.values())
        assert abs(total_rate - 1.0) < 1e-4, f"Rates do not sum to 1.0 in banner {bid}: {total_rate}"

        for char_id in case["pool"]:
            assert char_id in catalog.characters, f"Character {char_id} in pool of {bid} not in catalog"

        for feat_id in case.get("featured", []):
            assert feat_id in catalog.characters, f"Featured character {feat_id} of {bid} not in catalog"

    # Verify standard and premium banners contain all 25 characters
    for bid in ["standard_banner", "premium_banner"]:
        assert len(catalog.cases[bid]["pool"]) >= 25

def test_all_banners_pullable_via_api():
    init_db()
    with TestClient(app) as client:
        # Create rich tester
        auth_resp = client.post("/api/auth/guest")
        assert auth_resp.status_code == 200
        token = auth_resp.json()["access_token"]
        user_id = auth_resp.json()["user_id"]
        headers = {"Authorization": f"Bearer {token}"}

        # Give generous currency
        session = next(get_session())
        user = session.get(User, user_id)
        user.coins = 100000
        user.love_gems = 5000
        session.add(user)
        session.commit()

        cases = client.get("/api/gacha/cases").json()
        assert len(cases) >= 6

        for case_info in cases:
            case_id = case_info["id"]
            roll_resp = client.post(
                "/api/gacha/roll",
                headers=headers,
                json={"case_id": case_id, "count": 10}
            )
            assert roll_resp.status_code == 200, f"Roll failed on {case_id}: {roll_resp.text}"
            data = roll_resp.json()
            assert len(data["drops"]) == 10
            for drop in data["drops"]:
                char = drop["character"]
                assert char["id"] in catalog.characters

def test_new_waifus_care_and_wardrobe():
    test_engine = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(test_engine)

    with Session(test_engine) as session:
        user = User(
            username="frieren_fan",
            hashed_password="pw",
            coins=10000,
            love_gems=100,
            soul_shards=200
        )
        session.add(user)
        session.commit()
        session.refresh(user)

        # Create Frieren
        frieren_waifu = UserWaifu(
            user_id=user.id,
            character_id="frieren_magic",
            stars=1,
            affection_level=1,
            affection_points=0,
            hunger=50,
            mood=50
        )
        session.add(frieren_waifu)
        session.commit()
        session.refresh(frieren_waifu)

        # Headpat
        hp_res = waifu_service.headpat(session, user, frieren_waifu.id)
        assert hp_res["success"] is True
        assert "Гиммель" in hp_res["reply"]

        # Feed with favorite food (beef_steak)
        from app.models.schemas import UserInventory
        inv_item = UserInventory(user_id=user.id, item_id="beef_steak", quantity=5)
        session.add(inv_item)
        session.commit()

        feed_res = waifu_service.feed(session, user, frieren_waifu.id, "beef_steak")
        assert feed_res["success"] is True
        assert feed_res["is_favorite"] is True
        assert "приключения" in feed_res["reply"]

        # Outfit unlock with soul shards
        unlock_res = waifu_service.unlock_outfit_with_shards(
            session, user, frieren_waifu.id, "winter_journey", cost=50
        )
        assert unlock_res["success"] is True
        assert "winter_journey" in unlock_res["unlocked_outfits"]
        assert unlock_res["current_outfit_id"] == "winter_journey"
        assert unlock_res["soul_shards"] == 150

        # Equip outfit
        equip_res = waifu_service.equip_outfit(session, user, frieren_waifu.id, "default")
        assert equip_res["success"] is True
        assert equip_res["current_outfit_id"] == "default"

        # Attempting to unlock invalid outfit should fail
        with pytest.raises(Exception) as excinfo:
            waifu_service.unlock_outfit_with_shards(
                session, user, frieren_waifu.id, "nonexistent_fake_outfit", cost=50
            )
        assert "не найден" in str(excinfo.value.detail)

def test_duplicate_shards_and_pity_reset_use_actual_rarity():
    from app.models.schemas import UserPity
    test_engine = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(test_engine)

    with Session(test_engine) as session:
        user = User(
            username="shards_tester",
            hashed_password="pw",
            coins=100000,
            love_gems=1000,
            soul_shards=0
        )
        session.add(user)
        session.commit()
        session.refresh(user)

        # Pre-give user Raiden (UR) and Bocchi (R)
        w_ur = UserWaifu(user_id=user.id, character_id="raiden_genshin", stars=1)
        w_r = UserWaifu(user_id=user.id, character_id="bocchi_hitori", stars=1)
        session.add(w_ur)
        session.add(w_r)
        session.commit()

        # Simulate pull loop and verify duplicate shards
        for _ in range(50):
            res = gacha_service.roll_case(session, user, "standard_banner", count=1)
            drop = res["drops"][0]
            if drop["is_duplicate"]:
                cid = drop["character"]["id"]
                char_rarity = drop["character"]["rarity"]
                expected_shards = {"UR": 50, "SSR": 25, "SR": 10, "R": 3, "N": 1}[char_rarity]
                assert drop["shards_awarded"] == expected_shards, (
                    f"Expected {expected_shards} shards for duplicate {char_rarity} ({cid}), got {drop['shards_awarded']}"
                )

        # Check pity reset on hard pity
        pity_record = session.exec(select(UserPity).where(UserPity.user_id == user.id, UserPity.case_id == "standard_banner")).first()
        assert pity_record is not None
        assert pity_record.pull_count < 60, "Pull count must never exceed pity limit"
