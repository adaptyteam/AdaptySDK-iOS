#!/bin/bash

# Script for updating Adapty iOS SDK version
# Usage: ./update_version.sh <new_version>
# Example: ./update_version.sh 3.11.1

set -e

# Color codes for terminal output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if version argument is provided
if [ $# -eq 0 ]; then
    echo "Error: Version argument is required"
    echo "Usage: $0 <new_version>"
    echo "Example: $0 3.11.1"
    exit 1
fi

NEW_VERSION="$1"

# Validate version format (x.y.z or x.y.z-SUFFIX)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Z]+)?$ ]]; then
    echo "Error: Invalid version format. Use format x.y.z or x.y.z-SUFFIX"
    echo "Examples: 3.11.1, 3.12.0-SNAPSHOT"
    exit 1
fi

echo "Updating Adapty iOS SDK version to $NEW_VERSION..."

# Get old version from Sources/Versions.swift
OLD_VERSION=$(grep -o 'SDKVersion = "[^"]*"' Sources/Versions.swift | sed 's/SDKVersion = "\([^"]*\)"/\1/')
echo "  Old version: $OLD_VERSION"
echo "  New version: $NEW_VERSION"

# Find all podspec files automatically
PODSPEC_FILES=()
while IFS= read -r -d '' file; do
    PODSPEC_FILES+=("$file")
done < <(find . -maxdepth 1 -name "*.podspec" -print0)


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

# Update .podspec files
for file in "${PODSPEC_FILES[@]}"; do
    echo "  • $file"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/s.version *= *'[^']*'/s.version          = '$NEW_VERSION'/" "$file"
    else
        # Linux
        sed -i "s/s.version *= *'[^']*'/s.version          = '$NEW_VERSION'/" "$file"
    fi
done

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

# Check all podspec files
for file in "${PODSPEC_FILES[@]}"; do
    PODSPEC_VERSION=$(grep "s.version" "$file" | head -1 | sed -n "s/.*s.version[[:space:]]*=[[:space:]]*'\([^']*\)'.*/\1/p")
    if [ "$PODSPEC_VERSION" != "$NEW_VERSION" ]; then
        echo "❌ Error: $file version mismatch!"
        echo "   Expected: $NEW_VERSION"
        echo "   Actual: $PODSPEC_VERSION"
        exit 1
    fi
done

# Show changes
echo ""
echo -e "  Sources/Versions.swift:"
echo -e "  ${GREEN}$(grep "SDKVersion" Sources/Versions.swift)${NC}"

for file in "${PODSPEC_FILES[@]}"; do
    echo -e "  $file:"
    echo -e "    ${GREEN}$(grep "s.version" "$file" | head -1)${NC}"
done

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
