@echo off
setlocal
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
  echo [error] .venv not found. Please run: python -m venv .venv
  pause
  exit /b 1
)

if not exist ".env" (
  if exist ".env.example" (
    copy ".env.example" ".env" >nul
    echo [info] Created .env from .env.example. Edit API_KEY for real AI replies.
  )
)

if not exist "frontend\node_modules" (
  echo [setup] Installing frontend dependencies...
  pushd frontend
  call npm install
  popd
)

set PYTHONIOENCODING=utf-8
echo [start] ServiceBot demo stack
echo [open] http://localhost:3000
echo [docs] http://localhost:8000/docs
echo.
".venv\Scripts\python.exe" run_all.py

echo.
echo [stopped] Press any key to close.
pause >nul
