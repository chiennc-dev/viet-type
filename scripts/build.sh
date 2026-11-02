#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"
source "$PROJECT_DIR/scripts/environment.sh"
swift build -c release "${SWIFT_FLAGS[@]}" "$@"
BINARY_DIR="$(swift build -c release "${SWIFT_FLAGS[@]}" --show-bin-path "$@")"
mkdir -p "$PROJECT_DIR/dist"
STAGE="$(mktemp -d "$PROJECT_DIR/dist/.build.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
APP_DIR="$STAGE/VietType.app"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BINARY_DIR/VietType" "$APP_DIR/Contents/MacOS/VietType"
cp Resources/Info.plist "$APP_DIR/Contents/Info.plist"
swift -module-cache-path "$CLANG_MODULE_CACHE_PATH" scripts/make-icon.swift "$APP_DIR/Contents/Resources/VietType.tiff"
plutil -lint "$APP_DIR/Contents/Info.plist"
SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"
SIGN_FLAGS=(--force --sign "$SIGNING_IDENTITY")
if [ "$SIGNING_IDENTITY" != "-" ]; then
    SIGN_FLAGS+=(--options runtime --timestamp)
fi
codesign "${SIGN_FLAGS[@]}" "$APP_DIR"
codesign --verify --strict "$APP_DIR"
INSTALLER_DIR="$STAGE/VietType Installer.app"
mkdir -p "$INSTALLER_DIR/Contents/MacOS" "$INSTALLER_DIR/Contents/Resources"
cp "$BINARY_DIR/VietTypeInstaller" "$INSTALLER_DIR/Contents/MacOS/VietTypeInstaller"
cp Resources/Installer-Info.plist "$INSTALLER_DIR/Contents/Info.plist"
if [ -d "$INSTALLER_DIR/Contents/Resources/VietType.app" ]; then
    rm -rf "$INSTALLER_DIR/Contents/Resources/VietType.app"
fi
ditto "$APP_DIR" "$INSTALLER_DIR/Contents/Resources/VietType.app"
plutil -lint "$INSTALLER_DIR/Contents/Info.plist"
codesign "${SIGN_FLAGS[@]}" "$INSTALLER_DIR"
codesign --verify --deep --strict "$INSTALLER_DIR"
# Replace complete bundles rather than overwriting executable files in place.
for NAME in "VietType.app" "VietType Installer.app"; do
    if [ -e "$PROJECT_DIR/dist/$NAME" ]; then
        mv "$PROJECT_DIR/dist/$NAME" "$STAGE/previous-$NAME"
    fi
    mv "$STAGE/$NAME" "$PROJECT_DIR/dist/$NAME"
done
printf 'Built: %s\n' "$PROJECT_DIR/dist/VietType.app"
printf 'Installer: %s\nSigning: %s\n' "$PROJECT_DIR/dist/VietType Installer.app" "$SIGNING_IDENTITY"
