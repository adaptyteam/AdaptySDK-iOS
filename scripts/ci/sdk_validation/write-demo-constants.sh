#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  write-demo-constants.sh [--output <path>]

Default output:
  Examples/AdaptyRecipes-SwiftUI/AdaptyRecipes-SwiftUI/Application/AppConstants.swift
EOF
}

output_path="Examples/AdaptyRecipes-SwiftUI/AdaptyRecipes-SwiftUI/Application/AppConstants.swift"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      if [[ $# -lt 2 ]]; then
        echo "Error: --output requires an argument" >&2
        exit 1
      fi
      output_path="$2"
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

mkdir -p "$(dirname "$output_path")"

cat > "$output_path" <<'SWIFT'
//
//  AppConstants.swift
//  AdaptyRecipes-SwiftUI
//
//  Auto-generated in CI for build validation.
//

import Foundation

enum AppConstants {
    static let accessLevelId = "premium"
    static let adaptyApiKey = "ci_dummy_api_key"
    static let placementId = "ci_dummy_placement_id"
}
SWIFT
