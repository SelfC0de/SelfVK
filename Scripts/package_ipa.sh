#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:?Path to .app is required}"
OUTPUT_PATH="${2:-VKSelfCode-unsigned.ipa}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Application bundle not found: $APP_PATH" >&2
  exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$WORK_DIR/Payload"
cp -R "$APP_PATH" "$WORK_DIR/Payload/"
(
  cd "$WORK_DIR"
  /usr/bin/zip -qry "$OLDPWD/$OUTPUT_PATH" Payload
)

echo "Created $OUTPUT_PATH"
