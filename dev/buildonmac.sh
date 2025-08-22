#!/usr/bin/env bash
set -e

echo -e "\n• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • •\n"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT" && echo "Working Dir: $PROJECT_ROOT"
echo -e "
Make sure the working directory is project root and you are performing these actions on a mac...

For reference: setting up env on mac includes
  brew install go, node
  go install github.com/wailsapp/wails/v2/cmd/wails@latest
  wails doctor
  npm install -g vite@3.0.7 # dev version
  # in wails.json > frontend:install and frontend:build are left blank ""
  wails build
  dev/buildonmac.sh
"
echo -e "Do you want to convert your APP to DMG [Y/n] "
read -r dmg_answer

if [[ "$dmg_answer" =~ ^[Yy]$ ]]; then
    BUILD_DIR="$PROJECT_ROOT/build"
    WAILS_JSON="$PROJECT_ROOT/wails.json"
    APP_NAME=$(jq -r '.info.productName' "$WAILS_JSON")
    APP_BINARY=$(jq -r '.outputfilename' "$WAILS_JSON")
    APP_PATH="$BUILD_DIR/bin/${APP_NAME}.app"
    OUTPUT_DMG="$BUILD_DIR/bin/${APP_BINARY}.dmg"
    if [ ! -d "$APP_PATH" ]; then
        echo "Error: Cant find app, $APP_PATH" && exit 1
    fi
    MAIN_BIN="$APP_PATH/Contents/MacOS/$APP_BINARY"
    if [ -f "$MAIN_BIN" ]; then
        chmod +x "$MAIN_BIN"
    else
        echo "Main binary missing from $MAIN_BIN"
    fi
    hdiutil create -volname "$APP_BINARY" -srcfolder "$APP_PATH" \
                   -ov -format UDZO "$OUTPUT_DMG"
    echo "DMG created at $OUTPUT_DMG"
fi