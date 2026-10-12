#!/bin/bash
#
# install-fanc.command
# One-command installer for FanC on Apple Silicon Macs
# Built locally so Gatekeeper never blocks it.
#

set -e

cd "$(dirname "$0")"

echo "==========================================="
echo "   🌀 Installing FanC by Arun Thomas"
echo "==========================================="
echo ""

# Build release
echo "==> Compiling native Swift binaries..."
swift build -c release --quiet

# Run setup
./setup.sh

echo ""
echo "==========================================="
echo "   ✅ FanC installation complete!"
echo "==========================================="
echo ""
read -p "Press [Enter] to launch FanC..."
open /Applications/FanC.app
