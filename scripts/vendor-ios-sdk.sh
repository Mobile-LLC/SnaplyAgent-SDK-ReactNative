#!/usr/bin/env bash
#
#  vendor-ios-sdk.sh
#  @snaplyagent/react-native
#
#  Created by Gevorg Karapetyan on 11/10/26.
#  Copyright © 2026 iFixgroup. All rights reserved.
#
#  Brings a published Snaply Agent iOS SDK into ios/Frameworks — the binary the pod embeds — and refuses
#  one that does not match the checksums its own release recorded (the annotated tag of
#  Mobile-LLC/SnaplyAgent-SDK-iOS names the sha256 of each slice's binary).
#
#  Usage:  scripts/vendor-ios-sdk.sh 2.48.0
#          scripts/vendor-ios-sdk.sh --check 2.48.0     compare what is here; change nothing
#
#  SNAPLY_IOS_SDK_REMOTE points at another copy of that repository (a local one, for a test).
#
set -euo pipefail

CHECK=0
if [ "${1:-}" = "--check" ]; then CHECK=1; shift; fi
VERSION="${1:?usage: scripts/vendor-ios-sdk.sh [--check] <version>   e.g. scripts/vendor-ios-sdk.sh 2.48.0}"
REMOTE="${SNAPLY_IOS_SDK_REMOTE:-https://github.com/Mobile-LLC/SnaplyAgent-SDK-iOS.git}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HERE="$ROOT/ios/Frameworks/SnaplyAgent.xcframework"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git -c advice.detachedHead=false clone -q --depth 1 --branch "$VERSION" "$REMOTE" "$WORK/sdk"
NOTES="$(git -C "$WORK/sdk" tag -l --format='%(contents)' "$VERSION")"
[ -n "$NOTES" ] || { echo "✗ tag $VERSION carries no release notes — nothing to check the binary against." >&2; exit 1; }

for SLICE in ios-arm64 ios-arm64_x86_64-simulator; do
  FRAMEWORK="$WORK/sdk/SnaplyAgent.xcframework/$SLICE/SnaplyAgent.framework"
  [ -f "$FRAMEWORK/SnaplyAgent" ] || { echo "✗ $VERSION has no $SLICE slice." >&2; exit 1; }
  SUM="$(shasum -a 256 "$FRAMEWORK/SnaplyAgent" | cut -d' ' -f1)"
  printf '%s\n' "$NOTES" | grep -qF "$SLICE  sha256 $SUM" \
    || { echo "✗ $SLICE: the binary's sha256 is not the one the $VERSION release recorded." >&2; exit 1; }
  BUILT="$(plutil -extract CFBundleShortVersionString raw "$FRAMEWORK/Info.plist")"
  [ "$BUILT" = "$VERSION" ] || { echo "✗ $SLICE reports $BUILT, expected $VERSION." >&2; exit 1; }
  if [ "$CHECK" = 1 ]; then
    MINE="$(shasum -a 256 "$HERE/$SLICE/SnaplyAgent.framework/SnaplyAgent" 2>/dev/null | cut -d' ' -f1 || true)"
    [ "$MINE" = "$SUM" ] || { echo "✗ $SLICE in ios/Frameworks is not the published $VERSION binary." >&2; exit 1; }
  fi
  echo "  ✓ $SLICE — $BUILT, sha256 $SUM"
done

if [ "$CHECK" = 1 ]; then
  echo "✓ ios/Frameworks holds the published $VERSION."
  exit 0
fi

rm -rf "$HERE"
mkdir -p "$ROOT/ios/Frameworks"
cp -R "$WORK/sdk/SnaplyAgent.xcframework" "$HERE"
find "$HERE" -name .DS_Store -delete
echo "✓ ios/Frameworks/SnaplyAgent.xcframework is the published $VERSION. Commit it with the version bump."
