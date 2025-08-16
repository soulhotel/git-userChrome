#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR"
PROJECT_ROOT="$(cd "$BUILD_DIR/.." && pwd)"
APPDIR="$BUILD_DIR/AppDir"

WAILS_JSON="$PROJECT_ROOT/wails.json"
if [ ! -f "$WAILS_JSON" ]; then
    echo "Error: Cannot find wails.json at $WAILS_JSON"
    exit 1
fi

APP_NAME=$(jq -r '.info.productName' "$WAILS_JSON")
APP_BINARY=$(jq -r '.outputfilename' "$WAILS_JSON")
APP_VERSION=$(jq -r '.info.productVersion' "$WAILS_JSON")
APP_DESC=$(jq -r '.info.comments' "$WAILS_JSON")

BIN_SRC="$BUILD_DIR/bin/$APP_BINARY"
if [ ! -f "$BIN_SRC" ]; then
    echo "Error: Cannot find binary at $BIN_SRC"
    exit 1
fi

rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

# Copy binary
cp "$BIN_SRC" "$APPDIR/usr/bin/$APP_BINARY"
chmod 755 "$APPDIR/usr/bin/$APP_BINARY"

# AppRun: symlink binary to AppRun
ln -s "usr/bin/$APP_BINARY" "$APPDIR/AppRun"

# Icon
if [ -f "$BUILD_DIR/appicon.png" ]; then
    cp "$BUILD_DIR/appicon.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_BINARY.png"
    cp "$BUILD_DIR/appicon.png" "$APPDIR/$APP_BINARY.png"   # AppImage root needs it
fi

# Desktop file
DESKTOP_FILE="$APPDIR/$APP_BINARY.desktop"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=$APP_DESC
Exec=$APP_BINARY
Icon=$APP_BINARY
Terminal=false
Type=Application
Categories=Utility;
EOF

# Also install it inside usr/share (optional but nice)
mkdir -p "$APPDIR/usr/share/applications"
cp "$DESKTOP_FILE" "$APPDIR/usr/share/applications/"

# appimagetool
AIT="$BUILD_DIR/ait.AppImage"
if [ ! -f "$AIT" ]; then
    echo "Error: ait.AppImage not found in $BUILD_DIR"
    exit 1
fi
chmod +x "$AIT"

echo
read -p "Do you want to build the AppImage now? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ || -z "$answer" ]]; then
    OUTPUT="$BUILD_DIR/bin/${APP_BINARY}-${APP_VERSION}.AppImage"
    "$AIT" "$APPDIR" "$OUTPUT"
    echo "AppImage created: $OUTPUT"
fi
