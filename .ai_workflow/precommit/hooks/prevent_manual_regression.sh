#!/bin/bash

# Manual Process Regression Prevention System
echo "🛡️  Manual Process Regression Prevention"
echo "========================================"

# Configuration
PREVENTION_LOG=".ai_workflow/logs/prevention_$(date +%Y%m%d_%H%M%S).log"
BLOCKED_PATTERNS=(
    "read -p"
    "manually.*run"
    "user.*confirm"
    "check.*manually"
    "configure.*manually"
    "you.*need.*to"
    "please.*run"
    "don't.*forget"
    "remember.*to"
    "make.*sure.*to"
)

# Create logs directory
mkdir -p .ai_workflow/logs

# Initialize prevention log
echo "📝 Prevention Log - $(date)" > "$PREVENTION_LOG"

# Get changed files
CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(md|sh)$' || true)

if [[ -z "$CHANGED_FILES" ]]; then
    echo "✅ No relevant files changed"
    echo "$(date): No relevant files changed" >> "$PREVENTION_LOG"
    exit 0
fi

echo "🔍 Checking changed files for manual process patterns..."
echo "$(date): Checking files: $CHANGED_FILES" >> "$PREVENTION_LOG"

# Check each changed file
MANUAL_FOUND=false
BLOCKED_FILES=()

for file in $CHANGED_FILES; do
    if [[ -f "$file" ]]; then
        echo "📄 Analyzing: $file"
        
        # Check for each blocked pattern
        for pattern in "${BLOCKED_PATTERNS[@]}"; do
            if grep -q -i "$pattern" "$file" 2>/dev/null; then
                echo "⚠️  Manual process detected in: $file"
                echo "    Pattern: $pattern"
                echo "$(date): Manual process detected in $file - Pattern: $pattern" >> "$PREVENTION_LOG"
                MANUAL_FOUND=true
                BLOCKED_FILES+=("$file")
                break
            fi
        done
    fi
done

if [[ "$MANUAL_FOUND" == "true" ]]; then
    echo ""
    echo "🚫 COMMIT BLOCKED - Manual processes detected!"
    echo "============================================="
    echo ""
    echo "📋 Blocked files:"
    for file in "${BLOCKED_FILES[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "💡 Automation suggestions:"
    echo "   - Replace 'read -p' with environment variables or config files"
    echo "   - Convert 'manually run' to CLI commands or workflows"
    echo "   - Replace 'user confirm' with auto-confirmation + --force flag"
    echo "   - Convert 'check manually' to automated validation workflows"
    echo "   - Replace 'configure manually' with auto-configuration workflows"
    echo "   - Convert 'you need to' instructions to automated actions"
    echo ""
    echo "🔧 Resolution steps:"
    echo "   1. Review detected patterns in blocked files"
    echo "   2. Implement automated alternatives"
    echo "   3. Update workflows to use ./ai-dev commands"
    echo "   4. Add environment variable support where needed"
    echo "   5. Create validation workflows for manual checks"
    echo ""
    echo "⚠️  To bypass (NOT recommended): git commit --no-verify"
    echo ""
    echo "🎯 Goal: Maintain zero-friction automation philosophy"
    echo "$(date): Commit blocked - Manual processes detected" >> "$PREVENTION_LOG"
    exit 1
fi

echo "✅ No manual processes detected in changes"
echo "$(date): No manual processes detected - Commit allowed" >> "$PREVENTION_LOG"
exit 0