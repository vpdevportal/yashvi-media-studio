#!/bin/bash

# Migration script for Yashvi Media Studio backend
# Runs Alembic database migrations

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔄 Running database migrations..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Please run setup first."
    exit 1
fi

# Activate virtual environment
source venv/bin/activate

# Run migrations
alembic upgrade head

echo "✅ Migrations completed successfully!"

