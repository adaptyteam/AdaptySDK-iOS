#!/bin/bash

# Script for updating Adapty iOS SDK version
# Usage: ./update_version.sh <new_version>
# Example: ./update_version.sh 4.0.0-beta.1

set -e

# Color codes for terminal output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if version argument is provided
if [ $# -eq 0 ]; then
    echo "Error: Version argument is required"
    echo "Usage: $0 <new_version>"
    echo "Example: $0 4.0.0-beta.1"
    exit 1
fi

NEW_VERSION="$1"

# Validate version format (x.y.z or x.y.z-SUFFIX, e.g. 4.0.0, 4.0.0-beta.1, 4.0.0-SNAPSHOT)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?$ ]]; then
    echo "Error: Invalid version format. Use format x.y.z or x.y.z-SUFFIX"
    echo "Examples: 4.0.0, 4.0.0-beta.1, 4.0.0-SNAPSHOT"
    exit 1
fi

echo "Updating Adapty iOS SDK version to $NEW_VERSION..."

# Get old version from Sources/Versions.swift
OLD_VERSION=$(grep -o 'SDKVersion = "[^"]*"' Sources/Versions.swift | sed 's/SDKVersion = "\([^"]*\)"/\1/')
echo "  Old version: $OLD_VERSION"
echo "  New version: $NEW_VERSION"

echo ""
echo "✏️  Updating files:"

# Update Sources/Versions.swift
echo "  • Sources/Versions.swift"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/SDKVersion = \"[^\"]*\"/SDKVersion = \"$NEW_VERSION\"/" Sources/Versions.swift
else
    # Linux
    sed -i "s/SDKVersion = \"[^\"]*\"/SDKVersion = \"$NEW_VERSION\"/" Sources/Versions.swift
fi

# Update Sources.AdaptyPlugin/cross_platform.yaml
echo "  • Sources.AdaptyPlugin/cross_platform.yaml"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|\$id: \"https://adapty.io/crossPlatform/[^/]*/schema\"|\$id: \"https://adapty.io/crossPlatform/$NEW_VERSION/schema\"|" Sources.AdaptyPlugin/cross_platform.yaml
else
    # Linux
    sed -i "s|\$id: \"https://adapty.io/crossPlatform/[^/]*/schema\"|\$id: \"https://adapty.io/crossPlatform/$NEW_VERSION/schema\"|" Sources.AdaptyPlugin/cross_platform.yaml
fi

echo ""
echo "🔍 Verifying version updates..."

# Check Sources/Versions.swift
ACTUAL_VERSION=$(grep -o 'SDKVersion = "[^"]*"' Sources/Versions.swift | sed 's/SDKVersion = "\([^"]*\)"/\1/')
if [ "$ACTUAL_VERSION" != "$NEW_VERSION" ]; then
    echo "❌ Error: Sources/Versions.swift version mismatch!"
    echo "   Expected: $NEW_VERSION"
    echo "   Actual: $ACTUAL_VERSION"
    exit 1
fi

# Check Sources.AdaptyPlugin/cross_platform.yaml
YAML_VERSION=$(grep -o '\$id: "https://adapty.io/crossPlatform/[^/]*/schema"' Sources.AdaptyPlugin/cross_platform.yaml | sed 's|$id: "https://adapty.io/crossPlatform/\([^/]*\)/schema"|\1|')
if [ "$YAML_VERSION" != "$NEW_VERSION" ]; then
    echo "❌ Error: Sources.AdaptyPlugin/cross_platform.yaml version mismatch!"
    echo "   Expected: $NEW_VERSION"
    echo "   Actual: $YAML_VERSION"
    exit 1
fi

# Show changes
echo ""
echo -e "  Sources/Versions.swift:"
echo -e "  ${GREEN}$(grep "SDKVersion" Sources/Versions.swift)${NC}"

echo -e "  Sources.AdaptyPlugin/cross_platform.yaml:"
echo -e "  ${GREEN}$(grep '\$id:' Sources.AdaptyPlugin/cross_platform.yaml)${NC}"

echo ""
echo "✅ Update completed!"

echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Run tests to verify functionality"
echo "  3. Create commit: git add . && git commit -m \"Bump version to $NEW_VERSION\""
echo "  4. Push changes: git push origin HEAD --tags"

if [[ $NEW_VERSION =~ -SNAPSHOT$ ]]; then
    echo ""
    echo "⚠️  Note: Version contains SNAPSHOT suffix - this is a development version"
fi
