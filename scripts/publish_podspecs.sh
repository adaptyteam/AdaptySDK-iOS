#!/bin/bash

# Script for publishing Adapty iOS SDK podspecs to CocoaPods trunk
# This script publishes podspecs in the correct dependency order and waits
# for each pod to be available before publishing the next one.
# Usage: ./publish_podspecs.sh [--skip-lint] [--max-retries N] [--initial-wait N]
# Example: ./publish_podspecs.sh --max-retries 5 --initial-wait 30

set -e

# Color codes for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
SKIP_LINT=false
SKIP_TESTS=false
MAX_RETRIES=5
RETRY_DELAY=10       # Delay between retries in seconds

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-lint)
            SKIP_LINT=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --max-retries)
            MAX_RETRIES="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-lint          Skip pod lib lint before publishing"
            echo "  --skip-tests         Skip building and running tests during validation (faster, less thorough)"
            echo "  --max-retries N      Maximum number of retries for each podspec (default: 5)"
            echo "  --help               Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Podspecs in dependency order (must be published in this order)
PODSPECS=("Adapty.podspec" "AdaptyUI.podspec" "AdaptyPlugin.podspec")

# Function to extract pod name from podspec
get_pod_name() {
    local podspec=$1
    grep "s.name" "$podspec" | head -1 | sed -n "s/.*s.name[[:space:]]*=[[:space:]]*'\([^']*\)'.*/\1/p"
}

# Function to extract version from podspec
get_pod_version() {
    local podspec=$1
    grep "s.version" "$podspec" | head -1 | sed -n "s/.*s.version[[:space:]]*=[[:space:]]*'\([^']*\)'.*/\1/p"
}

# Function to check if podspec has dependencies
has_dependencies() {
    local podspec=$1
    # Check if podspec contains s.dependency
    if grep -q "s.dependency" "$podspec"; then
        return 0  # Has dependencies
    else
        return 1  # No dependencies
    fi
}


# Function to publish a podspec
publish_podspec() {
    local podspec=$1
    local pod_name=$(get_pod_name "$podspec")
    local version=$(get_pod_version "$podspec")
    local attempt=1
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📦 Publishing $pod_name ($version)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Update pod repo before processing to ensure we have latest dependencies
    echo -e "${BLUE}🔄 Updating pod repo to get latest dependencies...${NC}"
    if ! pod repo update; then
        echo -e "${YELLOW}⚠️  Warning: pod repo update failed, but continuing...${NC}"
    else
        echo -e "${GREEN}✅ Pod repo updated${NC}"
    fi
    echo ""
    
    while [ $attempt -le $MAX_RETRIES ]; do
        echo ""
        echo -e "${YELLOW}Attempt $attempt/$MAX_RETRIES${NC}"
        
        # Step 1: Lint (if not skipped)
        if [ "$SKIP_LINT" = false ]; then
            echo -e "${BLUE}🔍 Linting $podspec...${NC}"
            LINT_ARGS="--allow-warnings"
            # Skip tests if explicitly requested OR if podspec has dependencies
            # (dependencies might not be fully available yet, causing test failures)
            if [ "$SKIP_TESTS" = true ] || has_dependencies "$podspec"; then
                if has_dependencies "$podspec"; then
                    echo -e "${YELLOW}   Note: Skipping tests because podspec has dependencies${NC}"
                fi
                LINT_ARGS="$LINT_ARGS --skip-tests"
            fi
            if ! pod lib lint "$podspec" $LINT_ARGS; then
                echo -e "${RED}❌ Lint failed for $podspec${NC}"
                if [ $attempt -lt $MAX_RETRIES ]; then
                    echo -e "${YELLOW}   Retrying in ${RETRY_DELAY}s...${NC}"
                    sleep $RETRY_DELAY
                    attempt=$((attempt + 1))
                    continue
                else
                    echo -e "${RED}❌ Failed to lint $podspec after $MAX_RETRIES attempts${NC}"
                    return 1
                fi
            fi
            echo -e "${GREEN}✅ Lint passed${NC}"
        else
            echo -e "${YELLOW}⏭️  Skipping lint (--skip-lint flag set)${NC}"
        fi
        
        # Step 2: Publish with --synchronous flag to wait for dependencies
        echo -e "${BLUE}🚀 Publishing $podspec to CocoaPods trunk (synchronous)...${NC}"
        PUSH_ARGS="--allow-warnings --synchronous"
        # Skip tests if explicitly requested OR if podspec has dependencies
        if [ "$SKIP_TESTS" = true ] || has_dependencies "$podspec"; then
            PUSH_ARGS="$PUSH_ARGS --skip-tests"
        fi
        if pod trunk push "$podspec" $PUSH_ARGS; then
            echo -e "${GREEN}✅ Successfully published $pod_name ($version)${NC}"
            
            # Step 3: Update pod repo
            echo -e "${BLUE}🔄 Updating pod repo...${NC}"
            if pod repo update; then
                echo -e "${GREEN}✅ Pod repo updated${NC}"
            else
                echo -e "${YELLOW}⚠️  Warning: pod repo update failed, but continuing...${NC}"
            fi
            
            return 0
        else
            echo -e "${RED}❌ Failed to publish $podspec${NC}"
            if [ $attempt -lt $MAX_RETRIES ]; then
                echo -e "${YELLOW}   Retrying in ${RETRY_DELAY}s...${NC}"
                sleep $RETRY_DELAY
                attempt=$((attempt + 1))
            else
                echo -e "${RED}❌ Failed to publish $podspec after $MAX_RETRIES attempts${NC}"
                return 1
            fi
        fi
    done
    
    return 1
}

# Main execution
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 Adapty iOS SDK Podspec Publisher${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Configuration:"
echo "  Max retries: $MAX_RETRIES"
echo "  Skip lint: $SKIP_LINT"
echo "  Skip tests: $SKIP_TESTS"
echo "  Using --synchronous flag to wait for dependencies"
echo ""

# Check if we're in the right directory
if [ ! -f "Adapty.podspec" ]; then
    echo -e "${RED}❌ Error: Adapty.podspec not found. Please run this script from the project root.${NC}"
    exit 1
fi

# Check if pod command is available
if ! command -v pod &> /dev/null; then
    echo -e "${RED}❌ Error: CocoaPods is not installed. Please install it with: gem install cocoapods${NC}"
    exit 1
fi

# Check if user is logged into trunk
if ! pod trunk me &> /dev/null; then
    echo -e "${RED}❌ Error: Not logged into CocoaPods trunk. Please run: pod trunk register${NC}"
    exit 1
fi

# Publish each podspec in order
FAILED_PODSPECS=()
for podspec in "${PODSPECS[@]}"; do
    if [ ! -f "$podspec" ]; then
        echo -e "${YELLOW}⚠️  Warning: $podspec not found, skipping...${NC}"
        continue
    fi
    
    if ! publish_podspec "$podspec"; then
        FAILED_PODSPECS+=("$podspec")
        echo -e "${RED}❌ Failed to publish $podspec. Stopping.${NC}"
        break
    fi
done

# Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ ${#FAILED_PODSPECS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All podspecs published successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${RED}❌ Some podspecs failed to publish:${NC}"
    for podspec in "${FAILED_PODSPECS[@]}"; do
        echo -e "${RED}   - $podspec${NC}"
    done
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi

