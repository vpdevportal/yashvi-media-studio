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
cd "$ROOT_DIR/apps/backend"
source venv/bin/activate
pip install -q -r requirements.txt
cd "$ROOT_DIR"

# Start Flutter macOS app in background (logs in browser console)
echo "🍎 Starting Flutter macOS app in background..."
cd "$ROOT_DIR/apps/frontend"
flutter run -d macos > /dev/null 2>&1 &
FLUTTER_PID=$!
cd "$ROOT_DIR"

# Function to cleanup Flutter on exit
cleanup() {
    echo ""
    echo "🛑 Stopping Flutter app (PID: $FLUTTER_PID)..."
    kill $FLUTTER_PID 2>/dev/null || true
    wait $FLUTTER_PID 2>/dev/null || true
    exit
}
trap cleanup EXIT INT TERM

# Wait a moment for Flutter to start
sleep 3
echo "✅ Flutter app started (PID: $FLUTTER_PID)"
echo "   Frontend logs available in browser console (F12)"
echo ""

# Check and kill any process using port 8000
echo "🔍 Checking for processes on port 8000..."
PORT=8000
PID=$(lsof -ti:$PORT 2>/dev/null) || PID=""
if [ -n "$PID" ]; then
    echo "⚠️  Found process $PID using port $PORT, killing it..."
    kill -9 $PID 2>/dev/null || true
    sleep 1
    echo "✅ Port $PORT is now free"
else
    echo "✅ Port $PORT is free"
fi

# Start backend in foreground (logs visible in terminal)
echo "🔧 Starting backend server in foreground..."
echo "📋 Backend logs will appear below:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$ROOT_DIR/apps/backend"
source venv/bin/activate

# Run backend in foreground with unbuffered output
# This will block and show all backend logs
python -u -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000


