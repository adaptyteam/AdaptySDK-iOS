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
- Validates version format
- Verifies all changes were applied correctly
- Shows summary of all updated files

**Version format**: `x.y.z` or `x.y.z-SUFFIX` (e.g., `3.12.0`, `3.12.0-SNAPSHOT`)

**Note**: This script should be used whenever you need to change the SDK version. Do not manually edit version numbers in individual files.

> **Distribution note**: As of 4.0.0 the SDK ships via Swift Package Manager only; CocoaPods support (podspecs and the trunk-publish flow) was removed.
