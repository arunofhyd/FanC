#!/bin/bash
set -e

SOURCE_BINARY="$1"
OWNER_UID="${2:-501}"

if [ -z "$SOURCE_BINARY" ] || [ ! -f "$SOURCE_BINARY" ]; then
    if [ -f "/Applications/FanC.app/Contents/MacOS/fanc" ]; then
        SOURCE_BINARY="/Applications/FanC.app/Contents/MacOS/fanc"
    elif [ -f "/usr/local/bin/fanc" ]; then
        SOURCE_BINARY="/usr/local/bin/fanc"
    elif [ -f "$(dirname "$0")/../.build/release/fanc" ]; then
        SOURCE_BINARY="$(dirname "$0")/../.build/release/fanc"
    fi
fi

mkdir -p /usr/local/bin

# 1. Install fanc binary to /usr/local/bin/fanc
if [ -n "$SOURCE_BINARY" ] && [ -f "$SOURCE_BINARY" ]; then
    cp "$SOURCE_BINARY" /usr/local/bin/fanc
fi
chown root:wheel /usr/local/bin/fanc
chmod 755 /usr/local/bin/fanc

# 2. Stop legacy ThermalForge daemon if running
/bin/launchctl bootout system/com.thermalforge.daemon 2>/dev/null || true
/bin/launchctl bootout system /Library/LaunchDaemons/com.thermalforge.daemon.plist 2>/dev/null || true
rm -f /Library/LaunchDaemons/com.thermalforge.daemon.plist /var/run/thermalforge.sock

# 3. Create FanC LaunchDaemon plist
PLIST="/Library/LaunchDaemons/com.aoh.fanc.daemon.plist"
cat <<EOF > "$PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.aoh.fanc.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/fanc</string>
        <string>daemon</string>
        <string>--owner-uid</string>
        <string>${OWNER_UID}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

chown root:wheel "$PLIST"
chmod 644 "$PLIST"

# 4. Bootstrap and kickstart FanC daemon
/bin/launchctl bootout system/com.aoh.fanc.daemon 2>/dev/null || true
/bin/launchctl bootstrap system "$PLIST"
/bin/launchctl kickstart -k system/com.aoh.fanc.daemon 2>/dev/null || true

echo "FanC daemon successfully installed and started."
