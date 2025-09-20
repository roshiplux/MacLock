#!/bin/bash

# App Icon Generation Script
# This creates AppIcon.icns from SVG

echo "🎨 Creating app icon..."

if command -v rsvg-convert >/dev/null 2>&1; then
    # Convert SVG to PNG at different sizes
    mkdir -p icon_temp
    
    # Generate different sizes for the icon set
    rsvg-convert -w 16 -h 16 AppIcon.svg -o icon_temp/icon_16x16.png
    rsvg-convert -w 32 -h 32 AppIcon.svg -o icon_temp/icon_16x16@2x.png
    rsvg-convert -w 32 -h 32 AppIcon.svg -o icon_temp/icon_32x32.png
    rsvg-convert -w 64 -h 64 AppIcon.svg -o icon_temp/icon_32x32@2x.png
    rsvg-convert -w 128 -h 128 AppIcon.svg -o icon_temp/icon_128x128.png
    rsvg-convert -w 256 -h 256 AppIcon.svg -o icon_temp/icon_128x128@2x.png
    rsvg-convert -w 256 -h 256 AppIcon.svg -o icon_temp/icon_256x256.png
    rsvg-convert -w 512 -h 512 AppIcon.svg -o icon_temp/icon_256x256@2x.png
    rsvg-convert -w 512 -h 512 AppIcon.svg -o icon_temp/icon_512x512.png
    rsvg-convert -w 1024 -h 1024 AppIcon.svg -o icon_temp/icon_512x512@2x.png
    
    # Create iconset
    mkdir -p AppIcon.iconset
    cp icon_temp/*.png AppIcon.iconset/
    
    # Generate .icns file
    iconutil -c icns AppIcon.iconset
    
    # Clean up
    rm -rf icon_temp AppIcon.iconset
    
    echo "✅ AppIcon.icns created successfully!"
else
    echo "⚠️ rsvg-convert not found. Installing..."
    if command -v brew >/dev/null 2>&1; then
        brew install librsvg
        echo "✅ librsvg installed. Please run this script again."
    else
        echo "❌ Please install librsvg or Homebrew first."
        echo "Alternative: Use online SVG to ICNS converter and save as AppIcon.icns"
    fi
fi
