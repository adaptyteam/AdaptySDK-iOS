#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/lib/logging.sh"

usage() {
  cat <<'EOF'
Usage:
  build-demo-app.sh --log <path>
EOF
}

log_path=""
original_args=("$@")

while [[ $# -gt 0 ]]; do
  case "$1" in
    --log)
      if [[ $# -lt 2 ]]; then
        echo "Error: --log requires an argument" >&2
        exit 1
      fi
      log_path="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$log_path" ]]; then
  echo "Error: --log is required." >&2
  usage
  exit 1
fi

if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
  echo "Error: GITHUB_OUTPUT is not set." >&2
  exit 1
fi

ci_init_artifact_log "$(basename "$0")" "$log_path" "${original_args[@]}"
ci_log_section "Building demo app"

exit_code=0
ci_run_logged_command_capture_exit \
  exit_code \
  xcodebuild \
  -project Examples/AdaptyRecipes-SwiftUI/AdaptyRecipes-SwiftUI.xcodeproj \
  -scheme AdaptyRecipes-SwiftUI \
  -configuration Debug \
  -destination "generic/platform=iOS" \
  CODE_SIGNING_ALLOWED=NO \
  build

printf 'exit_code=%s\n' "$exit_code" >> "$GITHUB_OUTPUT"
