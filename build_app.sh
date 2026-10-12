#!/bin/bash
#
# build_app.sh — FanC Local Build Script
# Adheres to Arun Thomas's macOS App Blueprint
#

set -e

cd "$(dirname "$0")"

# 1. Read version from version.json (Single Source of Truth)
VERSION=$(python3 -c "import json; print(json.load(open('version.json'))['version'])")
echo "==> Building FanC v${VERSION}..."

# 2. Build release binaries
swift build -c release

# 3. Ensure icon exists
if [ ! -f FanC.icns ]; then
    echo "==> Generating FanC icon..."
    swift Scripts/generate-icon.swift
    iconutil -c icns FanC.iconset -o FanC.icns
fi

# 4. Assemble local FanC.app in .build/release
APP_PATH=".build/release/FanC.app"
rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

cp ".build/release/FanCApp" "$APP_PATH/Contents/MacOS/FanCApp"
cp ".build/release/fanc" "$APP_PATH/Contents/MacOS/fanc"
cp "FanC.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
cp "Scripts/install-daemon.sh" "$APP_PATH/Contents/Resources/install-daemon.sh"
chmod +x "$APP_PATH/Contents/MacOS/fanc" "$APP_PATH/Contents/Resources/install-daemon.sh"

cat <<EOF > "$APP_PATH/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>FanC</string>
    <key>CFBundleDisplayName</key>
    <string>FanC</string>
    <key>CFBundleIdentifier</key>
    <string>com.aoh.fanc</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleExecutable</key>
    <string>FanCApp</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 5. Ad-hoc sign
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || true

echo "==> FanC.app successfully built at $APP_PATH"
echo "==> To test locally: open $APP_PATH"
