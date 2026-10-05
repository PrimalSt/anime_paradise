from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.core.config import settings
from app.core.database import init_db
from app.api import auth, gacha, waifus, dorm, dating, shop, quests, achievements

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: ensure tables exist
    init_db()
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Anime Paradise Backend — Gacha, Care & Dating Sim API",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API Routers
app.include_router(auth.router, prefix=settings.API_PREFIX)
app.include_router(gacha.router, prefix=settings.API_PREFIX)
app.include_router(waifus.router, prefix=settings.API_PREFIX)
app.include_router(dorm.router, prefix=settings.API_PREFIX)
app.include_router(dating.router, prefix=settings.API_PREFIX)
app.include_router(shop.router, prefix=settings.API_PREFIX)
app.include_router(quests.router, prefix=settings.API_PREFIX)
app.include_router(achievements.router, prefix=settings.API_PREFIX + "/achievements", tags=["Achievements"])

@app.get("/")
def root():
    return {
        "status": "online",
        "game": "Anime Paradise: Waifu Gacha & Dating Sim",
        "version": settings.VERSION,
        "docs": "/docs"
    }
