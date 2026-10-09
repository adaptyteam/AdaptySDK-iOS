#!/bin/bash
# Runs the cocoapods-specs script tests.
set -euo pipefail
cd "$(dirname "$0")"
for test in *_test.rb; do
  echo "== $test"
  ruby "$test"
done
