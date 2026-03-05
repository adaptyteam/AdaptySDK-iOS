#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/lib/logging.sh"

usage() {
  cat <<'EOF'
Usage:
  build-spm-library-targets.sh --log <path> [--triple <target>] [--scratch-path <path>]

Examples:
  build-spm-library-targets.sh --log swift-build-products.log
  build-spm-library-targets.sh --log swift-build-macos.log --triple arm64-apple-macosx11.0
  build-spm-library-targets.sh --log swift-build-products.log --scratch-path /tmp/adapty-sdk-build
EOF
}

log_path=""
target_triple=""
scratch_path=""
resolve_package=false
package_scheme=""
package_destination=""
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
    --triple)
      if [[ $# -lt 2 ]]; then
        echo "Error: --triple requires an argument" >&2
        exit 1
      fi
      target_triple="$2"
      shift 2
      ;;
    --scratch-path)
      if [[ $# -lt 2 ]]; then
        echo "Error: --scratch-path requires an argument" >&2
        exit 1
      fi
      scratch_path="$2"
      shift 2
      ;;
    --resolve-package)
      resolve_package=true
      shift
      ;;
    --package-scheme)
      if [[ $# -lt 2 ]]; then
        echo "Error: --package-scheme requires an argument" >&2
        exit 1
      fi
      package_scheme="$2"
      shift 2
      ;;
    --package-destination)
      if [[ $# -lt 2 ]]; then
        echo "Error: --package-destination requires an argument" >&2
        exit 1
      fi
      package_destination="$2"
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

if [[ -n "$package_scheme" && -z "$package_destination" ]]; then
  echo "Error: --package-destination is required when --package-scheme is set." >&2
  exit 1
fi

if [[ -z "$package_scheme" && -n "$package_destination" ]]; then
  echo "Error: --package-destination cannot be used without --package-scheme." >&2
  exit 1
fi

ci_init_artifact_log "$(basename "$0")" "$log_path" "${original_args[@]}"

if [[ "$resolve_package" == true ]]; then
  ci_log_section "Resolving Swift package dependencies"
  resolve_args=(package)
  if [[ -n "$scratch_path" ]]; then
    resolve_args+=(--scratch-path "$scratch_path")
  fi
  resolve_args+=(resolve)
  ci_run_logged_command swift "${resolve_args[@]}"
fi

ci_log_section "Discovering SwiftPM library targets"
printf '+ '
ci_format_command node "$script_dir/list-library-targets.js"
targets_output="$(node "$script_dir/list-library-targets.js")"

targets=()
while IFS= read -r target; do
  [[ -n "$target" ]] && targets+=("$target")
done <<< "$targets_output"

if [[ "${#targets[@]}" -eq 0 ]]; then
  echo "No SwiftPM library targets found in Package.swift." >&2
  exit 1
fi

ci_log_section "Discovered ${#targets[@]} SwiftPM library target(s)"
for target in "${targets[@]}"; do
  echo " - ${target}"
done

for target in "${targets[@]}"; do
  build_args=(--target "$target")
  if [[ -n "$scratch_path" ]]; then
    build_args+=(--scratch-path "$scratch_path")
  fi

  if [[ -n "$target_triple" ]]; then
    build_args=(--triple "$target_triple" "${build_args[@]}")
    ci_log_section "Building SwiftPM target for ${target_triple}: ${target}"
  else
    ci_log_section "Building SwiftPM target: ${target}"
  fi

  ci_run_logged_command swift build "${build_args[@]}"
done

if [[ -n "$package_scheme" ]]; then
  ci_log_section "Building package scheme: ${package_scheme}"
  ci_run_logged_command \
    xcodebuild \
    -scheme "$package_scheme" \
    -configuration Debug \
    -destination "$package_destination" \
    CODE_SIGNING_ALLOWED=NO \
    build
fi
