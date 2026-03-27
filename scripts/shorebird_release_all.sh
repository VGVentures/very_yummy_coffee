#!/usr/bin/env bash
# Run Shorebird release for every application that has shorebird.yaml, targeting the
# production API on Railway. Passes the same compile-time API settings used by
# ApiClient.fromDartDefines() in shared/api_client.
#
# Loads variables from .env in the repo root (ENV_FILE) without overwriting
# variables already set in the shell (so you can override per run).
#
# Usage:
#   ./shorebird_release_all.sh
#   ./shorebird_release_all.sh --apps=kds,menu --platforms=android,ios
#   SHOREBIRD_PLATFORMS=android,ios,macos ./shorebird_release_all.sh
#   MENU_BOARD_PLATFORMS=android,ios,macos,linux ./shorebird_release_all.sh
#
# Flags (optional; must appear before any args passed through to shorebird):
#   --apps=kds,kiosk,menu,mobile,pos   Comma-separated short names or applications/<dir>
#   --platforms=android,ios,macos      Overrides SHOREBIRD_PLATFORMS and MENU_BOARD_PLATFORMS for this run
#   -h, --help                         Show this help
#
# Requested platforms are intersected with each app's project (android/, ios/, macos/, linux/, windows/).
# Example: pos_app has no android/ — only ios and macos are built.
#   ENV_FILE=/path/to/other.env ./shorebird_release_all.sh
#   ./shorebird_release_all.sh --dry-run
#
# Override the API base (must be https or http; host is derived for API_HOST):
#   PRODUCTION_API_BASE_URL='https://example.com/' ./shorebird_release_all.sh
#
# Or set API_HOST / API_SECURE directly (skips URL parsing):
#   API_HOST='example.com' API_SECURE=true ./shorebird_release_all.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Script may live in repo root or in scripts/; resolve monorepo root (applications/).
if [[ -d "${SCRIPT_DIR}/applications" ]]; then
  ROOT="$SCRIPT_DIR"
elif [[ -d "${SCRIPT_DIR}/../applications" ]]; then
  ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
else
  echo "Could not find monorepo root (applications/)." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/shorebird_platforms.sh"
ENV_FILE="${ENV_FILE:-${ROOT}/.env}"

# Load KEY=value pairs from .env; skip comments and blank lines.
# Does not override variables already exported in the parent environment.
_load_env_file() {
  local env_file="$1"
  [[ -f "$env_file" ]] || return 0

  local line key
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    [[ "$line" != *"="* ]] && continue
    key="${line%%=*}"
    key="${key%"${key##*[![:space:]]}"}"
    key="${key#"${key%%[![:space:]]*}"}"
    [[ -n "$key" ]] || continue
    if eval "[[ -z \"\${${key}+x}\" ]]"; then
      export "${key}=${line#*=}"
    fi
  done < "$env_file"
}

_load_env_file "${ENV_FILE}"

# Default production API (Dart Frog on Railway) if .env did not set API_HOST.
# https://very-yummy-coffee-production.up.railway.app/
PRODUCTION_API_BASE_URL="${PRODUCTION_API_BASE_URL:-https://very-yummy-coffee-production.up.railway.app/}"

if [[ -z "${API_HOST:-}" ]]; then
  _rest="${PRODUCTION_API_BASE_URL#https://}"
  _rest="${_rest#http://}"
  API_HOST="${_rest%%/*}"
  API_HOST="${API_HOST%%:*}"
fi

if [[ -z "${API_SECURE+x}" ]]; then
  case "${PRODUCTION_API_BASE_URL}" in
    http://*) API_SECURE=false ;;
    *) API_SECURE=true ;;
  esac
fi

# Default empty omits an explicit port (default https/wss port).
API_PORT="${API_PORT:-}"

SHOREBIRD_PLATFORMS="${SHOREBIRD_PLATFORMS:-android,ios,macos}"
# menu_board_app also has linux/; override with MENU_BOARD_PLATFORMS.
# Linux is omitted automatically on non-Linux hosts (see shorebird_platforms.sh).
MENU_BOARD_PLATFORMS="${MENU_BOARD_PLATFORMS:-android,ios,macos,linux}"

# All apps under applications/ that include shorebird.yaml in the repo.
SHOREBIRD_APPS=(
  applications/kds_app
  applications/kiosk_app
  applications/menu_board_app
  applications/mobile_app
  applications/pos_app
)

_parse_shorebird_script_args "$@"
if [[ "${SHOREBIRD_SCRIPT_HELP:-}" == "1" ]]; then
  cat <<'EOF'
Usage: shorebird_release_all.sh [options] [-- extra shorebird args]

  --apps=kds,kiosk,menu,mobile,pos   Only these apps (comma-separated). Aliases: kds, kiosk, menu,
                                     mobile, pos — or applications/<folder> if it exists.
  --platforms=android,ios,macos      Build these platforms for every selected app (overrides
                                     SHOREBIRD_PLATFORMS and MENU_BOARD_PLATFORMS for this run).

Environment: SHOREBIRD_PLATFORMS, MENU_BOARD_PLATFORMS, SHOREBIRD_FLUTTER_VERSION, API_HOST,
  API_KEY, ENV_FILE, etc.  (SHOREBIRD_FLUTTER_VERSION: optional; full Flutter git hash for
  `shorebird release --flutter-version`, required when matching an existing multi-platform release.)

Examples:
  ./scripts/shorebird_release_all.sh --apps=kds,menu --platforms=ios,macos
  ./scripts/shorebird_release_all.sh --apps=applications/mobile_app
EOF
  exit 0
fi

if [[ -n "${SHOREBIRD_PLATFORMS_CLI:-}" ]]; then
  SHOREBIRD_PLATFORMS="${SHOREBIRD_PLATFORMS_CLI}"
  MENU_BOARD_PLATFORMS="${SHOREBIRD_PLATFORMS_CLI}"
fi

_select_shorebird_apps "${ROOT}" "${SHOREBIRD_APPS_CLI:-}" "${SHOREBIRD_APPS[@]}"

if [[ -n "${API_KEY:-}" ]]; then
  _api_key_echo="***"
else
  _api_key_echo="(empty)"
fi

echo "Shorebird release — API_HOST=${API_HOST} API_SECURE=${API_SECURE} API_PORT=${API_PORT:-<empty>} API_KEY=${_api_key_echo}"
echo "Apps: ${SHOREBIRD_SELECTED_APPS[*]}"
echo "Requested platforms (default apps): ${SHOREBIRD_PLATFORMS}"
echo "Requested platforms (menu_board_app): ${MENU_BOARD_PLATFORMS}"
echo "Each app only builds targets that exist under that app (android/, ios/, macos/, linux/, windows/)."
echo ""

_ran=0
for app_rel in "${SHOREBIRD_SELECTED_APPS[@]}"; do
  app_dir="${ROOT}/${app_rel}"
  if [[ ! -f "${app_dir}/shorebird.yaml" ]]; then
    echo "Skipping ${app_rel} (no shorebird.yaml)" >&2
    continue
  fi
  case "${app_rel}" in
    applications/menu_board_app) _requested="${MENU_BOARD_PLATFORMS}" ;;
    *) _requested="${SHOREBIRD_PLATFORMS}" ;;
  esac
  _platforms="$(_filter_platforms_for_app "${app_dir}" "${_requested}")"
  _platforms="$(_filter_platforms_for_host "${_platforms}")"
  if [[ -z "${_platforms}" ]]; then
    echo "Skipping ${app_rel} (no platforms to build for this project/host after filtering)" >&2
    continue
  fi
  echo "========== ${app_rel} (${_requested} -> ${_platforms}) =========="
  (
    cd "${app_dir}"
    _dart_defines=(
      --dart-define=API_HOST="${API_HOST}"
      --dart-define=API_SECURE="${API_SECURE}"
      --dart-define=API_PORT="${API_PORT}"
    )
    if [[ -n "${API_KEY:-}" ]]; then
      _dart_defines+=(--dart-define=API_KEY="${API_KEY}")
    fi
    _shorebird_flutter_args=()
    if [[ -n "${SHOREBIRD_FLUTTER_VERSION:-}" ]]; then
      _shorebird_flutter_args+=(--flutter-version="${SHOREBIRD_FLUTTER_VERSION}")
    fi
    shorebird release \
      "${_shorebird_flutter_args[@]}" \
      --platforms "${_platforms}" \
      "${_dart_defines[@]}" \
      "${SHOREBIRD_PASSTHROUGH[@]}"
  )
  _ran=$((_ran + 1))
  echo ""
done

echo "Done. Released ${_ran} app(s)."
