#!/bin/bash
set -e

PROJECT="AfharaAdzan.xcodeproj"
SCHEME="AfharaAdzan"
BUILD_DIR="build"
DMG_NAME="AfharaAdzan-v1.5.0.dmg"

echo "==> Building..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    | xcpretty || true

APP_PATH="$BUILD_DIR/Build/Products/Release/AfharaAdzan.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: build gagal, .app tidak ditemukan"
    exit 1
fi

echo "==> Membuat DMG..."
rm -rf dmg_tmp
mkdir dmg_tmp
cp -r "$APP_PATH" dmg_tmp/
ln -s /Applications dmg_tmp/Applications

hdiutil create \
    -volname "AfharaAdzan" \
    -srcfolder dmg_tmp \
    -ov -format UDZO \
    "$DMG_NAME"

rm -rf dmg_tmp

echo ""
echo "Done! File: $DMG_NAME"
