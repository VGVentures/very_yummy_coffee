#!/usr/bin/env bash
# Runs dart format and dart analyze on any .dart file modified by a tool use.
# Receives tool use context as JSON on stdin (PostToolUse hook).

set -uo pipefail

# Parse file_path from the tool_input JSON payload
FILE_PATH=$(python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('file_path', ''))
except Exception:
    print('')
")

# Only process .dart files that exist on disk
[[ -z "$FILE_PATH" || "$FILE_PATH" != *.dart || ! -f "$FILE_PATH" ]] && exit 0

# Find the nearest package root (directory containing pubspec.yaml)
PACKAGE_DIR="$(dirname "$FILE_PATH")"
while [[ "$PACKAGE_DIR" != "/" && ! -f "$PACKAGE_DIR/pubspec.yaml" ]]; do
  PACKAGE_DIR="$(dirname "$PACKAGE_DIR")"
done

[[ ! -f "$PACKAGE_DIR/pubspec.yaml" ]] && exit 0

# Format the file in place (always runs, rewrites if needed)
dart format "$FILE_PATH" 2>&1

# Analyze and surface any issues — non-zero exit causes Claude to see the output
dart analyze "$FILE_PATH" 2>&1
