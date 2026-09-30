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

**Purpose**: Publishes all Adapty iOS SDK podspecs to CocoaPods trunk in dependency order, with retries.

**Usage**:
```bash
# From project root directory
./scripts/publish_podspecs.sh [OPTIONS]

# Examples
./scripts/publish_podspecs.sh
./scripts/publish_podspecs.sh --skip-lint
./scripts/publish_podspecs.sh --skip-tests
./scripts/publish_podspecs.sh --max-retries 10
```

**Options**:
- `--skip-lint`: Skip `pod lib lint` before publishing (faster, but less safe)
- `--skip-tests`: Skip building and running tests during validation for all podspecs
- `--max-retries N`: Maximum number of retries for each podspec (default: 5)
- `--help`: Show help message

**What it does**:
1. Publishes podspecs in dependency order: `AdaptyLogger`, `AdaptyCSimdjson`, `AdaptyCodable`, `AdaptyUIBuilder`, `Adapty`, `AdaptyUI`, `AdaptyPlugin`.
2. For each podspec:
   - Runs `pod repo update` to pick up the pods published before it
   - Runs `pod lib lint` (unless `--skip-lint` is used); tests are skipped for podspecs that have dependencies
   - Publishes with `pod trunk push --synchronous`, which waits for the dependencies pushed just before to become available
   - Retries on failure up to `--max-retries` times
3. Stops if any podspec fails to publish.

**Prerequisites**:
- CocoaPods must be installed (`gem install cocoapods`)
- You must be registered with CocoaPods trunk (`pod trunk register`, check with `pod trunk me`)

**Note**: Run `update_version.sh` first, so that every podspec carries the version being released; the podspecs point at the git tag of that version.
