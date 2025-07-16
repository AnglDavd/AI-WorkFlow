#!/bin/bash

# Simple Pre-commit Validation Script
# This script provides basic validation for the AI Framework

set -e

echo "=== Pre-commit Validation Started ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Initialize counters
validation_score=100
critical_issues=0
security_issues=0
quality_issues=0
compliance_issues=0

# Get changed files
if git rev-parse --verify HEAD >/dev/null 2>&1; then
    changed_files=$(git diff --cached --name-only --diff-filter=ACM)
else
    changed_files=$(git diff --cached --name-only --diff-filter=A)
fi

if [ -z "$changed_files" ]; then
    echo "ℹ️  No files staged for commit"
    exit 0
fi

echo "📁 Changed files:"
echo "$changed_files" | while read -r file; do
    echo "  - $file"
done
echo ""

# Filter relevant files
filtered_files=""
for file in $changed_files; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    if [[ "$file" =~ \.(sh|md|json|yml|yaml)$ ]] || [[ "$file" == "ai-dev" ]]; then
        if [[ ! "$file" =~ ^\.git/ ]] && [[ ! "$file" =~ ^\.ai_workflow/cache/ ]] && [[ ! "$file" =~ ^\.ai_workflow/logs/ ]]; then
            filtered_files="$filtered_files$file"$'\n'
        fi
    fi
done

filtered_files=$(echo "$filtered_files" | sed '/^$/d')

if [ -z "$filtered_files" ]; then
    echo "✅ No relevant files to validate"
    exit 0
fi

echo "🔍 Files to validate:"
echo "$filtered_files" | while read -r file; do
    echo "  ✓ $file"
done
echo ""

# Code Quality Validation
echo "=== Code Quality Validation ==="
echo "$filtered_files" | while read -r file; do
    if [ -z "$file" ]; then continue; fi
    
    echo "🔍 Validating: $file"
    
    # Bash syntax validation
    if [[ "$file" =~ \.sh$ ]] || [[ "$file" == "ai-dev" ]]; then
        if bash -n "$file" 2>/dev/null; then
            echo "  ✅ Bash syntax valid"
        else
            echo "  ❌ Bash syntax error in $file"
            exit 1
        fi
    fi
    
    # Markdown validation
    if [[ "$file" =~ \.md$ ]]; then
        if grep -q "^# " "$file"; then
            echo "  ✅ Markdown structure valid"
        else
            echo "  ⚠️  No main heading found in $file"
        fi
    fi
    
    # JSON validation
    if [[ "$file" =~ \.json$ ]]; then
        if command -v python3 >/dev/null 2>&1; then
            if python3 -m json.tool "$file" >/dev/null 2>&1; then
                echo "  ✅ JSON syntax valid"
            else
                echo "  ❌ JSON syntax error in $file"
                exit 1
            fi
        fi
    fi
    
    echo ""
done

# Security Validation
echo "=== Security Validation ==="
echo "$filtered_files" | while read -r file; do
    if [ -z "$file" ]; then continue; fi
    
    echo "🔒 Security scan: $file"
    
    # Check for sensitive data patterns
    if grep -i -E "(password|secret|key|token|api_key)" "$file" >/dev/null 2>&1; then
        echo "  ⚠️  Potential sensitive data found in $file"
    fi
    
    # Check for dangerous commands
    if [[ "$file" =~ \.sh$ ]] || [[ "$file" == "ai-dev" ]]; then
        if grep -E "(rm -rf|chmod 777|sudo|su -)" "$file" >/dev/null 2>&1; then
            echo "  ⚠️  Potentially dangerous commands in $file"
        fi
    fi
    
    echo "  ✅ Security scan completed"
    echo ""
done

# Framework Compliance
echo "=== Framework Compliance Validation ==="
if [ -f "CLAUDE.md" ]; then
    echo "✅ CLAUDE.md exists"
else
    echo "⚠️  CLAUDE.md not found"
fi

if [ -f ".ai_workflow/GLOBAL_AI_RULES.md" ]; then
    echo "✅ GLOBAL_AI_RULES.md exists"
else
    echo "⚠️  GLOBAL_AI_RULES.md not found"
fi

echo ""

# Final Result
echo "=== Validation Summary ==="
echo "✅ VALIDATION PASSED"
echo "All basic checks completed successfully."
echo ""

exit 0