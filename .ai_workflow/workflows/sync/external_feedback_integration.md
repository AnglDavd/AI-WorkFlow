# External Feedback Integration System

## Purpose
Integrate external feedback and community contributions into the AI Development Framework while maintaining security and quality standards.

## Philosophy
**Community-Driven Evolution** - Harness collective intelligence while maintaining framework integrity and security.

## External Feedback Integration Workflow

### 1. Function Definitions

```bash
#!/bin/bash

# Feedback Validation Function
validate_feedback() {
    local feedback_file="$1"
    
    echo "🔍 Validating feedback: $feedback_file"
    
    # Check file format
    if ! command -v jq >/dev/null 2>&1; then
        echo "⚠️  jq not found - skipping JSON validation"
        return 0
    fi
    
    if ! jq empty "$feedback_file" 2>/dev/null; then
        echo "❌ Invalid JSON format in $feedback_file"
        return 1
    fi
    
    # Enhanced security validation using GitHub security policy
    local feedback_data=$(cat "$feedback_file" 2>/dev/null || echo "{}")
    if ! validate_security_policy "$feedback_data"; then
        echo "⚠️  Security policy validation failed for $feedback_file"
        return 1
    fi
    
    # Validate against contribution guidelines
    local guidelines_result
    validate_contribution_guidelines "$feedback_data"
    guidelines_result=$?
    
    if [[ $guidelines_result -eq 1 ]]; then
        echo "⚠️  Contribution guidelines validation failed for $feedback_file"
        echo "$(date): Contribution guidelines validation failed for $feedback_file" >> "$INTEGRATION_LOG"
        # Move to manual review queue
        mkdir -p "$FEEDBACK_DIR/manual_review"
        cp "$feedback_file" "$FEEDBACK_DIR/manual_review/"
        return 1
    elif [[ $guidelines_result -eq 2 ]]; then
        echo "ℹ️  Feedback requires manual review - processing with lower priority"
        echo "$(date): Feedback flagged for manual review: $feedback_file" >> "$INTEGRATION_LOG"
    fi
    
    # Quality validation
    local title=$(jq -r '.title // .[] | select(.title) | .title' "$feedback_file" 2>/dev/null)
    local body=$(jq -r '.body // .[] | select(.body) | .body' "$feedback_file" 2>/dev/null)
    
    if [[ -z "$title" || -z "$body" ]]; then
        echo "⚠️  Incomplete feedback in $feedback_file"
        return 1
    fi
    
    echo "✅ Feedback validation passed"
    return 0
}

# Enhanced GitHub Template Validation Functions
validate_issue_template() {
    local issue_data="$1"
    local template_type="$2"  # bug_report or feature_request
    
    echo "🔍 Validating issue against $template_type template..."
    
    # Check if template exists
    if [[ ! -f ".github/ISSUE_TEMPLATE/${template_type}.md" ]]; then
        echo "⚠️  Template not found: .github/ISSUE_TEMPLATE/${template_type}.md"
        return 0  # Continue processing without template validation
    fi
    
    # Extract issue body
    local issue_body=$(echo "$issue_data" | jq -r '.body // ""' 2>/dev/null)
    
    if [[ -z "$issue_body" ]]; then
        echo "⚠️  Empty issue body - cannot validate template"
        return 1
    fi
    
    # Basic template validation - check for required sections
    local validation_score=0
    local total_checks=0
    
    case "$template_type" in
        "bug_report")
            # Check for bug report sections
            if echo "$issue_body" | grep -i -E "(bug description|steps to reproduce|expected behavior|actual behavior)" >/dev/null; then
                validation_score=$((validation_score + 1))
            fi
            total_checks=$((total_checks + 1))
            
            if echo "$issue_body" | grep -i -E "(environment|version|os)" >/dev/null; then
                validation_score=$((validation_score + 1))
            fi
            total_checks=$((total_checks + 1))
            ;;
        "feature_request")
            # Check for feature request sections
            if echo "$issue_body" | grep -i -E "(feature description|problem statement|proposed solution)" >/dev/null; then
                validation_score=$((validation_score + 1))
            fi
            total_checks=$((total_checks + 1))
            
            if echo "$issue_body" | grep -i -E "(use case|implementation)" >/dev/null; then
                validation_score=$((validation_score + 1))
            fi
            total_checks=$((total_checks + 1))
            ;;
    esac
    
    # Calculate validation percentage
    local validation_percentage=$((validation_score * 100 / total_checks))
    
    echo "📊 Template validation score: $validation_score/$total_checks ($validation_percentage%)"
    
    if [[ $validation_percentage -ge 50 ]]; then
        echo "✅ Issue follows template structure"
        return 0
    else
        echo "⚠️  Issue partially follows template - processing with lower priority"
        return 2  # Special return code for partial validation
    fi
}

validate_pr_template() {
    local pr_data="$1"
    
    echo "🔍 Validating PR against template requirements..."
    
    # Check if template exists
    if [[ ! -f ".github/PULL_REQUEST_TEMPLATE.md" ]]; then
        echo "⚠️  PR template not found: .github/PULL_REQUEST_TEMPLATE.md"
        return 0  # Continue processing without template validation
    fi
    
    # Extract PR body
    local pr_body=$(echo "$pr_data" | jq -r '.body // ""' 2>/dev/null)
    
    if [[ -z "$pr_body" ]]; then
        echo "⚠️  Empty PR body - cannot validate template"
        return 1
    fi
    
    # Basic template validation - check for required sections
    local validation_score=0
    local total_checks=0
    
    # Check for description
    if echo "$pr_body" | grep -i -E "(description|summary)" >/dev/null; then
        validation_score=$((validation_score + 1))
    fi
    total_checks=$((total_checks + 1))
    
    # Check for type of change
    if echo "$pr_body" | grep -i -E "(type of change|bug fix|new feature)" >/dev/null; then
        validation_score=$((validation_score + 1))
    fi
    total_checks=$((total_checks + 1))
    
    # Check for testing section
    if echo "$pr_body" | grep -i -E "(testing|test|diagnostic)" >/dev/null; then
        validation_score=$((validation_score + 1))
    fi
    total_checks=$((total_checks + 1))
    
    # Check for checklist items
    if echo "$pr_body" | grep -E "\[x\]|\[X\]" >/dev/null; then
        validation_score=$((validation_score + 1))
    fi
    total_checks=$((total_checks + 1))
    
    # Calculate validation percentage
    local validation_percentage=$((validation_score * 100 / total_checks))
    
    echo "📊 PR template validation score: $validation_score/$total_checks ($validation_percentage%)"
    
    if [[ $validation_percentage -ge 75 ]]; then
        echo "✅ PR follows template structure"
        return 0
    else
        echo "⚠️  PR partially follows template - processing with lower priority"
        return 2  # Special return code for partial validation
    fi
}

# Enhanced security validation using GitHub policies
validate_security_policy() {
    local feedback_data="$1"
    
    echo "🔍 Validating against security policy..."
    
    # Check if security policy exists
    if [[ ! -f ".github/SECURITY.md" ]]; then
        echo "⚠️  Security policy not found: .github/SECURITY.md"
        return 0  # Continue with basic security validation
    fi
    
    # Extract content for security scanning
    local content=$(echo "$feedback_data" | jq -r '.body // .title // ""' 2>/dev/null)
    
    if [[ -z "$content" ]]; then
        echo "⚠️  No content to validate"
        return 1
    fi
    
    # Enhanced security patterns from SECURITY.md
    local security_patterns=(
        "password|passwd|pwd"
        "secret|token|key|api_key|access_key"
        "vulnerability|exploit|hack|attack"
        "injection|xss|csrf|rce"
        "credential|auth|login|session"
        "private|confidential|internal"
    )
    
    for pattern in "${security_patterns[@]}"; do
        if echo "$content" | grep -i -E "$pattern" >/dev/null; then
            echo "🛡️  Security-sensitive content detected: $pattern"
            echo "$(date): Security pattern '$pattern' found in feedback" >> "$INTEGRATION_LOG"
            
            # Move to security review queue
            mkdir -p "$FEEDBACK_DIR/security_review"
            echo "$feedback_data" > "$FEEDBACK_DIR/security_review/security_flagged_$(date +%Y%m%d_%H%M%S).json"
            
            return 1  # Block processing
        fi
    done
    
    echo "✅ Security policy validation passed"
    return 0
}

# Validate feedback against contribution guidelines
validate_contribution_guidelines() {
    local feedback_data="$1"
    
    echo "🔍 Validating against contribution guidelines..."
    
    # Check if contribution guidelines exist
    if [[ ! -f ".github/CONTRIBUTING.md" ]]; then
        echo "⚠️  Contribution guidelines not found: .github/CONTRIBUTING.md"
        return 0  # Continue without guidelines validation
    fi
    
    # Extract content for validation
    local content=$(echo "$feedback_data" | jq -r '.body // .title // ""' 2>/dev/null)
    
    if [[ -z "$content" ]]; then
        echo "⚠️  No content to validate"
        return 1
    fi
    
    # Check for quality indicators from CONTRIBUTING.md
    local quality_score=0
    local total_quality_checks=0
    
    # Check for clear description
    if [[ ${#content} -gt 50 ]]; then
        quality_score=$((quality_score + 1))
    fi
    total_quality_checks=$((total_quality_checks + 1))
    
    # Check for respectful language (basic check)
    if ! echo "$content" | grep -i -E "(stupid|dumb|idiot|garbage|trash|sucks)" >/dev/null; then
        quality_score=$((quality_score + 1))
    fi
    total_quality_checks=$((total_quality_checks + 1))
    
    # Check for constructive tone
    if echo "$content" | grep -i -E "(please|thank|help|improve|suggest|recommend)" >/dev/null; then
        quality_score=$((quality_score + 1))
    fi
    total_quality_checks=$((total_quality_checks + 1))
    
    # Check for specific details (not just generic complaints)
    if echo "$content" | grep -i -E "(step|reproduce|example|version|error|specific)" >/dev/null; then
        quality_score=$((quality_score + 1))
    fi
    total_quality_checks=$((total_quality_checks + 1))
    
    # Calculate quality percentage
    local quality_percentage=$((quality_score * 100 / total_quality_checks))
    
    echo "📊 Contribution quality score: $quality_score/$total_quality_checks ($quality_percentage%)"
    
    if [[ $quality_percentage -ge 75 ]]; then
        echo "✅ Feedback meets contribution guidelines"
        return 0
    elif [[ $quality_percentage -ge 50 ]]; then
        echo "⚠️  Feedback partially meets guidelines - processing with review"
        return 2  # Partial validation
    else
        echo "❌ Feedback does not meet contribution guidelines - requires manual review"
        return 1
    fi
}

# Feedback Integration Function
integrate_feedback() {
    local feedback_file="$1"
    
    echo "🔄 Integrating feedback: $feedback_file"
    
    # Extract feedback details
    local feedback_type=$(determine_feedback_type "$feedback_file")
    local priority=$(determine_priority "$feedback_file")
    
    echo "📋 Feedback type: $feedback_type"
    echo "⚡ Priority: $priority"
    
    case "$feedback_type" in
        "enhancement")
            integrate_enhancement "$feedback_file"
            ;;
        "bug_report")
            integrate_bug_report "$feedback_file"
            ;;
        "feature_request")
            integrate_feature_request "$feedback_file"
            ;;
        "documentation")
            integrate_documentation "$feedback_file"
            ;;
        *)
            echo "ℹ️  Unknown feedback type: $feedback_type"
            return 1
            ;;
    esac
    
    return $?
}

# Determine feedback type
determine_feedback_type() {
    local feedback_file="$1"
    
    # Check labels
    local labels=$(jq -r '.labels[]?.name // .[] | select(.labels) | .labels[]?.name' "$feedback_file" 2>/dev/null)
    
    if echo "$labels" | grep -q "enhancement"; then
        echo "enhancement"
    elif echo "$labels" | grep -q "bug"; then
        echo "bug_report"
    elif echo "$labels" | grep -q "feature"; then
        echo "feature_request"
    elif echo "$labels" | grep -q "documentation"; then
        echo "documentation"
    else
        # Analyze content
        local content=$(jq -r '.body // .[] | select(.body) | .body' "$feedback_file" 2>/dev/null)
        
        if echo "$content" | grep -i -q "improve\|enhance\|optimize"; then
            echo "enhancement"
        elif echo "$content" | grep -i -q "bug\|error\|issue\|problem"; then
            echo "bug_report"
        elif echo "$content" | grep -i -q "feature\|request\|add\|implement"; then
            echo "feature_request"
        elif echo "$content" | grep -i -q "documentation\|docs\|guide"; then
            echo "documentation"
        else
            echo "unknown"
        fi
    fi
}

# Determine priority
determine_priority() {
    local feedback_file="$1"
    
    # Check for priority labels
    local labels=$(jq -r '.labels[]?.name // .[] | select(.labels) | .labels[]?.name' "$feedback_file" 2>/dev/null)
    
    if echo "$labels" | grep -q "critical\|urgent"; then
        echo "high"
    elif echo "$labels" | grep -q "important\|medium"; then
        echo "medium"
    elif echo "$labels" | grep -q "low\|nice-to-have"; then
        echo "low"
    else
        # Default priority
        echo "medium"
    fi
}

# Enhancement Integration
integrate_enhancement() {
    local feedback_file="$1"
    
    echo "🔧 Integrating enhancement feedback"
    
    # Create enhancement task
    local title=$(jq -r '.title // .[] | select(.title) | .title' "$feedback_file")
    local body=$(jq -r '.body // .[] | select(.body) | .body' "$feedback_file")
    local enhancement_id="enhancement_$(date +%Y%m%d_%H%M%S)"
    
    # Create enhancement task in framework feedback directory
    mkdir -p "$FEEDBACK_DIR/tasks/enhancements"
    cat > "$FEEDBACK_DIR/tasks/enhancements/$enhancement_id.md" << EOF
# Community Enhancement: $title

## Source
- **Type**: Community Feedback
- **Date**: $(date)
- **Priority**: $(determine_priority "$feedback_file")
- **Status**: Pending Review

## Description
$body

## Implementation Plan
1. Review enhancement request
2. Assess framework compatibility
3. Design implementation approach
4. Implement enhancement
5. Test and validate
6. Document changes

## Validation
- [ ] Enhancement aligns with framework philosophy
- [ ] Implementation doesn't break existing functionality
- [ ] Documentation updated
- [ ] Tests added/updated
EOF

    echo "✅ Enhancement task created: $enhancement_id.md"
    echo "$(date): Enhancement integrated - $enhancement_id" >> "$INTEGRATION_LOG"
    return 0
}

# Bug Report Integration
integrate_bug_report() {
    local feedback_file="$1"
    
    echo "🐛 Integrating bug report feedback"
    
    # Create bug fix task
    local title=$(jq -r '.title // .[] | select(.title) | .title' "$feedback_file")
    local body=$(jq -r '.body // .[] | select(.body) | .body' "$feedback_file")
    local bug_id="bug_$(date +%Y%m%d_%H%M%S)"
    
    # Create bug fix task in framework feedback directory
    mkdir -p "$FEEDBACK_DIR/tasks/bugs"
    cat > "$FEEDBACK_DIR/tasks/bugs/$bug_id.md" << EOF
# Community Bug Report: $title

## Source
- **Type**: Community Bug Report
- **Date**: $(date)
- **Priority**: $(determine_priority "$feedback_file")
- **Status**: Pending Investigation

## Bug Description
$body

## Fix Plan
1. Reproduce the issue
2. Identify root cause
3. Design fix approach
4. Implement fix
5. Test thoroughly
6. Update documentation if needed

## Validation
- [ ] Bug reproduced and confirmed
- [ ] Fix implemented and tested
- [ ] No regression introduced
- [ ] Documentation updated
EOF

    echo "✅ Bug fix task created: $bug_id.md"
    echo "$(date): Bug report integrated - $bug_id" >> "$INTEGRATION_LOG"
    return 0
}

# Feature Request Integration
integrate_feature_request() {
    local feedback_file="$1"
    
    echo "💡 Integrating feature request feedback"
    
    # Create feature development task
    local title=$(jq -r '.title // .[] | select(.title) | .title' "$feedback_file")
    local body=$(jq -r '.body // .[] | select(.body) | .body' "$feedback_file")
    local feature_id="feature_$(date +%Y%m%d_%H%M%S)"
    
    # Create feature task in framework feedback directory
    mkdir -p "$FEEDBACK_DIR/tasks/features"
    cat > "$FEEDBACK_DIR/tasks/features/$feature_id.md" << EOF
# Community Feature Request: $title

## Source
- **Type**: Community Feature Request
- **Date**: $(date)
- **Priority**: $(determine_priority "$feedback_file")
- **Status**: Pending Analysis

## Feature Description
$body

## Development Plan
1. Analyze feature requirements
2. Design architecture
3. Assess impact on existing framework
4. Implement feature
5. Create comprehensive tests
6. Update documentation

## Validation
- [ ] Feature requirements clear
- [ ] Architecture design approved
- [ ] Implementation complete
- [ ] Tests passing
- [ ] Documentation updated
EOF

    echo "✅ Feature task created: $feature_id.md"
    echo "$(date): Feature request integrated - $feature_id" >> "$INTEGRATION_LOG"
    return 0
}

# Documentation Integration
integrate_documentation() {
    local feedback_file="$1"
    
    echo "📚 Integrating documentation feedback"
    
    # Create documentation task
    local title=$(jq -r '.title // .[] | select(.title) | .title' "$feedback_file")
    local body=$(jq -r '.body // .[] | select(.body) | .body' "$feedback_file")
    local doc_id="docs_$(date +%Y%m%d_%H%M%S)"
    
    # Create documentation task in framework feedback directory
    mkdir -p "$FEEDBACK_DIR/tasks/documentation"
    cat > "$FEEDBACK_DIR/tasks/documentation/$doc_id.md" << EOF
# Community Documentation: $title

## Source
- **Type**: Community Documentation
- **Date**: $(date)
- **Priority**: $(determine_priority "$feedback_file")
- **Status**: Pending Review

## Documentation Request
$body

## Documentation Plan
1. Review documentation request
2. Identify documentation gaps
3. Create or update documentation
4. Ensure accuracy and clarity
5. Test documentation examples
6. Review and publish

## Validation
- [ ] Documentation request understood
- [ ] Content accurate and helpful
- [ ] Examples tested
- [ ] Documentation integrated
EOF

    echo "✅ Documentation task created: $doc_id.md"
    echo "$(date): Documentation integrated - $doc_id" >> "$INTEGRATION_LOG"
    return 0
}

# Generate Integration Report
generate_integration_report() {
    echo "📊 Generating integration report..."
    
    local report_file=".ai_workflow/reports/feedback_integration_$(date +%Y%m%d_%H%M%S).md"
    mkdir -p ".ai_workflow/reports"
    
    cat > "$report_file" << EOF
# External Feedback Integration Report

**Generated**: $(date)
**Period**: Last 24 hours

## Summary
- **Feedback Processed**: $FEEDBACK_PROCESSED
- **Feedback Integrated**: $FEEDBACK_INTEGRATED
- **Integration Rate**: $(( FEEDBACK_INTEGRATED * 100 / (FEEDBACK_PROCESSED + 1) ))%
- **Security Reviews**: $(find "$FEEDBACK_DIR/security_review" -name "*.json" 2>/dev/null | wc -l)
- **Manual Reviews**: $(find "$FEEDBACK_DIR/manual_review" -name "*" 2>/dev/null | wc -l)

## Integration Breakdown
- **Enhancements**: $(find "$FEEDBACK_DIR/tasks/enhancements" -name "*.md" -type f 2>/dev/null | wc -l)
- **Bug Reports**: $(find "$FEEDBACK_DIR/tasks/bugs" -name "*.md" -type f 2>/dev/null | wc -l)
- **Feature Requests**: $(find "$FEEDBACK_DIR/tasks/features" -name "*.md" -type f 2>/dev/null | wc -l)
- **Documentation**: $(find "$FEEDBACK_DIR/tasks/documentation" -name "*.md" -type f 2>/dev/null | wc -l)

## Task Locations
- **Enhancement Tasks**: $FEEDBACK_DIR/tasks/enhancements/
- **Bug Fix Tasks**: $FEEDBACK_DIR/tasks/bugs/
- **Feature Tasks**: $FEEDBACK_DIR/tasks/features/
- **Documentation Tasks**: $FEEDBACK_DIR/tasks/documentation/

## Next Steps
1. Review and prioritize integrated feedback tasks
2. Execute high-priority tasks
3. Communicate progress back to community
4. Continue monitoring for new feedback

## Log File
$INTEGRATION_LOG
EOF

    echo "📋 Integration report generated: $report_file"
    echo "$(date): Integration report generated" >> "$INTEGRATION_LOG"
}
```

### 2. Feedback Collection System

```bash
# External Feedback Collection and Integration
echo "🌐 External Feedback Integration System"
echo "======================================"

# Configuration - Framework-level feedback storage
FEEDBACK_DIR=".ai_workflow/feedback"
INTEGRATION_LOG=".ai_workflow/logs/feedback_integration_$(date +%Y%m%d_%H%M%S).log"
FEEDBACK_QUEUE="$FEEDBACK_DIR/queue"
PROCESSED_FEEDBACK="$FEEDBACK_DIR/processed"

# Initialize feedback system
mkdir -p "$FEEDBACK_DIR" "$FEEDBACK_QUEUE" "$PROCESSED_FEEDBACK"
mkdir -p "$FEEDBACK_DIR/tasks/enhancements" "$FEEDBACK_DIR/tasks/bugs" "$FEEDBACK_DIR/tasks/features" "$FEEDBACK_DIR/tasks/documentation"
echo "📝 Feedback Integration Log - $(date)" > "$INTEGRATION_LOG"

echo "🔄 Starting feedback integration process..."
echo "$(date): Starting feedback integration" >> "$INTEGRATION_LOG"

# Enhanced GitHub Integration with Template Validation
if command -v gh >/dev/null 2>&1; then
    echo "📋 Checking GitHub for community feedback..."
    
    # Get recent issues labeled as 'enhancement' or 'feature-request'
    GITHUB_ISSUES=$(gh issue list --label "enhancement,feature-request" --state open --limit 10 --json number,title,body,labels 2>/dev/null || echo "[]")
    
    if [[ "$GITHUB_ISSUES" != "[]" ]]; then
        echo "📥 Found GitHub issues for review"
        
        # Enhanced validation using .github templates
        VALIDATED_ISSUES=$(echo "$GITHUB_ISSUES" | jq -r '.[] | select(.body != null and .body != "") | {number, title, body, labels, validated: true}' 2>/dev/null || echo "$GITHUB_ISSUES")
        
        # Check if issues follow template structure
        if [[ -f ".github/ISSUE_TEMPLATE/bug_report.md" ]] || [[ -f ".github/ISSUE_TEMPLATE/feature_request.md" ]]; then
            echo "🔍 Validating issues against GitHub templates..."
            
            # Process each issue individually for template validation
            TEMPLATE_VALIDATED_ISSUES="[]"
            
            # Process each issue with template validation
            while IFS= read -r issue; do
                if [[ -n "$issue" && "$issue" != "null" ]]; then
                    # Determine template type based on labels
                    local template_type="feature_request"  # default
                    if echo "$issue" | jq -r '.labels[]?.name' 2>/dev/null | grep -i "bug" >/dev/null; then
                        template_type="bug_report"
                    fi
                    
                    # Validate against template
                    if validate_issue_template "$issue" "$template_type"; then
                        echo "✅ Issue $(echo "$issue" | jq -r '.number') validated successfully"
                        TEMPLATE_VALIDATED_ISSUES=$(echo "$TEMPLATE_VALIDATED_ISSUES" | jq ". + [$issue]")
                    else
                        echo "⚠️  Issue $(echo "$issue" | jq -r '.number') validation failed - skipping"
                    fi
                fi
            done < <(echo "$GITHUB_ISSUES" | jq -c '.[]?')
            
            VALIDATED_ISSUES="$TEMPLATE_VALIDATED_ISSUES"
        fi
        
        echo "$VALIDATED_ISSUES" > "$FEEDBACK_QUEUE/github_issues_$(date +%Y%m%d_%H%M%S).json"
        echo "$(date): GitHub issues collected and validated" >> "$INTEGRATION_LOG"
    else
        echo "ℹ️  No new GitHub issues found"
    fi
    
    # Get recent pull requests with enhanced validation
    GITHUB_PRS=$(gh pr list --state open --limit 5 --json number,title,body,labels 2>/dev/null || echo "[]")
    
    if [[ "$GITHUB_PRS" != "[]" ]]; then
        echo "📥 Found GitHub pull requests for review"
        
        # Enhanced PR validation using template
        if [[ -f ".github/PULL_REQUEST_TEMPLATE.md" ]]; then
            echo "🔍 Validating PRs against template requirements..."
            
            # Process each PR individually for template validation
            TEMPLATE_VALIDATED_PRS="[]"
            
            # Process each PR with template validation
            while IFS= read -r pr; do
                if [[ -n "$pr" && "$pr" != "null" ]]; then
                    # Validate against template and security policy
                    if validate_pr_template "$pr" && validate_security_policy "$pr"; then
                        echo "✅ PR $(echo "$pr" | jq -r '.number') validated successfully"
                        TEMPLATE_VALIDATED_PRS=$(echo "$TEMPLATE_VALIDATED_PRS" | jq ". + [$pr]")
                    else
                        echo "⚠️  PR $(echo "$pr" | jq -r '.number') validation failed - skipping"
                    fi
                fi
            done < <(echo "$GITHUB_PRS" | jq -c '.[]?')
            
            GITHUB_PRS="$TEMPLATE_VALIDATED_PRS"
        fi
        
        echo "$GITHUB_PRS" > "$FEEDBACK_QUEUE/github_prs_$(date +%Y%m%d_%H%M%S).json"
        echo "$(date): GitHub PRs collected and validated" >> "$INTEGRATION_LOG"
    else
        echo "ℹ️  No new GitHub pull requests found"
    fi
else
    echo "⚠️  GitHub CLI not found - skipping GitHub integration"
    echo "💡 Install with: https://github.com/cli/cli#installation"
fi

# Process feedback queue
echo "🔄 Processing feedback queue..."
FEEDBACK_PROCESSED=0
FEEDBACK_INTEGRATED=0

for feedback_file in "$FEEDBACK_QUEUE"/*.json; do
    if [[ -f "$feedback_file" ]]; then
        echo "📋 Processing: $(basename "$feedback_file")"
        
        # Validate and categorize feedback
        if validate_feedback "$feedback_file"; then
            if integrate_feedback "$feedback_file"; then
                FEEDBACK_INTEGRATED=$((FEEDBACK_INTEGRATED + 1))
                mv "$feedback_file" "$PROCESSED_FEEDBACK/"
            fi
        fi
        
        FEEDBACK_PROCESSED=$((FEEDBACK_PROCESSED + 1))
    fi
done

echo "📊 Enhanced feedback processing complete:"
echo "  - Processed: $FEEDBACK_PROCESSED items"
echo "  - Integrated: $FEEDBACK_INTEGRATED items"
echo "  - Security reviewed: $(find "$FEEDBACK_DIR/security_review" -name "*.json" 2>/dev/null | wc -l) items"
echo "  - Manual review required: $(find "$FEEDBACK_DIR/manual_review" -name "*" 2>/dev/null | wc -l) items"
echo "$(date): Processed $FEEDBACK_PROCESSED, integrated $FEEDBACK_INTEGRATED" >> "$INTEGRATION_LOG"

# Generate final report
generate_integration_report

echo "🎉 External feedback integration complete!"
echo "📝 Integration log: $INTEGRATION_LOG"
echo "📂 Framework feedback tasks: $FEEDBACK_DIR/tasks/"
```

### 3. Directory Structure

```bash
# Framework feedback organization structure
echo "📁 Framework Feedback Directory Structure:"
echo "======================================="
echo "📂 .ai_workflow/feedback/"
echo "├── 📁 queue/                    # Incoming feedback awaiting processing"
echo "├── 📁 processed/                # Successfully processed feedback"
echo "├── 📁 security_review/          # Feedback flagged for security review"
echo "└── 📁 tasks/                    # Framework development tasks"
echo "    ├── 📁 enhancements/         # Enhancement tasks"
echo "    ├── 📁 bugs/                 # Bug fix tasks"
echo "    ├── 📁 features/             # Feature development tasks"
echo "    └── 📁 documentation/        # Documentation tasks"
echo ""
echo "📋 This structure separates:"
echo "• Framework feedback from user project content"
echo "• Different types of community contributions"
echo "• Development tasks by category"
echo "• Security concerns from regular feedback"
```

## CLI Integration

### Add to ai-dev script:
```bash
sync)
    case "$2" in
        "feedback")
            echo "🌐 Synchronizing with external feedback..."
            execute_workflow "${AI_WORKFLOW_DIR}/workflows/sync/external_feedback_integration.md" "External Feedback Integration"
            ;;
        *)
            echo "🔄 Framework synchronization..."
            echo "Available sync options:"
            echo "  ./ai-dev sync feedback    # Integrate external feedback"
            echo "  ./ai-dev sync framework   # Synchronize framework updates"
            ;;
    esac
    ;;
```

## Benefits

### Community Engagement
- **Automated feedback collection** from GitHub issues and PRs
- **Structured integration** of community contributions
- **Security validation** of external inputs
- **Priority-based processing** of feedback

### Quality Assurance
- **Validation pipeline** for all external feedback
- **Security screening** for sensitive content
- **Categorization system** for efficient processing
- **Task generation** for systematic implementation

### Framework Evolution
- **Community-driven improvements** while maintaining quality
- **Systematic integration** of external ideas
- **Transparent process** for community contributions
- **Continuous improvement** based on user feedback

### Clear Separation of Concerns
- **Framework-level feedback** stored in `.ai_workflow/feedback/`
- **User project content** remains in user directories
- **Community tasks** organized by type for efficient processing
- **Security isolation** of sensitive feedback

## Framework vs User Project Content

### Framework Feedback (`.ai_workflow/feedback/`)
- Community contributions to the framework itself
- Enhancement requests for CLI commands
- Bug reports about framework functionality
- Documentation improvements for framework guides

### User Project Content (User directories)
- Project-specific PRPs and tasks
- Application development work
- User-generated documentation
- Project-specific configurations

This clear separation ensures that framework development tasks don't interfere with user project work while maintaining organized community contribution processing.