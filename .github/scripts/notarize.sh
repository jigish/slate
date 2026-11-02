#!/bin/bash
# Submit a file to Apple's notary service and wait for the result.
# Usage: notarize.sh <file.zip|file.dmg>
# Requires NOTARY_KEY (path to .p8), NOTARY_KEY_ID, NOTARY_ISSUER_ID.
set -euo pipefail

FILE="$1"
AUTH=(--key "$NOTARY_KEY" --key-id "$NOTARY_KEY_ID" --issuer "$NOTARY_ISSUER_ID")
RESULT="$(mktemp)"

xcrun notarytool submit "$FILE" "${AUTH[@]}" --wait --output-format json > "$RESULT"
STATUS="$(plutil -extract status raw -o - "$RESULT")"
ID="$(plutil -extract id raw -o - "$RESULT")"
echo "Notarization of $(basename "$FILE"): $STATUS (submission $ID)"

if [ "$STATUS" != "Accepted" ]; then
  xcrun notarytool log "$ID" "${AUTH[@]}"
  echo "::error::Notarization of $(basename "$FILE") failed: $STATUS"
  exit 1
fi
