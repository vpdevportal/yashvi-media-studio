#!/bin/bash

set -e

echo "🚀 Starting Yashvi Media Studio (macOS app + backend)..."

# Project root
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

# Setup backend venv if needed
if [ ! -d "apps/backend/venv" ]; then
    echo "📦 Setting up backend virtual environment..."
    cd apps/backend
    python3 -m venv venv
    cd "$ROOT_DIR"
fi

# Always install/update requirements
echo "📦 Installing backend dependencies..."
cd apps/backend
source venv/bin/activate
pip install -q -r requirements.txt

# Start backend in background
echo "🔧 Starting backend server..."
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
cd "$ROOT_DIR"

# Start Flutter macOS app
echo "🍎 Starting Flutter macOS app..."
cd apps/frontend
flutter run -d macos

# Cleanup backend when frontend exits
kill $BACKEND_PID 2>/dev/null || true


