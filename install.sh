#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

UUID="BudsLink-Companion@maniacx.github.com"
APPLET_DIR="$HOME/.local/share/cinnamon/applets/$UUID"

echo "Installing applet BudsLink-Companion"

rm -rf "$APPLET_DIR"
mkdir -p "$APPLET_DIR"

cp "$SCRIPT_DIR/applet.js" \
   "$SCRIPT_DIR/metadata.json" \
   "$SCRIPT_DIR/settings-schema.json" \
   "$SCRIPT_DIR/stylesheet.css" \
   "$APPLET_DIR"

cp -r "$SCRIPT_DIR/lib" "$APPLET_DIR"
cp -r "$SCRIPT_DIR/icons" "$APPLET_DIR"
cp "$SCRIPT_DIR/icon.png" "$APPLET_DIR"

if compgen -G "$SCRIPT_DIR/po/*.po" > /dev/null; then
    for po in "$SCRIPT_DIR"/po/*.po; do
        lang=$(basename "$po" .po)

        mkdir -p "$HOME/.local/share/locale/$lang/LC_MESSAGES"

        msgfmt "$po" -o "$HOME/.local/share/locale/$lang/LC_MESSAGES/$UUID.mo"
    done
fi

echo "Done. Restart Cinnamon (Alt+F2 → r) if needed."
