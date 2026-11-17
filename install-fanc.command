#!/bin/bash
#
# install-fanc.command
# One-command installer for FanC on Apple Silicon Macs
# Built locally so Gatekeeper never blocks it.
#

set -e

# If not run inside a FanC repository containing Package.swift, clone into a clean temp workspace
if [ ! -f "Package.swift" ] || [ ! -f "setup.sh" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    if [ -f "$SCRIPT_DIR/Package.swift" ] && [ -f "$SCRIPT_DIR/setup.sh" ]; then
        cd "$SCRIPT_DIR"
    else
        echo "==> Preparing clean workspace for FanC..."
        WORK_DIR="$(mktemp -d)"
        trap 'rm -rf "$WORK_DIR"' EXIT
        git clone --depth 1 https://github.com/arunofhyd/FanC.git "$WORK_DIR"
        cd "$WORK_DIR"
    fi
else
    cd "$(dirname "$0")"
fi

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
