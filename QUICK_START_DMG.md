# 🚀 Quick Start: Create Professional DMG for Textiq

This guide will help you create a professional .dmg installer for your Textiq app in just a few steps.

## 📋 What You Need

- ✅ Xcode installed
- ✅ Your Textiq project (already done!)
- ⏱️ 5-10 minutes

## 🎯 Quick Steps

### Step 1: Build Your App

1. **Open Xcode**: Double-click `Textiq.xcodeproj`
2. **Select Target**: Choose "Any Mac" in the destination dropdown
3. **Archive**: Go to `Product` → `Archive`
4. **Export**: Click "Distribute App" → "Copy App" → "Export"
5. **Copy**: Move the exported `Textiq.app` to your project folder

### Step 2: Create DMG

Run the simple DMG creation script:

```bash
./create_dmg_simple.sh
```

That's it! 🎉

## 📁 What You'll Get

- `Textiq-1.0.dmg` - Your professional installer
- Beautiful drag-and-drop interface
- Proper app icon and layout
- Compressed for easy distribution

## 🔧 Alternative Method (Advanced)

If you have full Xcode setup and want automated building:

```bash
./create_dmg.sh
```

## 🔐 For Distribution (Optional)

To distribute your app professionally:

1. **Code Sign**: Use `./sign_and_notarize.sh`
2. **Upload**: Add to GitHub releases
3. **Share**: Send the DMG to users

## 📚 Need More Help?

- Read `DMG_CREATION_GUIDE.md` for detailed instructions
- Check `sign_and_notarize.sh` for code signing
- Look at Apple's developer documentation

## 🐛 Troubleshooting

**"App not found"**: Make sure `Textiq.app` is in the project folder

**"Permission denied"**: Run `chmod +x *.sh` to make scripts executable

**"DMG creation failed"**: Check you have enough disk space (200MB+)

---

**Ready to ship your app? Let's go! 🚀**