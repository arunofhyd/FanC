#!/bin/bash
#
# FanC Uninstall
# Removes everything: daemon, app, CLI, and logs.
#

set -e

echo "Uninstalling FanC..."

sudo /usr/local/bin/fanc uninstall 2>/dev/null || true
sudo rm -f /usr/local/bin/fanc
sudo rm -rf /Applications/FanC.app
rm -rf ~/Library/Logs/FanC
rm -rf ~/Library/Application\ Support/FanC

# Legacy cleanup
rm -rf ~/Library/Logs/ThermalForge 2>/dev/null || true
rm -rf ~/Library/Application\ Support/ThermalForge 2>/dev/null || true

echo "FanC cleanly removed."
