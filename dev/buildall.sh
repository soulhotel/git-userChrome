#!/usr/bin/env bash
set -e

echo -e "\n• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • •\n"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT" && echo "Working Dir: $PROJECT_ROOT"
echo -e "\nMake sure the working directory is project root...\n"
echo "Wails build all (windows/amd64, darwin/amd64, linux/amd64)"
read -p "Proceed? [Y/n] " answer

if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
    TARGETS=("windows/amd64" "darwin/amd64" "linux/amd64")
    for target in "${TARGETS[@]}"; do
        wails build -platform "$target"
    done
fi

echo -e "\n• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • •\n"
cd "$PROJECT_ROOT" && echo "Working Dir: $PROJECT_ROOT"
echo -e "\nMake sure the working directory is project root...\n"
echo -e "\nDo you want to build a .deb package [Y/n] "
read -r deb_answer

if [[ "$deb_answer" =~ ^[Yy]$ ]]; then
    BUILD_DIR="$PROJECT_ROOT/build"
    DEB_DIR="$BUILD_DIR/deb"
    WAILS_JSON="$PROJECT_ROOT/wails.json"
    if [ ! -f "$WAILS_JSON" ]; then
        echo "Error: Cannot find wails.json at $WAILS_JSON" && exit 1
    fi
    APP_NAME=$(jq -r '.info.productName' "$WAILS_JSON")
    APP_BINARY=$(jq -r '.outputfilename' "$WAILS_JSON")
    APP_VERSION=$(jq -r '.info.productVersion' "$WAILS_JSON")
    APP_DESC=$(jq -r '.info.comments' "$WAILS_JSON")
    APP_AUTHOR_NAME=$(jq -r '.author.name' "$WAILS_JSON")
    APP_AUTHOR_EMAIL=$(jq -r '.author.email' "$WAILS_JSON")
    BIN_SRC="$BUILD_DIR/bin/$APP_BINARY"
    if [ ! -f "$BIN_SRC" ]; then
        echo "Error: Cannot find binary at $BIN_SRC" && exit 1
    fi
    # clear first
    rm -rf "$DEB_DIR"
    mkdir -p "$DEB_DIR/DEBIAN"
    mkdir -p "$DEB_DIR/usr/local/bin"
    mkdir -p "$DEB_DIR/usr/share/applications"
    mkdir -p "$DEB_DIR/usr/share/icons/hicolor/256x256/apps"
    cp "$BIN_SRC" "$DEB_DIR/usr/local/bin/$APP_BINARY"
    chmod 755 "$DEB_DIR/usr/local/bin/$APP_BINARY"
    cat > "$DEB_DIR/DEBIAN/control" <<EOF
Package: ${APP_BINARY,,}
Version: $APP_VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: $APP_AUTHOR_NAME <$APP_AUTHOR_EMAIL>
Description: $APP_DESC
EOF
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
    OUTPUT_DEB="$BUILD_DIR/bin/${APP_BINARY,,}-${APP_VERSION}_amd64.deb"
    dpkg --build "$DEB_DIR" "$OUTPUT_DEB"
    echo "Debian package created at: $OUTPUT_DEB"
fi

echo -e "\n• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • •\n"
cd "$PROJECT_ROOT" && echo "Working Dir: $PROJECT_ROOT"
echo -e "\nMake sure the working directory is project root...\n"
echo -e "\nDo you want to build an appimage [Y/n] "
read -r appimage_answer

if [[ "$appimage_answer" =~ ^[Yy]$ ]]; then
    BUILD_DIR="$PROJECT_ROOT/build"
    APPDIR="$BUILD_DIR/AppDir"
    AIT="$PROJECT_ROOT/dev/ait.AppImage"
    WAILS_JSON="$PROJECT_ROOT/wails.json"
    APP_NAME=$(jq -r '.info.productName' "$WAILS_JSON")
    APP_BINARY=$(jq -r '.outputfilename' "$WAILS_JSON")
    APP_VERSION=$(jq -r '.info.productVersion' "$WAILS_JSON")
    APP_DESC=$(jq -r '.info.comments' "$WAILS_JSON")
    BIN_SRC="$BUILD_DIR/bin/$APP_BINARY"
    if [ ! -f "$WAILS_JSON" ]; then
        echo "Error: Cannot find wails.json at $WAILS_JSON" && exit 1
    fi
    if [ ! -f "$BIN_SRC" ]; then
        echo "Error: Cannot find binary at $BIN_SRC" && exit 1
    fi
    if [ ! -f "$AIT" ]; then
        echo "Error: ait.AppImage not found in $BUILD_DIR" && exit 1
    fi
    rm -rf "$APPDIR"
    mkdir -p "$APPDIR/usr/bin"
    mkdir -p "$APPDIR/usr/share/applications"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
    cp "$BIN_SRC" "$APPDIR/usr/bin/$APP_BINARY"
    chmod 755 "$APPDIR/usr/bin/$APP_BINARY"
    ln -s "usr/bin/$APP_BINARY" "$APPDIR/AppRun"
    if [ -f "$BUILD_DIR/appicon.png" ]; then
        cp "$BUILD_DIR/appicon.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_BINARY.png"
        cp "$BUILD_DIR/appicon.png" "$APPDIR/$APP_BINARY.png"
    fi

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

    mkdir -p "$APPDIR/usr/share/applications"
    cp "$DESKTOP_FILE" "$APPDIR/usr/share/applications/"
    chmod +x "$AIT"
    OUTPUT="$BUILD_DIR/bin/${APP_BINARY}-${APP_VERSION}_amd64.AppImage"
    "$AIT" "$APPDIR" "$OUTPUT"
    echo "AppImage created: $OUTPUT"
fi


echo -e "\n• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • •\n"
cd "$PROJECT_ROOT" && echo "Working Dir: $PROJECT_ROOT"
echo -e "\nMake sure the working directory is project root...\n"
echo -e "\nDo you want to build an RPM package [Y/n] "
read -r rpm_answer

if [[ "$rpm_answer" =~ ^[Yy]$ ]]; then
    BUILD_DIR="$PROJECT_ROOT/build"
    RPMDIR="$BUILD_DIR/rpm"
    WAILS_JSON="$PROJECT_ROOT/wails.json"
    APP_NAME=$(jq -r '.info.productName' "$WAILS_JSON")
    APP_BINARY=$(jq -r '.outputfilename' "$WAILS_JSON")
    APP_VERSION=$(jq -r '.info.productVersion' "$WAILS_JSON")
    APP_DESC=$(jq -r '.info.comments' "$WAILS_JSON")
    BIN_SRC="$BUILD_DIR/bin/$APP_BINARY"
    if [ ! -f "$WAILS_JSON" ]; then
        echo "Error: Cannot find wails.json at $WAILS_JSON" && exit 1
    fi
    if [ ! -f "$BIN_SRC" ]; then
        echo "Error: Cannot find binary at $BIN_SRC" && exit 1
    fi
    rm -rf "$RPMDIR"
    mkdir -p "$RPMDIR/BUILD" "$RPMDIR/RPMS" "$RPMDIR/SOURCES" "$RPMDIR/SPECS" "$RPMDIR/SRPMS"
    mkdir -p "$RPMDIR/usr/bin"
    cp "$BIN_SRC" "$RPMDIR/usr/bin/$APP_BINARY"
    chmod 755 "$RPMDIR/usr/bin/$APP_BINARY"
    if [ -f "$BUILD_DIR/appicon.png" ]; then
        mkdir -p "$RPMDIR/usr/share/icons/hicolor/256x256/apps"
        cp "$BUILD_DIR/appicon.png" "$RPMDIR/usr/share/icons/hicolor/256x256/apps/$APP_BINARY.png"
    fi

    SPEC_FILE="$RPMDIR/SPECS/$APP_BINARY.spec"
cat > "$SPEC_FILE" <<EOF
Name: $APP_BINARY
Version: $APP_VERSION
Release: 1%{?dist}
Summary: $APP_DESC
License: MIT
URL: https://github.com/soulhotel/git-userChrome
Group: Applications/Utilities
BuildArch: x86_64

%description
$APP_DESC

%install
mkdir -p %{buildroot}/usr/bin
cp -p $RPMDIR/usr/bin/$APP_BINARY %{buildroot}/usr/bin/
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps
cp -p $RPMDIR/usr/share/icons/hicolor/256x256/apps/$APP_BINARY.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/

%files
/usr/bin/$APP_BINARY
/usr/share/icons/hicolor/256x256/apps/$APP_BINARY.png

%changelog
* $(date +"%a %b %d %Y") Jonnie <soulhotel@pm.me> - $APP_VERSION-1
- Initial RPM release
EOF

    rpmbuild --define "_topdir $RPMDIR" -bb "$SPEC_FILE"
    mv "$RPMDIR/RPMS/x86_64/$APP_BINARY-$APP_VERSION-1.x86_64.rpm" "$BUILD_DIR/bin/"
    echo "RPM package created: $BUILD_DIR/bin/$APP_BINARY-$APP_VERSION-1.x86_64.rpm"
fi


echo -e "\n• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • •\n"
cd "$PROJECT_ROOT" && echo "Working Dir: $PROJECT_ROOT"
echo -e "\nDo you want to build an Arch package [Y/n] "
read -r arch_answer

if [[ "$arch_answer" =~ ^[Yy]$ ]]; then
    BUILD_DIR="$PROJECT_ROOT/build"
    PKGDIR="$BUILD_DIR/pkg"
    mkdir -p "$PKGDIR/src" "$PKGDIR/pkg"
    WAILS_JSON="$PROJECT_ROOT/wails.json"
    APP_NAME=$(jq -r '.info.productName' "$WAILS_JSON")
    APP_BINARY=$(jq -r '.outputfilename' "$WAILS_JSON")
    APP_VERSION=$(jq -r '.info.productVersion' "$WAILS_JSON")
    APP_DESC=$(jq -r '.info.comments' "$WAILS_JSON")
    BIN_SRC="$BUILD_DIR/bin/$APP_BINARY"
    cp "$BIN_SRC" "$PKGDIR/src/$APP_BINARY"

    SRC_FILES=("$APP_BINARY")
    if [ -f "$BUILD_DIR/appicon.png" ]; then
        cp "$BUILD_DIR/appicon.png" "$PKGDIR/src/appicon.png"
        SRC_FILES+=("appicon.png")
    fi
    DESKTOP_FILE="$PKGDIR/src/$APP_BINARY.desktop"
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=$APP_DESC
Exec=/usr/bin/$APP_BINARY
Icon=$APP_BINARY
Terminal=false
Type=Application
Categories=Utility;
EOF
    SRC_FILES+=("$APP_BINARY.desktop")

    SHA_LIST=()
    for f in "${SRC_FILES[@]}"; do
        sha=$(sha256sum "$PKGDIR/src/$f" | cut -d ' ' -f1)
        SHA_LIST+=("$sha")
    done

    cat > "$PKGDIR/src/PKGBUILD" <<EOF
pkgname=${APP_BINARY,,}
pkgver=$APP_VERSION
pkgrel=1
pkgdesc="$APP_DESC"
arch=('x86_64')
license=('MIT')
source=(${SRC_FILES[@]})
sha256sums=(${SHA_LIST[@]})
package() {
    install -Dm755 "\$srcdir/$APP_BINARY" "\$pkgdir/usr/bin/$APP_BINARY"
EOF

    if [ -f "$PKGDIR/src/appicon.png" ]; then
        echo "    install -Dm644 \"\$srcdir/appicon.png\" \"\$pkgdir/usr/share/icons/hicolor/256x256/apps/$APP_BINARY.png\"" >> "$PKGDIR/src/PKGBUILD"
    fi
    if [ -f "$PKGDIR/src/$APP_BINARY.desktop" ]; then
        echo "    install -Dm644 \"\$srcdir/$APP_BINARY.desktop\" \"\$pkgdir/usr/share/applications/$APP_BINARY.desktop\"" >> "$PKGDIR/src/PKGBUILD"
    fi

    echo "}" >> "$PKGDIR/src/PKGBUILD"

    cd "$PKGDIR/src"
    makepkg -f --noconfirm
    cp *.pkg.tar.zst "$BUILD_DIR/bin/"
    LATEST_PKG=$(ls -1t *.pkg.tar.zst | head -n1)
    echo "Arch package created: $BUILD_DIR/bin/$(ls $BUILD_DIR/bin/*.pkg.tar.zst | xargs -n1 basename)"
    echo -e "to install it (for now): sudo pacman -U build/bin/$LATEST_PKG"
fi
