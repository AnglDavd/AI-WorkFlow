#!/bin/bash

# Repository Cleanliness Checker
# This script verifies that no unwanted files are being tracked by Git

echo "🔍 Checking repository cleanliness..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Flag to track if any issues are found
ISSUES_FOUND=0

# Function to check for specific patterns
check_files() {
    local pattern="$1"
    local description="$2"
    
    echo -n "Checking for $description... "
    
    if git ls-files | grep -q "$pattern"; then
        echo -e "${RED}FOUND${NC}"
        echo -e "${YELLOW}Files found:${NC}"
        git ls-files | grep "$pattern" | sed 's/^/  - /'
        ISSUES_FOUND=1
    else
        echo -e "${GREEN}CLEAN${NC}"
    fi
}

# Check for various unwanted file types
check_files "\.vscode/" "VSCode configuration files"
check_files "\.idea/" "IntelliJ IDEA configuration files"
check_files "\.claude$" "Claude configuration files"
check_files "\.DS_Store$" "macOS .DS_Store files"
check_files "\.log$" "Log files"
check_files "\.tmp$" "Temporary files"
check_files "\.temp$" "Temp files"
check_files "__pycache__" "Python cache directories"
check_files "node_modules" "Node.js modules"
check_files "\.env$" "Environment files"
check_files "\.key$" "Key files"
check_files "\.pem$" "Certificate files"
check_files "plan_de_trabajo\.md$" "Internal planning documents"
check_files "roadmap_interno\.md$" "Internal roadmap files"
check_files "internal_planning\.md$" "Internal planning files"
check_files "CLAUDE\.md$" "Internal development documentation"
check_files "claude_instructions\.md$" "Claude instruction files"
check_files "dev_guide\.md$" "Development guide files"

echo "=================================="

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ Repository is clean!${NC}"
    echo "All checks passed. No unwanted files found in Git tracking."
else
    echo -e "${RED}❌ Issues found!${NC}"
    echo "Some files that should be ignored are being tracked by Git."
    echo ""
    echo "To fix these issues:"
    echo "1. Add the files to .gitignore if not already there"
    echo "2. Remove them from Git tracking: git rm --cached <file>"
    echo "3. Commit the changes"
fi

echo ""
echo "Current .gitignore effectiveness:"
git status --ignored --porcelain | grep "^!!" | wc -l | xargs echo "Files being properly ignored:"

exit $ISSUES_FOUND