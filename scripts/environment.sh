#!/bin/bash
# Keep compiler caches on the system disk, including when sources are on an external volume.
VIETTYPE_BUILD_DIR="${VIETTYPE_BUILD_DIR:-${TMPDIR:-/tmp}/viettype-build-$(id -u)}"
mkdir -p "$VIETTYPE_BUILD_DIR"
export CLANG_MODULE_CACHE_PATH="$VIETTYPE_BUILD_DIR/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$VIETTYPE_BUILD_DIR/swift-cache"
SWIFT_FLAGS=(--disable-sandbox --scratch-path "$VIETTYPE_BUILD_DIR/products" --cache-path "$VIETTYPE_BUILD_DIR/package-cache")
