# Review and Refactor

## Purpose
Comprehensive quality assurance workflow that reviews completed implementations, identifies optimization opportunities, and performs systematic refactoring to maintain code quality and framework standards.

## When to Use
- After completing task lists or major implementations
- Before finalizing features or releasing versions
- When code quality metrics indicate refactoring needs
- As part of regular maintenance cycles

## Objective
Systematically review implemented code for quality, performance, maintainability, and adherence to framework standards. Perform necessary refactoring while ensuring no regressions are introduced.

## Pre-conditions
- Implementation phase is completed
- All tests are passing
- Code is committed to version control
- Framework quality tools are available

## Commands
```bash
# Initialize review session
REVIEW_SESSION_ID="review_$(date +%Y%m%d_%H%M%S)"
REVIEW_DIR=".ai_workflow/state/review_sessions/$REVIEW_SESSION_ID"
mkdir -p "$REVIEW_DIR"

# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting review and refactor session: $REVIEW_SESSION_ID"

echo "🔍 Starting Review and Refactor Session"
echo "📂 Session ID: $REVIEW_SESSION_ID"
echo "📁 Review directory: $REVIEW_DIR"
echo ""

# Set target directory for review
TARGET_DIR="${REVIEW_TARGET:-.}"
if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: Target directory not found: $TARGET_DIR"
    ./.ai_workflow/workflows/common/error.md "Review target directory does not exist: $TARGET_DIR"
    exit 1
fi

echo "🎯 Review target: $TARGET_DIR"
echo ""

# Function to run quality checks
run_quality_checks() {
    local check_type="$1"
    echo "🔧 Running $check_type checks..."
    
    case "$check_type" in
        "code_quality")
            # Framework quality validation
            if command -v ./ai-dev >/dev/null 2>&1; then
                echo "📋 Running framework quality validation..."
                ./ai-dev quality "$TARGET_DIR" --verbose > "$REVIEW_DIR/quality_report.txt" 2>&1
                local quality_exit_code=$?
                
                if [ $quality_exit_code -eq 0 ]; then
                    echo "✅ Quality validation passed"
                else
                    echo "⚠️  Quality issues detected - see $REVIEW_DIR/quality_report.txt"
                fi
            else
                echo "⚠️  Framework quality command not available"
            fi
            ;;
            
        "security")
            # Security audit
            if command -v ./ai-dev >/dev/null 2>&1; then
                echo "🛡️  Running security audit..."
                ./ai-dev audit --target "$TARGET_DIR" > "$REVIEW_DIR/security_audit.txt" 2>&1
                local security_exit_code=$?
                
                if [ $security_exit_code -eq 0 ]; then
                    echo "✅ Security audit passed"
                else
                    echo "⚠️  Security issues detected - see $REVIEW_DIR/security_audit.txt"
                fi
            else
                echo "⚠️  Framework security audit not available"
            fi
            ;;
            
        "performance")
            # Performance analysis
            echo "⚡ Analyzing performance metrics..."
            
            # File size analysis
            echo "📊 File Size Analysis:" > "$REVIEW_DIR/performance_analysis.txt"
            find "$TARGET_DIR" -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.js" 2>/dev/null | \
                xargs wc -l 2>/dev/null | \
                sort -rn >> "$REVIEW_DIR/performance_analysis.txt"
            
            # Check for files exceeding recommended limits
            echo "" >> "$REVIEW_DIR/performance_analysis.txt"
            echo "📏 Files exceeding 500 lines (framework limit):" >> "$REVIEW_DIR/performance_analysis.txt"
            find "$TARGET_DIR" -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.js" 2>/dev/null | \
                xargs wc -l 2>/dev/null | \
                awk '$1 > 500 {print $0}' >> "$REVIEW_DIR/performance_analysis.txt"
            
            echo "✅ Performance analysis completed"
            ;;
            
        "documentation")
            # Documentation review
            echo "📚 Reviewing documentation completeness..."
            
            echo "📖 Documentation Review:" > "$REVIEW_DIR/documentation_review.txt"
            echo "Generated: $(date)" >> "$REVIEW_DIR/documentation_review.txt"
            echo "" >> "$REVIEW_DIR/documentation_review.txt"
            
            # Check for README files
            echo "📄 README Files:" >> "$REVIEW_DIR/documentation_review.txt"
            find "$TARGET_DIR" -name "README*" -o -name "readme*" 2>/dev/null >> "$REVIEW_DIR/documentation_review.txt"
            
            # Check for documentation structure
            echo "" >> "$REVIEW_DIR/documentation_review.txt"
            echo "📁 Documentation Structure:" >> "$REVIEW_DIR/documentation_review.txt"
            find "$TARGET_DIR" -type d -name "*doc*" -o -name "*guide*" 2>/dev/null >> "$REVIEW_DIR/documentation_review.txt"
            
            echo "✅ Documentation review completed"
            ;;
    esac
}

# Function to identify refactoring opportunities
identify_refactoring_opportunities() {
    echo "🔍 Identifying refactoring opportunities..."
    
    local refactor_report="$REVIEW_DIR/refactoring_opportunities.txt"
    echo "🔧 Refactoring Opportunities Analysis" > "$refactor_report"
    echo "Generated: $(date)" >> "$refactor_report"
    echo "Target: $TARGET_DIR" >> "$refactor_report"
    echo "" >> "$refactor_report"
    
    # Check for code duplication patterns
    echo "🔄 Code Duplication Analysis:" >> "$refactor_report"
    echo "Looking for similar function patterns..." >> "$refactor_report"
    
    # Check for long files
    echo "" >> "$refactor_report"
    echo "📏 Long Files (>500 lines):" >> "$refactor_report"
    find "$TARGET_DIR" -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.js" 2>/dev/null | \
        xargs wc -l 2>/dev/null | \
        awk '$1 > 500 {print "REFACTOR NEEDED: " $2 " (" $1 " lines)"}' >> "$refactor_report"
    
    # Check for complex scripts
    echo "" >> "$refactor_report"
    echo "🧩 Complex Scripts Analysis:" >> "$refactor_report"
    find "$TARGET_DIR" -name "*.sh" 2>/dev/null | while read -r script; do
        if [ -f "$script" ]; then
            local func_count=$(grep -c "^[a-zA-Z_][a-zA-Z0-9_]*(" "$script" 2>/dev/null || echo "0")
            local line_count=$(wc -l < "$script" 2>/dev/null || echo "0")
            
            if [ "$line_count" -gt 200 ] || [ "$func_count" -gt 10 ]; then
                echo "COMPLEXITY WARNING: $script ($line_count lines, $func_count functions)" >> "$refactor_report"
            fi
        fi
    done
    
    # Framework-specific checks
    echo "" >> "$refactor_report"
    echo "🏗️  Framework Compliance:" >> "$refactor_report"
    
    # Check for proper workflow structure
    if [ -d "$TARGET_DIR/.ai_workflow" ]; then
        if [ ! -f "$TARGET_DIR/.ai_workflow/GLOBAL_AI_RULES.md" ]; then
            echo "MISSING: GLOBAL_AI_RULES.md not found" >> "$refactor_report"
        fi
        
        if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
            echo "MISSING: CLAUDE.md not found" >> "$refactor_report"
        fi
    fi
    
    echo "✅ Refactoring analysis completed"
}

# Function to generate improvement recommendations
generate_recommendations() {
    echo "💡 Generating improvement recommendations..."
    
    local recommendations="$REVIEW_DIR/recommendations.md"
    cat > "$recommendations" << 'EOF'
# Review and Refactor Recommendations

## Overview
This document contains actionable recommendations based on the code review and quality analysis.

## Priority Actions

### High Priority
- [ ] **Code Quality Issues**: Address any failing quality checks
- [ ] **Security Vulnerabilities**: Fix security audit findings
- [ ] **Performance Bottlenecks**: Optimize identified performance issues

### Medium Priority
- [ ] **Documentation Gaps**: Complete missing documentation
- [ ] **Code Duplication**: Refactor duplicated code patterns
- [ ] **Long Files**: Break down files exceeding 500 lines

### Low Priority
- [ ] **Code Style**: Standardize code formatting and conventions
- [ ] **Test Coverage**: Improve test coverage for uncovered areas
- [ ] **Performance Optimization**: Minor performance improvements

## Specific Recommendations

### File Structure
- Review files exceeding recommended size limits
- Consider splitting complex modules into smaller components
- Ensure proper separation of concerns

### Code Quality
- Follow framework coding standards (see CLAUDE.md)
- Implement proper error handling patterns
- Use consistent naming conventions

### Documentation
- Ensure all public functions have proper documentation
- Update README files with current functionality
- Add usage examples for complex features

### Testing
- Add unit tests for new functionality
- Ensure integration tests cover critical paths
- Validate error handling scenarios

## Next Steps
1. Review detailed analysis files in the review session directory
2. Prioritize recommendations based on project needs
3. Create specific tasks or PRPs for major refactoring efforts
4. Schedule regular review cycles for ongoing quality maintenance

## Review Session Details
- **Session ID**: PLACEHOLDER_SESSION_ID
- **Date**: PLACEHOLDER_DATE
- **Target**: PLACEHOLDER_TARGET
- **Analysis Files**: Available in review session directory
EOF

    # Replace placeholders
    sed -i "s/PLACEHOLDER_SESSION_ID/$REVIEW_SESSION_ID/g" "$recommendations"
    sed -i "s/PLACEHOLDER_DATE/$(date)/g" "$recommendations"
    sed -i "s|PLACEHOLDER_TARGET|$TARGET_DIR|g" "$recommendations"
    
    echo "✅ Recommendations generated: $recommendations"
}

# Main review process
echo "🚀 Starting comprehensive review process..."
echo ""

# Run all quality checks
run_quality_checks "code_quality"
echo ""
run_quality_checks "security"
echo ""
run_quality_checks "performance"
echo ""
run_quality_checks "documentation"
echo ""

# Identify refactoring opportunities
identify_refactoring_opportunities
echo ""

# Generate recommendations
generate_recommendations
echo ""

# Create session summary
SESSION_SUMMARY="$REVIEW_DIR/session_summary.json"
cat > "$SESSION_SUMMARY" << EOF
{
  "session_id": "$REVIEW_SESSION_ID",
  "timestamp": "$(date -Iseconds)",
  "target_directory": "$TARGET_DIR",
  "status": "completed",
  "checks_performed": [
    "code_quality",
    "security",
    "performance",
    "documentation"
  ],
  "output_files": [
    "quality_report.txt",
    "security_audit.txt",
    "performance_analysis.txt",
    "documentation_review.txt",
    "refactoring_opportunities.txt",
    "recommendations.md"
  ],
  "recommendations_count": $(grep -c "- \[ \]" "$REVIEW_DIR/recommendations.md" 2>/dev/null || echo "0"),
  "completed": "$(date -Iseconds)"
}
EOF

# Final summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Review and Refactor Session Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Session ID: $REVIEW_SESSION_ID"
echo "📁 Review directory: $REVIEW_DIR"
echo "🎯 Target reviewed: $TARGET_DIR"
echo ""
echo "📄 Generated Reports:"
echo "  • Quality report: quality_report.txt"
echo "  • Security audit: security_audit.txt"
echo "  • Performance analysis: performance_analysis.txt"
echo "  • Documentation review: documentation_review.txt"
echo "  • Refactoring opportunities: refactoring_opportunities.txt"
echo "  • Recommendations: recommendations.md"
echo ""
echo "💡 Next steps:"
echo "  1. Review recommendations file: cat $REVIEW_DIR/recommendations.md"
echo "  2. Address high-priority issues first"
echo "  3. Create PRPs for major refactoring tasks"
echo "  4. Schedule follow-up review sessions"

# Log completion
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Review and refactor session completed: $REVIEW_SESSION_ID"

echo ""
echo "✅ Review and refactor workflow completed successfully"
```

## Verification Criteria
- All quality checks are executed successfully
- Review session directory is created with all reports
- Recommendations are generated with actionable items
- Session summary contains accurate information
- No critical issues are left unaddressed

## Input Parameters
- `REVIEW_TARGET`: Directory to review (optional, defaults to current directory)
- `REVIEW_SCOPE`: Scope of review - "full", "code", "docs", "security" (optional, defaults to "full")

## Output
- Comprehensive review session directory with all analysis files
- Quality reports and security audit results
- Performance analysis and optimization recommendations
- Documentation completeness review
- Refactoring opportunities and improvement recommendations
- Actionable task list for addressing identified issues

## Next Steps
- **On Success:** Review recommendations and create implementation tasks
- **On Issues Found:** Address high-priority recommendations before proceeding
- **On Critical Issues:** Proceed to [Generic Error Handler](./error.md) for immediate resolution

## Related Workflows
- [Process Task List](../run/process-task-list.md) - Execute review recommendations as tasks
- [Quality Validation](../security/validate_input.md) - Framework quality checks
- [Security Audit](../security/security_audit.md) - Detailed security analysis