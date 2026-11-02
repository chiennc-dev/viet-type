#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"
: "${SIGNING_IDENTITY:?Set SIGNING_IDENTITY to your Developer ID Application identity}"
: "${NOTARY_PROFILE:?Set NOTARY_PROFILE to a notarytool keychain profile}"
if [ "$SIGNING_IDENTITY" = "-" ]; then printf 'Developer ID required\n' >&2; exit 1; fi
bash scripts/build.sh --arch arm64 --arch x86_64
SUBMISSION_DIR="$(mktemp -d "${TMPDIR:-/tmp}/viettype-notary.XXXXXX")"
trap 'rm -rf "$SUBMISSION_DIR"' EXIT
ditto -c -k --keepParent dist/VietType.app "$SUBMISSION_DIR/InputMethod.zip"
xcrun notarytool submit "$SUBMISSION_DIR/InputMethod.zip" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple dist/VietType.app
xcrun stapler validate dist/VietType.app
rm -rf "dist/VietType Installer.app/Contents/Resources/VietType.app"
ditto dist/VietType.app "dist/VietType Installer.app/Contents/Resources/VietType.app"
codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "dist/VietType Installer.app"
ditto -c -k --keepParent "dist/VietType Installer.app" "$SUBMISSION_DIR/Installer.zip"
xcrun notarytool submit "$SUBMISSION_DIR/Installer.zip" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "dist/VietType Installer.app"
xcrun stapler validate "dist/VietType Installer.app"
spctl --assess --type execute --verbose "dist/VietType Installer.app"
bash scripts/package.sh --skip-build
