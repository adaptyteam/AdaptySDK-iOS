#!/usr/bin/env bash

set -euo pipefail

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

: > "$log_path"

targets_output="$(node scripts/ci/sdk_validation/list-library-targets.js)"

targets=()
while IFS= read -r target; do
  [[ -n "$target" ]] && targets+=("$target")
done <<< "$targets_output"

if [[ "${#targets[@]}" -eq 0 ]]; then
  echo "No SwiftPM library targets found in Package.swift." >&2
  exit 1
fi

for target in "${targets[@]}"; do
  build_args=(--target "$target")
  if [[ -n "$scratch_path" ]]; then
    build_args+=(--scratch-path "$scratch_path")
  fi

  if [[ -n "$target_triple" ]]; then
    build_args=(--triple "$target_triple" "${build_args[@]}")
    echo "=== Building SwiftPM target for ${target_triple}: ${target} ===" | tee -a "$log_path"
  else
    echo "=== Building SwiftPM target: ${target} ===" | tee -a "$log_path"
  fi

  swift build "${build_args[@]}" 2>&1 | tee -a "$log_path"
done
