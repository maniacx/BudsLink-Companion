#!/bin/bash

UUID="BudsLink-Companion@maniacx.github.com"

APP_DIR="./files/$UUID"
PO_DIR="$APP_DIR/po"
POT_FILE="$PO_DIR/$UUID.pot"

ALL_FILES=$(find "$APP_DIR" -type f -name '*.js')

mkdir -p "$PO_DIR"

xgettext \
    --add-comments="Translators:" \
    --from-code=UTF-8 \
    --package-name="$UUID" \
    --output="$POT_FILE" \
    $ALL_FILES

METADATA_FILE=$(mktemp)
NAME=$(sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$APP_DIR/metadata.json")
DESCRIPTION=$(sed -n 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$APP_DIR/metadata.json")

cat > "$METADATA_FILE" <<EOF
// metadata.json->name
_("$NAME");
// metadata.json->description
_("$DESCRIPTION");
EOF

xgettext \
    --join-existing \
    --add-comments="metadata.json->" \
    --from-code=UTF-8 \
    --language=JavaScript \
    --output="$POT_FILE" \
    "$METADATA_FILE"

rm -f "$METADATA_FILE"

sed -i \
    '/^#. metadata\.json->/{N;s/\n#: .*//;}' \
    "$POT_FILE"

fuzzy_found=false

for file in "$PO_DIR"/*.po
do
    [ -e "$file" ] || continue

    echo -n "Updating $(basename "$file" .po)"
    msgmerge --backup=off --update --no-fuzzy-matching "$file" "$POT_FILE"

    if grep --silent "#, fuzzy" "$file"; then
        fuzzy+=("$(basename "$file" .po)")
        fuzzy_found=true
    fi

    echo
done

if $fuzzy_found; then
    echo "WARNING: Translations have unclear strings and need an update: ${fuzzy[*]}"
fi
