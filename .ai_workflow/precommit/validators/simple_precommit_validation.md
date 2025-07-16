# Simple Pre-commit Validation

## Purpose
Non-blocking validation that provides warnings and guidance without stopping development progress.

## Philosophy
**Progressive Development Support** - Guide developers with helpful feedback while maintaining development velocity.

## Validation Workflow

```bash
#!/bin/bash

# Simple Pre-commit Validation (Non-blocking)
echo "🔍 Pre-commit Quality Check"
echo "=========================="

# Configuration
QUALITY_THRESHOLD=70
VALIDATION_SCORE=100
WARNINGS=0
ERRORS=0

# Get changed files
if git rev-parse --verify HEAD >/dev/null 2>&1; then
    CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")
else
    CHANGED_FILES=$(git diff --cached --name-only --diff-filter=A 2>/dev/null || echo "")
fi

if [[ -z "$CHANGED_FILES" ]]; then
    echo "ℹ️  No files to validate"
    exit 0
fi

echo "📋 Validating files:"
echo "$CHANGED_FILES" | sed 's/^/  - /'
echo ""

# Basic validation for each file
while IFS= read -r file; do
    if [[ -z "$file" || ! -f "$file" ]]; then
        continue
    fi
    
    echo "🔍 Checking: $file"
    
    # JSON validation
    if [[ "$file" =~ \.json$ ]]; then
        if command -v jq >/dev/null 2>&1; then
            if jq empty "$file" >/dev/null 2>&1; then
                echo "  ✅ Valid JSON syntax"
            else
                echo "  ❌ Invalid JSON syntax"
                ERRORS=$((ERRORS + 1))
                VALIDATION_SCORE=$((VALIDATION_SCORE - 15))
            fi
        else
            echo "  ⚠️  JSON validation skipped (jq not available)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
    
    # Bash validation
    if [[ "$file" =~ \.sh$ ]] || [[ "$file" == "ai-dev" ]]; then
        if bash -n "$file" 2>/dev/null; then
            echo "  ✅ Valid bash syntax"
        else
            echo "  ❌ Invalid bash syntax"
            ERRORS=$((ERRORS + 1))
            VALIDATION_SCORE=$((VALIDATION_SCORE - 20))
        fi
    fi
    
    # Markdown validation
    if [[ "$file" =~ \.md$ ]]; then
        if [[ -s "$file" ]]; then
            if grep -q "^# " "$file"; then
                echo "  ✅ Valid markdown structure"
            else
                echo "  ⚠️  Consider adding main heading"
                WARNINGS=$((WARNINGS + 1))
                VALIDATION_SCORE=$((VALIDATION_SCORE - 5))
            fi
        else
            echo "  ⚠️  Empty markdown file"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
    
    # Security check
    if grep -q -E "(password|secret|key|token)" "$file" 2>/dev/null; then
        echo "  ⚠️  Potential sensitive data detected"
        WARNINGS=$((WARNINGS + 1))
        VALIDATION_SCORE=$((VALIDATION_SCORE - 10))
    fi
    
    echo ""
done <<< "$CHANGED_FILES"

# Repository cleanliness check
echo "🧹 Repository Cleanliness Check"
CLEANUP_ISSUES=$(git ls-files | grep -E '\.(backup|tmp|temp|log)$' | wc -l)
if [[ $CLEANUP_ISSUES -gt 0 ]]; then
    echo "  ⚠️  Found $CLEANUP_ISSUES cleanup candidates"
    echo "  💡 Run: ./ai-dev cleanup --auto"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  ✅ Repository is clean"
fi
echo ""

# Framework integrity (basic)
echo "🔧 Framework Integrity Check"
if [[ -f "ai-dev" && -d ".ai_workflow" ]]; then
    echo "  ✅ Framework structure detected"
    if [[ -f "CLAUDE.md" ]]; then
        echo "  ✅ Documentation present"
    else
        echo "  ⚠️  Consider adding CLAUDE.md documentation"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "  ℹ️  Non-framework project"
fi
echo ""

# Final assessment
echo "📊 Validation Results"
echo "===================="
echo "  Validation Score: $VALIDATION_SCORE/100"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo "❌ ERRORS DETECTED"
    echo "Please fix the following issues:"
    echo "  - JSON syntax errors"
    echo "  - Bash syntax errors"
    echo ""
    echo "💡 To commit anyway (not recommended): git commit --no-verify"
    exit 1
elif [[ $VALIDATION_SCORE -lt $QUALITY_THRESHOLD ]]; then
    echo "⚠️  QUALITY BELOW THRESHOLD"
    echo "Consider addressing warnings to improve code quality"
    echo ""
    echo "✅ Commit allowed (warnings don't block development)"
    exit 0
else
    echo "✅ VALIDATION PASSED"
    echo "All checks completed successfully"
    exit 0
fi
```

## Benefits

### Development-Friendly
- **Non-blocking warnings**: Warnings don't stop development
- **Critical errors only**: Only syntax errors block commits
- **Clear guidance**: Specific suggestions for improvements
- **Progressive improvement**: Encourages quality without blocking progress

### Practical Validation
- **Essential checks**: Focus on critical issues (syntax, security)
- **Repository cleanliness**: Guidance for cleanup without blocking
- **Framework awareness**: Adapts to framework vs regular projects
- **Tool availability**: Graceful degradation when tools missing

### Developer Experience
- **Fast execution**: Lightweight validation
- **Clear output**: Easy to understand results
- **Actionable feedback**: Specific suggestions for improvement
- **Bypass option**: Emergency escape hatch available