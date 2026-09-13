#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TRANSLATE_DIR="$SCRIPT_DIR/translate"
POT_FILE="$TRANSLATE_DIR/BudsLinkCompanion-KDE.pot"
PLUGIN_ID="com.github.maniacx.BudsLink-Companion"
DOMAIN="plasma_applet_$PLUGIN_ID"

if ! command -v xgettext >/dev/null 2>&1; then
    echo "xgettext not found. Install gettext."
    exit 1
fi

if ! command -v msgmerge >/dev/null 2>&1; then
    echo "msgmerge not found. Install gettext."
    exit 1
fi

mapfile -t SOURCE_FILES < <(
    find "$SCRIPT_DIR/contents" \
        \( -name '*.qml' -o -name '*.js' \) \
        -type f \
        -print \
        | sort
)

if [ "${#SOURCE_FILES[@]}" -eq 0 ]; then
    echo "No QML or JS files found."
    exit 1
fi

mkdir -p "$TRANSLATE_DIR"

echo "Extracting translations..."

xgettext \
    --from-code=UTF-8 \
    --width=400 \
    --add-location=file \
    -C -kde \
    -ci18n \
    -ki18n:1 \
    -ki18nc:1c,2 \
    -ki18np:1,2 \
    -ki18ncp:1c,2,3 \
    -ktr2i18n:1 \
    -kI18N_NOOP:1 \
    -kI18N_NOOP2:1c,2 \
    -kN_:1 \
    -kaliasLocale \
    -kki18n:1 \
    -kki18nc:1c,2 \
    -kki18np:1,2 \
    -kki18ncp:1c,2,3 \
    --package-name="$PLUGIN_ID" \
    --output="$POT_FILE" \
    "${SOURCE_FILES[@]}"

echo "Generated: $POT_FILE"

for po in "$TRANSLATE_DIR"/*.po; do
    [ -f "$po" ] || continue

    echo "Updating $(basename "$po")..."

    msgmerge \
        --update \
        --backup=none \
        "$po" \
        "$POT_FILE"
done

echo "Done."
