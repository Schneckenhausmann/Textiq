#!/bin/bash

# Simplified Textiq DMG Creation Script
# This script works with Xcode command line tools and manual app building

set -e  # Exit on any error

# Configuration
APP_NAME="Textiq"
VERSION="1.0"
DMG_NAME="${APP_NAME}-${VERSION}"
DMG_DIR="dmg_temp"
FINAL_DMG="${DMG_NAME}.dmg"

echo "🚀 Starting simplified DMG creation for ${APP_NAME} v${VERSION}"
echo ""
echo "📋 Prerequisites:"
echo "   1. Build your app in Xcode (Product → Archive → Export)"
echo "   2. Place the exported Textiq.app in this directory"
echo ""

# Check if app exists
if [ ! -d "Textiq.app" ]; then
    echo "❌ Textiq.app not found in current directory"
    echo ""
    echo "📝 To build your app manually:"
    echo "   1. Open Textiq.xcodeproj in Xcode"
    echo "   2. Select 'Any Mac' as the destination"
    echo "   3. Go to Product → Archive"
    echo "   4. Click 'Distribute App'"
    echo "   5. Choose 'Copy App'"
    echo "   6. Save and copy Textiq.app to this directory"
    echo "   7. Run this script again"
    echo ""
    exit 1
fi

echo "✅ Found Textiq.app"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "${DMG_DIR}"
rm -f "${FINAL_DMG}"
rm -f "${DMG_NAME}-temp.dmg"

# Create DMG staging directory
echo "📁 Creating DMG staging directory..."
mkdir -p "${DMG_DIR}"

# Copy the app to DMG directory
echo "📦 Copying app to DMG..."
cp -R "Textiq.app" "${DMG_DIR}/"

# Create Applications symlink
ln -s /Applications "${DMG_DIR}/Applications"

# Create a background image directory
echo "🎨 Creating DMG background..."
mkdir -p "${DMG_DIR}/.background"

# Create a simple background image using built-in tools
cat > "${DMG_DIR}/.background/background.svg" << 'EOF'
<svg width="600" height="400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#f8f9fa;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#e9ecef;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#grad1)"/>
  <text x="300" y="50" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="28" font-weight="600" text-anchor="middle" fill="#1d1d1f">Welcome to Textiq</text>
  <text x="300" y="85" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="16" text-anchor="middle" fill="#86868b">Drag Textiq to Applications to install</text>
  <circle cx="150" cy="200" r="80" fill="none" stroke="#007AFF" stroke-width="2" stroke-dasharray="5,5" opacity="0.3"/>
  <text x="150" y="205" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="14" text-anchor="middle" fill="#007AFF">Textiq</text>
  <path d="M 250 200 L 350 200" stroke="#86868b" stroke-width="2" marker-end="url(#arrowhead)" opacity="0.6"/>
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#86868b" opacity="0.6"/>
    </marker>
  </defs>
  <circle cx="450" cy="200" r="80" fill="none" stroke="#34C759" stroke-width="2" stroke-dasharray="5,5" opacity="0.3"/>
  <text x="450" y="205" font-family="-apple-system, BlinkMacSystemFont, sans-serif" font-size="14" text-anchor="middle" fill="#34C759">Applications</text>
</svg>
EOF

# Calculate DMG size
DMG_SIZE=$(du -sm "${DMG_DIR}" | cut -f1)
DMG_SIZE=$((DMG_SIZE + 50))  # Add 50MB padding

echo "💿 Creating temporary DMG (${DMG_SIZE}MB)..."

# Create temporary DMG
hdiutil create -srcfolder "${DMG_DIR}" \
               -volname "${APP_NAME}" \
               -fs HFS+ \
               -fsargs "-c c=64,a=16,e=16" \
               -format UDRW \
               -size ${DMG_SIZE}m \
               "${DMG_NAME}-temp.dmg"

echo "🔧 Mounting DMG for customization..."

# Mount the temporary DMG
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${DMG_NAME}-temp.dmg" | egrep '^/dev/' | sed 1q | awk '{print $1}')
VOLUME_PATH="/Volumes/${APP_NAME}"

# Wait for mount
sleep 3

echo "🎯 Configuring DMG appearance..."

# Set up the DMG window properties using AppleScript
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
        set background picture of viewOptions to file ".background:background.svg"
        set position of item "${APP_NAME}.app" of container window to {150, 200}
        set position of item "Applications" of container window to {450, 200}
        close
        open
        update without registering applications
        delay 3
        close
    end tell
end tell
EOF

echo "🔒 Hiding background folder..."
# Hide background folder
chflags hidden "${VOLUME_PATH}/.background" 2>/dev/null || true

echo "💾 Finalizing DMG..."
# Sync and unmount
sync
sleep 2
hdiutil detach "${DEVICE}"

echo "🗜️  Compressing final DMG..."
# Convert to final compressed DMG
hdiutil convert "${DMG_NAME}-temp.dmg" \
               -format UDZO \
               -imagekey zlib-level=9 \
               -o "${FINAL_DMG}"

# Clean up
rm -f "${DMG_NAME}-temp.dmg"
rm -rf "${DMG_DIR}"

# Get final DMG info
FINAL_SIZE=$(du -h "${FINAL_DMG}" | cut -f1)
FINAL_PATH=$(pwd)/${FINAL_DMG}

echo ""
echo "🎉 DMG creation completed successfully!"
echo "📁 Output: ${FINAL_DMG}"
echo "📏 Size: ${FINAL_SIZE}"
echo "📍 Full path: ${FINAL_PATH}"
echo ""
echo "✨ Your professional DMG installer is ready!"
echo ""
echo "📋 Next steps:"
echo "   1. Test the DMG by double-clicking it"
echo "   2. Verify the installation by dragging to Applications"
echo "   3. For distribution, consider code signing (see sign_and_notarize.sh)"
echo "   4. Upload to GitHub releases or your distribution platform"
echo ""
echo "🚀 Happy distributing!"