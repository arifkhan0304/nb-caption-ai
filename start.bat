@echo off
echo Starting NB Caption AI...

where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] ffmpeg was not found on PATH. Install it and try again.
    echo See INSTALLATION.md for instructions.
    pause
    exit /b 1
)

if not exist backend\venv (
    echo Creating Python virtual environment...
    python -m venv backend\venv
)

call backend\venv\Scripts\activate.bat
pip install -q -r backend\requirements.txt

if not exist frontend\node_modules (
    echo Installing frontend dependencies...
    pushd frontend
    call npm install
    popd
)

start "NB Caption AI - Backend" cmd /k "call backend\venv\Scripts\activate.bat && uvicorn app.main:app --app-dir backend --reload --port 8000"
start "NB Caption AI - Frontend" cmd /k "cd frontend && npm run dev"

timeout /t 4 >nul
start http://localhost:3000
