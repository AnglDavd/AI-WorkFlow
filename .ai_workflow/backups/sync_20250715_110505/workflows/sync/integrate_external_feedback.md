# Integrate External Feedback

## Purpose
Process and integrate improvements, bug reports, and feature requests from the community and external sources while maintaining security and quality standards.

## Input Parameters
- `feedback_source`: Source of feedback (github_issues, github_prs, email, manual)
- `feedback_id`: Unique identifier for the feedback item
- `priority`: Priority level (low, medium, high, critical)
- `auto_integrate`: Whether to automatically integrate approved changes (default: false)

## Prerequisites
- Valid feedback source configuration
- Security validation tools available
- Quality gates configured
- Backup system functional

## Process Flow

### 1. Feedback Collection
```bash
# Initialize feedback processing
feedback_timestamp=$(date +%Y%m%d_%H%M%S)
feedback_dir=".ai_workflow/feedback/${feedback_source}_${feedback_id}_${feedback_timestamp}"
mkdir -p "$feedback_dir"

# Collect feedback based on source
case "$feedback_source" in
    "github_issues")
        # Fetch issue details via GitHub API
        if command -v gh >/dev/null 2>&1; then
            gh issue view "$feedback_id" --json title,body,labels,state > "$feedback_dir/issue_data.json"
        else
            echo "⚠️  GitHub CLI not available. Manual processing required."
        fi
        ;;
    "github_prs")
        # Fetch PR details and changes
        if command -v gh >/dev/null 2>&1; then
            gh pr view "$feedback_id" --json title,body,labels,state,files > "$feedback_dir/pr_data.json"
            gh pr diff "$feedback_id" > "$feedback_dir/pr_changes.diff"
        else
            echo "⚠️  GitHub CLI not available. Manual processing required."
        fi
        ;;
    "manual")
        # Manual feedback processing
        echo "Manual feedback processing for ID: $feedback_id"
        ;;
esac
```

### 2. Feedback Classification
```bash
# Analyze feedback content
feedback_type="unknown"
risk_level="medium"

if [ -f "$feedback_dir/issue_data.json" ]; then
    # Classify based on GitHub issue labels and content
    if grep -q "bug\|error\|fix" "$feedback_dir/issue_data.json"; then
        feedback_type="bug_report"
        risk_level="high"
    elif grep -q "enhancement\|feature\|improvement" "$feedback_dir/issue_data.json"; then
        feedback_type="feature_request"
        risk_level="medium"
    elif grep -q "security\|vulnerability" "$feedback_dir/issue_data.json"; then
        feedback_type="security_issue"
        risk_level="critical"
    elif grep -q "documentation\|docs" "$feedback_dir/issue_data.json"; then
        feedback_type="documentation"
        risk_level="low"
    fi
fi

# Create feedback classification report
cat > "$feedback_dir/classification.md" << EOF
# Feedback Classification Report

- **ID**: $feedback_id
- **Source**: $feedback_source
- **Type**: $feedback_type
- **Risk Level**: $risk_level
- **Priority**: $priority
- **Timestamp**: $feedback_timestamp

## Next Steps
- [ ] Security validation
- [ ] Technical feasibility analysis
- [ ] Impact assessment
- [ ] Implementation planning
EOF
```

### 3. Security Validation
```bash
# Security assessment for feedback
security_validated=false

# Check if feedback involves security-sensitive areas
if [ -f "$feedback_dir/pr_changes.diff" ]; then
    # Scan for security-sensitive file modifications
    if grep -E "\.ai_workflow/workflows/security/|ai-dev|CLAUDE\.md|manager\.md" "$feedback_dir/pr_changes.diff"; then
        echo "🔒 Security-sensitive files detected in feedback"
        risk_level="critical"
    fi
    
    # Scan for potentially dangerous commands
    if grep -E "rm -rf|sudo|eval|exec|curl.*bash|wget.*bash" "$feedback_dir/pr_changes.diff"; then
        echo "⚠️  Potentially dangerous commands detected"
        risk_level="critical"
    fi
fi

# Validate against security policies
if [ "$risk_level" = "critical" ]; then
    echo "🔒 Critical security validation required"
    echo "Manual security review needed before integration"
    security_validated=false
else
    security_validated=true
fi
```

### 4. Technical Feasibility Analysis
```bash
# Assess technical implementation feasibility
feasibility_score=0
implementation_complexity="unknown"

if [ -f "$feedback_dir/pr_changes.diff" ]; then
    # Count changed lines
    changed_lines=$(wc -l < "$feedback_dir/pr_changes.diff")
    
    if [ "$changed_lines" -lt 50 ]; then
        implementation_complexity="low"
        feasibility_score=3
    elif [ "$changed_lines" -lt 200 ]; then
        implementation_complexity="medium"
        feasibility_score=2
    else
        implementation_complexity="high"
        feasibility_score=1
    fi
    
    # Check for breaking changes
    if grep -q "BREAKING\|breaking" "$feedback_dir/pr_changes.diff"; then
        echo "⚠️  Breaking changes detected"
        feasibility_score=$((feasibility_score - 1))
    fi
fi

# Generate feasibility report
cat > "$feedback_dir/feasibility.md" << EOF
# Technical Feasibility Analysis

- **Implementation Complexity**: $implementation_complexity
- **Feasibility Score**: $feasibility_score/3
- **Changed Lines**: ${changed_lines:-0}
- **Breaking Changes**: $(grep -q "BREAKING\|breaking" "$feedback_dir/pr_changes.diff" 2>/dev/null && echo "Yes" || echo "No")

## Recommendations
$(if [ "$feasibility_score" -ge 2 ]; then
    echo "✅ Recommended for integration"
else
    echo "⚠️  Requires careful evaluation before integration"
fi)
EOF
```

### 5. Integration Decision
```bash
# Determine if feedback should be integrated
integrate_feedback=false

# Decision matrix
if [ "$security_validated" = true ] && [ "$feasibility_score" -ge 2 ]; then
    case "$feedback_type" in
        "bug_report")
            if [ "$priority" = "high" ] || [ "$priority" = "critical" ]; then
                integrate_feedback=true
            fi
            ;;
        "feature_request")
            if [ "$priority" = "medium" ] || [ "$priority" = "high" ]; then
                integrate_feedback=true
            fi
            ;;
        "documentation")
            integrate_feedback=true
            ;;
        "security_issue")
            if [ "$priority" = "critical" ]; then
                integrate_feedback=true
            fi
            ;;
    esac
fi

# Log integration decision
echo "Integration Decision: $([ "$integrate_feedback" = true ] && echo "APPROVED" || echo "REJECTED")" >> "$feedback_dir/decision.log"
```

### 6. Implementation Phase
```bash
if [ "$integrate_feedback" = true ]; then
    # Create implementation branch
    implementation_branch="integrate-feedback-${feedback_id}-${feedback_timestamp}"
    git checkout -b "$implementation_branch"
    
    # Apply changes based on feedback type
    case "$feedback_type" in
        "bug_report")
            echo "🐛 Implementing bug fix for feedback ID: $feedback_id"
            
            # Apply PR changes if available
            if [ -f "$feedback_dir/pr_changes.diff" ]; then
                git apply "$feedback_dir/pr_changes.diff" || {
                    echo "❌ Failed to apply patch. Manual intervention required."
                    exit 1
                }
            fi
            ;;
        "feature_request")
            echo "✨ Implementing feature request for feedback ID: $feedback_id"
            
            # For feature requests, create implementation plan
            if [ -f "$feedback_dir/pr_changes.diff" ]; then
                git apply "$feedback_dir/pr_changes.diff" || {
                    echo "❌ Failed to apply patch. Manual intervention required."
                    exit 1
                }
            fi
            ;;
        "documentation")
            echo "📖 Updating documentation for feedback ID: $feedback_id"
            
            # Apply documentation changes
            if [ -f "$feedback_dir/pr_changes.diff" ]; then
                git apply "$feedback_dir/pr_changes.diff" || {
                    echo "❌ Failed to apply patch. Manual intervention required."
                    exit 1
                }
            fi
            ;;
    esac
    
    # Commit changes
    git add .
    git commit -m "integrate: Apply external feedback #${feedback_id}

Type: $feedback_type
Source: $feedback_source
Priority: $priority
Risk Level: $risk_level

- Applied community feedback
- Passed security validation
- Validated technical feasibility

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
    
else
    echo "❌ Feedback integration rejected based on security/feasibility analysis"
    
    # Create rejection report
    cat > "$feedback_dir/rejection_report.md" << EOF
# Feedback Rejection Report

- **ID**: $feedback_id
- **Reason**: Security validation: $security_validated, Feasibility score: $feasibility_score
- **Type**: $feedback_type
- **Risk Level**: $risk_level

## Rejection Reasons
$([ "$security_validated" = false ] && echo "- Security validation failed")
$([ "$feasibility_score" -lt 2 ] && echo "- Low feasibility score")
$([ "$priority" = "low" ] && echo "- Low priority")
EOF
fi
```

### 7. Validation and Testing
```bash
if [ "$integrate_feedback" = true ]; then
    # Run framework validation
    validation_passed=true
    
    # Test framework CLI
    if [ -f "ai-dev" ]; then
        chmod +x ai-dev
        if ! ./ai-dev help >/dev/null 2>&1; then
            echo "❌ Framework CLI validation failed"
            validation_passed=false
        fi
    fi
    
    # Validate workflow syntax
    for workflow_file in .ai_workflow/workflows/*/*.md; do
        if [ -f "$workflow_file" ]; then
            if ! grep -q "^## Purpose\|^## Input Parameters\|^## Process Flow" "$workflow_file"; then
                echo "⚠️  Warning: $workflow_file may have incomplete workflow structure"
            fi
        fi
    done
    
    # If validation passes, merge to main
    if [ "$validation_passed" = true ]; then
        git checkout main
        git merge "$implementation_branch" --no-ff -m "Integrate external feedback #${feedback_id}"
        git branch -d "$implementation_branch"
        
        echo "✅ Feedback integration completed successfully"
        
        # Update feedback status
        if [ "$feedback_source" = "github_issues" ] && command -v gh >/dev/null 2>&1; then
            gh issue comment "$feedback_id" --body "✅ This feedback has been integrated into the framework. Thank you for your contribution!"
        fi
    else
        echo "❌ Validation failed. Rolling back integration."
        git checkout main
        git branch -D "$implementation_branch"
    fi
fi
```

## Output
- Processed feedback classification
- Security validation report
- Technical feasibility analysis
- Integration decision log
- Implementation changes (if approved)
- Validation results

## Error Handling
- Invalid feedback source → Log error and skip processing
- Security validation failure → Reject integration with detailed report
- Technical feasibility issues → Create manual review task
- Integration conflicts → Rollback and create manual merge task
- Validation failure → Automatic rollback to previous state

## Security Considerations
- All external feedback undergoes security validation
- Critical security issues require manual review
- Dangerous commands automatically trigger rejection
- Security-sensitive files require elevated approval
- Complete audit trail maintained

## Dependencies
- Git repository with proper branching
- GitHub CLI for GitHub-based feedback
- Security validation workflows
- Quality gates configured
- Backup system functional

## Success Criteria
- Feedback properly classified and processed
- Security validation completed
- Technical feasibility assessed
- Integration decision documented
- Changes applied and validated (if approved)
- Feedback source updated with results