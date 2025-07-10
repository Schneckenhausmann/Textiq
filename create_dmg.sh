#!/bin/bash

# Textiq DMG Creation Script
# This script builds the app and creates a professional .dmg installer

set -e  # Exit on any error

# Configuration
APP_NAME="Textiq"
BUNDLE_ID="com.textiq.Textiq"
VERSION="1.0"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR="build"
DMG_DIR="dmg_temp"
FINAL_DMG="${DMG_NAME}.dmg"

echo "🚀 Starting DMG creation for ${APP_NAME} v${VERSION}"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "${BUILD_DIR}"
rm -rf "${DMG_DIR}"
rm -f "${FINAL_DMG}"
rm -f "${DMG_NAME}-temp.dmg"

# Create build directory
mkdir -p "${BUILD_DIR}"

# Build the app in Release mode
echo "🔨 Building ${APP_NAME} in Release mode..."
xcodebuild -project "Textiq.xcodeproj" \
           -scheme "Textiq" \
           -configuration Release \
           -derivedDataPath "${BUILD_DIR}" \
           -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" \
           archive

# Export the app
echo "📦 Exporting application..."
cat > "${BUILD_DIR}/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
           -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" \
           -exportPath "${BUILD_DIR}/Export" \
           -exportOptionsPlist "${BUILD_DIR}/ExportOptions.plist"

# Verify the app was built
if [ ! -d "${BUILD_DIR}/Export/${APP_NAME}.app" ]; then
    echo "❌ Error: ${APP_NAME}.app not found in export directory"
    exit 1
fi

echo "✅ App built successfully"

# Create DMG staging directory
echo "📁 Creating DMG staging directory..."
mkdir -p "${DMG_DIR}"

# Copy the app to DMG directory
cp -R "${BUILD_DIR}/Export/${APP_NAME}.app" "${DMG_DIR}/"

# Create Applications symlink
ln -s /Applications "${DMG_DIR}/Applications"

# Create a background image (simple gradient)
echo "🎨 Creating DMG background..."
mkdir -p "${DMG_DIR}/.background"

# Create a simple SVG background
cat > "${DMG_DIR}/.background/background.svg" << 'EOF'
<svg width="600" height="400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#f8f9fa;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#e9ecef;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#grad1)"/>
  <text x="300" y="50" font-family="Arial, sans-serif" font-size="24" font-weight="bold" text-anchor="middle" fill="#495057">Welcome to Textiq</text>
  <text x="300" y="80" font-family="Arial, sans-serif" font-size="14" text-anchor="middle" fill="#6c757d">Drag Textiq to Applications to install</text>
</svg>
EOF

# Convert SVG to PNG for DMG background (if available)
if command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -w 600 -h 400 "${DMG_DIR}/.background/background.svg" > "${DMG_DIR}/.background/background.png"
else
    echo "⚠️  rsvg-convert not found. DMG will use default background."
fi

# Create DS_Store for proper icon positioning
echo "📐 Setting up DMG layout..."

# Calculate DMG size
DMG_SIZE=$(du -sm "${DMG_DIR}" | cut -f1)
DMG_SIZE=$((DMG_SIZE + 50))  # Add 50MB padding

# Create temporary DMG
echo "💿 Creating temporary DMG..."
hdiutil create -srcfolder "${DMG_DIR}" \
               -volname "${APP_NAME}" \
               -fs HFS+ \
               -fsargs "-c c=64,a=16,e=16" \
               -format UDRW \
               -size ${DMG_SIZE}m \
               "${DMG_NAME}-temp.dmg"

# Mount the temporary DMG
echo "🔧 Mounting DMG for customization..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${DMG_NAME}-temp.dmg" | egrep '^/dev/' | sed 1q | awk '{print $1}')
VOLUME_PATH="/Volumes/${APP_NAME}"

# Wait for mount
sleep 2

# Set up the DMG window properties using AppleScript
echo "🎯 Configuring DMG appearance..."
osascript << EOF
tell application "Finder"
    tell disk "${APP_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 1000, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        if exists file ".background:background.png" then
            set background picture of viewOptions to file ".background:background.png"
        end if
        set position of item "${APP_NAME}.app" of container window to {150, 200}
        set position of item "Applications" of container window to {450, 200}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Hide background folder
chflags hidden "${VOLUME_PATH}/.background" 2>/dev/null || true

# Sync and unmount
echo "💾 Finalizing DMG..."
sync
hdiutil detach "${DEVICE}"

# Convert to final compressed DMG
echo "🗜️  Compressing final DMG..."
hdiutil convert "${DMG_NAME}-temp.dmg" \
               -format UDZO \
               -imagekey zlib-level=9 \
               -o "${FINAL_DMG}"

# Clean up
rm -f "${DMG_NAME}-temp.dmg"
rm -rf "${BUILD_DIR}"
rm -rf "${DMG_DIR}"

# Get final DMG size
FINAL_SIZE=$(du -h "${FINAL_DMG}" | cut -f1)

echo "🎉 DMG creation completed!"
echo "📁 Output: ${FINAL_DMG}"
echo "📏 Size: ${FINAL_SIZE}"
echo ""
echo "Your professional DMG installer is ready for distribution! 🚀"
echo "You can now upload this DMG to your GitHub releases or distribute it to users."