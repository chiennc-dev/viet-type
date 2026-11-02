#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
bash "$PROJECT_DIR/scripts/build.sh"
"$PROJECT_DIR/dist/VietType Installer.app/Contents/MacOS/VietTypeInstaller" --install
