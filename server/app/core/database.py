from sqlmodel import SQLModel, create_engine, Session
from app.core.config import settings

engine = create_engine(
    settings.DATABASE_URL,
    echo=False,
    connect_args={"check_same_thread": False} if "sqlite" in settings.DATABASE_URL else {}
)

from sqlalchemy import text

def init_db():
    SQLModel.metadata.create_all(engine)
    if "sqlite" in settings.DATABASE_URL:
        with engine.connect() as conn:
            try:
                cols = [row[1] for row in conn.execute(text("PRAGMA table_info(dormstate)")).fetchall()]
                if cols and "theme" not in cols:
                    conn.execute(text("ALTER TABLE dormstate ADD COLUMN theme VARCHAR DEFAULT 'bg_dorm_room'"))
                if cols and "last_cleaned" not in cols:
                    conn.execute(text("ALTER TABLE dormstate ADD COLUMN last_cleaned DATETIME"))
                
                waifu_cols = [row[1] for row in conn.execute(text("PRAGMA table_info(userwaifu)")).fetchall()]
                if waifu_cols and "is_favorite" not in waifu_cols:
                    conn.execute(text("ALTER TABLE userwaifu ADD COLUMN is_favorite BOOLEAN DEFAULT 0"))
                if waifu_cols and "claimed_milestones_json" not in waifu_cols:
                    conn.execute(text("ALTER TABLE userwaifu ADD COLUMN claimed_milestones_json VARCHAR DEFAULT '[]'"))

                user_cols = [row[1] for row in conn.execute(text("PRAGMA table_info(user)")).fetchall()]
                if user_cols:
                    if "last_daily_bonus" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN last_daily_bonus DATETIME"))
                    if "daily_dates" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN daily_dates INTEGER DEFAULT 0"))
                    if "daily_dorm_collects" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN daily_dorm_collects INTEGER DEFAULT 0"))
                    if "daily_cases_opened" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN daily_cases_opened INTEGER DEFAULT 0"))
                    if "quests_claimed_json" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN quests_claimed_json VARCHAR DEFAULT '[]'"))
                    if "last_quest_reset" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN last_quest_reset DATETIME"))
                    if "total_pulls" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN total_pulls INTEGER DEFAULT 0"))
                    if "total_dates" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN total_dates INTEGER DEFAULT 0"))
                    if "claimed_achievements_json" not in user_cols:
                        conn.execute(text("ALTER TABLE user ADD COLUMN claimed_achievements_json VARCHAR DEFAULT '[]'"))

                conn.commit()
            except Exception as e:
                print("Migration error:", e)
                pass

def get_session():
    with Session(engine) as session:
        yield session
