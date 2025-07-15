# Validate External Changes

## Purpose
Comprehensive validation of external changes before integration to ensure security, quality, and compatibility with the existing framework.

## Input Parameters
- `change_source`: Source of changes (git_diff, pr_files, patch_file)
- `change_location`: Path to changes file or directory
- `validation_level`: Level of validation (basic, standard, strict)
- `auto_fix`: Attempt automatic fixes for minor issues (default: false)

## Prerequisites
- Change files available for analysis
- Security scanning tools configured
- Quality gates operational
- Framework validation tools available

## Process Flow

### 1. Change Analysis
```bash
# Initialize validation
validation_timestamp=$(date +%Y%m%d_%H%M%S)
validation_dir=".ai_workflow/validation/${validation_timestamp}"
mkdir -p "$validation_dir"

# Parse change source
case "$change_source" in
    "git_diff")
        # Git diff analysis
        if [ -f "$change_location" ]; then
            cp "$change_location" "$validation_dir/changes.diff"
        else
            echo "❌ Git diff file not found: $change_location"
            exit 1
        fi
        ;;
    "pr_files")
        # Pull request files analysis
        if [ -d "$change_location" ]; then
            cp -r "$change_location"/* "$validation_dir/"
        else
            echo "❌ PR files directory not found: $change_location"
            exit 1
        fi
        ;;
    "patch_file")
        # Patch file analysis
        if [ -f "$change_location" ]; then
            cp "$change_location" "$validation_dir/changes.patch"
        else
            echo "❌ Patch file not found: $change_location"
            exit 1
        fi
        ;;
esac

# Extract changed files list
changed_files=()
if [ -f "$validation_dir/changes.diff" ]; then
    changed_files=($(grep '^+++' "$validation_dir/changes.diff" | sed 's/^+++ b\///'))
elif [ -f "$validation_dir/changes.patch" ]; then
    changed_files=($(grep '^+++' "$validation_dir/changes.patch" | sed 's/^+++ b\///'))
else
    changed_files=($(find "$validation_dir" -type f -name "*.md" -o -name "*.sh" -o -name "*.json"))
fi

echo "📋 Analyzing ${#changed_files[@]} changed files..."
```

### 2. Security Validation
```bash
# Security scan results
security_issues=()
critical_security_issues=()

# Check for dangerous patterns
dangerous_patterns=(
    "rm -rf"
    "sudo"
    "eval"
    "exec"
    "curl.*bash"
    "wget.*bash"
    ">/dev/null.*2>&1.*&"
    "nohup"
    "kill -9"
    "pkill"
    "chmod 777"
    "chown -R"
)

echo "🔒 Running security validation..."

for file in "${changed_files[@]}"; do
    if [ -f "$file" ]; then
        # Scan for dangerous patterns
        for pattern in "${dangerous_patterns[@]}"; do
            if grep -q "$pattern" "$file"; then
                security_issues+=("$file: Dangerous pattern '$pattern' detected")
                
                # Critical patterns
                if [[ "$pattern" == "rm -rf" || "$pattern" == "sudo" || "$pattern" == "eval" ]]; then
                    critical_security_issues+=("$file: CRITICAL - '$pattern' detected")
                fi
            fi
        done
        
        # Check for security-sensitive file modifications
        if [[ "$file" == *"security/"* || "$file" == *"ai-dev"* || "$file" == *"CLAUDE.md"* ]]; then
            security_issues+=("$file: Security-sensitive file modification detected")
        fi
        
        # Check for suspicious file permissions
        if grep -q "chmod.*7[0-9][0-9]" "$file"; then
            security_issues+=("$file: Suspicious file permission changes detected")
        fi
    fi
done

# Generate security report
cat > "$validation_dir/security_report.md" << EOF
# Security Validation Report

## Summary
- **Total Issues**: ${#security_issues[@]}
- **Critical Issues**: ${#critical_security_issues[@]}
- **Files Analyzed**: ${#changed_files[@]}

## Critical Security Issues
$(for issue in "${critical_security_issues[@]}"; do echo "- ❌ $issue"; done)

## Security Issues
$(for issue in "${security_issues[@]}"; do echo "- ⚠️  $issue"; done)

## Security Status
$(if [ ${#critical_security_issues[@]} -eq 0 ]; then echo "✅ No critical security issues found"; else echo "❌ Critical security issues detected - BLOCKING"; fi)
EOF

# Fail validation if critical security issues found
if [ ${#critical_security_issues[@]} -gt 0 ]; then
    echo "❌ Critical security issues detected. Validation failed."
    cat "$validation_dir/security_report.md"
    exit 1
fi
```

### 3. Quality Validation
```bash
# Quality checks
quality_issues=()
style_issues=()
structural_issues=()

echo "🔍 Running quality validation..."

for file in "${changed_files[@]}"; do
    if [ -f "$file" ]; then
        case "$file" in
            *.md)
                # Markdown quality checks
                
                # Check for proper header structure
                if ! grep -q "^# " "$file"; then
                    quality_issues+=("$file: Missing main header")
                fi
                
                # Check for required sections in workflow files
                if [[ "$file" == *.ai_workflow/workflows/* ]]; then
                    required_sections=("## Purpose" "## Input Parameters" "## Process Flow")
                    for section in "${required_sections[@]}"; do
                        if ! grep -q "^$section" "$file"; then
                            structural_issues+=("$file: Missing required section '$section'")
                        fi
                    done
                fi
                
                # Check for proper code block formatting
                if grep -q '```' "$file"; then
                    # Verify balanced code blocks
                    code_block_count=$(grep -c '```' "$file")
                    if [ $((code_block_count % 2)) -ne 0 ]; then
                        style_issues+=("$file: Unbalanced code blocks")
                    fi
                fi
                ;;
                
            *.sh)
                # Shell script quality checks
                
                # Check for shebang
                if ! head -1 "$file" | grep -q "^#!"; then
                    quality_issues+=("$file: Missing shebang")
                fi
                
                # Check for set -e (exit on error)
                if ! grep -q "set -e" "$file"; then
                    quality_issues+=("$file: Missing 'set -e' for error handling")
                fi
                
                # Check for proper variable quoting
                if grep -q '\$[A-Za-z_][A-Za-z0-9_]*[^"]' "$file"; then
                    style_issues+=("$file: Potentially unquoted variables")
                fi
                ;;
                
            *.json)
                # JSON quality checks
                
                # Validate JSON syntax
                if ! python3 -m json.tool "$file" >/dev/null 2>&1; then
                    quality_issues+=("$file: Invalid JSON syntax")
                fi
                ;;
        esac
    fi
done

# Generate quality report
cat > "$validation_dir/quality_report.md" << EOF
# Quality Validation Report

## Summary
- **Total Quality Issues**: ${#quality_issues[@]}
- **Style Issues**: ${#style_issues[@]}
- **Structural Issues**: ${#structural_issues[@]}

## Quality Issues
$(for issue in "${quality_issues[@]}"; do echo "- ❌ $issue"; done)

## Style Issues
$(for issue in "${style_issues[@]}"; do echo "- ⚠️  $issue"; done)

## Structural Issues
$(for issue in "${structural_issues[@]}"; do echo "- 🔨 $issue"; done)

## Quality Status
$(if [ ${#quality_issues[@]} -eq 0 ] && [ ${#structural_issues[@]} -eq 0 ]; then echo "✅ Quality validation passed"; else echo "⚠️  Quality issues detected - REVIEW REQUIRED"; fi)
EOF
```

### 4. Compatibility Validation
```bash
# Framework compatibility checks
compatibility_issues=()

echo "🔗 Running compatibility validation..."

# Check for breaking changes
breaking_change_patterns=(
    "BREAKING:"
    "BREAKING CHANGE:"
    "breaking"
    "deprecated"
    "removed"
    "renamed"
)

for file in "${changed_files[@]}"; do
    if [ -f "$file" ]; then
        # Check for breaking change indicators
        for pattern in "${breaking_change_patterns[@]}"; do
            if grep -i -q "$pattern" "$file"; then
                compatibility_issues+=("$file: Potential breaking change detected - '$pattern'")
            fi
        done
        
        # Check for dependency changes
        if [[ "$file" == *"package.json"* || "$file" == *"requirements.txt"* || "$file" == *"Gemfile"* ]]; then
            compatibility_issues+=("$file: Dependency file modified - compatibility check required")
        fi
        
        # Check for workflow interface changes
        if [[ "$file" == *.ai_workflow/workflows/* ]] && grep -q "## Input Parameters" "$file"; then
            # TODO: More sophisticated parameter compatibility check
            compatibility_issues+=("$file: Workflow parameters may have changed")
        fi
    fi
done

# Generate compatibility report
cat > "$validation_dir/compatibility_report.md" << EOF
# Compatibility Validation Report

## Summary
- **Compatibility Issues**: ${#compatibility_issues[@]}
- **Breaking Changes Detected**: $(if grep -q "BREAKING" "$validation_dir/compatibility_report.md"; then echo "Yes"; else echo "No"; fi)

## Compatibility Issues
$(for issue in "${compatibility_issues[@]}"; do echo "- ⚠️  $issue"; done)

## Compatibility Status
$(if [ ${#compatibility_issues[@]} -eq 0 ]; then echo "✅ No compatibility issues detected"; else echo "⚠️  Compatibility issues detected - REVIEW REQUIRED"; fi)
EOF
```

### 5. Automated Fixes
```bash
# Auto-fix minor issues if enabled
if [ "$auto_fix" = "true" ]; then
    echo "🔧 Attempting automated fixes..."
    
    fixes_applied=()
    
    for file in "${changed_files[@]}"; do
        if [ -f "$file" ]; then
            case "$file" in
                *.md)
                    # Fix common markdown issues
                    
                    # Add missing newline at end of file
                    if [ -n "$(tail -c1 "$file")" ]; then
                        echo "" >> "$file"
                        fixes_applied+=("$file: Added missing newline at end")
                    fi
                    
                    # Fix multiple consecutive blank lines
                    if sed -i '/^$/N;/^\n$/d' "$file" 2>/dev/null; then
                        fixes_applied+=("$file: Fixed multiple consecutive blank lines")
                    fi
                    ;;
                    
                *.sh)
                    # Fix shell script issues
                    
                    # Add shebang if missing
                    if ! head -1 "$file" | grep -q "^#!"; then
                        sed -i '1i#!/bin/bash' "$file"
                        fixes_applied+=("$file: Added missing shebang")
                    fi
                    ;;
            esac
        fi
    done
    
    # Generate fix report
    cat > "$validation_dir/fixes_report.md" << EOF
# Automated Fixes Report

## Summary
- **Fixes Applied**: ${#fixes_applied[@]}

## Applied Fixes
$(for fix in "${fixes_applied[@]}"; do echo "- ✅ $fix"; done)
EOF
    
    echo "✅ Applied ${#fixes_applied[@]} automated fixes"
fi
```

### 6. Final Validation Summary
```bash
# Compile final validation report
total_issues=$((${#security_issues[@]} + ${#quality_issues[@]} + ${#compatibility_issues[@]}))
validation_status="PASSED"

# Determine validation status
if [ ${#critical_security_issues[@]} -gt 0 ]; then
    validation_status="FAILED - Critical Security Issues"
elif [ ${#security_issues[@]} -gt 5 ] || [ ${#quality_issues[@]} -gt 10 ]; then
    validation_status="FAILED - Too Many Issues"
elif [ ${#structural_issues[@]} -gt 0 ]; then
    validation_status="WARNING - Structural Issues"
elif [ $total_issues -gt 0 ]; then
    validation_status="WARNING - Minor Issues"
fi

# Generate final report
cat > "$validation_dir/validation_summary.md" << EOF
# External Changes Validation Summary

## Overall Status: $validation_status

## Validation Results
- **Security Issues**: ${#security_issues[@]} (${#critical_security_issues[@]} critical)
- **Quality Issues**: ${#quality_issues[@]}
- **Compatibility Issues**: ${#compatibility_issues[@]}
- **Total Issues**: $total_issues

## Validation Level: $validation_level

## Files Analyzed: ${#changed_files[@]}

## Recommendations
$(if [ "$validation_status" = "PASSED" ]; then
    echo "✅ Changes are safe for integration"
elif [ "$validation_status" = "WARNING - Minor Issues" ]; then
    echo "⚠️  Changes can be integrated with minor issues noted"
elif [ "$validation_status" = "WARNING - Structural Issues" ]; then
    echo "⚠️  Changes require review before integration"
else
    echo "❌ Changes must be revised before integration"
fi)

## Next Steps
$(if [ "$validation_status" = "PASSED" ]; then
    echo "- Proceed with integration"
elif [[ "$validation_status" == "WARNING"* ]]; then
    echo "- Review reported issues"
    echo "- Address critical items"
    echo "- Consider manual testing"
else
    echo "- Fix critical security issues"
    echo "- Address structural problems"
    echo "- Re-run validation"
fi)
EOF

# Display summary
echo "📊 Validation Summary:"
echo "Status: $validation_status"
echo "Total Issues: $total_issues"
echo "Files Analyzed: ${#changed_files[@]}"
echo "📁 Detailed reports available in: $validation_dir"

# Exit with appropriate code
if [[ "$validation_status" == "FAILED"* ]]; then
    exit 1
elif [[ "$validation_status" == "WARNING"* ]]; then
    exit 2
else
    exit 0
fi
```

## Output
- Comprehensive validation reports (security, quality, compatibility)
- Automated fixes applied (if enabled)
- Final validation summary with recommendations
- Detailed issue breakdown by category
- Next steps for integration

## Error Handling
- Missing change files → Detailed error with expected locations
- Invalid change format → Format detection and conversion suggestions
- Validation tool failures → Fallback to manual checks
- Critical security issues → Immediate termination with detailed report
- Network issues → Offline validation mode

## Security Considerations
- All external changes undergo comprehensive security scanning
- Critical security patterns trigger immediate validation failure
- Security-sensitive files require elevated scrutiny
- Suspicious file permissions detected and reported
- Complete audit trail maintained for all validations

## Dependencies
- Change files in supported formats
- Security scanning tools
- Quality validation tools
- JSON validation capabilities
- Git tools for diff analysis

## Success Criteria
- All security validations passed
- Quality issues within acceptable limits
- Compatibility maintained with existing framework
- Structural integrity preserved
- Comprehensive validation documentation generated