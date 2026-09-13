#!/usr/bin/env bash
set -euo pipefail

scriptDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$scriptDir"

if ! command -v msgfmt >/dev/null 2>&1; then
    echo "msgfmt not found. Install gettext."
    exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
    echo "zip not found."
    exit 1
fi

version=$(sed -n 's/.*"Version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' metadata.json)
archive="BudsLinkCompanion-v${version}.plasmoid"

PLUGIN_ID="com.github.maniacx.BudsLink-Companion"
DOMAIN="plasma_applet_$PLUGIN_ID"

TRANSLATE_DIR="$scriptDir/translate"

tmpDir="$(mktemp -d)"
packageDir="$tmpDir/$PLUGIN_ID"

cleanup() {
    rm -rf "$tmpDir"
}

trap cleanup EXIT

echo "Preparing package..."

mkdir -p "$packageDir"

cp metadata.json "$packageDir/"
cp LICENSE "$packageDir/"
cp README.md "$packageDir/"
cp -a contents "$packageDir/"

if [ -d "$TRANSLATE_DIR" ]; then
    for po in "$TRANSLATE_DIR"/*.po; do
        [ -f "$po" ] || continue

        lang="$(basename "$po" .po)"
        outDir="$packageDir/contents/locale/$lang/LC_MESSAGES"

        mkdir -p "$outDir"

        msgfmt "$po" -o "$outDir/$DOMAIN.mo"

        echo "compiled: $lang"
    done
fi

echo "Building $archive..."

rm -f "$archive"

(
    cd "$packageDir"
    zip -qr "$scriptDir/$archive" .
)

echo
echo "Built: $archive"
