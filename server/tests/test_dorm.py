import pytest
from datetime import datetime, timezone, timedelta
from sqlmodel import Session, SQLModel, create_engine
from fastapi import HTTPException
from app.models.schemas import User, UserWaifu
from app.services.dorm_service import dorm_service

def test_dorm_service_full_flow():
    test_engine = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(test_engine)

    with Session(test_engine) as session:
        user = User(
            username="dorm_tester",
            hashed_password="hashed_test_pass",
            coins=100,
            love_gems=10,
            soul_shards=0
        )
        session.add(user)
        session.commit()
        session.refresh(user)

        # 1. Create dorm
        dorm = dorm_service.get_or_create_dorm(session, user)
        assert dorm.comfort_level == 20
        assert dorm.theme == "bg_dorm_room"
        assert dorm.furniture_layout == []
        assert dorm.assigned_waifus == []

        # 2. Update layout with furniture
        layout = [
            {"id": "cozy_bed", "x": 300, "y": 600},
            {"id": "plush_sofa", "x": 750, "y": 620},
            {"id": "tea_table", "x": 1100, "y": 650}
        ]
        res = dorm_service.update_layout(session, user, layout)
        assert res["success"] is True
        # Base 10 + bed(40) + sofa(30) + table(20) = 100
        assert res["comfort_level"] == 100
        assert dorm.comfort_level == 100
        tier = dorm_service.get_comfort_tier(dorm.comfort_level)
        assert "Роскошные" in tier

        # 3. Assign waifus
        dorm_service.assign_waifus(session, user, ["raiden_genshin", "hutao_genshin", "saber_fate"])
        assert len(dorm.assigned_waifus) == 3

        # Test assign limit
        with pytest.raises(HTTPException) as excinfo:
            dorm_service.assign_waifus(session, user, ["1", "2", "3", "4", "5"])
        assert excinfo.value.status_code == 400

        # 4. Income calculation
        # Fast forward time by 60 minutes
        dorm.last_income_collected = datetime.now(timezone.utc) - timedelta(minutes=60)
        session.add(dorm)
        session.commit()

        pending = dorm_service.calculate_pending_income(dorm)
        # coins_per_minute = 2 + (100 * 0.1) + (3 * 1.5) = 2 + 10 + 4.5 = 16.5
        # 60 * 16.5 = 990
        assert pending >= 980 and pending <= 1000

        # Collect
        init_coins = user.coins
        col_res = dorm_service.collect_income(session, user)
        assert col_res["coins_collected"] == pending
        assert user.coins == init_coins + pending

        # 5. Set theme
        theme_res = dorm_service.set_theme(session, user, "bg_cozy_cafe")
        assert theme_res["success"] is True
        assert dorm.theme == "bg_cozy_cafe"

        # Invalid theme
        with pytest.raises(HTTPException):
            dorm_service.set_theme(session, user, "malicious_script_inject")

        # 6. Clean dorm
        clean_res = dorm_service.clean_dorm(session, user)
        assert clean_res["success"] is True
        assert clean_res["coins_reward"] > 0

        # Clean cooldown
        with pytest.raises(HTTPException) as excinfo:
            dorm_service.clean_dorm(session, user)
        assert excinfo.value.status_code == 429

def test_dorm_router_import():
    from app.routers.dorm import router as dorm_router
    assert dorm_router is not None
    assert dorm_router.prefix == "/dorm"

