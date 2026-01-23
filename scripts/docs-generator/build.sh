#!/bin/bash

# Script for installing dependencies and building HTML documentation for Adapty SDK
# This script uses Swift Package Manager to generate DocC documentation

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display informational messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Function to display warnings
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to display errors
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for required tools
check_requirements() {
    info "Checking for required tools..."

    # Check for Swift
    if ! command -v swift &> /dev/null; then
        error "swift not found. Please install Xcode Command Line Tools."
        exit 1
    fi

    # Check Swift version (need 5.6+ for docc plugin)
    SWIFT_VERSION=$(swift --version | head -n 1 | awk '{print $4}')
    info "Swift version: $SWIFT_VERSION"

    info "All required tools are installed ✓"
}

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
info "Project root directory: $PROJECT_ROOT"

# Output directory for documentation
OUTPUT_DIR="${PROJECT_ROOT}/docs"
info "Documentation directory: $OUTPUT_DIR"

# Create documentation directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to build documentation for a module using manual docc compilation
build_documentation() {
    local module_name=$1
    info "Building documentation for module: $module_name"

    # Map module name to source directory
    local SOURCE_DIR=""
    case "$module_name" in
        "Adapty")
            SOURCE_DIR="${PROJECT_ROOT}/Sources"
            ;;
        "AdaptyUI")
            SOURCE_DIR="${PROJECT_ROOT}/Sources.AdaptyUI"
            ;;
        "AdaptyLogger")
            SOURCE_DIR="${PROJECT_ROOT}/Sources.Logger"
            ;;
        "AdaptyUIBuilder")
            SOURCE_DIR="${PROJECT_ROOT}/Sources.UIBuilder"
            ;;
        "AdaptyPlugin")
            SOURCE_DIR="${PROJECT_ROOT}/Sources.AdaptyPlugin"
            ;;
        *)
            error "Unknown module: $module_name"
            return 1
            ;;
    esac

    # Check if source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        error "Source directory not found: $SOURCE_DIR"
        return 1
    fi

    info "Source directory: $SOURCE_DIR"

    # Build the module and generate symbol graph
    info "Building module and generating symbol graph..."

    # Create module-specific symbol graphs directory (keep existing graphs for incremental builds)
    local SYMBOL_GRAPH_DIR="${PROJECT_ROOT}/.build/symbol-graphs/${module_name}"
    mkdir -p "$SYMBOL_GRAPH_DIR"

    swift build --target "$module_name" \
        -Xswiftc -emit-symbol-graph \
        -Xswiftc -emit-symbol-graph-dir -Xswiftc "$SYMBOL_GRAPH_DIR" \
        || {
            error "Failed to build $module_name and generate symbol graph"
            return 1
        }

    # Fallback: incremental builds can skip compilation and not emit symbol graphs
    if ! compgen -G "$SYMBOL_GRAPH_DIR/*.symbols.json" > /dev/null; then
        warn "Symbol graphs were not generated. Forcing clean rebuild..."
        swift package clean
        rm -rf "$SYMBOL_GRAPH_DIR"
        mkdir -p "$SYMBOL_GRAPH_DIR"
        swift build --target "$module_name" \
            -Xswiftc -emit-symbol-graph \
            -Xswiftc -emit-symbol-graph-dir -Xswiftc "$SYMBOL_GRAPH_DIR" \
            || {
                error "Failed to build $module_name and generate symbol graph"
                return 1
            }
    fi

    info "Symbol graphs for $module_name and its dependencies generated ✓"

    # Build documentation with docc
    local ARCHIVE_PATH="${PROJECT_ROOT}/.build/${module_name}.doccarchive"
    mkdir -p "${PROJECT_ROOT}/.build"
    rm -rf "$ARCHIVE_PATH"

    info "Generating DocC archive..."
    xcrun docc convert "$SOURCE_DIR" \
        --allow-arbitrary-catalog-directories \
        --fallback-display-name "$module_name" \
        --fallback-bundle-identifier "io.adapty.${module_name}" \
        --fallback-bundle-version "1.0.0" \
        --additional-symbol-graph-dir "$SYMBOL_GRAPH_DIR" \
        --output-path "$ARCHIVE_PATH" \
        || {
            error "Failed to generate documentation for $module_name"
            return 1
        }

    info "Documentation archive created at $ARCHIVE_PATH ✓"
}

# Function to export documentation to HTML
export_to_html() {
    local module_name=$1
    local ARCHIVE_PATH="${PROJECT_ROOT}/.build/${module_name}.doccarchive"

    if [ ! -d "$ARCHIVE_PATH" ]; then
        error "Documentation archive for $module_name not found at $ARCHIVE_PATH, cannot export to HTML"
        return 1
    fi

    info "Exporting $module_name documentation to HTML..."

    # Ensure OUTPUT_DIR is clean and exists
    rm -rf "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"

    # Export to HTML using xcrun docc
    xcrun docc process-archive transform-for-static-hosting \
        "$ARCHIVE_PATH" \
        --output-path "$OUTPUT_DIR" \
        || {
            error "Failed to export documentation for $module_name to HTML"
            return 1
        }

    info "HTML documentation for $module_name created at $OUTPUT_DIR ✓"
}

# Main function
main() {
    info "=== Starting Adapty SDK documentation build process ==="

    # Check requirements
    check_requirements

    # Navigate to project root directory
    cd "$PROJECT_ROOT"

    # We only build AdaptyUI (it now includes Adapty docs)
    local module="AdaptyUI"

    # 1. Build the archive
    build_documentation "$module" || exit 1

    # 2. Export to HTML (Mandatory)
    export_to_html "$module" || exit 1

    # 3. Use the landing template for the root index.html
    info "Setting up documentation hub (landing page)..."
    local template_path="${PROJECT_ROOT}/scripts/docs-generator/landing.html"
    if [ -f "$template_path" ]; then
        cp "$template_path" "${OUTPUT_DIR}/index.html"
        info "Documentation hub configured ✓"
    else
        warn "Landing template not found at $template_path, skipping..."
    fi

    info "=== Documentation build completed successfully! ==="
    info "Final documentation saved to: ${OUTPUT_DIR}"
    info ""
    info "To view the documentation:"
    info "  1. Start a local server: cd ${OUTPUT_DIR} && python3 -m http.server 8080"
    info "  2. Open: http://localhost:8080/"
}

# Run main function
main "$@"
