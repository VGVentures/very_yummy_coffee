#!/usr/bin/env bash
# Shared helpers for Shorebird scripts. Source after SCRIPT_DIR is set:
#   source "${SCRIPT_DIR}/shorebird_platforms.sh"

# Map a short name or applications/... path to applications/<name>_app. Echoes nothing if unknown.
# $1 = repo root (absolute), $2 = token (e.g. kds, menu, applications/kds_app)
_resolve_shorebird_app_alias() {
  local _root="$1"
  local token="$2"
  token="${token#"${token%%[![:space:]]*}"}"
  token="${token%"${token##*[![:space:]]}"}"
  [[ -z "$token" ]] && return 0
  case "${token}" in
    kds | kds_app) echo "applications/kds_app" ;;
    kiosk | kiosk_app) echo "applications/kiosk_app" ;;
    menu | menu_board | menuboard | menu_board_app) echo "applications/menu_board_app" ;;
    mobile | mobile_app) echo "applications/mobile_app" ;;
    pos | pos_app) echo "applications/pos_app" ;;
    applications/*)
      if [[ -d "${_root}/${token}" ]]; then
        echo "${token}"
      fi
      ;;
  esac
}

# Sets SHOREBIRD_SELECTED_APPS (bash array) from optional comma-separated filter.
# With an empty filter, copies all_apps. Unknown tokens exit 1. Dedupes by first occurrence order.
_select_shorebird_apps() {
  local _root="$1"
  local filter_csv="$2"
  shift 2
  local all_apps=("$@")
  SHOREBIRD_SELECTED_APPS=()
  if [[ -z "${filter_csv// }" ]]; then
    SHOREBIRD_SELECTED_APPS=("${all_apps[@]}")
    return 0
  fi
  local token rel seen p
  local -a _toks
  IFS=',' read -ra _toks <<< "${filter_csv}"
  for token in "${_toks[@]}"; do
    token="${token#"${token%%[![:space:]]*}"}"
    token="${token%"${token##*[![:space:]]}"}"
    [[ -z "$token" ]] && continue
    rel="$(_resolve_shorebird_app_alias "${_root}" "${token}")"
    if [[ -z "${rel}" ]]; then
      echo "Unknown app '${token}'. Use: kds, kiosk, menu, mobile, pos, or applications/<dir> (under repo root)." >&2
      exit 1
    fi
    seen=false
    for p in "${SHOREBIRD_SELECTED_APPS[@]}"; do
      [[ "$p" == "$rel" ]] && seen=true && break
    done
    if [[ "${seen}" == false ]]; then
      SHOREBIRD_SELECTED_APPS+=("$rel")
    fi
  done
}

# Parses leading --apps and --platforms; remaining args go to SHOREBIRD_PASSTHROUGH (array).
# Sets SHOREBIRD_APPS_CLI and SHOREBIRD_PLATFORMS_CLI (optional).
_parse_shorebird_script_args() {
  SHOREBIRD_APPS_CLI=""
  SHOREBIRD_PLATFORMS_CLI=""
  SHOREBIRD_SCRIPT_HELP=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --apps=*)
        SHOREBIRD_APPS_CLI="${1#--apps=}"
        shift
        ;;
      --apps)
        [[ $# -ge 2 ]] || {
          echo "error: --apps requires a value (comma-separated: kds,kiosk,menu,mobile,pos)" >&2
          exit 1
        }
        SHOREBIRD_APPS_CLI="$2"
        shift 2
        ;;
      --platforms=*)
        SHOREBIRD_PLATFORMS_CLI="${1#--platforms=}"
        shift
        ;;
      --platforms)
        [[ $# -ge 2 ]] || {
          echo "error: --platforms requires a value (e.g. android,ios,macos)" >&2
          exit 1
        }
        SHOREBIRD_PLATFORMS_CLI="$2"
        shift 2
        ;;
      -h | --help)
        SHOREBIRD_SCRIPT_HELP=1
        SHOREBIRD_PASSTHROUGH=()
        return 0
        ;;
      *)
        break
        ;;
    esac
  done
  SHOREBIRD_PASSTHROUGH=("$@")
}

# Echo comma-separated platforms from $2 that exist under $1 (android/, ios/, macos/, linux/, windows/).
# Order follows the requested list. Echoes nothing if none match.
_filter_platforms_for_app() {
  local app_dir="$1"
  local requested="$2"
  local result=()
  local p
  # Comma-separated list (tr is portable; ${var//,/ } is easy to typo).
  local _tokens
  _tokens="$(printf '%s' "$requested" | tr ',' ' ')"
  for p in ${_tokens}; do
    p="${p// /}"
    [[ -z "$p" ]] && continue
    case "$p" in
      android) [[ -d "${app_dir}/android" ]] && result+=("$p") ;;
      ios) [[ -d "${app_dir}/ios" ]] && result+=("$p") ;;
      macos) [[ -d "${app_dir}/macos" ]] && result+=("$p") ;;
      linux) [[ -d "${app_dir}/linux" ]] && result+=("$p") ;;
      windows) [[ -d "${app_dir}/windows" ]] && result+=("$p") ;;
      *) echo "Unknown platform '${p}' ignored (expected android|ios|macos|linux|windows)." >&2 ;;
    esac
  done
  (IFS=','; echo "${result[*]}")
}

# Remove platforms that Shorebird cannot build on this OS. Linux release/patch is only
# supported on Linux hosts; including linux on macOS or Windows causes shorebird to exit 1.
_filter_platforms_for_host() {
  local platforms_csv="$1"
  local result=()
  local p
  local _tokens
  local _omit_linux=false
  case "$(uname -s)" in
    Linux) ;;
    *) _omit_linux=true ;;
  esac
  _tokens="$(printf '%s' "$platforms_csv" | tr ',' ' ')"
  for p in ${_tokens}; do
    p="${p// /}"
    [[ -z "$p" ]] && continue
    case "$p" in
      linux)
        if [[ "${_omit_linux}" == true ]]; then
          continue
        fi
        ;;
    esac
    result+=("$p")
  done
  if [[ "${_omit_linux}" == true ]] && [[ "${platforms_csv}" == *"linux"* ]]; then
    echo "Note: omitting platform 'linux' on this host (Shorebird Linux builds require Linux). Use a Linux machine or CI to release/patch Linux." >&2
  fi
  (IFS=','; echo "${result[*]}")
}
