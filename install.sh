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

CONTENT_DIR="$SCRIPT_DIR/contents"
TRANSLATE_DIR="$SCRIPT_DIR/translate"

PLUGIN_ID="com.github.maniacx.BudsLink-Companion"
DOMAIN="plasma_applet_$PLUGIN_ID"

TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

PACKAGE_DIR="$TMP_DIR/$PLUGIN_ID"

echo "Preparing temporary package..."

cp -a "$SCRIPT_DIR/." "$PACKAGE_DIR"

rm -rf "$PACKAGE_DIR/translate"

if [ -d "$TRANSLATE_DIR" ]; then
    for po in "$TRANSLATE_DIR"/*.po; do
        [ -f "$po" ] || continue

        lang=$(basename "$po" .po)
        out_dir="$PACKAGE_DIR/contents/locale/$lang/LC_MESSAGES"

        mkdir -p "$out_dir"

        msgfmt "$po" -o "$out_dir/$DOMAIN.mo"

        echo "compiled: $lang"
    done
fi

# --- install plasmoid ---
echo "Installing plasmoid..."

if ! kpackagetool6 --type Plasma/Applet --install "$PACKAGE_DIR" &> /dev/null; then
    kpackagetool6 --type Plasma/Applet --upgrade "$PACKAGE_DIR"
fi

echo "Installed: $PLUGIN_ID"

echo
echo "Plasma Shell needs to be reloaded for changes to take effect."
echo
echo "1) Exit without reloading"
echo "2) Reload Plasma Shell and exit"
echo

while true; do
    read -r -p "Choose an option [1-2]: " choice

    case "$choice" in
        1)
            echo "Exiting without reloading Plasma Shell."
            exit 0
            ;;
        2)
            echo "Reloading Plasma Shell..."
            systemctl restart --user plasma-plasmashell.service
            echo "Plasma Shell reloaded."
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose 1 or 2."
            ;;
    esac
done
