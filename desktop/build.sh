#!/bin/bash
# Builds OilTimer.app (the desktop version) next to index.html.
# Usage: bash desktop/build.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP="$DIR/OilTimer.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O "$DIR/desktop/OilTimerDesk.swift" -o "$APP/Contents/MacOS/OilTimer" -framework Cocoa -framework WebKit
cp "$DIR/index.html" "$APP/Contents/Resources/index.html"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Oil Timer</string>
  <key>CFBundleDisplayName</key><string>Oil Timer</string>
  <key>CFBundleIdentifier</key><string>local.oiltimer.desktop</string>
  <key>CFBundleExecutable</key><string>OilTimer</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>OTProjectHTML</key><string>$DIR/index.html</string>
  <key>CFBundleURLTypes</key>
  <array><dict>
    <key>CFBundleURLName</key><string>local.oiltimer.open</string>
    <key>CFBundleURLSchemes</key><array><string>oiltimer</string></array>
  </dict></array>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP" >/dev/null 2>&1 || true
# register the oiltimer:// link so the web page can open the app
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" || true
echo "built: $APP"
