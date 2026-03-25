#!/usr/bin/env bash
# Find every .aab under a directory tree and build a universal .apk next to each one
# (same basename: app-release.aab -> app-release.apk) using Android bundletool.
#
# Requires: bundletool on PATH (brew install bundletool), or set BUNDLETOOL_JAR to a
# bundletool-all-*.jar and Java on PATH.
#
# Usage:
#   ./aab_to_apk_all.sh
#   ./aab_to_apk_all.sh /path/to/search
#   SEARCH_ROOT=/path ./aab_to_apk_all.sh
#
# Skips paths under .git.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "${SCRIPT_DIR}/applications" ]]; then
  REPO_ROOT="$SCRIPT_DIR"
elif [[ -d "${SCRIPT_DIR}/../applications" ]]; then
  REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
else
  REPO_ROOT="$SCRIPT_DIR"
fi
SEARCH_ROOT="${SEARCH_ROOT:-${1:-$REPO_ROOT}}"

_bundletool() {
  if [[ -n "${BUNDLETOOL_JAR:-}" ]]; then
    java -jar "${BUNDLETOOL_JAR}" "$@"
  else
    bundletool "$@"
  fi
}

if [[ -n "${BUNDLETOOL_JAR:-}" ]]; then
  command -v java >/dev/null 2>&1 || {
    echo "java not found; required when BUNDLETOOL_JAR is set." >&2
    exit 1
  }
else
  command -v bundletool >/dev/null 2>&1 || {
    echo "bundletool not found. Install with: brew install bundletool" >&2
    echo "Or download bundletool-all-*.jar and set BUNDLETOOL_JAR to its path." >&2
    exit 1
  }
fi

if [[ ! -d "${SEARCH_ROOT}" ]]; then
  echo "Not a directory: ${SEARCH_ROOT}" >&2
  exit 1
fi

count=0
while IFS= read -r -d '' aab; do
  apk="${aab%.aab}.apk"
  # bundletool requires --output to end in .apks; mktemp templates must end in XXXXXX only.
  tmp_apks="$(mktemp -t bundletool).apks"
  echo "==> ${aab}"
  _bundletool build-apks --bundle="${aab}" --output="${tmp_apks}" --mode=universal
  unzip -p "${tmp_apks}" universal.apk >"${apk}"
  rm -f "${tmp_apks}"
  echo "    ${apk}"
  count=$((count + 1))
done < <(find "${SEARCH_ROOT}" -name '*.aab' -not -path '*/.git/*' -print0)

if [[ "${count}" -eq 0 ]]; then
  echo "No .aab files under ${SEARCH_ROOT}"
  exit 0
fi

echo "Done. Wrote ${count} APK(s)."
