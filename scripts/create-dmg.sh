#!/bin/bash

# Simple DMG Creation Script for MacLock
set -e

APP_NAME="MacLock"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR=".build/release"
DIST_DIR="dist"
APP_BUNDLE="${APP_NAME}.app"

echo "📦 Creating DMG installer for ${APP_NAME}..."

# Build first
swift build -c release

# Create dist directory
mkdir -p "${DIST_DIR}"
rm -rf "${DIST_DIR}/${APP_BUNDLE}"

# Create app bundle
mkdir -p "${DIST_DIR}/${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${DIST_DIR}/${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${DIST_DIR}/${APP_BUNDLE}/Contents/MacOS/"

# Copy the project Info.plist which has all the correct settings
cp "Info.plist" "${DIST_DIR}/${APP_BUNDLE}/Contents/"

# Also create a backup Info.plist in case the copy fails
cat > "${DIST_DIR}/${APP_BUNDLE}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.pluxcore.maclock</string>
    <key>CFBundleName</key>
    <string>Mac Lock</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
</dict>
</plist>
EOF

# Create PkgInfo
echo "APPL????" > "${DIST_DIR}/${APP_BUNDLE}/Contents/PkgInfo"

# Make executable
chmod +x "${DIST_DIR}/${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Create staging directory
mkdir -p dmg_staging
rm -rf dmg_staging/*
cp -R "${DIST_DIR}/${APP_BUNDLE}" dmg_staging/
ln -sf /Applications dmg_staging/

# Create DMG
DMG_PATH="${DIST_DIR}/${DMG_NAME}.dmg"
rm -f "${DMG_PATH}"

hdiutil create -volname "${APP_NAME}" -srcfolder dmg_staging -format UDZO "${DMG_PATH}"

# Clean up
rm -rf dmg_staging

echo "✅ DMG created: ${DMG_PATH}"
echo "📏 Size: $(du -h "${DMG_PATH}" | cut -f1)"

# Open dist folder
open "${DIST_DIR}"
