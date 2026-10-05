@echo off
echo ========================================================
echo Starting Anime Paradise (Server + Client)...
echo ========================================================
start "Anime Paradise Server" cmd /k "cd server && uv run uvicorn app.main:app --reload --host 127.0.0.1 --port 8000"
timeout /t 2 /nobreak >nul
start "Anime Paradise Client" "C:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --path "%~dp0client"
