# Escalate to User

## Overview
This workflow handles escalation of errors and issues to the user when automatic correction fails or when manual intervention is required. It provides comprehensive context, clear explanations, and actionable guidance for user resolution.

## Workflow Instructions

### For AI Agents
When escalating to user:

1. **Provide comprehensive context** about the error and attempted corrections
2. **Explain the situation clearly** in non-technical terms when possible
3. **Offer actionable recommendations** for user resolution
4. **Maintain detailed logs** for debugging and future reference
5. **Establish clear next steps** for user guidance

### Escalation Functions

#### Main Escalation Function
```bash
# Main escalation function
escalate_to_user() {
    local ERROR_ANALYSIS_FILE="$1"
    local CORRECTION_ATTEMPTS_FILE="$2"
    local ESCALATION_REASON="$3"
    local OUTPUT_FILE="$4"
    
    if [ -z "$ERROR_ANALYSIS_FILE" ] || [ ! -f "$ERROR_ANALYSIS_FILE" ]; then
        echo "ERROR: Valid error analysis file is required"
        return 1
    fi
    
    if [ -z "$ESCALATION_REASON" ]; then
        ESCALATION_REASON="Auto-correction failed"
    fi
    
    if [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE=".ai_workflow/escalations/escalation_$(date +%Y%m%d_%H%M%S).md"
    fi
    
    echo "Escalating to user..."
    echo "Error Analysis: $ERROR_ANALYSIS_FILE"
    echo "Correction Attempts: $CORRECTION_ATTEMPTS_FILE"
    echo "Escalation Reason: $ESCALATION_REASON"
    echo "Output File: $OUTPUT_FILE"
    
    # Initialize escalation report
    init_escalation_report "$OUTPUT_FILE" "$ERROR_ANALYSIS_FILE" "$CORRECTION_ATTEMPTS_FILE" "$ESCALATION_REASON"
    
    # Gather escalation context
    gather_escalation_context "$OUTPUT_FILE" "$ERROR_ANALYSIS_FILE" "$CORRECTION_ATTEMPTS_FILE"
    
    # Generate user explanation
    generate_user_explanation "$OUTPUT_FILE" "$ERROR_ANALYSIS_FILE" "$CORRECTION_ATTEMPTS_FILE"
    
    # Provide resolution guidance
    provide_resolution_guidance "$OUTPUT_FILE" "$ERROR_ANALYSIS_FILE" "$CORRECTION_ATTEMPTS_FILE"
    
    # Create action plan for user
    create_user_action_plan "$OUTPUT_FILE" "$ERROR_ANALYSIS_FILE"
    
    # Finalize escalation report
    finalize_escalation_report "$OUTPUT_FILE"
    
    # Display escalation to user
    display_escalation_to_user "$OUTPUT_FILE"
    
    echo "Escalation completed: $OUTPUT_FILE"
}
```

#### Initialize Escalation Report
```bash
# Initialize escalation report
init_escalation_report() {
    local OUTPUT_FILE="$1"
    local ERROR_ANALYSIS_FILE="$2"
    local CORRECTION_ATTEMPTS_FILE="$3"
    local ESCALATION_REASON="$4"
    
    # Create escalation directory
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    
    cat > "$OUTPUT_FILE" << EOF
# User Escalation Report

## Escalation Information
- **Escalation ID**: $(basename "$OUTPUT_FILE" .md)
- **Escalation Time**: $(date)
- **Escalation Reason**: $ESCALATION_REASON
- **Error Analysis Source**: $ERROR_ANALYSIS_FILE
- **Correction Attempts**: $CORRECTION_ATTEMPTS_FILE

## Issue Summary
*Analysis in progress...*

## What Happened
*Context gathering in progress...*

## What We Tried
*Correction attempts summary in progress...*

## What You Need to Do
*Resolution guidance in progress...*

## Action Plan
*User action plan in progress...*

EOF
    
    echo "Escalation report initialized: $OUTPUT_FILE"
}
```

#### Gather Escalation Context
```bash
# Gather escalation context
gather_escalation_context() {
    local OUTPUT_FILE="$1"
    local ERROR_ANALYSIS_FILE="$2"
    local CORRECTION_ATTEMPTS_FILE="$3"
    
    echo "Gathering escalation context..."
    
    # Extract key information from error analysis
    local ERROR_MESSAGE=$(grep "Error Message:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    local ERROR_CATEGORY=$(grep "Category:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    local ERROR_SEVERITY=$(grep "Severity:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    local ROOT_CAUSE=$(grep -A 3 "Primary Root Cause" "$ERROR_ANALYSIS_FILE" | tail -3 | head -1)
    
    # Extract correction attempts if available
    local ATTEMPTS_MADE=0
    local CORRECTION_SUCCESS="false"
    
    if [ -f "$CORRECTION_ATTEMPTS_FILE" ]; then
        ATTEMPTS_MADE=$(grep -c "Correction Attempt" "$CORRECTION_ATTEMPTS_FILE" || echo "0")
        CORRECTION_SUCCESS=$(grep "Correction Status:" "$CORRECTION_ATTEMPTS_FILE" | cut -d':' -f2- | sed 's/^ *//' || echo "false")
    fi
    
    # Get current system state
    local SYSTEM_STATE=$(capture_current_system_state)
    local AFFECTED_FILES=$(identify_affected_files "$ERROR_MESSAGE")
    local WORKFLOW_CONTEXT=$(get_workflow_context)
    
    # Update escalation report with context
    cat >> "$OUTPUT_FILE" << EOF
### Issue Summary

**What went wrong:** $ERROR_MESSAGE

**Impact Level:** $ERROR_SEVERITY

**Root Cause:** $ROOT_CAUSE

**Correction Attempts:** $ATTEMPTS_MADE attempts made, Status: $CORRECTION_SUCCESS

### Current System State

#### Environment Information
- **Working Directory**: $(pwd)
- **Current User**: $(whoami)
- **System Time**: $(date)
- **Git Status**: $(git status --porcelain 2>/dev/null | wc -l) modified files

#### Workflow Context
$WORKFLOW_CONTEXT

#### Affected Files
$AFFECTED_FILES

#### System Resources
- **Memory Usage**: $(free -h | grep Mem | awk '{print $3"/"$2}' 2>/dev/null || echo "Not available")
- **Disk Space**: $(df -h . | tail -1 | awk '{print $4" available"}' 2>/dev/null || echo "Not available")

EOF
    
    echo "Escalation context gathered"
}
```

#### Generate User Explanation
```bash
# Generate user explanation
generate_user_explanation() {
    local OUTPUT_FILE="$1"
    local ERROR_ANALYSIS_FILE="$2"
    local CORRECTION_ATTEMPTS_FILE="$3"
    
    echo "Generating user explanation..."
    
    # Extract error details
    local ERROR_CATEGORY=$(grep "Category:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    local ERROR_SEVERITY=$(grep "Severity:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    
    cat >> "$OUTPUT_FILE" << EOF
## What Happened

### In Simple Terms
$(explain_error_in_simple_terms "$ERROR_CATEGORY" "$ERROR_SEVERITY")

### Technical Details
$(provide_technical_details "$ERROR_ANALYSIS_FILE")

### Timeline of Events
$(generate_event_timeline "$ERROR_ANALYSIS_FILE" "$CORRECTION_ATTEMPTS_FILE")

EOF
    
    echo "User explanation generated"
}
```

#### Explain Error in Simple Terms
```bash
# Explain error in simple terms
explain_error_in_simple_terms() {
    local ERROR_CATEGORY="$1"
    local ERROR_SEVERITY="$2"
    
    echo "**Non-technical explanation:**"
    echo ""
    
    case "$ERROR_CATEGORY" in
        "SYNTAX_ERROR")
            echo "The system found a formatting error in one of the code files. It's like having a typo in a document that prevents it from being read properly."
            echo ""
            echo "**Severity:** $(get_severity_explanation "$ERROR_SEVERITY")"
            echo "**Impact:** The workflow cannot continue until this formatting issue is fixed."
            ;;
        "FILESYSTEM_ERROR")
            echo "The system couldn't find a file or folder it was looking for, or doesn't have permission to access it."
            echo ""
            echo "**Severity:** $(get_severity_explanation "$ERROR_SEVERITY")"
            echo "**Impact:** The workflow is stuck because it can't access the files it needs."
            ;;
        "NETWORK_ERROR")
            echo "The system couldn't connect to a required online service or the connection timed out."
            echo ""
            echo "**Severity:** $(get_severity_explanation "$ERROR_SEVERITY")"
            echo "**Impact:** The workflow can't continue without this network connection."
            ;;
        "DEPENDENCY_ERROR")
            echo "The system is missing a required component or library that it needs to function properly."
            echo ""
            echo "**Severity:** $(get_severity_explanation "$ERROR_SEVERITY")"
            echo "**Impact:** The workflow can't run without this missing component."
            ;;
        "TOOL_ERROR")
            echo "There's an issue with one of the internal tools the system uses to complete tasks."
            echo ""
            echo "**Severity:** $(get_severity_explanation "$ERROR_SEVERITY")"
            echo "**Impact:** The workflow can't use this tool until the issue is resolved."
            ;;
        "CONFIGURATION_ERROR")
            echo "The system's configuration settings are incorrect or missing."
            echo ""
            echo "**Severity:** $(get_severity_explanation "$ERROR_SEVERITY")"
            echo "**Impact:** The workflow can't proceed with incorrect settings."
            ;;
        "RUNTIME_ERROR")
            echo "The system encountered an unexpected error while running. This is like a program crashing unexpectedly."
            echo ""
            echo "**Severity:** $(get_severity_explanation "$ERROR_SEVERITY")"
            echo "**Impact:** The workflow stopped working and needs to be restarted or fixed."
            ;;
        *)
            echo "The system encountered an unexpected issue that it couldn't identify or resolve automatically."
            echo ""
            echo "**Severity:** $(get_severity_explanation "$ERROR_SEVERITY")"
            echo "**Impact:** The workflow cannot continue until this issue is manually resolved."
            ;;
    esac
}
```

#### Get Severity Explanation
```bash
# Get severity explanation
get_severity_explanation() {
    local ERROR_SEVERITY="$1"
    
    case "$ERROR_SEVERITY" in
        "CRITICAL")
            echo "Critical - This completely stops the workflow and needs immediate attention"
            ;;
        "HIGH")
            echo "High - This prevents the workflow from continuing and should be fixed soon"
            ;;
        "MEDIUM")
            echo "Medium - This may cause issues but the workflow might be able to continue"
            ;;
        "LOW")
            echo "Low - This is a minor issue that doesn't stop the workflow"
            ;;
        *)
            echo "Unknown - The severity level couldn't be determined"
            ;;
    esac
}
```

#### Provide Technical Details
```bash
# Provide technical details
provide_technical_details() {
    local ERROR_ANALYSIS_FILE="$1"
    
    echo "**Technical Details:**"
    echo ""
    echo "- **Error Category:** $(grep "Category:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')"
    echo "- **Error Message:** $(grep "Error Message:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')"
    echo "- **Error Code:** $(grep "Error Code:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')"
    echo "- **Task Context:** $(grep "Execution Context:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')"
    echo ""
    echo "**Root Cause Analysis:**"
    echo "$(grep -A 5 "Primary Root Cause" "$ERROR_ANALYSIS_FILE" | tail -5 | head -1)"
}
```

#### Generate Event Timeline
```bash
# Generate event timeline
generate_event_timeline() {
    local ERROR_ANALYSIS_FILE="$1"
    local CORRECTION_ATTEMPTS_FILE="$2"
    
    echo "**Timeline of Events:**"
    echo ""
    echo "1. **Error Detected:** $(grep "Timestamp:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')"
    echo "   - System encountered the error during workflow execution"
    echo ""
    echo "2. **Error Analysis:** $(date -d '1 minute ago' '+%Y-%m-%d %H:%M:%S')"
    echo "   - System analyzed the error and identified the root cause"
    echo ""
    
    if [ -f "$CORRECTION_ATTEMPTS_FILE" ]; then
        local ATTEMPTS=$(grep -c "Correction Attempt" "$CORRECTION_ATTEMPTS_FILE" || echo "0")
        echo "3. **Auto-Correction Attempted:** $(date -d '30 seconds ago' '+%Y-%m-%d %H:%M:%S')"
        echo "   - System made $ATTEMPTS automatic correction attempts"
        echo "   - All attempts failed, escalating to user"
        echo ""
    fi
    
    echo "4. **User Escalation:** $(date '+%Y-%m-%d %H:%M:%S')"
    echo "   - System escalated the issue for manual resolution"
}
```

#### Provide Resolution Guidance
```bash
# Provide resolution guidance
provide_resolution_guidance() {
    local OUTPUT_FILE="$1"
    local ERROR_ANALYSIS_FILE="$2"
    local CORRECTION_ATTEMPTS_FILE="$3"
    
    echo "Providing resolution guidance..."
    
    local ERROR_CATEGORY=$(grep "Category:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    local ERROR_MESSAGE=$(grep "Error Message:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    
    cat >> "$OUTPUT_FILE" << EOF
## What We Tried

### Automatic Correction Attempts
$(summarize_correction_attempts "$CORRECTION_ATTEMPTS_FILE")

### Why Automatic Correction Failed
$(explain_correction_failure "$ERROR_CATEGORY" "$CORRECTION_ATTEMPTS_FILE")

## What You Need to Do

### Immediate Actions
$(provide_immediate_actions "$ERROR_CATEGORY" "$ERROR_MESSAGE")

### Detailed Resolution Steps
$(provide_detailed_resolution_steps "$ERROR_CATEGORY" "$ERROR_MESSAGE")

### Verification Steps
$(provide_verification_steps "$ERROR_CATEGORY" "$ERROR_MESSAGE")

### Prevention Measures
$(provide_prevention_measures "$ERROR_CATEGORY" "$ERROR_MESSAGE")

EOF
    
    echo "Resolution guidance provided"
}
```

#### Summarize Correction Attempts
```bash
# Summarize correction attempts
summarize_correction_attempts() {
    local CORRECTION_ATTEMPTS_FILE="$1"
    
    if [ -f "$CORRECTION_ATTEMPTS_FILE" ]; then
        local ATTEMPTS=$(grep -c "Correction Attempt" "$CORRECTION_ATTEMPTS_FILE" || echo "0")
        local SUCCESS=$(grep "SUCCESS" "$CORRECTION_ATTEMPTS_FILE" | wc -l || echo "0")
        local FAILED=$(grep "FAILED" "$CORRECTION_ATTEMPTS_FILE" | wc -l || echo "0")
        
        echo "**Correction Attempts Summary:**"
        echo "- Total attempts made: $ATTEMPTS"
        echo "- Successful attempts: $SUCCESS"
        echo "- Failed attempts: $FAILED"
        echo ""
        echo "**Strategies Tried:**"
        grep -o "Strategy: [^-]*" "$CORRECTION_ATTEMPTS_FILE" | head -5 | sed 's/^/- /'
    else
        echo "**No automatic correction attempts were made.**"
        echo "- The error was immediately escalated to user"
        echo "- This indicates the error requires manual intervention"
    fi
}
```

#### Explain Correction Failure
```bash
# Explain correction failure
explain_correction_failure() {
    local ERROR_CATEGORY="$1"
    local CORRECTION_ATTEMPTS_FILE="$2"
    
    echo "**Why Automatic Correction Failed:**"
    echo ""
    
    case "$ERROR_CATEGORY" in
        "SYNTAX_ERROR")
            echo "- The syntax error was too complex for automatic pattern matching"
            echo "- Manual review is needed to understand the intended code structure"
            echo "- The error may be part of a larger logic issue"
            ;;
        "FILESYSTEM_ERROR")
            echo "- The system couldn't determine the correct file path or permissions"
            echo "- Manual intervention is needed to create or locate the missing files"
            echo "- File system permissions may need administrative access"
            ;;
        "NETWORK_ERROR")
            echo "- The network issue persisted beyond automatic retry attempts"
            echo "- The service may be permanently unavailable or misconfigured"
            echo "- Network settings may need manual adjustment"
            ;;
        "DEPENDENCY_ERROR")
            echo "- The missing dependency couldn't be automatically installed"
            echo "- Manual package installation or configuration is required"
            echo "- Version compatibility issues may need resolution"
            ;;
        "TOOL_ERROR")
            echo "- The tool configuration or parameters are incorrect"
            echo "- Manual review of tool settings is required"
            echo "- The tool may need to be reinstalled or updated"
            ;;
        *)
            echo "- The error type requires human judgment to resolve"
            echo "- Automatic correction strategies were insufficient"
            echo "- Manual analysis and intervention are necessary"
            ;;
    esac
}
```

#### Provide Immediate Actions
```bash
# Provide immediate actions
provide_immediate_actions() {
    local ERROR_CATEGORY="$1"
    local ERROR_MESSAGE="$2"
    
    echo "**Immediate Actions (Do these first):**"
    echo ""
    
    case "$ERROR_CATEGORY" in
        "SYNTAX_ERROR")
            echo "1. **Review the error message** for the specific file and line number"
            echo "2. **Open the problematic file** in your code editor"
            echo "3. **Check for obvious syntax issues** like missing brackets, quotes, or semicolons"
            echo "4. **Save the file** after making corrections"
            echo "5. **Test the fix** by running the workflow again"
            ;;
        "FILESYSTEM_ERROR")
            echo "1. **Check if the file exists** at the specified location"
            echo "2. **Verify file permissions** using 'ls -la' command"
            echo "3. **Create missing directories** if needed using 'mkdir -p'"
            echo "4. **Check file paths** for typos or incorrect locations"
            echo "5. **Ensure you have proper access** to the file system"
            ;;
        "NETWORK_ERROR")
            echo "1. **Check your internet connection** is working"
            echo "2. **Verify the service URL** is correct and accessible"
            echo "3. **Check for firewall or proxy issues** that might block access"
            echo "4. **Try accessing the service** manually in a browser"
            echo "5. **Wait and retry** as the service might be temporarily down"
            ;;
        "DEPENDENCY_ERROR")
            echo "1. **Check what dependency is missing** from the error message"
            echo "2. **Verify your package manager** (npm, pip, etc.) is working"
            echo "3. **Try installing the dependency** manually"
            echo "4. **Check version compatibility** with your project"
            echo "5. **Update your package lists** if needed"
            ;;
        "TOOL_ERROR")
            echo "1. **Review the tool call parameters** in the error message"
            echo "2. **Check if the tool is properly installed** and available"
            echo "3. **Verify the tool configuration** is correct"
            echo "4. **Try running the tool** manually to test it"
            echo "5. **Check for tool updates** or reinstallation needs"
            ;;
        *)
            echo "1. **Document the exact error** for future reference"
            echo "2. **Check system logs** for additional context"
            echo "3. **Verify system resources** are available"
            echo "4. **Try restarting the workflow** from the beginning"
            echo "5. **Contact support** if the issue persists"
            ;;
    esac
}
```

#### Provide Detailed Resolution Steps
```bash
# Provide detailed resolution steps
provide_detailed_resolution_steps() {
    local ERROR_CATEGORY="$1"
    local ERROR_MESSAGE="$2"
    
    echo "**Detailed Resolution Steps:**"
    echo ""
    
    case "$ERROR_CATEGORY" in
        "SYNTAX_ERROR")
            echo "**Step 1: Locate the Error**"
            echo "- Find the file and line number mentioned in the error"
            echo "- Use your editor's 'Go to Line' feature to navigate quickly"
            echo ""
            echo "**Step 2: Understand the Error**"
            echo "- Read the error message carefully to understand what's wrong"
            echo "- Look for missing or mismatched brackets, quotes, or punctuation"
            echo "- Check for typos in keywords or function names"
            echo ""
            echo "**Step 3: Fix the Error**"
            echo "- Make the necessary corrections to the code"
            echo "- Ensure proper indentation and formatting"
            echo "- Use syntax highlighting to identify issues"
            echo ""
            echo "**Step 4: Test the Fix**"
            echo "- Save the file and run the workflow again"
            echo "- Check that the error is resolved"
            echo "- Verify the code works as expected"
            ;;
        "FILESYSTEM_ERROR")
            echo "**Step 1: Identify the Problem**"
            echo "- Check what file or directory is missing or inaccessible"
            echo "- Verify the full path mentioned in the error"
            echo ""
            echo "**Step 2: Check File System**"
            echo "- Use 'ls -la' to list files and their permissions"
            echo "- Navigate to the parent directory to ensure it exists"
            echo "- Check for typos in file names or paths"
            echo ""
            echo "**Step 3: Fix the Issue**"
            echo "- Create missing directories: mkdir -p /path/to/directory"
            echo "- Create missing files: touch /path/to/file"
            echo "- Fix permissions: chmod 644 /path/to/file"
            echo ""
            echo "**Step 4: Verify the Fix**"
            echo "- Test file access: cat /path/to/file"
            echo "- Run the workflow again to confirm resolution"
            ;;
        "NETWORK_ERROR")
            echo "**Step 1: Test Connectivity**"
            echo "- Check internet connection: ping google.com"
            echo "- Test the specific service: curl -I [service-url]"
            echo ""
            echo "**Step 2: Diagnose the Issue**"
            echo "- Check for DNS resolution: nslookup [service-url]"
            echo "- Verify no firewall blocking: check firewall settings"
            echo "- Test with different network if possible"
            echo ""
            echo "**Step 3: Resolve the Problem**"
            echo "- Wait for service to come back online"
            echo "- Configure proxy settings if needed"
            echo "- Update network configuration if required"
            echo ""
            echo "**Step 4: Retry the Operation**"
            echo "- Run the workflow again once connectivity is restored"
            echo "- Monitor for recurring network issues"
            ;;
        *)
            echo "**Step 1: Gather Information**"
            echo "- Document the exact error message and context"
            echo "- Note any patterns or conditions that trigger the error"
            echo ""
            echo "**Step 2: Research the Issue**"
            echo "- Search for similar errors in documentation or forums"
            echo "- Check if others have encountered this problem"
            echo ""
            echo "**Step 3: Apply Solutions**"
            echo "- Try suggested fixes from research"
            echo "- Make incremental changes and test each one"
            echo ""
            echo "**Step 4: Verify and Document**"
            echo "- Confirm the issue is resolved"
            echo "- Document the solution for future reference"
            ;;
    esac
}
```

#### Provide Verification Steps
```bash
# Provide verification steps
provide_verification_steps() {
    local ERROR_CATEGORY="$1"
    local ERROR_MESSAGE="$2"
    
    echo "**Verification Steps (How to confirm it's fixed):**"
    echo ""
    echo "1. **Test the Fix**"
    echo "   - Run the workflow again from the point where it failed"
    echo "   - Check that the error no longer occurs"
    echo ""
    echo "2. **Verify System State**"
    echo "   - Ensure no new errors were introduced"
    echo "   - Check that all files and configurations are correct"
    echo ""
    echo "3. **Monitor Performance**"
    echo "   - Watch for any performance degradation"
    echo "   - Ensure the fix doesn't cause other issues"
    echo ""
    echo "4. **Document the Resolution**"
    echo "   - Record what was done to fix the issue"
    echo "   - Update any relevant documentation"
    echo ""
    echo "5. **Test Edge Cases**"
    echo "   - Try different scenarios to ensure robustness"
    echo "   - Verify the fix works under various conditions"
}
```

#### Create User Action Plan
```bash
# Create user action plan
create_user_action_plan() {
    local OUTPUT_FILE="$1"
    local ERROR_ANALYSIS_FILE="$2"
    
    echo "Creating user action plan..."
    
    local ERROR_CATEGORY=$(grep "Category:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    local ERROR_SEVERITY=$(grep "Severity:" "$ERROR_ANALYSIS_FILE" | cut -d':' -f2- | sed 's/^ *//')
    
    cat >> "$OUTPUT_FILE" << EOF
## Action Plan

### Priority Level
$(determine_priority_level "$ERROR_SEVERITY")

### Estimated Time
$(estimate_resolution_time "$ERROR_CATEGORY" "$ERROR_SEVERITY")

### Required Skills
$(identify_required_skills "$ERROR_CATEGORY")

### Step-by-Step Plan
$(create_step_by_step_plan "$ERROR_CATEGORY")

### Success Criteria
$(define_success_criteria "$ERROR_CATEGORY")

### Rollback Plan
$(create_rollback_plan "$ERROR_CATEGORY")

### When to Get Help
$(define_escalation_criteria "$ERROR_CATEGORY" "$ERROR_SEVERITY")

EOF
    
    echo "User action plan created"
}
```

#### Determine Priority Level
```bash
# Determine priority level
determine_priority_level() {
    local ERROR_SEVERITY="$1"
    
    case "$ERROR_SEVERITY" in
        "CRITICAL")
            echo "**🚨 URGENT - Handle immediately**"
            echo "- This error completely blocks the workflow"
            echo "- Immediate attention required"
            echo "- Consider this your top priority"
            ;;
        "HIGH")
            echo "**⚠️ HIGH - Handle within 24 hours**"
            echo "- This error prevents workflow completion"
            echo "- Should be addressed soon"
            echo "- May block other dependent tasks"
            ;;
        "MEDIUM")
            echo "**📋 MEDIUM - Handle within a few days**"
            echo "- This error causes issues but isn't blocking"
            echo "- Can be scheduled with other tasks"
            echo "- Monitor for any escalation"
            ;;
        "LOW")
            echo "**📝 LOW - Handle when convenient**"
            echo "- This error is minor and doesn't block work"
            echo "- Can be addressed in regular maintenance"
            echo "- Keep an eye on it but not urgent"
            ;;
        *)
            echo "**❓ UNKNOWN - Assess and prioritize**"
            echo "- Priority level needs to be determined"
            echo "- Review the error details to assess impact"
            echo "- Start with medium priority until assessed"
            ;;
    esac
}
```

#### Estimate Resolution Time
```bash
# Estimate resolution time
estimate_resolution_time() {
    local ERROR_CATEGORY="$1"
    local ERROR_SEVERITY="$2"
    
    echo "**Estimated Resolution Time:**"
    
    case "$ERROR_CATEGORY" in
        "SYNTAX_ERROR")
            echo "- **Simple fix**: 5-15 minutes"
            echo "- **Complex fix**: 30-60 minutes"
            echo "- **Investigation needed**: 1-2 hours"
            ;;
        "FILESYSTEM_ERROR")
            echo "- **File creation**: 2-5 minutes"
            echo "- **Permission fix**: 5-10 minutes"
            echo "- **Path restructure**: 30-60 minutes"
            ;;
        "NETWORK_ERROR")
            echo "- **Service recovery**: 5-30 minutes (wait time)"
            echo "- **Configuration fix**: 15-45 minutes"
            echo "- **Network troubleshooting**: 1-3 hours"
            ;;
        "DEPENDENCY_ERROR")
            echo "- **Package installation**: 10-30 minutes"
            echo "- **Version resolution**: 30-90 minutes"
            echo "- **Configuration fix**: 15-45 minutes"
            ;;
        *)
            echo "- **Simple fix**: 15-30 minutes"
            echo "- **Complex fix**: 1-3 hours"
            echo "- **Research required**: 2-4 hours"
            ;;
    esac
}
```

#### Display Escalation to User
```bash
# Display escalation to user
display_escalation_to_user() {
    local OUTPUT_FILE="$1"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "                              🚨 USER INTERVENTION REQUIRED 🚨"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "The AI system has encountered an error that requires your attention."
    echo "A detailed escalation report has been generated for your review."
    echo ""
    echo "📋 ESCALATION REPORT: $OUTPUT_FILE"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "QUICK SUMMARY:"
    echo "$(head -20 "$OUTPUT_FILE" | grep -A 5 "What went wrong:" | head -3)"
    echo ""
    echo "📖 Please review the full report above for detailed resolution steps."
    echo ""
    echo "❓ Need help? Check the 'When to Get Help' section in the report."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}
```

#### Finalize Escalation Report
```bash
# Finalize escalation report
finalize_escalation_report() {
    local OUTPUT_FILE="$1"
    
    cat >> "$OUTPUT_FILE" << EOF

## Summary and Next Steps

### Quick Reference
- **Issue**: Review the "What Happened" section above
- **Actions**: Follow the immediate actions in "What You Need to Do"
- **Timeline**: Check estimated resolution time in Action Plan
- **Help**: Use escalation criteria if you need assistance

### After Resolution
1. **Test the fix** thoroughly to ensure it works
2. **Run the workflow again** to confirm resolution
3. **Document the solution** for future reference
4. **Update prevention measures** if applicable

### Framework Integration
- **Workflow State**: The framework is paused and waiting for resolution
- **Rollback Available**: Use rollback procedures if needed
- **Monitoring**: The system will log resolution attempts
- **Future Prevention**: Consider implementing preventive measures

### Contact Information
- **System Logs**: Check .ai_workflow/logs/ for additional details
- **Error History**: Review .ai_workflow/logs/error_history.log
- **Escalation History**: Check .ai_workflow/escalations/ for past issues

---
*Escalation completed by AI Framework Error Management System*
*Generated on: $(date)*
*Priority: $(determine_priority_level "$(grep "Severity:" "$OUTPUT_FILE" | cut -d':' -f2- | sed 's/^ *//' | head -1)")*
*Estimated Resolution: $(estimate_resolution_time "$(grep "Category:" "$OUTPUT_FILE" | cut -d':' -f2- | sed 's/^ *//' | head -1)" "$(grep "Severity:" "$OUTPUT_FILE" | cut -d':' -f2- | sed 's/^ *//' | head -1)")*
EOF
    
    echo "Escalation report finalized"
}
```

### Utility Functions

#### Capture Current System State
```bash
# Capture current system state
capture_current_system_state() {
    echo "**Current System State:**"
    echo "- Working Directory: $(pwd)"
    echo "- Git Status: $(git status --porcelain 2>/dev/null | wc -l) modified files"
    echo "- System Load: $(uptime | awk -F'load average:' '{print $2}' | sed 's/^[[:space:]]*//' 2>/dev/null || echo "Not available")"
    echo "- Available Memory: $(free -h | grep Mem | awk '{print $7}' 2>/dev/null || echo "Not available")"
}
```

#### Identify Affected Files
```bash
# Identify affected files
identify_affected_files() {
    local ERROR_MESSAGE="$1"
    
    echo "**Affected Files:**"
    
    # Extract file paths from error message
    local FILES=$(echo "$ERROR_MESSAGE" | grep -oE '[^[:space:]]+\.(js|py|json|md|txt|sh|yml|yaml)' | head -5)
    
    if [ -n "$FILES" ]; then
        echo "$FILES" | while read -r file; do
            if [ -f "$file" ]; then
                echo "- $file (exists)"
            else
                echo "- $file (missing)"
            fi
        done
    else
        echo "- No specific files identified in error message"
    fi
}
```

#### Get Workflow Context
```bash
# Get workflow context
get_workflow_context() {
    echo "**Workflow Context:**"
    
    if [ -n "$CURRENT_TASK" ]; then
        echo "- Current Task: $CURRENT_TASK"
    fi
    
    if [ -n "$EXECUTION_ID" ]; then
        echo "- Execution ID: $EXECUTION_ID"
    fi
    
    if [ -f "$STATE_FILE" ]; then
        echo "- Last State: $(tail -1 "$STATE_FILE" | head -1)"
    fi
    
    echo "- Workflow Stage: Error Recovery"
}
```

#### Create Step-by-Step Plan
```bash
# Create step-by-step plan
create_step_by_step_plan() {
    local ERROR_CATEGORY="$1"
    
    echo "**Step-by-Step Execution Plan:**"
    echo ""
    echo "□ **Step 1: Preparation**"
    echo "  - Read this entire report carefully"
    echo "  - Gather any necessary tools or access"
    echo "  - Set aside adequate time for resolution"
    echo ""
    echo "□ **Step 2: Analysis**"
    echo "  - Review the error message and context"
    echo "  - Understand what the system was trying to do"
    echo "  - Identify the root cause of the issue"
    echo ""
    echo "□ **Step 3: Resolution**"
    echo "  - Follow the immediate actions listed above"
    echo "  - Apply the detailed resolution steps"
    echo "  - Make changes carefully and incrementally"
    echo ""
    echo "□ **Step 4: Testing**"
    echo "  - Test your fix thoroughly"
    echo "  - Run the workflow again to confirm resolution"
    echo "  - Check for any side effects or new issues"
    echo ""
    echo "□ **Step 5: Documentation**"
    echo "  - Document what you did to fix the issue"
    echo "  - Update any relevant configuration or documentation"
    echo "  - Consider preventive measures for the future"
}
```

#### Define Success Criteria
```bash
# Define success criteria
define_success_criteria() {
    local ERROR_CATEGORY="$1"
    
    echo "**Success Criteria (How to know it's fixed):**"
    echo ""
    echo "✅ **Primary Success Indicators:**"
    echo "  - The error no longer occurs when running the workflow"
    echo "  - The workflow completes successfully from start to finish"
    echo "  - No new errors are introduced by the fix"
    echo ""
    echo "✅ **Secondary Success Indicators:**"
    echo "  - System performance is not degraded"
    echo "  - All related functionality works as expected"
    echo "  - The fix is maintainable and doesn't create technical debt"
    echo ""
    echo "✅ **Validation Tests:**"
    echo "  - Run the workflow multiple times to ensure consistency"
    echo "  - Test edge cases and different scenarios"
    echo "  - Verify the fix works in different environments if applicable"
}
```

#### Create Rollback Plan
```bash
# Create rollback plan
create_rollback_plan() {
    local ERROR_CATEGORY="$1"
    
    echo "**Rollback Plan (If something goes wrong):**"
    echo ""
    echo "🔄 **Before Making Changes:**"
    echo "  - Create a backup of any files you'll modify"
    echo "  - Note the current system state"
    echo "  - Consider using version control (git) to track changes"
    echo ""
    echo "🔄 **If the Fix Causes Problems:**"
    echo "  - Revert all changes you made"
    echo "  - Restore from backups if necessary"
    echo "  - Return to the original error state"
    echo ""
    echo "🔄 **Emergency Rollback:**"
    echo "  - Use the framework's rollback system if available"
    echo "  - Check .ai_workflow/rollback/ for restoration points"
    echo "  - Contact support if you can't restore the system"
}
```

#### Define Escalation Criteria
```bash
# Define escalation criteria
define_escalation_criteria() {
    local ERROR_CATEGORY="$1"
    local ERROR_SEVERITY="$2"
    
    echo "**When to Get Help:**"
    echo ""
    echo "🆘 **Escalate immediately if:**"
    echo "  - You don't understand the error or resolution steps"
    echo "  - The fix requires skills or access you don't have"
    echo "  - You're not confident about making the changes"
    echo "  - The issue affects production systems"
    echo ""
    echo "🆘 **Escalate after trying if:**"
    echo "  - The fix doesn't work after following all steps"
    echo "  - New errors appear after applying the fix"
    echo "  - The resolution takes longer than estimated"
    echo "  - The system becomes unstable"
    echo ""
    echo "🆘 **How to escalate:**"
    echo "  - Document exactly what you tried and the results"
    echo "  - Provide the full error messages and context"
    echo "  - Include this escalation report in your request"
    echo "  - Mention any deadlines or urgency factors"
}
```

## Integration with Framework

### With Error Analysis
- Uses comprehensive error analysis results
- Provides context-aware explanations
- Integrates with root cause analysis

### With Auto-Correction
- Receives failed correction attempts
- Explains why automatic fixes didn't work
- Provides manual alternatives

### With Loop Prevention
- Tracks escalation patterns
- Prevents repeated escalations
- Identifies systemic issues

### With Workflow State
- Maintains workflow context
- Provides continuation guidance
- Supports state recovery

## Usage Examples

### Basic Escalation
```bash
# Escalate after failed auto-correction
ERROR_ANALYSIS_FILE=".ai_workflow/error_analysis/error_analysis_20250714_100000.md"
CORRECTION_ATTEMPTS_FILE=".ai_workflow/corrections/correction_20250714_100000.md"
escalate_to_user "$ERROR_ANALYSIS_FILE" "$CORRECTION_ATTEMPTS_FILE" "Auto-correction failed"
```

### Immediate Escalation
```bash
# Escalate without correction attempts
ERROR_ANALYSIS_FILE=".ai_workflow/error_analysis/error_analysis_20250714_100000.md"
escalate_to_user "$ERROR_ANALYSIS_FILE" "" "Critical error requires immediate attention"
```

### Integrated Usage
```bash
# Full error handling flow
ERROR_MSG="Critical system error"
analyze_error_context "$ERROR_MSG" "255" "Critical failure" "1"

if [ "$ERROR_SEVERITY" = "CRITICAL" ]; then
    escalate_to_user "$ERROR_ANALYSIS_FILE" "" "Critical error - immediate escalation"
else
    attempt_auto_correction "$ERROR_ANALYSIS_FILE" 3
    if [ $? -ne 0 ]; then
        escalate_to_user "$ERROR_ANALYSIS_FILE" "$CORRECTION_OUTPUT" "Auto-correction failed"
    fi
fi
```

## Notes
- Escalation provides comprehensive context for user resolution
- Clear explanations bridge technical and non-technical understanding
- Step-by-step guidance reduces resolution time
- Integration with all error management workflows
- Maintains detailed audit trail for learning and improvement
- Designed to minimize user frustration and maximize resolution success