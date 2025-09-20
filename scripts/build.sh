#!/bin/bash

# Build script for AppLock
# This script builds the application in release mode

set -e

echo "🔨 Building AppLock for macOS..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
swift package clean

# Build in release mode
echo "🚀 Building in release mode..."
swift build -c release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build completed successfully!"
    echo "📍 Executable location: .build/release/AppLock"
else
    echo "❌ Build failed!"
    exit 1
fi

echo "🎉 AppLock is ready to run!"
echo "Run with: ./.build/release/AppLock"
