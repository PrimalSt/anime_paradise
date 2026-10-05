@echo off
echo ========================================================
echo Starting Anime Paradise Server (FastAPI + SQLModel)...
echo ========================================================
cd server
uv run uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
pause
