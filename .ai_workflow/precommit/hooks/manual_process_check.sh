#!/bin/bash

# Manual Process Prevention Hook
echo "🔍 Checking for manual processes in changes..."

# Get changed files
CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(md|sh)$' || true)

if [[ -z "$CHANGED_FILES" ]]; then
    echo "✅ No relevant files changed"
    exit 0
fi

# Check each changed file for manual process indicators
MANUAL_FOUND=false
for file in $CHANGED_FILES; do
    if [[ -f "$file" ]]; then
        # Check for high-severity manual process patterns
        if grep -q -i "read -p\|user.*confirm\|manually.*run\|check.*manually\|configure.*manually\|install.*manually\|you.*need.*to\|please.*run" "$file"; then
            echo "⚠️  Manual process detected in: $file"
            echo "   Consider automating this process before committing"
            MANUAL_FOUND=true
        fi
    fi
done

if [[ "$MANUAL_FOUND" == "true" ]]; then
    echo ""
    echo "💡 Suggestions:"
    echo "   - Review the detected manual processes"
    echo "   - Consider creating automated workflows"
    echo "   - Add CLI commands for manual operations"
    echo "   - Use environment variables for user input"
    echo ""
    echo "   To bypass this check (not recommended): git commit --no-verify"
    echo ""
    echo "🎯 Goal: Maintain zero-friction automation philosophy"
    exit 1
fi

echo "✅ No manual processes detected in changes"
exit 0
