#!/bin/bash

# Textiq Code Signing and Notarization Script
# This script helps you sign and notarize your app for distribution

set -e  # Exit on any error

# Configuration - UPDATE THESE VALUES
APP_NAME="Textiq"
APP_PATH="./Textiq.app"  # Path to your built app
DMG_PATH="./Textiq-1.0.dmg"  # Path to your DMG
DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"  # Your Developer ID
APPLE_ID="your-apple-id@example.com"  # Your Apple ID
TEAM_ID="YOUR_TEAM_ID"  # Your Team ID
KEYCHAIN_PROFILE="notarytool-profile"  # Keychain profile name

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Textiq Code Signing and Notarization Tool${NC}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command_exists "codesign"; then
    print_error "codesign not found. Please install Xcode command line tools."
    exit 1
fi

if ! command_exists "xcrun"; then
    print_error "xcrun not found. Please install Xcode command line tools."
    exit 1
fi

print_status "Prerequisites check passed"
echo ""

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    print_error "App not found at $APP_PATH"
    print_info "Please build your app first or update the APP_PATH variable"
    exit 1
fi

# Function to setup notarization profile
setup_notarization() {
    echo "Setting up notarization profile..."
    print_warning "You'll need an app-specific password from appleid.apple.com"
    print_info "Go to https://appleid.apple.com → Sign-In and Security → App-Specific Passwords"
    echo ""
    
    read -p "Enter your Apple ID [$APPLE_ID]: " input_apple_id
    APPLE_ID=${input_apple_id:-$APPLE_ID}
    
    read -p "Enter your Team ID [$TEAM_ID]: " input_team_id
    TEAM_ID=${input_team_id:-$TEAM_ID}
    
    read -s -p "Enter your app-specific password: " app_password
    echo ""
    
    xcrun notarytool store-credentials "$KEYCHAIN_PROFILE" \
        --apple-id "$APPLE_ID" \
        --team-id "$TEAM_ID" \
        --password "$app_password"
    
    print_status "Notarization profile created"
}

# Function to sign the app
sign_app() {
    echo "Signing the application..."
    
    # List available certificates
    echo "Available Developer ID certificates:"
    security find-identity -v -p codesigning | grep "Developer ID Application"
    echo ""
    
    read -p "Enter your Developer ID certificate name [$DEVELOPER_ID]: " input_dev_id
    DEVELOPER_ID=${input_dev_id:-$DEVELOPER_ID}
    
    # Sign the app
    codesign --force --deep --sign "$DEVELOPER_ID" "$APP_PATH"
    
    # Verify signing
    codesign --verify --verbose "$APP_PATH"
    
    print_status "App signed successfully"
}

# Function to notarize the app
notarize_app() {
    echo "Notarizing the application..."
    
    # Create zip for notarization
    ZIP_PATH="${APP_NAME}.zip"
    ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
    
    print_info "Submitting for notarization (this may take a few minutes)..."
    
    # Submit for notarization
    xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$KEYCHAIN_PROFILE" --wait
    
    # Check if notarization was successful
    if [ $? -eq 0 ]; then
        print_status "Notarization successful"
        
        # Staple the notarization
        xcrun stapler staple "$APP_PATH"
        print_status "Notarization stapled to app"
        
        # Clean up
        rm "$ZIP_PATH"
    else
        print_error "Notarization failed"
        rm "$ZIP_PATH"
        exit 1
    fi
}

# Function to sign the DMG
sign_dmg() {
    if [ -f "$DMG_PATH" ]; then
        echo "Signing the DMG..."
        codesign --sign "$DEVELOPER_ID" "$DMG_PATH"
        print_status "DMG signed successfully"
    else
        print_warning "DMG not found at $DMG_PATH. Skipping DMG signing."
    fi
}

# Function to verify everything
verify_signing() {
    echo "Verifying signatures..."
    
    # Verify app
    echo "App verification:"
    codesign --verify --verbose "$APP_PATH"
    spctl --assess --verbose "$APP_PATH"
    
    # Verify DMG if it exists
    if [ -f "$DMG_PATH" ]; then
        echo "DMG verification:"
        codesign --verify --verbose "$DMG_PATH"
    fi
    
    print_status "Verification complete"
}

# Main menu
while true; do
    echo ""
    echo "What would you like to do?"
    echo "1) Setup notarization profile"
    echo "2) Sign app only"
    echo "3) Sign and notarize app"
    echo "4) Sign DMG"
    echo "5) Full process (sign app, notarize, sign DMG)"
    echo "6) Verify signatures"
    echo "7) Exit"
    echo ""
    read -p "Choose an option (1-7): " choice
    
    case $choice in
        1)
            setup_notarization
            ;;
        2)
            sign_app
            ;;
        3)
            sign_app
            notarize_app
            ;;
        4)
            sign_dmg
            ;;
        5)
            sign_app
            notarize_app
            sign_dmg
            print_status "Full signing and notarization process complete!"
            ;;
        6)
            verify_signing
            ;;
        7)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose 1-7."
            ;;
    esac
done