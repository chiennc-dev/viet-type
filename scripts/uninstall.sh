#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ ! -x "$PROJECT_DIR/dist/VietType Installer.app/Contents/MacOS/VietTypeInstaller" ]; then
    bash "$PROJECT_DIR/scripts/build.sh"
fi
"$PROJECT_DIR/dist/VietType Installer.app/Contents/MacOS/VietTypeInstaller" --uninstall
