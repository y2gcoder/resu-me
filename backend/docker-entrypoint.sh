#!/bin/sh
set -e

echo "🚀 Starting Backend Service..."

cd /workspace/backend

# Check if project files exist
if [ ! -f "pyproject.toml" ]; then
    echo "⏳ Waiting for backend code (pyproject.toml not found)..."
    echo "   Mount your backend code to /workspace/backend"
    # Keep container running for development
    exec tail -f /dev/null
fi

echo "📦 Installing dependencies..."
uv sync --frozen --no-cache

echo "🔄 Running database migrations..."
uv run alembic upgrade head || echo "⚠️  Migration failed or not configured yet"

echo "✅ Starting FastAPI with hot reload..."
exec uv run uvicorn app.main:app \
    --reload \
    --host 0.0.0.0 \
    --port 8000 \
    --reload-dir /workspace/backend