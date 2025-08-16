#!/usr/bin/env bash
set -e

# Make sure all paths are relative to where the script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # build/
BUILD_DIR="$SCRIPT_DIR"
PROJECT_ROOT="$(cd "$BUILD_DIR/.." && pwd)"                 # project root
DEB_DIR="$BUILD_DIR/deb"

# Read info from wails.json
WAILS_JSON="$PROJECT_ROOT/wails.json"
if [ ! -f "$WAILS_JSON" ]; then
    echo "Error: Cannot find wails.json at $WAILS_JSON"
    exit 1
fi

APP_NAME=$(jq -r '.info.productName' "$WAILS_JSON")
APP_BINARY=$(jq -r '.outputfilename' "$WAILS_JSON")
APP_VERSION=$(jq -r '.info.productVersion' "$WAILS_JSON")
APP_DESC=$(jq -r '.info.comments' "$WAILS_JSON")
APP_AUTHOR_NAME=$(jq -r '.author.name' "$WAILS_JSON")
APP_AUTHOR_EMAIL=$(jq -r '.author.email' "$WAILS_JSON")
APP_COMPANY=$(jq -r '.info.companyName' "$WAILS_JSON")

# Dynamic binary path
BIN_SRC="$BUILD_DIR/bin/$APP_BINARY"
if [ ! -f "$BIN_SRC" ]; then
    echo "Error: Cannot find binary at $BIN_SRC"
    exit 1
fi

# Clear old deb folder
rm -rf "$DEB_DIR"

# Create folder structure
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/local/bin"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/share/icons/hicolor/256x256/apps"

# Copy binary
cp "$BIN_SRC" "$DEB_DIR/usr/local/bin/$APP_BINARY"
chmod 755 "$DEB_DIR/usr/local/bin/$APP_BINARY"

# Create control file
cat > "$DEB_DIR/DEBIAN/control" <<EOF
Package: ${APP_BINARY,,}
Version: $APP_VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: $APP_AUTHOR_NAME <$APP_AUTHOR_EMAIL>
Description: $APP_DESC
EOF

# Create desktop file
cat > "$DEB_DIR/usr/share/applications/${APP_BINARY}.desktop" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=$APP_DESC
Exec=/usr/local/bin/$APP_BINARY
Icon=$APP_BINARY
Terminal=false
Type=Application
Categories=Utility;
EOF

echo "Deb folder structure ready at $DEB_DIR"
echo "Run the following to build the .deb:"
echo "  dpkg --build $DEB_DIR"
echo
read -p "Do you want to build the .deb now? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ || -z "$answer" ]]; then
    OUTPUT_DEB="$BUILD_DIR/bin/${APP_BINARY,,}-${APP_VERSION}_amd64.deb"
    dpkg --build "$DEB_DIR" "$OUTPUT_DEB"
    echo "Debian package created at: $OUTPUT_DEB"
fi