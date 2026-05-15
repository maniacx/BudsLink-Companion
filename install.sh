#!/usr/bin/env bash
set -euo pipefail

# --- checks ---
if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "kpackagetool6 not found. Install plasma-framework."
    exit 1
fi

if ! command -v msgfmt >/dev/null 2>&1; then
    echo " msgfmt not found. Install gettext."
    exit 1
fi

# --- paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONTENT_DIR="$SCRIPT_DIR/contents"
TRANSLATE_DIR="$SCRIPT_DIR/translate"

PLUGIN_ID="com.github.maniacx.BudsLink-Companion"
DOMAIN="plasma_applet_$PLUGIN_ID"

# --- compile translations ---
if [ -d "$TRANSLATE_DIR" ]; then
    for po in "$TRANSLATE_DIR"/*.po; do
        [ -f "$po" ] || continue

        lang=$(basename "$po" .po)
        out_dir="$CONTENT_DIR/locale/$lang/LC_MESSAGES"

        mkdir -p "$out_dir"

        msgfmt "$po" -o "$out_dir/$DOMAIN.mo"

        echo "compiled: $lang"
    done
fi

# --- install plasmoid ---
echo "Installing plasmoid..."

if ! kpackagetool6 --type Plasma/Applet --install "$SCRIPT_DIR" &> /dev/null; then
        kpackagetool6 --type Plasma/Applet --upgrade "$SCRIPT_DIR"
fi

echo "Installed: $PLUGIN_ID"
