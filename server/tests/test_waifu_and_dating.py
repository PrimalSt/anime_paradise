import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, select
from app.main import app
from app.core.database import init_db, get_session
from app.models.schemas import User, UserWaifu

def test_waifu_collection_features():
    init_db()
    with TestClient(app) as client:
        # Create guest user
        auth_resp = client.post("/api/auth/guest")
        assert auth_resp.status_code == 200
        auth_data = auth_resp.json()
        token = auth_data["access_token"]
        user_id = auth_data["user_id"]
        headers = {"Authorization": f"Bearer {token}"}

        # Pull waifu from standard banner
        roll_resp = client.post("/api/gacha/roll", headers=headers, json={"case_id": "standard_banner", "count": 10})
        assert roll_resp.status_code == 200

        # Get waifus
        waifus_resp = client.get("/api/waifus/", headers=headers)
        assert waifus_resp.status_code == 200
        waifus = waifus_resp.json()
        assert len(waifus) > 0
        waifu = waifus[0]
        wid = waifu["id"]

        # 1. Favorite toggle
        assert waifu["is_favorite"] is False
        fav1 = client.post(f"/api/waifus/{wid}/favorite", headers=headers)
        assert fav1.status_code == 200
        assert fav1.json()["is_favorite"] is True

        fav2 = client.post(f"/api/waifus/{wid}/favorite", headers=headers)
        assert fav2.status_code == 200
        assert fav2.json()["is_favorite"] is False

        # 2. Star Ascension
        # Without soul shards: should fail (user has 0 soul shards initially)
        init_stars = waifu["stars"]
        # Ensure waifu is not max stars for testing ascension
        session = next(get_session())
        waifu_db = session.get(UserWaifu, wid)
        waifu_db.stars = 1
        session.add(waifu_db)
        user_db = session.get(User, user_id)
        user_db.soul_shards = 0
        session.add(user_db)
        session.commit()

        ascend_fail = client.post(f"/api/waifus/{wid}/ascend", headers=headers)
        assert ascend_fail.status_code == 400
        assert "Недостаточно осколков души" in ascend_fail.json()["detail"]

        # Give user soul shards directly in session for test
        user_db = session.get(User, user_id)
        user_db.soul_shards = 200
        session.add(user_db)
        session.commit()

        # Now ascend 1★ -> 2★ (costs 30)
        ascend_ok1 = client.post(f"/api/waifus/{wid}/ascend", headers=headers)
        assert ascend_ok1.status_code == 200
        assert ascend_ok1.json()["stars"] == 2
        assert ascend_ok1.json()["soul_shards"] == 170

        # Ascend 2★ -> 3★ (costs 60)
        ascend_ok2 = client.post(f"/api/waifus/{wid}/ascend", headers=headers)
        assert ascend_ok2.status_code == 200
        assert ascend_ok2.json()["stars"] == 3
        assert ascend_ok2.json()["soul_shards"] == 110

        # 3. Affection Milestones
        # Trying to claim Level 2 when affection is 0: should fail
        claim_fail = client.post(f"/api/waifus/{wid}/claim-milestone", headers=headers, json={"milestone_level": 2})
        assert claim_fail.status_code == 400
        assert "Требуется уровень привязанности" in claim_fail.json()["detail"]

        # Raise waifu affection points and level in db
        waifu_db = session.get(UserWaifu, wid)
        waifu_db.affection_points = 250
        waifu_db.affection_level = 3
        session.add(waifu_db)
        session.commit()

        # Claim Level 2 (+50 gems)
        claim_ok = client.post(f"/api/waifus/{wid}/claim-milestone", headers=headers, json={"milestone_level": 2})
        assert claim_ok.status_code == 200
        assert claim_ok.json()["gems_awarded"] == 50
        assert 2 in claim_ok.json()["claimed_milestones"]

        # Claiming Level 2 again should fail (duplicate)
        claim_dup = client.post(f"/api/waifus/{wid}/claim-milestone", headers=headers, json={"milestone_level": 2})
        assert claim_dup.status_code == 400
        assert "уже получена" in claim_dup.json()["detail"]

        # Claim Level 3 (+100 gems)
        claim_lvl3 = client.post(f"/api/waifus/{wid}/claim-milestone", headers=headers, json={"milestone_level": 3})
        assert claim_lvl3.status_code == 200
        assert claim_lvl3.json()["gems_awarded"] == 100

def test_dating_locations_and_branching():
    init_db()
    with TestClient(app) as client:
        auth_resp = client.post("/api/auth/guest")
        assert auth_resp.status_code == 200
        token = auth_resp.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Pull waifu
        client.post("/api/gacha/roll", headers=headers, json={"case_id": "standard_banner", "count": 10})
        waifus = client.get("/api/waifus/", headers=headers).json()
        wid = waifus[0]["id"]

        # Check locations metadata
        locs = client.get("/api/dating/locations").json()
        assert len(locs) == 4
        loc_map = {l["id"]: l for l in locs}
        for lid in ["sakura_park", "cozy_cafe", "night_festival", "library"]:
            assert lid in loc_map
            assert "vibe" in loc_map[lid]
            assert "duration" in loc_map[lid]
            assert "min_affection_level" in loc_map[lid]

        # Night festival requires level 2. Current level is 1 -> Should fail
        nf_fail = client.post("/api/dating/start", headers=headers, json={"waifu_id": wid, "location_id": "night_festival"})
        assert nf_fail.status_code == 400
        assert "уровень привязанности 2" in nf_fail.json()["detail"]

        # Start Sakura Park (requires level 1) -> Success
        sp_start = client.post("/api/dating/start", headers=headers, json={"waifu_id": wid, "location_id": "sakura_park"})
        assert sp_start.status_code == 200
        data = sp_start.json()
        assert data["node_id"] == "sp_intro"
        assert len(data["choices"]) == 3
        assert "hint" in data["choices"][0]

        # Submit romantic choice 0 -> sp_romantic
        sp_c1 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid,
            "location_id": "sakura_park",
            "node_id": "sp_intro",
            "choice_index": 0
        })
        assert sp_c1.status_code == 200
        assert sp_c1.json()["node_id"] == "sp_romantic"
        assert sp_c1.json()["emotion"] == "blush"

        # Submit choice 0 -> sp_hold_hands (End node + CG unlock)
        sp_c2 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid,
            "location_id": "sakura_park",
            "node_id": "sp_romantic",
            "choice_index": 0
        })
        assert sp_c2.status_code == 200
        assert sp_c2.json()["is_end"] is True
        assert sp_c2.json()["cg_unlocked"] is True
        assert sp_c2.json()["gems_reward"] > 0
        assert "rank_title" in sp_c2.json()

        # Now level waifu up to level 3 in db to test Library branch
        session = next(get_session())
        waifu_db = session.get(UserWaifu, wid)
        waifu_db.affection_level = 3
        waifu_db.affection_points = 300
        session.add(waifu_db)
        session.commit()

        # Start Library date
        lib_start = client.post("/api/dating/start", headers=headers, json={"waifu_id": wid, "location_id": "library"})
        assert lib_start.status_code == 200
        lib_data = lib_start.json()
        assert lib_data["node_id"] == "lib_intro"
        assert len(lib_data["choices"]) == 3

        # Choose choice 0 ("Забудем о книгах...") -> lib_whisper
        lib_c1 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid,
            "location_id": "library",
            "node_id": "lib_intro",
            "choice_index": 0
        })
        assert lib_c1.status_code == 200
        assert lib_c1.json()["node_id"] == "lib_whisper"
        assert lib_c1.json()["emotion"] == "blush"

        # Choose choice 0 -> lib_table_romance (End + CG)
        lib_c2 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid,
            "location_id": "library",
            "node_id": "lib_whisper",
            "choice_index": 0
        })
        assert lib_c2.status_code == 200
        assert lib_c2.json()["is_end"] is True
        assert lib_c2.json()["cg_unlocked"] is True

def test_relationship_ranks_and_confessions():
    init_db()
    with TestClient(app) as client:
        # Check all 13 characters in catalog have authentic confession dialogues
        chars = client.get("/api/waifus/catalog").json()
        assert len(chars) >= 13
        for c in chars:
            dialogues = c.get("dialogues", {})
            assert "confession" in dialogues, f"Character {c['id']} missing confession dialogue"
            assert len(dialogues["confession"]) > 10, f"Character {c['id']} confession is too short"

        # Check relationship rank titles across 1 to 10
        auth_resp = client.post("/api/auth/guest")
        assert auth_resp.status_code == 200
        token = auth_resp.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        client.post("/api/gacha/roll", headers=headers, json={"case_id": "standard_banner", "count": 10})
        waifus = client.get("/api/waifus/", headers=headers).json()
        wid = waifus[0]["id"]

        session = next(get_session())
        waifu_db = session.get(UserWaifu, wid)

        expected_ranks = {
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

        for lvl, expected_title in expected_ranks.items():
            waifu_db.affection_level = lvl
            session.add(waifu_db)
            session.commit()

            start_res = client.post("/api/dating/start", headers=headers, json={"waifu_id": wid, "location_id": "sakura_park"})
            assert start_res.status_code == 200
            data = start_res.json()
            assert data["affection_level"] == lvl
            assert data["rank_title"] == expected_title

def test_outfit_and_interaction_mechanics():
    init_db()
    with TestClient(app) as client:
        auth_resp = client.post("/api/auth/guest")
        assert auth_resp.status_code == 200
        token = auth_resp.json()["access_token"]
        user_id = auth_resp.json()["user_id"]
        headers = {"Authorization": f"Bearer {token}"}

        # Obtain Raiden
        session = next(get_session())
        raiden = UserWaifu(
            user_id=user_id,
            character_id="raiden_genshin",
            stars=1,
            affection_points=10,
            affection_level=1,
            current_outfit_id="default",
            unlocked_outfits=["default"],
            claimed_milestones=[]
        )
        session.add(raiden)
        session.commit()
        session.refresh(raiden)
        wid = raiden.id

        # 1. Outfits test
        # Try equip locked outfit modern_suit -> fails
        equip_fail = client.post(f"/api/waifus/{wid}/equip-outfit", headers=headers, json={"outfit_id": "modern_suit"})
        assert equip_fail.status_code == 400
        assert "ещё не разблокирован" in equip_fail.json()["detail"]

        # Try unlock without shards -> fails
        unlock_fail = client.post(f"/api/waifus/{wid}/unlock-outfit", headers=headers, json={"outfit_id": "modern_suit", "cost": 50})
        assert unlock_fail.status_code == 400
        assert "Недостаточно осколков души" in unlock_fail.json()["detail"]

        # Add soul shards
        user_db = session.get(User, user_id)
        user_db.soul_shards = 200
        session.add(user_db)
        session.commit()

        # Unlock modern_suit -> succeeds
        unlock_ok = client.post(f"/api/waifus/{wid}/unlock-outfit", headers=headers, json={"outfit_id": "modern_suit", "cost": 50})
        assert unlock_ok.status_code == 200
        assert "modern_suit" in unlock_ok.json()["unlocked_outfits"]
        assert unlock_ok.json()["soul_shards"] == 150

        # Equip modern_suit -> succeeds
        equip_ok = client.post(f"/api/waifus/{wid}/equip-outfit", headers=headers, json={"outfit_id": "modern_suit"})
        assert equip_ok.status_code == 200
        assert equip_ok.json()["current_outfit_id"] == "modern_suit"

        # 2. Headpat & cooldown
        hp1 = client.post(f"/api/waifus/{wid}/headpat", headers=headers)
        assert hp1.status_code == 200
        assert hp1.json()["affection_gain"] == 15

        # Second headpat immediately -> 429
        hp2 = client.post(f"/api/waifus/{wid}/headpat", headers=headers)
        assert hp2.status_code == 429
        assert "Погладить можно снова" in hp2.json()["detail"]

        # 3. Feeding with favorite food
        # Give user food items in inventory
        from app.models.schemas import UserInventory
        inv1 = UserInventory(user_id=user_id, item_id="dango_milk", item_type="food", quantity=2)
        session.add(inv1)
        session.commit()

        feed_fav = client.post(f"/api/waifus/{wid}/feed", headers=headers, json={"item_id": "dango_milk"})
        assert feed_fav.status_code == 200
        assert feed_fav.json()["is_favorite"] is True
        # Base affection for dango_milk is 15, favorite gives 2x = 30
        assert feed_fav.json()["affection_gain"] == 30

        # 4. Ascension past 5 stars limit
        user_db = session.get(User, user_id)
        user_db.soul_shards = 1000
        waifu_db = session.get(UserWaifu, wid)
        waifu_db.stars = 5
        session.add(user_db)
        session.add(waifu_db)
        session.commit()

        ascend_max = client.post(f"/api/waifus/{wid}/ascend", headers=headers)
        assert ascend_max.status_code == 400
        assert "максимальный ранг" in ascend_max.json()["detail"]

def test_dating_edge_cases_and_error_handling():
    init_db()
    with TestClient(app) as client:
        auth_resp = client.post("/api/auth/guest")
        assert auth_resp.status_code == 200
        token = auth_resp.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Obtain a waifu
        client.post("/api/gacha/roll", headers=headers, json={"case_id": "standard_banner", "count": 10})
        waifus = client.get("/api/waifus/", headers=headers).json()
        wid = waifus[0]["id"]

        # 1. Invalid location
        inv_loc = client.post("/api/dating/start", headers=headers, json={"waifu_id": wid, "location_id": "nonexistent_loc"})
        assert inv_loc.status_code == 404
        assert "не найдена" in inv_loc.json()["detail"]

        # 2. Non-existent waifu
        inv_w = client.post("/api/dating/start", headers=headers, json={"waifu_id": 999999, "location_id": "sakura_park"})
        assert inv_w.status_code == 404

        # 3. Start valid date
        start_res = client.post("/api/dating/start", headers=headers, json={"waifu_id": wid, "location_id": "sakura_park"})
        assert start_res.status_code == 200

        # 4. Out-of-bounds choice index (-1, 99)
        bad_c1 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid,
            "location_id": "sakura_park",
            "node_id": "sp_intro",
            "choice_index": -1
        })
        assert bad_c1.status_code == 400

        bad_c2 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid,
            "location_id": "sakura_park",
            "node_id": "sp_intro",
            "choice_index": 99
        })
        assert bad_c2.status_code == 400

        # 5. Non-existent node
        bad_node = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid,
            "location_id": "sakura_park",
            "node_id": "fake_node_123",
            "choice_index": 0
        })
        assert bad_node.status_code == 404

        # 6. Invalid location in submit_choice
        bad_loc_choice = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid,
            "location_id": "fake_location",
            "node_id": "sp_intro",
            "choice_index": 0
        })
        assert bad_loc_choice.status_code == 404

def test_all_four_dating_locations_branching_and_cg():
    init_db()
    with TestClient(app) as client:
        auth_resp = client.post("/api/auth/guest")
        token = auth_resp.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        client.post("/api/gacha/roll", headers=headers, json={"case_id": "standard_banner", "count": 10})
        waifus = client.get("/api/waifus/", headers=headers).json()
        wid = waifus[0]["id"]

        session = next(get_session())
        waifu_db = session.get(UserWaifu, wid)
        waifu_db.affection_level = 5  # High enough for all locations
        session.add(waifu_db)
        session.commit()

        # Test cozy cafe
        cc_start = client.post("/api/dating/start", headers=headers, json={"waifu_id": wid, "location_id": "cozy_cafe"})
        assert cc_start.status_code == 200
        assert cc_start.json()["node_id"] == "cc_intro"
        cc_c1 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid, "location_id": "cozy_cafe", "node_id": "cc_intro", "choice_index": 0
        })
        assert cc_c1.status_code == 200
        assert cc_c1.json()["node_id"] == "cc_sweet"
        cc_c2 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid, "location_id": "cozy_cafe", "node_id": "cc_sweet", "choice_index": 0
        })
        assert cc_c2.status_code == 200
        assert cc_c2.json()["is_end"] is True
        assert cc_c2.json()["cg_unlocked"] is True

        # Test night festival
        nf_start = client.post("/api/dating/start", headers=headers, json={"waifu_id": wid, "location_id": "night_festival"})
        assert nf_start.status_code == 200
        assert nf_start.json()["node_id"] == "nf_intro"
        nf_c1 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid, "location_id": "night_festival", "node_id": "nf_intro", "choice_index": 0
        })
        assert nf_c1.status_code == 200
        assert nf_c1.json()["node_id"] == "nf_compliment"
        nf_c2 = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": wid, "location_id": "night_festival", "node_id": "nf_compliment", "choice_index": 0
        })
        assert nf_c2.status_code == 200
        assert nf_c2.json()["is_end"] is True
        assert nf_c2.json()["cg_unlocked"] is True


