#!/bin/bash

# Complete Icon Generation Script for MacLock
# This creates all necessary icons for a professional macOS app

echo "🎨 Creating complete icon set for MacLock..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if SVG file exists
if [ ! -f "AppIcon.svg" ]; then
    print_error "AppIcon.svg not found! Please ensure it exists in the project root."
    exit 1
fi

# Check for required tools
if ! command -v rsvg-convert >/dev/null 2>&1; then
    print_warning "rsvg-convert not found. Installing..."
    if command -v brew >/dev/null 2>&1; then
        brew install librsvg
        print_success "librsvg installed."
    else
        print_error "Please install librsvg or Homebrew first."
        exit 1
    fi
fi

# Create temporary directories
mkdir -p temp_icons/{app,menubar,dmg}

print_status "1. Creating App Icon Set (.icns)..."

# Generate app icon PNG files at different sizes
rsvg-convert -w 16 -h 16 AppIcon.svg -o temp_icons/app/icon_16x16.png
rsvg-convert -w 32 -h 32 AppIcon.svg -o temp_icons/app/icon_16x16@2x.png
rsvg-convert -w 32 -h 32 AppIcon.svg -o temp_icons/app/icon_32x32.png
rsvg-convert -w 64 -h 64 AppIcon.svg -o temp_icons/app/icon_32x32@2x.png
rsvg-convert -w 128 -h 128 AppIcon.svg -o temp_icons/app/icon_128x128.png
rsvg-convert -w 256 -h 256 AppIcon.svg -o temp_icons/app/icon_128x128@2x.png
rsvg-convert -w 256 -h 256 AppIcon.svg -o temp_icons/app/icon_256x256.png
rsvg-convert -w 512 -h 512 AppIcon.svg -o temp_icons/app/icon_256x256@2x.png
rsvg-convert -w 512 -h 512 AppIcon.svg -o temp_icons/app/icon_512x512.png
rsvg-convert -w 1024 -h 1024 AppIcon.svg -o temp_icons/app/icon_512x512@2x.png

# Create iconset directory and copy files
mkdir -p AppIcon.iconset
cp temp_icons/app/*.png AppIcon.iconset/

# Generate .icns file
iconutil -c icns AppIcon.iconset -o AppIcon.icns

# Clean up iconset directory
rm -rf AppIcon.iconset

print_success "AppIcon.icns created successfully!"

print_status "2. Creating Menu Bar Icons..."

# Create menu bar icon (template style - black with transparency)
# First create a simplified version for menu bar
cat > temp_menubar_icon.svg << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <!-- Simplified lock for menu bar -->
  <rect x="20" y="28" width="24" height="20" rx="2" ry="2" fill="black"/>
  <!-- Lock shackle -->
  <path d="M 26 28 L 26 22 A 6 6 0 0 1 38 22 L 38 28" 
        fill="none" stroke="black" stroke-width="3" stroke-linecap="round"/>
  <!-- Lock hole -->
  <circle cx="32" cy="36" r="3" fill="white"/>
</svg>
EOF

# Generate menu bar icons
rsvg-convert -w 16 -h 16 temp_menubar_icon.svg -o temp_icons/menubar/menubar_16x16.png
rsvg-convert -w 32 -h 32 temp_menubar_icon.svg -o temp_icons/menubar/menubar_16x16@2x.png

print_success "Menu bar icons created!"

print_status "3. Creating DMG Icons..."

# Create DMG volume icon (same as app icon but optimized for DMG)
rsvg-convert -w 512 -h 512 AppIcon.svg -o temp_icons/dmg/dmg_icon_512.png
rsvg-convert -w 1024 -h 1024 AppIcon.svg -o temp_icons/dmg/dmg_icon_1024.png

# Create iconset for DMG
mkdir -p DMGIcon.iconset
cp temp_icons/app/icon_*.png DMGIcon.iconset/
iconutil -c icns DMGIcon.iconset -o DMGIcon.icns
rm -rf DMGIcon.iconset

print_success "DMG icons created!"

print_status "4. Organizing final icons..."

# Create Resources directory if it doesn't exist
mkdir -p Resources

# Move final icons to Resources
mv AppIcon.icns Resources/
mv DMGIcon.icns Resources/
mv temp_icons/menubar/menubar_16x16.png Resources/MenuBarIcon.png
mv temp_icons/menubar/menubar_16x16@2x.png Resources/MenuBarIcon@2x.png

# Clean up temporary files
rm -rf temp_icons temp_menubar_icon.svg

print_success "All icons created successfully!"

echo ""
echo "📁 Icon Files Created:"
echo "├── Resources/AppIcon.icns          - Main application icon"
echo "├── Resources/MenuBarIcon.png       - Menu bar icon @1x"
echo "├── Resources/MenuBarIcon@2x.png    - Menu bar icon @2x"
echo "└── Resources/DMGIcon.icns          - DMG installer icon"
echo ""
echo "🔧 Next Steps:"
echo "1. Update Info.plist to reference AppIcon.icns"
echo "2. Update MenuBar implementation to use custom icons"
echo "3. Update DMG creation script to use DMGIcon.icns"
echo "4. Test all icons in different contexts"
echo ""
print_success "Icon generation complete! 🎉"