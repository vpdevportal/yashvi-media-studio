#!/bin/bash

set -e

echo "🚀 Starting Yashvi Media Studio with Turborepo..."

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
cd "$ROOT_DIR"

# Install turbo if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing Turborepo dependencies..."
    pnpm install
fi

echo ""
echo "🎉 Starting all services via Turborepo..."
echo "   Backend:  http://localhost:6005"
echo "   Frontend: http://localhost:5005 (web)"
echo ""

# Run dev via Turborepo
pnpm dev
