from fastapi.testclient import TestClient
from app.main import app
from app.core.database import init_db, get_session
from sqlmodel import Session, select
from app.models.schemas import User

def test_achievements_flow():
    init_db()
    with TestClient(app) as client:
        # Register a guest user
        guest_resp = client.post("/api/auth/guest")
        assert guest_resp.status_code == 200
        auth_data = guest_resp.json()
        token = auth_data["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Check achievements initially
        ach_resp = client.get("/api/achievements/", headers=headers)
        assert ach_resp.status_code == 200
        achievements = ach_resp.json()
        assert len(achievements) > 0
        
        # Verify first_pull is not completed
        first_pull = next(a for a in achievements if a["id"] == "first_pull")
        assert not first_pull["completed"]
        
        # Make a pull
        pull_resp = client.post("/api/gacha/pull", headers=headers, json={"case_id": "standard_banner", "count": 1})
        assert pull_resp.status_code == 200

        # Check achievements again
        ach_resp2 = client.get("/api/achievements/", headers=headers)
        assert ach_resp2.status_code == 200
        achievements2 = ach_resp2.json()
        
        first_pull2 = next(a for a in achievements2 if a["id"] == "first_pull")
        assert first_pull2["completed"]
        assert not first_pull2["claimed"]
        
        # Claim achievement
        claim_resp = client.post("/api/achievements/claim", headers=headers, json={"achievement_id": "first_pull"})
        assert claim_resp.status_code == 200
        claim_data = claim_resp.json()
        assert claim_data["success"] is True
        assert claim_data["reward_type"] == "love_gems"
        
        # Verify it's claimed in the list
        ach_resp3 = client.get("/api/achievements/", headers=headers)
        assert ach_resp3.status_code == 200
        first_pull3 = next(a for a in ach_resp3.json() if a["id"] == "first_pull")
        assert first_pull3["claimed"]
        
        # Try to claim again
        claim_again_resp = client.post("/api/achievements/claim", headers=headers, json={"achievement_id": "first_pull"})
        assert claim_again_resp.status_code == 400
        
        # Try to claim incomplete
        claim_incomplete_resp = client.post("/api/achievements/claim", headers=headers, json={"achievement_id": "date_master"})
        assert claim_incomplete_resp.status_code == 400
