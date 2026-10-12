#!/bin/bash
#
# FanC Setup
# Run once: ./setup.sh
#

set -e

cd "$(dirname "$0")"

echo "Building FanC..."
swift build -c release --quiet

echo "Installing (requires admin password once)..."

# Kill old app and reset fans
pkill -x FanCApp 2>/dev/null || true
sleep 1
/usr/local/bin/fanc auto 2>/dev/null || true

# Generate app icon if needed
if [ ! -f FanC.icns ]; then
    echo "Generating app icon..."
    swift Scripts/generate-icon.swift
    iconutil -c icns FanC.iconset -o FanC.icns
fi

# Clear extended attributes (quarantine) with Apple's xattr
XATTR=/usr/bin/xattr

# Install CLI and daemon (handles stopping old daemon if present)
sudo "$XATTR" -c .build/release/fanc
sudo .build/release/fanc install

# Create the .app bundle in /Applications via the shared assembler
sudo .build/release/fanc build-app \
    --binary .build/release/FanCApp \
    --icon FanC.icns \
    --dest /Applications/FanC.app
sudo find /Applications/FanC.app -exec "$XATTR" -cs {} +

# Update Spotlight index
sudo mdimport /Applications/FanC.app 2>/dev/null || true

echo ""
echo "🚀 FanC successfully installed."
echo "  - Open from Spotlight: search 'FanC'"
echo "  - Open from Finder: Applications > FanC"
echo "  - Or from terminal: open /Applications/FanC.app"
echo ""
echo "Turn on 'Launch at Login' in the menu bar dropdown and it starts automatically."
