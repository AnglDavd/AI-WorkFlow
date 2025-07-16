# Pre-commit Validation Workflow

## Purpose
Comprehensive validation of code changes before commit to ensure quality, security, and framework compliance.

## When to Use
- Automatically triggered by git pre-commit hook
- Manually executed via `./ai-dev precommit validate`
- Before important commits or releases
- During development workflow validation

## Prerequisites
- Git repository initialized
- Framework properly configured
- Validation rules configured in `.ai_workflow/precommit/config/validation_rules.json`

## Validation Process

### 1. Initialize Validation Environment
```bash
echo "=== Pre-commit Validation Started ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Load configuration
CONFIG_FILE=".ai_workflow/precommit/config/validation_rules.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Create validation report directory
REPORT_DIR=".ai_workflow/precommit/reports/validation_reports"
mkdir -p "$REPORT_DIR"

# Generate unique report ID
REPORT_ID="validation_$(date '+%Y%m%d_%H%M%S')"
REPORT_FILE="$REPORT_DIR/$REPORT_ID.json"

# Initialize validation metrics
validation_score=100
critical_issues=0
security_issues=0
quality_issues=0
compliance_issues=0

echo "📊 Validation Report: $REPORT_FILE"
echo ""
```

### 2. Get Changed Files
```bash
echo "=== Analyzing Changed Files ==="

# Get list of changed files (staged for commit)
if git rev-parse --verify HEAD >/dev/null 2>&1; then
    # Normal case: compare with HEAD
    changed_files=$(git diff --cached --name-only --diff-filter=ACM)
else
    # Initial commit case: get all files
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

# Filter files based on include/exclude patterns
filtered_files=""
for file in $changed_files; do
    # Skip deleted files
    if [ ! -f "$file" ]; then
        continue
    fi
    
    # Check if file matches include patterns
    if [[ "$file" =~ \.(sh|md|json|yml|yaml)$ ]] || [[ "$file" == "ai-dev" ]]; then
        # Check if file doesn't match exclude patterns
        if [[ ! "$file" =~ ^\.git/ ]] && [[ ! "$file" =~ ^\.ai_workflow/cache/ ]] && [[ ! "$file" =~ ^\.ai_workflow/logs/ ]] && [[ ! "$file" =~ \.log$ ]] && [[ ! "$file" =~ \.tmp$ ]] && [[ ! "$file" =~ ^capturas/ ]]; then
            filtered_files="$filtered_files$file"$'\n'
        fi
    fi
done

# Remove trailing newline
filtered_files=$(echo "$filtered_files" | sed '/^$/d')

if [ -z "$filtered_files" ]; then
    echo "ℹ️  No relevant files to validate"
    exit 0
fi

echo "🔍 Files to validate:"
echo "$filtered_files" | while read -r file; do
    echo "  ✓ $file"
done
echo ""
```

### 3. Code Quality Validation
```bash
echo "=== Code Quality Validation ==="

quality_score=100

# Validate each file
echo "$filtered_files" | while read -r file; do
    if [ -z "$file" ]; then continue; fi
    
    echo "🔍 Validating: $file"
    
    # Bash syntax validation
    if [[ "$file" =~ \.sh$ ]] || [[ "$file" == "ai-dev" ]]; then
        if ! bash -n "$file" 2>/dev/null; then
            echo "  ❌ Bash syntax error in $file"
            quality_issues=$((quality_issues + 1))
            quality_score=$((quality_score - 10))
        else
            echo "  ✅ Bash syntax valid"
        fi
        
        # Check for proper shebang
        if ! head -1 "$file" | grep -q "^#!/bin/bash"; then
            echo "  ⚠️  Missing or incorrect shebang in $file"
            quality_score=$((quality_score - 2))
        fi
    fi
    
    # Markdown validation
    if [[ "$file" =~ \.md$ ]]; then
        # Check for basic markdown structure
        if grep -q "^# " "$file"; then
            echo "  ✅ Markdown structure valid"
        else
            echo "  ⚠️  No main heading found in $file"
            quality_score=$((quality_score - 3))
        fi
    fi
    
    # JSON/YAML validation
    if [[ "$file" =~ \.json$ ]]; then
        if python3 -m json.tool "$file" >/dev/null 2>&1; then
            echo "  ✅ JSON syntax valid"
        else
            echo "  ❌ JSON syntax error in $file"
            quality_issues=$((quality_issues + 1))
            quality_score=$((quality_score - 15))
        fi
    fi
    
    # File size check
    file_size=$(wc -l < "$file" 2>/dev/null || echo 0)
    if [ "$file_size" -gt 1000 ]; then
        echo "  ⚠️  Large file: $file ($file_size lines)"
        quality_score=$((quality_score - 1))
    fi
    
    echo ""
done

echo "📊 Code Quality Score: $quality_score/100"
if [ "$quality_score" -lt 70 ]; then
    echo "❌ Code quality below threshold"
    critical_issues=$((critical_issues + 1))
fi
echo ""
```

### 4. Security Validation
```bash
echo "=== Security Validation ==="

security_score=100

echo "$filtered_files" | while read -r file; do
    if [ -z "$file" ]; then continue; fi
    
    echo "🔒 Security scan: $file"
    
    # Check for sensitive data patterns
    if grep -i -E "(password|secret|key|token|api_key)" "$file" >/dev/null 2>&1; then
        echo "  ⚠️  Potential sensitive data found in $file"
        security_score=$((security_score - 5))
    fi
    
    # Check for dangerous commands (in shell scripts)
    if [[ "$file" =~ \.sh$ ]] || [[ "$file" == "ai-dev" ]]; then
        if grep -E "(rm -rf|chmod 777|sudo|su -)" "$file" >/dev/null 2>&1; then
            echo "  ⚠️  Potentially dangerous commands in $file"
            security_score=$((security_score - 10))
        fi
        
        # Check for path traversal
        if grep -E "\.\./|/etc/|/root/" "$file" >/dev/null 2>&1; then
            echo "  ⚠️  Potential path traversal in $file"
            security_score=$((security_score - 15))
        fi
    fi
    
    # Check file permissions
    if [ -x "$file" ] && [[ ! "$file" =~ \.sh$ ]] && [[ "$file" != "ai-dev" ]]; then
        echo "  ⚠️  Unexpected executable permissions on $file"
        security_score=$((security_score - 5))
    fi
    
    echo "  ✅ Security scan completed"
    echo ""
done

echo "🔒 Security Score: $security_score/100"
if [ "$security_score" -lt 80 ]; then
    echo "❌ Security issues detected"
    security_issues=$((security_issues + 1))
fi
echo ""
```

### 5. Framework Compliance Validation
```bash
echo "=== Framework Compliance Validation ==="

compliance_score=100

# Check if CLAUDE.md needs updating
if echo "$filtered_files" | grep -v "CLAUDE.md" | grep -E "\.(sh|md)$|ai-dev" >/dev/null; then
    if ! echo "$changed_files" | grep -q "CLAUDE.md"; then
        echo "⚠️  Significant changes detected but CLAUDE.md not updated"
        compliance_score=$((compliance_score - 10))
        compliance_issues=$((compliance_issues + 1))
    else
        echo "✅ CLAUDE.md updated with changes"
    fi
fi

# Check workflow structure compliance
echo "$filtered_files" | grep "\.md$" | while read -r file; do
    if [ -z "$file" ]; then continue; fi
    
    # Skip non-workflow files
    if [[ ! "$file" =~ \.ai_workflow/workflows/ ]]; then
        continue
    fi
    
    echo "📋 Checking workflow compliance: $file"
    
    # Check for required sections
    if ! grep -q "^## Purpose" "$file"; then
        echo "  ⚠️  Missing Purpose section in $file"
        compliance_score=$((compliance_score - 5))
    fi
    
    if ! grep -q "^## When to Use" "$file"; then
        echo "  ⚠️  Missing 'When to Use' section in $file"
        compliance_score=$((compliance_score - 5))
    fi
    
    if ! grep -q "^```bash" "$file"; then
        echo "  ⚠️  No bash code blocks found in $file"
        compliance_score=$((compliance_score - 3))
    fi
    
    echo "  ✅ Workflow structure validated"
done

echo "📋 Framework Compliance Score: $compliance_score/100"
if [ "$compliance_score" -lt 85 ]; then
    echo "❌ Framework compliance issues detected"
    compliance_issues=$((compliance_issues + 1))
fi
echo ""
```

### 6. Generate Validation Report
```bash
echo "=== Validation Report ==="

# Calculate overall score
overall_score=$(( (quality_score + security_score + compliance_score) / 3 ))
total_issues=$((critical_issues + security_issues + quality_issues + compliance_issues))

# Generate JSON report
cat > "$REPORT_FILE" << EOF
{
  "validation_id": "$REPORT_ID",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")",
  "changed_files": $(echo "$filtered_files" | jq -R -s 'split("\n") | map(select(length > 0))'),
  "scores": {
    "overall": $overall_score,
    "code_quality": $quality_score,
    "security": $security_score,
    "framework_compliance": $compliance_score
  },
  "issues": {
    "total": $total_issues,
    "critical": $critical_issues,
    "security": $security_issues,
    "quality": $quality_issues,
    "compliance": $compliance_issues
  },
  "quality_gates": {
    "minimum_score": 85,
    "passed": $([ $overall_score -ge 85 ] && echo "true" || echo "false"),
    "security_passed": $([ $security_issues -eq 0 ] && echo "true" || echo "false"),
    "critical_passed": $([ $critical_issues -eq 0 ] && echo "true" || echo "false")
  }
}
EOF

# Display summary
echo "📊 VALIDATION SUMMARY"
echo "══════════════════════"
echo "Overall Score: $overall_score/100"
echo "Files Validated: $(echo "$filtered_files" | wc -l)"
echo "Total Issues: $total_issues"
echo ""
echo "Detailed Scores:"
echo "  Code Quality: $quality_score/100"
echo "  Security: $security_score/100"
echo "  Framework Compliance: $compliance_score/100"
echo ""

# Determine validation result
if [ $overall_score -ge 85 ] && [ $security_issues -eq 0 ] && [ $critical_issues -eq 0 ]; then
    echo "✅ VALIDATION PASSED"
    echo "Changes meet quality standards and are ready for commit."
    validation_result=0
else
    echo "❌ VALIDATION FAILED"
    echo "Issues detected that must be resolved before commit:"
    
    if [ $overall_score -lt 85 ]; then
        echo "  - Overall quality score below threshold (85%)"
    fi
    
    if [ $security_issues -gt 0 ]; then
        echo "  - Security issues detected"
    fi
    
    if [ $critical_issues -gt 0 ]; then
        echo "  - Critical issues detected"
    fi
    
    echo ""
    echo "Please address these issues and run validation again."
    validation_result=1
fi

echo ""
echo "Detailed report: $REPORT_FILE"
echo "══════════════════════"

exit $validation_result
```

## Success Criteria
- All code quality checks pass
- No security vulnerabilities detected
- Framework compliance standards met
- Overall validation score ≥ 85%
- No critical or security issues present

## Error Handling
- Graceful handling of missing files
- Clear error messages for each validation type
- Detailed reporting for issue resolution
- Non-blocking warnings vs blocking errors

## Integration Points
- Git hook integration for automatic execution
- CLI command for manual validation
- Reporting system for metrics tracking
- Configuration management for customization