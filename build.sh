#!/bin/bash
set -e

echo "🚀 Starting n8n build process..."

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    pnpm install --frozen-lockfile
fi

# Build the project
echo "🔨 Building n8n..."
pnpm build:deploy

echo "✅ Build completed successfully!"
