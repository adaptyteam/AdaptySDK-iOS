# Scripts

This directory contains utility scripts for the Adapty iOS SDK project.

## Version Management

### `update_version.sh`

**Purpose**: Updates the Adapty iOS SDK version across all necessary files in the project.

**Usage**:
```bash
# From project root directory
./scripts/update_version.sh <new_version>

# Examples
./scripts/update_version.sh 3.12.0
./scripts/update_version.sh 3.12.0-SNAPSHOT
```

**What it does**:
- Updates version in `Sources/Versions.swift` (main SDK version constant)
- Updates version in `Sources.AdaptyPlugin/cross_platform.yaml` (cross-platform schema version)
- Updates version in all podspec files (CocoaPods specification)
- Validates version format
- Verifies all changes were applied correctly
- Shows summary of all updated files

**Version format**: `x.y.z` or `x.y.z-SUFFIX` (e.g., `3.12.0`, `3.12.0-SNAPSHOT`)

**Note**: This script should be used whenever you need to change the SDK version. Do not manually edit version numbers in individual files.

## Publishing to CocoaPods

### `publish_podspecs.sh`

**Purpose**: Publishes all Adapty iOS SDK podspecs to CocoaPods trunk in the correct dependency order, with automatic retry logic and availability checking.

**Usage**:
```bash
# From project root directory
./scripts/publish_podspecs.sh [OPTIONS]

# Examples
./scripts/publish_podspecs.sh
./scripts/publish_podspecs.sh --skip-lint
./scripts/publish_podspecs.sh --skip-tests
./scripts/publish_podspecs.sh --skip-lint --skip-tests
./scripts/publish_podspecs.sh --max-retries 10
```

**Options**:
- `--skip-lint`: Skip `pod lib lint` before publishing (faster, but less safe)
- `--skip-tests`: Skip building and running tests during validation for all podspecs (faster, but less thorough)
- `--max-retries N`: Maximum number of retries for each podspec (default: 5)
- `--help`: Show help message

**Note**: Tests are automatically skipped for podspecs that have dependencies (AdaptyUI and AdaptyPlugin), since dependencies might not be fully available yet during linting. The `--skip-tests` flag can be used to skip tests for all podspecs, including Adapty.

**What it does**:
1. Publishes podspecs in dependency order:
   - `Adapty.podspec` (no dependencies)
   - `AdaptyUI.podspec` (depends on Adapty)
   - `AdaptyPlugin.podspec` (depends on Adapty and AdaptyUI)
2. For each podspec:
   - Updates pod repo to get latest dependencies from previous publishes
   - Runs `pod lib lint` (unless `--skip-lint` is used)
     - Automatically skips tests for podspecs with dependencies (to avoid dependency availability issues)
   - Publishes to CocoaPods trunk with `pod trunk push --synchronous` (waits for dependencies to be available)
     - Automatically skips tests for podspecs with dependencies
   - Updates pod repo with `pod repo update`
   - Retries on failure with configurable retry count
3. Stops if any podspec fails to publish

**Prerequisites**:
- CocoaPods must be installed (`gem install cocoapods`)
- You must be logged into CocoaPods trunk (`pod trunk register` and `pod trunk me`)

**Note**: The script uses the `--synchronous` flag when publishing, which makes CocoaPods wait for recently pushed dependencies to become available before proceeding. This eliminates the need for manual waiting and polling.
