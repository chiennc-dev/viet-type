#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"
VERSION="$(tr -d '\r\n' < VERSION)"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
    printf 'Invalid VERSION\n' >&2; exit 1
fi
if [ "${1:-}" != "--skip-build" ]; then
    bash scripts/build.sh --arch arm64 --arch x86_64
fi
codesign --verify --deep --strict "dist/VietType Installer.app"
for BINARY in "dist/VietType.app/Contents/MacOS/VietType" "dist/VietType Installer.app/Contents/MacOS/VietTypeInstaller"; do
    lipo "$BINARY" -verify_arch arm64 x86_64
done
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/viettype-release.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
ditto "dist/VietType Installer.app" "$STAGE/VietType Installer.app"
cp docs/INSTALL.vi.md "$STAGE/Đọc trước khi cài.md"
cp LICENSE "$STAGE/LICENSE.txt"
cat > "$STAGE/BUILD-INFO.txt" <<EOF
VietType $VERSION
Repository: https://github.com/chiennc-dev/viet-type
Architectures: arm64, x86_64
Minimum macOS: 13
Revision: $(git rev-parse HEAD 2>/dev/null || printf 'local-build')
Signing identity: ${SIGNING_IDENTITY:-- (ad hoc; not notarized)}
EOF
ARCHIVE="dist/VietType-$VERSION-universal.zip"
ditto -c -k --sequesterRsrc "$STAGE" "$ARCHIVE"
(cd dist && shasum -a 256 "VietType-$VERSION-universal.zip" > "VietType-$VERSION-universal.zip.sha256")
printf 'Release: %s/%s\n' "$PROJECT_DIR" "$ARCHIVE"
