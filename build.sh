#!/usr/bin/env bash

scriptDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$scriptDir"

version=$(jq -r '.KPlugin.Version' metadata.json)

zip -r "BudsLinkCompanion-v${version}.plasmoid" \
    metadata.json \
    LICENSE \
    README.md \
    contents/
