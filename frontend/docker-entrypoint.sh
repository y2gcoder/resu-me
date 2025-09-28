#!/bin/sh
set -e

echo "🚀 Starting Frontend Service..."

cd /workspace/frontend

# Check if project files exist
if [ ! -f "package.json" ]; then
    echo "⏳ Waiting for frontend code (package.json not found)..."
    echo "   Mount your frontend code to /workspace/frontend"
    # Keep container running for development
    exec tail -f /dev/null
fi

echo "📦 Installing dependencies..."
pnpm install --frozen-lockfile

echo "✅ Starting Next.js dev server..."
exec pnpm dev --hostname 0.0.0.0 --port ${PORT:-3000}