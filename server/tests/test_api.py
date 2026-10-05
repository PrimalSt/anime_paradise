from fastapi.testclient import TestClient
from app.main import app
from app.core.database import init_db

def test_api_full_flow():
    init_db()
    with TestClient(app) as client:
        # 1. Root healthcheck
        root_resp = client.get("/")
        assert root_resp.status_code == 200
        assert root_resp.json()["status"] == "online"

        # 2. Guest Registration
        guest_resp = client.post("/api/auth/guest")
        assert guest_resp.status_code == 200
        auth_data = guest_resp.json()
        token = auth_data["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        assert auth_data["coins"] >= 1500

        # 3. Check /me
        me_resp = client.get("/api/auth/me", headers=headers)
        assert me_resp.status_code == 200
        assert me_resp.json()["username"] == auth_data["username"]

        # 4. List Gacha Cases
        cases_resp = client.get("/api/gacha/cases")
        assert cases_resp.status_code == 200
        cases = cases_resp.json()
        assert len(cases) >= 3

        # 5. Roll standard banner 10x via /roll and 1x via /pull
        roll_resp = client.post("/api/gacha/roll", headers=headers, json={"case_id": "standard_banner", "count": 10})
        assert roll_resp.status_code == 200
        roll_data = roll_resp.json()
        assert len(roll_data["drops"]) == 10
        assert roll_data["new_balance"]["coins"] < auth_data["coins"]

        pull_resp = client.post("/api/gacha/pull", headers=headers, json={"case_id": "standard_banner", "count": 1})
        assert pull_resp.status_code == 200
        pull_data = pull_resp.json()
        assert len(pull_data["drops"]) == 1

        # 6. Check user waifus
        waifus_resp = client.get("/api/waifus/", headers=headers)
        assert waifus_resp.status_code == 200
        waifus = waifus_resp.json()
        assert len(waifus) > 0
        first_waifu_id = waifus[0]["id"]

        # 7. Headpat waifu
        hp_resp = client.post(f"/api/waifus/{first_waifu_id}/headpat", headers=headers)
        assert hp_resp.status_code == 200
        assert hp_resp.json()["success"] is True

        # 8. Buy food from shop
        buy_resp = client.post("/api/shop/buy", headers=headers, json={"item_id": "strawberry_cake", "quantity": 1})
        assert buy_resp.status_code == 200

        # 9. Feed waifu
        feed_resp = client.post(f"/api/waifus/{first_waifu_id}/feed", headers=headers, json={"item_id": "strawberry_cake"})
        assert feed_resp.status_code == 200
        assert feed_resp.json()["success"] is True

        # 10. Check dorm
        dorm_resp = client.get("/api/dorm/", headers=headers)
        assert dorm_resp.status_code == 200
        dorm_json = dorm_resp.json()
        assert "comfort_level" in dorm_json
        assert "coins_per_minute" in dorm_json
        assert "comfort_tier" in dorm_json
        assert "theme" in dorm_json

        # 10a. Update dorm theme
        theme_resp = client.post("/api/dorm/theme", headers=headers, json={"theme": "bg_cozy_cafe"})
        assert theme_resp.status_code == 200
        assert theme_resp.json()["theme"] == "bg_cozy_cafe"

        # 10b. Clean dorm
        clean_resp = client.post("/api/dorm/clean", headers=headers)
        assert clean_resp.status_code == 200
        assert clean_resp.json()["success"] is True

        # 11. Start date
        date_resp = client.post("/api/dating/start", headers=headers, json={"waifu_id": first_waifu_id, "location_id": "sakura_park"})
        assert date_resp.status_code == 200
        assert "narrative_text" in date_resp.json()
        assert len(date_resp.json()["choices"]) > 0
        assert "rank_title" in date_resp.json()

        # 12. Submit date choice
        choice_resp = client.post("/api/dating/choice", headers=headers, json={
            "waifu_id": first_waifu_id,
            "location_id": "sakura_park",
            "node_id": date_resp.json()["node_id"],
            "choice_index": 0
        })
        assert choice_resp.status_code == 200
        assert choice_resp.json()["affection_gain"] > 0
        assert "rank_title" in choice_resp.json()

        # 13. Test Dating locations metadata
        locs_resp = client.get("/api/dating/locations")
        assert locs_resp.status_code == 200
        locs = locs_resp.json()
        assert len(locs) == 4
        loc_ids = [l["id"] for l in locs]
        assert "sakura_park" in loc_ids
        assert "cozy_cafe" in loc_ids
        assert "night_festival" in loc_ids
        assert "library" in loc_ids

        # 14. Favorite toggle
        fav_resp = client.post(f"/api/waifus/{first_waifu_id}/favorite", headers=headers)
        assert fav_resp.status_code == 200
        assert fav_resp.json()["is_favorite"] is True
        fav_resp2 = client.post(f"/api/waifus/{first_waifu_id}/favorite", headers=headers)
        assert fav_resp2.status_code == 200
        assert fav_resp2.json()["is_favorite"] is False

        # 15. Star Ascension (with insufficient shards test)
        ascend_fail = client.post(f"/api/waifus/{first_waifu_id}/ascend", headers=headers)
        assert ascend_fail.status_code == 400  # not enough soul shards initially
