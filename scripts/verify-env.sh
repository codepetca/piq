#!/bin/bash

# piq Development Environment Verification
# Validates that the development environment is properly configured before AI work begins

set -e  # Exit immediately on error

echo "🔍 Verifying piq development environment..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function for errors
error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    exit 1
}

# Helper function for success
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Helper function for warnings
warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Check Swift compiler
echo "Checking Swift compiler..."
if ! which swift > /dev/null 2>&1; then
    error "Swift compiler not found. Install Xcode from the App Store."
fi
SWIFT_VERSION=$(swift --version | head -1)
success "Swift compiler found: $SWIFT_VERSION"
echo ""

# 2. Check swift build
echo "Building project..."
if ! swift build > /tmp/piq-build.log 2>&1; then
    echo -e "${RED}Build failed. Error output:${NC}"
    cat /tmp/piq-build.log
    error "swift build failed. Fix build errors before proceeding."
fi
success "Project builds successfully"
echo ""

# 3. Run tests
echo "Running tests..."
if ! swift test > /tmp/piq-test.log 2>&1; then
    echo -e "${RED}Tests failed. Test output:${NC}"
    tail -50 /tmp/piq-test.log
    error "Tests failing. Fix test failures before proceeding."
fi

# Extract test summary
TEST_SUMMARY=$(grep "Test Suite.*passed" /tmp/piq-test.log | tail -1 || echo "")
if [ -z "$TEST_SUMMARY" ]; then
    error "Could not determine test status. Check /tmp/piq-test.log"
fi
success "Tests passed: $TEST_SUMMARY"
echo ""

# 4. Check Xcode project
echo "Checking Xcode project..."
if [ ! -f "ios/Piq.xcodeproj/project.pbxproj" ]; then
    error "Xcode project not found at ios/Piq.xcodeproj"
fi
success "Xcode project exists: ios/Piq.xcodeproj"
echo ""

# 5. Check .ai/ infrastructure
echo "Checking AI infrastructure..."
if [ ! -d ".ai" ]; then
    error ".ai/ directory missing. Run issue #102 implementation to create it."
fi
success ".ai/ directory exists"

MISSING_FILES=()
if [ ! -f ".ai/START-HERE.md" ]; then
    MISSING_FILES+=("START-HERE.md")
fi
if [ ! -f ".ai/JOURNAL.md" ]; then
    MISSING_FILES+=("JOURNAL.md")
fi
if [ ! -f ".ai/features.json" ]; then
    MISSING_FILES+=("features.json")
fi

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    error "Missing .ai/ files: ${MISSING_FILES[*]}"
fi
success "All required .ai/ files present"
echo ""

# 6. Validate features.json is valid JSON
echo "Validating features.json..."
if ! python3 -m json.tool .ai/features.json > /dev/null 2>&1; then
    error "features.json is not valid JSON"
fi
success "features.json is valid JSON"
echo ""

# All checks passed
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Environment verified. Ready for development.${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Review .ai/START-HERE.md for workflow"
echo "  2. Check feature status: bash scripts/features-status.sh"
echo "  3. Review recent journal: tail -50 .ai/JOURNAL.md"
echo ""
