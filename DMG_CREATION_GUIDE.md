# Textiq DMG Creation Guide

This guide will help you create a professional .dmg installer for your Textiq macOS application.

## Prerequisites

Before creating the DMG, ensure you have:

1. **Xcode** installed with command line tools
2. **Valid Developer Certificate** (for code signing)
3. **Clean build environment**

## Quick Start

To create your DMG installer, simply run:

```bash
./create_dmg.sh
```

The script will:
- Build your app in Release mode
- Create a professional DMG with proper layout
- Add a custom background and icon positioning
- Compress the final DMG for distribution

## What the Script Does

### 1. Build Process
- Cleans previous builds
- Builds the app using `xcodebuild` in Release configuration
- Archives and exports the application
- Targets macOS 14.0+ as specified in your project

### 2. DMG Creation
- Creates a staging directory with your app
- Adds an "Applications" symlink for easy installation
- Sets up a custom background image
- Configures icon positioning (app on left, Applications on right)
- Compresses the final DMG for optimal file size

### 3. Professional Features
- Custom window size and positioning
- Hidden toolbar and status bar
- Large icons (128px) for better visibility
- Proper drag-and-drop installation layout

## Output

After successful completion, you'll have:
- `Textiq-1.0.dmg` - Your distribution-ready installer

## Code Signing

### For Distribution
If you plan to distribute outside the Mac App Store, you should:

1. **Sign your app** with a Developer ID certificate:
   ```bash
   codesign --force --deep --sign "Developer ID Application: Your Name" Textiq.app
   ```

2. **Notarize the app** (required for macOS 10.15+):
   ```bash
   # Create a zip for notarization
   ditto -c -k --keepParent Textiq.app Textiq.zip
   
   # Submit for notarization
   xcrun notarytool submit Textiq.zip --keychain-profile "notarytool-profile" --wait
   
   # Staple the notarization
   xcrun stapler staple Textiq.app
   ```

3. **Sign the DMG**:
   ```bash
   codesign --sign "Developer ID Application: Your Name" Textiq-1.0.dmg
   ```

### Setting up Notarization Profile

```bash
# Store your credentials securely
xcrun notarytool store-credentials "notarytool-profile" \
  --apple-id "your-apple-id@example.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "app-specific-password"
```

## Customization Options

### Modify the Script
You can customize the DMG by editing `create_dmg.sh`:

- **Change DMG name**: Modify the `DMG_NAME` variable
- **Update version**: Change the `VERSION` variable
- **Customize background**: Replace the SVG background in the script
- **Adjust window size**: Modify the bounds in the AppleScript section
- **Change icon positions**: Update the position coordinates

### Background Image
The script creates a simple gradient background. For a custom background:

1. Create a 600x400 PNG image
2. Replace the SVG generation code with your image
3. Update the background picture path in the AppleScript

## Troubleshooting

### Common Issues

**Build Fails**:
- Ensure Xcode command line tools are installed: `xcode-select --install`
- Check that your project builds successfully in Xcode first
- Verify your bundle identifier matches the project settings

**DMG Creation Fails**:
- Make sure you have enough disk space (script needs ~200MB temporarily)
- Check that no other DMGs with the same name are mounted
- Ensure you have write permissions in the project directory

**Code Signing Issues**:
- Verify your certificates in Keychain Access
- Make sure your Developer ID certificate is valid
- Check that your app's entitlements are properly configured

### Manual Verification

After creating the DMG:

1. **Mount and test**: Double-click the DMG and verify the layout
2. **Install test**: Drag the app to Applications and launch it
3. **Security check**: Right-click the app and select "Open" to test Gatekeeper

## Distribution

### GitHub Releases
1. Go to your GitHub repository
2. Click "Releases" → "Create a new release"
3. Upload your `Textiq-1.0.dmg` file
4. Add release notes describing new features

### Direct Distribution
- Upload to your website
- Share via cloud storage
- Distribute through third-party app stores

## Security Best Practices

1. **Always sign your releases** with a valid Developer ID
2. **Notarize for macOS 10.15+** to avoid Gatekeeper warnings
3. **Use HTTPS** for download links
4. **Provide checksums** (SHA-256) for verification
5. **Keep certificates secure** and rotate them before expiration

## Advanced Features

For more advanced DMG customization, consider:

- **create-dmg tool**: A more feature-rich DMG creation tool
- **Custom installer scripts**: Add post-installation scripts
- **Multi-language support**: Localized DMG backgrounds
- **License agreements**: Add EULA to the DMG

---

**Need Help?**
If you encounter issues, check:
- Apple Developer Documentation
- Xcode build logs
- Console.app for system messages
- Your project's GitHub issues page

Happy distributing! 🚀