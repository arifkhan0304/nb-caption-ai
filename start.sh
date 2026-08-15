#!/usr/bin/env bash
set -e

echo "Starting NB Caption AI..."

command -v ffmpeg >/dev/null 2>&1 || {
  echo "[ERROR] ffmpeg not found. Install it (see INSTALLATION.md) and try again."
  exit 1
}

if [ ! -d backend/venv ]; then
  echo "Creating Python virtual environment..."
  python3 -m venv backend/venv
fi

source backend/venv/bin/activate
pip install -q -r backend/requirements.txt

if [ ! -d frontend/node_modules ]; then
  echo "Installing frontend dependencies..."
  (cd frontend && npm install)
fi

(cd backend && uvicorn app.main:app --reload --port "${BACKEND_PORT:-8000}") &
BACKEND_PID=$!

(cd frontend && npm run dev) &
FRONTEND_PID=$!

trap "kill $BACKEND_PID $FRONTEND_PID" EXIT
sleep 3

if command -v xdg-open >/dev/null 2>&1; then xdg-open http://localhost:3000
elif command -v open >/dev/null 2>&1; then open http://localhost:3000
fi

wait
