#!/usr/bin/env bash
set -euo pipefail

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "kpackagetool6 not found. Install plasma-framework."
    exit 1
fi

if ! command -v msgfmt >/dev/null 2>&1; then
    echo "msgfmt not found. Install gettext."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSLATE_DIR="$SCRIPT_DIR/translate"

PLUGIN_ID="com.github.maniacx.BudsLink-Companion"
DOMAIN="plasma_applet_$PLUGIN_ID"

TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

cp -r "$SCRIPT_DIR"/. "$TMP_DIR"

if [ -d "$TRANSLATE_DIR" ]; then
    for po in "$TRANSLATE_DIR"/*.po; do
        [ -f "$po" ] || continue

        lang=$(basename "$po" .po)
        out_dir="$TMP_DIR/contents/locale/$lang/LC_MESSAGES"

        mkdir -p "$out_dir"

        msgfmt "$po" -o "$out_dir/$DOMAIN.mo"

        echo "compiled: $lang"
    done
fi

echo "Installing plasmoid..."

kpackagetool6 --type Plasma/Applet --upgrade "$TMP_DIR"

echo "Installed: $PLUGIN_ID"
