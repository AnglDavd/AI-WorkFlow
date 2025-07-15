# Analyze Error Context

## Overview
This workflow provides intelligent error analysis and categorization for PRP execution, enabling the system to understand error context, identify root causes, and determine appropriate correction strategies. It forms the foundation for automated error recovery.

## Workflow Instructions

### For AI Agents
When analyzing error context:

1. **Capture comprehensive error information** including context, environment, and system state
2. **Categorize errors** by type, severity, and resolution complexity
3. **Identify root causes** through systematic analysis
4. **Determine correction strategies** based on error patterns and context
5. **Generate structured error reports** for auto-correction and user escalation

### Error Analysis Functions

#### Main Error Analysis Function
```bash
# Main error analysis function
analyze_error_context() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local CONTEXT_INFO="$3"
    local TASK_INDEX="$4"
    local ANALYSIS_OUTPUT="$5"
    
    if [ -z "$ERROR_MESSAGE" ]; then
        echo "ERROR: Error message is required for analysis"
        return 1
    fi
    
    if [ -z "$ANALYSIS_OUTPUT" ]; then
        ANALYSIS_OUTPUT=".ai_workflow/error_analysis/error_analysis_$(date +%Y%m%d_%H%M%S).md"
    fi
    
    echo "Starting error context analysis..."
    echo "Error: $ERROR_MESSAGE"
    echo "Analysis Output: $ANALYSIS_OUTPUT"
    
    # Initialize error analysis report
    init_error_analysis_report "$ANALYSIS_OUTPUT" "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO" "$TASK_INDEX"
    
    # Capture system state
    capture_system_state "$ANALYSIS_OUTPUT"
    
    # Categorize error
    categorize_error "$ERROR_MESSAGE" "$ERROR_CODE" "$ANALYSIS_OUTPUT"
    
    # Analyze root cause
    analyze_root_cause "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO" "$ANALYSIS_OUTPUT"
    
    # Determine correction strategy
    determine_correction_strategy "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO" "$ANALYSIS_OUTPUT"
    
    # Generate recovery recommendations
    generate_recovery_recommendations "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO" "$ANALYSIS_OUTPUT"
    
    # Finalize analysis report
    finalize_error_analysis_report "$ANALYSIS_OUTPUT"
    
    echo "Error analysis completed: $ANALYSIS_OUTPUT"
    
    # Return analysis result for use by other workflows
    export ERROR_ANALYSIS_FILE="$ANALYSIS_OUTPUT"
    export ERROR_CATEGORY=$(get_error_category "$ERROR_MESSAGE" "$ERROR_CODE")
    export ERROR_SEVERITY=$(get_error_severity "$ERROR_MESSAGE" "$ERROR_CODE")
    export CORRECTION_STRATEGY=$(get_correction_strategy "$ERROR_MESSAGE" "$ERROR_CODE")
    
    return 0
}
```

#### Initialize Error Analysis Report
```bash
# Initialize error analysis report
init_error_analysis_report() {
    local ANALYSIS_OUTPUT="$1"
    local ERROR_MESSAGE="$2"
    local ERROR_CODE="$3"
    local CONTEXT_INFO="$4"
    local TASK_INDEX="$5"
    
    # Create analysis directory
    mkdir -p "$(dirname "$ANALYSIS_OUTPUT")"
    
    cat > "$ANALYSIS_OUTPUT" << EOF
# Error Context Analysis Report

## Error Information
- **Error Message**: $ERROR_MESSAGE
- **Error Code**: $ERROR_CODE
- **Task Index**: $TASK_INDEX
- **Timestamp**: $(date)
- **Analysis ID**: $(basename "$ANALYSIS_OUTPUT" .md)

## Context Information
- **Execution Context**: $CONTEXT_INFO
- **Working Directory**: $(pwd)
- **Current User**: $(whoami)
- **System State**: Captured below

## Analysis Results
*Analysis in progress...*

## Root Cause Analysis
*Root cause analysis in progress...*

## Correction Strategy
*Correction strategy in progress...*

## Recovery Recommendations
*Recovery recommendations in progress...*

EOF
    
    echo "Error analysis report initialized: $ANALYSIS_OUTPUT"
}
```

#### Capture System State
```bash
# Capture comprehensive system state
capture_system_state() {
    local ANALYSIS_OUTPUT="$1"
    
    echo "Capturing system state..."
    
    cat >> "$ANALYSIS_OUTPUT" << EOF
### System State Capture

#### Environment Variables
\`\`\`bash
# Key environment variables
PROJECT_NAME: ${PROJECT_NAME:-"Not set"}
EXECUTION_ID: ${EXECUTION_ID:-"Not set"}
CURRENT_TASK: ${CURRENT_TASK:-"Not set"}
STATE_FILE: ${STATE_FILE:-"Not set"}
\`\`\`

#### File System State
- **Current Directory**: $(pwd)
- **Directory Contents**: $(ls -la | wc -l) items
- **Git Status**: $(git status --porcelain 2>/dev/null | wc -l) modified files
- **Disk Usage**: $(df -h . | tail -1 | awk '{print $5}') used

#### Process Information
- **Process ID**: $$
- **Parent Process**: $PPID
- **Shell**: $SHELL
- **Terminal**: ${TERM:-"Not set"}

#### System Resources
- **Memory Usage**: $(free -h | grep Mem | awk '{print $3"/"$2}')
- **CPU Load**: $(uptime | awk -F'load average:' '{print $2}')
- **Available Space**: $(df -h . | tail -1 | awk '{print $4}')

#### Framework State
- **Abstract Tools**: $([ -f ".ai_workflow/tools/execute_abstract_tool_call.md" ] && echo "Available" || echo "Not available")
- **State Management**: $([ -f ".ai_workflow/workflows/common/manage_workflow_state.md" ] && echo "Available" || echo "Not available")
- **Rollback System**: $([ -f ".ai_workflow/workflows/common/rollback_changes.md" ] && echo "Available" || echo "Not available")

#### Recent Operations
$(get_recent_operations)

EOF
    
    echo "System state captured"
}
```

#### Categorize Error
```bash
# Categorize error by type and severity
categorize_error() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local ANALYSIS_OUTPUT="$3"
    
    echo "Categorizing error..."
    
    # Determine error category
    local ERROR_CATEGORY=$(classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE")
    local ERROR_SEVERITY=$(classify_error_severity "$ERROR_MESSAGE" "$ERROR_CODE")
    local ERROR_TYPE=$(classify_error_type "$ERROR_MESSAGE" "$ERROR_CODE")
    local RECOVERY_DIFFICULTY=$(assess_recovery_difficulty "$ERROR_MESSAGE" "$ERROR_CODE")
    
    cat >> "$ANALYSIS_OUTPUT" << EOF
### Error Classification

#### Primary Classification
- **Category**: $ERROR_CATEGORY
- **Severity**: $ERROR_SEVERITY
- **Type**: $ERROR_TYPE
- **Recovery Difficulty**: $RECOVERY_DIFFICULTY

#### Detailed Classification
$(provide_detailed_classification "$ERROR_MESSAGE" "$ERROR_CODE")

#### Similar Error Patterns
$(find_similar_error_patterns "$ERROR_MESSAGE" "$ERROR_CODE")

#### Error Frequency
$(calculate_error_frequency "$ERROR_MESSAGE" "$ERROR_CODE")

EOF
    
    echo "Error categorized: $ERROR_CATEGORY ($ERROR_SEVERITY)"
}
```

#### Classify Error Category
```bash
# Classify error into main categories
classify_error_category() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    
    # Syntax and compilation errors
    if echo "$ERROR_MESSAGE" | grep -qi "syntax\|parse\|compile\|invalid syntax"; then
        echo "SYNTAX_ERROR"
        return
    fi
    
    # File system errors
    if echo "$ERROR_MESSAGE" | grep -qi "file not found\|permission denied\|no such file\|directory"; then
        echo "FILESYSTEM_ERROR"
        return
    fi
    
    # Network and connectivity errors
    if echo "$ERROR_MESSAGE" | grep -qi "network\|connection\|timeout\|unreachable\|dns"; then
        echo "NETWORK_ERROR"
        return
    fi
    
    # Dependency and import errors
    if echo "$ERROR_MESSAGE" | grep -qi "module not found\|import error\|dependency\|package not found"; then
        echo "DEPENDENCY_ERROR"
        return
    fi
    
    # Abstract tool errors
    if echo "$ERROR_MESSAGE" | grep -qi "abstract tool\|tool call\|adapter\|validation"; then
        echo "TOOL_ERROR"
        return
    fi
    
    # Configuration errors
    if echo "$ERROR_MESSAGE" | grep -qi "config\|configuration\|setting\|environment"; then
        echo "CONFIGURATION_ERROR"
        return
    fi
    
    # Runtime errors
    if echo "$ERROR_MESSAGE" | grep -qi "runtime\|execution\|null pointer\|segmentation"; then
        echo "RUNTIME_ERROR"
        return
    fi
    
    # Resource errors
    if echo "$ERROR_MESSAGE" | grep -qi "memory\|disk\|space\|resource\|quota"; then
        echo "RESOURCE_ERROR"
        return
    fi
    
    # Authentication and authorization
    if echo "$ERROR_MESSAGE" | grep -qi "auth\|permission\|access denied\|unauthorized"; then
        echo "AUTH_ERROR"
        return
    fi
    
    # Default category
    echo "UNKNOWN_ERROR"
}
```

#### Classify Error Severity
```bash
# Classify error severity
classify_error_severity() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    
    # Critical errors (system-breaking)
    if echo "$ERROR_MESSAGE" | grep -qi "critical\|fatal\|system\|crash\|corruption"; then
        echo "CRITICAL"
        return
    fi
    
    # High severity (workflow-breaking)
    if echo "$ERROR_MESSAGE" | grep -qi "failed\|error\|exception\|abort"; then
        if [ "$ERROR_CODE" -gt 100 ] 2>/dev/null; then
            echo "HIGH"
        else
            echo "MEDIUM"
        fi
        return
    fi
    
    # Medium severity (task-breaking)
    if echo "$ERROR_MESSAGE" | grep -qi "warning\|deprecated\|invalid"; then
        echo "MEDIUM"
        return
    fi
    
    # Low severity (informational)
    if echo "$ERROR_MESSAGE" | grep -qi "info\|notice\|debug"; then
        echo "LOW"
        return
    fi
    
    # Default to medium
    echo "MEDIUM"
}
```

#### Classify Error Type
```bash
# Classify error type for correction strategy
classify_error_type() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    
    # Recoverable errors
    if echo "$ERROR_MESSAGE" | grep -qi "timeout\|retry\|temporary\|busy"; then
        echo "RECOVERABLE"
        return
    fi
    
    # Correctable errors
    if echo "$ERROR_MESSAGE" | grep -qi "syntax\|format\|validation\|typo"; then
        echo "CORRECTABLE"
        return
    fi
    
    # Configuration errors
    if echo "$ERROR_MESSAGE" | grep -qi "config\|setting\|environment\|path"; then
        echo "CONFIGURATION"
        return
    fi
    
    # External dependency errors
    if echo "$ERROR_MESSAGE" | grep -qi "network\|service\|api\|external"; then
        echo "EXTERNAL"
        return
    fi
    
    # System errors
    if echo "$ERROR_MESSAGE" | grep -qi "system\|kernel\|hardware\|resource"; then
        echo "SYSTEM"
        return
    fi
    
    # User errors
    if echo "$ERROR_MESSAGE" | grep -qi "input\|parameter\|argument\|user"; then
        echo "USER_ERROR"
        return
    fi
    
    # Unknown type
    echo "UNKNOWN"
}
```

#### Analyze Root Cause
```bash
# Analyze root cause of error
analyze_root_cause() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local CONTEXT_INFO="$3"
    local ANALYSIS_OUTPUT="$4"
    
    echo "Analyzing root cause..."
    
    # Perform root cause analysis
    local ROOT_CAUSE=$(identify_root_cause "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")
    local CONTRIBUTING_FACTORS=$(identify_contributing_factors "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")
    local FAILURE_CHAIN=$(trace_failure_chain "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")
    
    cat >> "$ANALYSIS_OUTPUT" << EOF
### Root Cause Analysis

#### Primary Root Cause
$ROOT_CAUSE

#### Contributing Factors
$CONTRIBUTING_FACTORS

#### Failure Chain Analysis
$FAILURE_CHAIN

#### Environment Analysis
$(analyze_environment_factors "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

#### Timing Analysis
$(analyze_timing_factors "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

#### Dependencies Analysis
$(analyze_dependency_factors "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

EOF
    
    echo "Root cause analysis completed"
}
```

#### Identify Root Cause
```bash
# Identify primary root cause
identify_root_cause() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local CONTEXT_INFO="$3"
    
    local ERROR_CATEGORY=$(classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE")
    
    case "$ERROR_CATEGORY" in
        "SYNTAX_ERROR")
            echo "**Code syntax violation** - Invalid syntax in source code or configuration file"
            ;;
        "FILESYSTEM_ERROR")
            echo "**File system access issue** - Missing file, permission denied, or path error"
            ;;
        "NETWORK_ERROR")
            echo "**Network connectivity issue** - Connection timeout, DNS resolution failure, or service unavailable"
            ;;
        "DEPENDENCY_ERROR")
            echo "**Missing or incompatible dependency** - Required package, module, or library not available"
            ;;
        "TOOL_ERROR")
            echo "**Abstract tool system malfunction** - Tool validation failure or adapter error"
            ;;
        "CONFIGURATION_ERROR")
            echo "**Configuration mismatch** - Invalid settings, environment variables, or configuration parameters"
            ;;
        "RUNTIME_ERROR")
            echo "**Runtime execution failure** - Null pointer, segmentation fault, or execution exception"
            ;;
        "RESOURCE_ERROR")
            echo "**Resource exhaustion** - Insufficient memory, disk space, or system resources"
            ;;
        "AUTH_ERROR")
            echo "**Authentication or authorization failure** - Invalid credentials or insufficient permissions"
            ;;
        *)
            echo "**Unknown root cause** - Error pattern not recognized, requires manual investigation"
            ;;
    esac
}
```

#### Determine Correction Strategy
```bash
# Determine appropriate correction strategy
determine_correction_strategy() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local CONTEXT_INFO="$3"
    local ANALYSIS_OUTPUT="$4"
    
    echo "Determining correction strategy..."
    
    local ERROR_CATEGORY=$(classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE")
    local ERROR_TYPE=$(classify_error_type "$ERROR_MESSAGE" "$ERROR_CODE")
    local ERROR_SEVERITY=$(classify_error_severity "$ERROR_MESSAGE" "$ERROR_CODE")
    
    local CORRECTION_STRATEGY=$(select_correction_strategy "$ERROR_CATEGORY" "$ERROR_TYPE" "$ERROR_SEVERITY")
    local CORRECTION_COMPLEXITY=$(assess_correction_complexity "$ERROR_MESSAGE" "$ERROR_CODE")
    local SUCCESS_PROBABILITY=$(estimate_success_probability "$ERROR_MESSAGE" "$ERROR_CODE")
    
    cat >> "$ANALYSIS_OUTPUT" << EOF
### Correction Strategy

#### Recommended Strategy
$CORRECTION_STRATEGY

#### Strategy Details
$(provide_strategy_details "$ERROR_CATEGORY" "$ERROR_TYPE" "$ERROR_SEVERITY")

#### Correction Complexity
- **Complexity Level**: $CORRECTION_COMPLEXITY
- **Success Probability**: $SUCCESS_PROBABILITY
- **Estimated Time**: $(estimate_correction_time "$ERROR_MESSAGE" "$ERROR_CODE")
- **Required Resources**: $(identify_required_resources "$ERROR_MESSAGE" "$ERROR_CODE")

#### Step-by-Step Approach
$(generate_correction_steps "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

#### Fallback Options
$(identify_fallback_options "$ERROR_MESSAGE" "$ERROR_CODE")

#### Risk Assessment
$(assess_correction_risks "$ERROR_MESSAGE" "$ERROR_CODE")

EOF
    
    echo "Correction strategy determined: $CORRECTION_STRATEGY"
}
```

#### Select Correction Strategy
```bash
# Select appropriate correction strategy
select_correction_strategy() {
    local ERROR_CATEGORY="$1"
    local ERROR_TYPE="$2"
    local ERROR_SEVERITY="$3"
    
    case "$ERROR_CATEGORY" in
        "SYNTAX_ERROR")
            echo "**AUTOMATED_CORRECTION** - Apply syntax fixes using pattern matching and correction rules"
            ;;
        "FILESYSTEM_ERROR")
            echo "**ENVIRONMENT_CORRECTION** - Fix file paths, permissions, or create missing files"
            ;;
        "NETWORK_ERROR")
            echo "**RETRY_WITH_BACKOFF** - Implement exponential backoff retry strategy"
            ;;
        "DEPENDENCY_ERROR")
            echo "**DEPENDENCY_INSTALLATION** - Install missing dependencies or update versions"
            ;;
        "TOOL_ERROR")
            echo "**TOOL_VALIDATION_FIX** - Correct tool call parameters or adapter configuration"
            ;;
        "CONFIGURATION_ERROR")
            echo "**CONFIGURATION_REPAIR** - Update configuration files or environment variables"
            ;;
        "RUNTIME_ERROR")
            if [ "$ERROR_SEVERITY" = "CRITICAL" ]; then
                echo "**ROLLBACK_AND_ESCALATE** - Rollback to safe state and escalate to user"
            else
                echo "**DEFENSIVE_CORRECTION** - Apply defensive programming fixes"
            fi
            ;;
        "RESOURCE_ERROR")
            echo "**RESOURCE_OPTIMIZATION** - Free resources or optimize usage"
            ;;
        "AUTH_ERROR")
            echo "**CREDENTIAL_REFRESH** - Refresh authentication or request new permissions"
            ;;
        *)
            echo "**MANUAL_ESCALATION** - Require manual intervention due to unknown error pattern"
            ;;
    esac
}
```

#### Generate Recovery Recommendations
```bash
# Generate specific recovery recommendations
generate_recovery_recommendations() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local CONTEXT_INFO="$3"
    local ANALYSIS_OUTPUT="$4"
    
    echo "Generating recovery recommendations..."
    
    local ERROR_CATEGORY=$(classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE")
    local CORRECTION_STRATEGY=$(select_correction_strategy "$ERROR_CATEGORY" "$(classify_error_type "$ERROR_MESSAGE" "$ERROR_CODE")" "$(classify_error_severity "$ERROR_MESSAGE" "$ERROR_CODE")")
    
    cat >> "$ANALYSIS_OUTPUT" << EOF
### Recovery Recommendations

#### Immediate Actions
$(generate_immediate_actions "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

#### Corrective Actions
$(generate_corrective_actions "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

#### Preventive Actions
$(generate_preventive_actions "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

#### Monitoring and Validation
$(generate_monitoring_actions "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

#### Escalation Criteria
$(define_escalation_criteria "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

#### Success Metrics
$(define_success_metrics "$ERROR_MESSAGE" "$ERROR_CODE" "$CONTEXT_INFO")

EOF
    
    echo "Recovery recommendations generated"
}
```

#### Generate Immediate Actions
```bash
# Generate immediate actions for error recovery
generate_immediate_actions() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local CONTEXT_INFO="$3"
    
    local ERROR_CATEGORY=$(classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE")
    
    echo "**Immediate Actions Required:**"
    echo ""
    
    case "$ERROR_CATEGORY" in
        "SYNTAX_ERROR")
            echo "1. **Validate syntax** - Check file syntax using appropriate linter"
            echo "2. **Identify error location** - Locate exact line and character position"
            echo "3. **Apply quick fix** - Correct obvious syntax errors (missing quotes, brackets)"
            echo "4. **Test correction** - Verify syntax is now valid"
            ;;
        "FILESYSTEM_ERROR")
            echo "1. **Check file existence** - Verify file paths and permissions"
            echo "2. **Create missing files** - Generate required files if missing"
            echo "3. **Fix permissions** - Adjust file permissions if needed"
            echo "4. **Verify access** - Test file read/write access"
            ;;
        "NETWORK_ERROR")
            echo "1. **Check connectivity** - Test network connection"
            echo "2. **Verify endpoints** - Confirm service availability"
            echo "3. **Implement retry** - Use exponential backoff retry logic"
            echo "4. **Switch to backup** - Use alternative endpoints if available"
            ;;
        "DEPENDENCY_ERROR")
            echo "1. **Check dependencies** - Verify required packages are installed"
            echo "2. **Install missing packages** - Use package manager to install"
            echo "3. **Update versions** - Ensure compatibility with current versions"
            echo "4. **Verify installation** - Test dependency functionality"
            ;;
        "TOOL_ERROR")
            echo "1. **Validate tool call** - Check abstract tool call syntax"
            echo "2. **Verify adapter** - Ensure tool adapter is available and functional"
            echo "3. **Check parameters** - Validate all required parameters are provided"
            echo "4. **Test tool execution** - Run tool call in isolation"
            ;;
        *)
            echo "1. **Capture error state** - Save current system state for analysis"
            echo "2. **Create rollback point** - Establish recovery point"
            echo "3. **Log detailed error** - Record comprehensive error information"
            echo "4. **Assess impact** - Determine scope of error effects"
            ;;
    esac
}
```

#### Get Recent Operations
```bash
# Get recent operations for context
get_recent_operations() {
    echo "**Recent Operations:**"
    
    # Check if state file exists
    if [ -f "$STATE_FILE" ]; then
        echo "- $(tail -3 "$STATE_FILE" | head -3)"
    else
        echo "- No state file available"
    fi
    
    # Check recent commands from history
    echo "- Recent commands: $(history | tail -3 | cut -d' ' -f4-)"
    
    # Check recent abstract tool calls
    if [ -f ".ai_workflow/logs/tool_executions.log" ]; then
        echo "- Recent tool calls: $(tail -2 ".ai_workflow/logs/tool_executions.log" | head -2)"
    fi
}
```

#### Find Similar Error Patterns
```bash
# Find similar error patterns from history
find_similar_error_patterns() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    
    echo "**Similar Error Patterns:**"
    echo ""
    
    # Check error history
    if [ -f ".ai_workflow/logs/error_history.log" ]; then
        local SIMILAR_ERRORS=$(grep -i "$(echo "$ERROR_MESSAGE" | cut -d' ' -f1-3)" ".ai_workflow/logs/error_history.log" | head -3)
        if [ -n "$SIMILAR_ERRORS" ]; then
            echo "$SIMILAR_ERRORS"
        else
            echo "- No similar errors found in history"
        fi
    else
        echo "- No error history available"
    fi
    
    # Check for common error patterns
    local ERROR_KEYWORDS=$(echo "$ERROR_MESSAGE" | tr ' ' '\n' | grep -E '^[a-zA-Z]{4,}$' | head -3 | tr '\n' ' ')
    echo "- Key error terms: $ERROR_KEYWORDS"
    echo "- Error category matches: Common $(classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE") errors"
}
```

#### Finalize Error Analysis Report
```bash
# Finalize error analysis report
finalize_error_analysis_report() {
    local ANALYSIS_OUTPUT="$1"
    
    cat >> "$ANALYSIS_OUTPUT" << EOF

## Summary and Next Steps

### Analysis Summary
- **Error Category**: $(classify_error_category "$(head -10 "$ANALYSIS_OUTPUT" | grep "Error Message" | cut -d':' -f2-)" "")
- **Severity Level**: $(classify_error_severity "$(head -10 "$ANALYSIS_OUTPUT" | grep "Error Message" | cut -d':' -f2-)" "")
- **Correction Strategy**: $(select_correction_strategy "$(classify_error_category "$(head -10 "$ANALYSIS_OUTPUT" | grep "Error Message" | cut -d':' -f2-)" "")" "$(classify_error_type "$(head -10 "$ANALYSIS_OUTPUT" | grep "Error Message" | cut -d':' -f2-)" "")" "$(classify_error_severity "$(head -10 "$ANALYSIS_OUTPUT" | grep "Error Message" | cut -d':' -f2-)" "")")

### Recommended Next Steps
1. **Execute correction strategy** using determined approach
2. **Monitor correction progress** and validate results
3. **Escalate if necessary** based on defined criteria
4. **Document resolution** for future reference

### Success Criteria
- Error no longer occurs during execution
- System returns to stable state
- Workflow can continue or complete successfully
- No regression in functionality

### Monitoring Requirements
- **Immediate**: Monitor correction application
- **Short-term**: Verify error doesn't reoccur
- **Long-term**: Track error patterns and prevention

---
*Analysis completed by AI Framework Error Management System*
*Generated on: $(date)*
*For use by: attempt_auto_correction.md and escalate_to_user.md*
EOF
    
    echo "Error analysis report finalized"
}
```

### Utility Functions for Error Analysis

#### Get Error Category
```bash
# Get error category for export
get_error_category() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    
    classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE"
}
```

#### Get Error Severity
```bash
# Get error severity for export
get_error_severity() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    
    classify_error_severity "$ERROR_MESSAGE" "$ERROR_CODE"
}
```

#### Get Correction Strategy
```bash
# Get correction strategy for export
get_correction_strategy() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    
    local ERROR_CATEGORY=$(classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE")
    local ERROR_TYPE=$(classify_error_type "$ERROR_MESSAGE" "$ERROR_CODE")
    local ERROR_SEVERITY=$(classify_error_severity "$ERROR_MESSAGE" "$ERROR_CODE")
    
    select_correction_strategy "$ERROR_CATEGORY" "$ERROR_TYPE" "$ERROR_SEVERITY"
}
```

#### Log Error Analysis
```bash
# Log error analysis for future reference
log_error_analysis() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local ANALYSIS_FILE="$3"
    
    local ERROR_CATEGORY=$(classify_error_category "$ERROR_MESSAGE" "$ERROR_CODE")
    local ERROR_SEVERITY=$(classify_error_severity "$ERROR_MESSAGE" "$ERROR_CODE")
    
    # Log to error history
    echo "$(date): $ERROR_CATEGORY ($ERROR_SEVERITY) - $ERROR_MESSAGE - Analysis: $ANALYSIS_FILE" >> ".ai_workflow/logs/error_history.log"
}
```

### Integration Functions

#### Integrate with Workflow State
```bash
# Integrate error analysis with workflow state
integrate_error_with_workflow_state() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local ANALYSIS_FILE="$3"
    
    if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ]; then
        source .ai_workflow/workflows/common/manage_workflow_state.md
        log_error "$CURRENT_TASK" "$ERROR_MESSAGE" "1" "Analysis completed: $ANALYSIS_FILE"
    fi
}
```

#### Integrate with Rollback System
```bash
# Integrate error analysis with rollback system
integrate_error_with_rollback() {
    local ERROR_MESSAGE="$1"
    local ERROR_CODE="$2"
    local ANALYSIS_FILE="$3"
    
    local ERROR_SEVERITY=$(classify_error_severity "$ERROR_MESSAGE" "$ERROR_CODE")
    
    if [ "$ERROR_SEVERITY" = "CRITICAL" ] || [ "$ERROR_SEVERITY" = "HIGH" ]; then
        # Create emergency rollback point
        source .ai_workflow/workflows/common/rollback_changes.md
        create_rollback_point "error_analysis_$(date +%Y%m%d_%H%M%S)" "Error analysis for: $ERROR_MESSAGE"
    fi
}
```

## Integration with Framework

### With Auto-Correction System
- Provides detailed error analysis for correction strategies
- Feeds correction recommendations to auto-correction workflow
- Supplies success criteria for validation

### With User Escalation
- Provides comprehensive error reports for user review
- Identifies when manual intervention is required
- Supplies troubleshooting guidance for users

### With Loop Prevention
- Tracks error patterns and frequencies
- Identifies potential infinite loop scenarios
- Provides data for loop prevention strategies

### With Rollback System
- Triggers rollback for critical errors
- Provides context for rollback decisions
- Supplies recovery recommendations

## Usage Examples

### Basic Error Analysis
```bash
# Analyze syntax error
analyze_error_context "Syntax error: unexpected token" "1" "File: script.js, Line: 45" "3"

# Analyze tool error
analyze_error_context "Abstract tool validation failed" "2" "Tool: git.add, File: missing.txt" "1"

# Analyze network error
analyze_error_context "Connection timeout" "124" "URL: https://api.example.com" "2"
```

### Integration Usage
```bash
# Analyze error with full integration
ERROR_MSG="File not found: config.json"
analyze_error_context "$ERROR_MSG" "2" "Task: setup_config" "1"

# Use analysis results
if [ "$ERROR_CATEGORY" = "FILESYSTEM_ERROR" ]; then
    echo "Proceeding with file system correction"
fi
```

## Notes
- Error analysis is the foundation for all error recovery workflows
- Comprehensive context capture enables intelligent correction strategies
- Integration with all framework components for complete error handling
- Categorization system supports automated decision making
- Analysis results are exported for use by other error management workflows
- Historical error tracking enables pattern recognition and prevention