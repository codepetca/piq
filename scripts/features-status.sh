#!/bin/bash

# piq Feature Status Display
# Shows feature summary from .ai/features.json without external dependencies (pure bash + grep)

set -e  # Exit immediately on error
set -u  # Exit on undefined variable

FEATURES_FILE=".ai/features.json"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if features.json exists
if [ ! -f "$FEATURES_FILE" ]; then
    echo -e "${RED}Error: $FEATURES_FILE not found${NC}"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}piq Feature Status${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Extract meta information using grep
CURRENT_PHASE=$(grep '"phase"' "$FEATURES_FILE" | head -1 | sed 's/.*: "//;s/",//')
TOTAL=$(grep -c '"id":' "$FEATURES_FILE")
PASSING=$(grep -c '"passes": true' "$FEATURES_FILE")
FAILING=$(grep -c '"passes": false' "$FEATURES_FILE")

echo -e "${BLUE}Current Phase:${NC} $CURRENT_PHASE"
echo ""
echo -e "${BLUE}Overall Progress:${NC}"
echo "  Total features: $TOTAL"
echo -e "  ${GREEN}Passing: $PASSING ✅${NC}"
echo -e "  ${RED}Failing: $FAILING ❌${NC}"
echo ""

# Calculate percentage
if [ "$TOTAL" -gt 0 ]; then
    PERCENT=$((PASSING * 100 / TOTAL))
    echo -e "${BLUE}Completion: ${PERCENT}%${NC}"
    echo ""
fi

# Show next 5 failing features
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}Next Failing Features:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Extract failing features (showing description lines after "passes": false)
grep -B 3 '"passes": false' "$FEATURES_FILE" | \
    grep '"description"' | \
    sed 's/.*"description": "//;s/",//' | \
    head -5 | \
    nl -w2 -s'. '

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For detailed feature info, read .ai/features.json"
echo "To see full journal history: tail -50 .ai/JOURNAL.md"
echo ""
