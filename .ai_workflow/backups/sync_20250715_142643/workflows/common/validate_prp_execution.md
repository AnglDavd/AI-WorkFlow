# Validate PRP Execution

## Overview
This workflow provides comprehensive validation for PRP execution, ensuring all tasks were completed successfully, abstract tools functioned properly, and the system is in a stable state. It performs end-to-end validation of the entire execution pipeline.

## Workflow Instructions

### For AI Agents
When performing PRP execution validation:

1. **Validate execution completeness** - Ensure all tasks were completed
2. **Validate system state** - Check git, files, and environment
3. **Validate tool functionality** - Test abstract tool system
4. **Generate validation report** - Document findings and recommendations

### Validation Functions

#### Main Validation Function
```bash
# Main PRP execution validation
validate_prp_execution() {
    local EXECUTION_ID="$1"
    local VALIDATION_LEVEL="$2"
    
    if [ -z "$EXECUTION_ID" ]; then
        EXECUTION_ID="${EXECUTION_ID:-unknown}"
    fi
    
    if [ -z "$VALIDATION_LEVEL" ]; then
        VALIDATION_LEVEL="full"
    fi
    
    echo "Starting PRP execution validation..."
    echo "Execution ID: $EXECUTION_ID"
    echo "Validation Level: $VALIDATION_LEVEL"
    
    # Initialize validation results
    local VALIDATION_RESULTS=".ai_workflow/validation_results_${EXECUTION_ID}.md"
    init_validation_report "$VALIDATION_RESULTS" "$EXECUTION_ID"
    
    # Perform validation checks
    local TOTAL_CHECKS=0
    local PASSED_CHECKS=0
    local FAILED_CHECKS=0
    
    # Basic validation checks
    validate_execution_state "$VALIDATION_RESULTS" && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || FAILED_CHECKS=$((FAILED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    validate_git_state "$VALIDATION_RESULTS" && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || FAILED_CHECKS=$((FAILED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    validate_file_integrity "$VALIDATION_RESULTS" && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || FAILED_CHECKS=$((FAILED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    validate_abstract_tools "$VALIDATION_RESULTS" && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || FAILED_CHECKS=$((FAILED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Extended validation for full level
    if [ "$VALIDATION_LEVEL" = "full" ]; then
        validate_environment_setup "$VALIDATION_RESULTS" && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || FAILED_CHECKS=$((FAILED_CHECKS + 1))
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        validate_project_structure "$VALIDATION_RESULTS" && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || FAILED_CHECKS=$((FAILED_CHECKS + 1))
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        validate_dependencies "$VALIDATION_RESULTS" && PASSED_CHECKS=$((PASSED_CHECKS + 1)) || FAILED_CHECKS=$((FAILED_CHECKS + 1))
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
    
    # Generate final report
    finalize_validation_report "$VALIDATION_RESULTS" "$TOTAL_CHECKS" "$PASSED_CHECKS" "$FAILED_CHECKS"
    
    echo "Validation completed: $PASSED_CHECKS/$TOTAL_CHECKS checks passed"
    echo "Results: $VALIDATION_RESULTS"
    
    # Return success if all checks passed
    if [ $FAILED_CHECKS -eq 0 ]; then
        return 0
    else
        return 1
    fi
}
```

#### Initialize Validation Report
```bash
# Initialize validation report
init_validation_report() {
    local REPORT_FILE="$1"
    local EXECUTION_ID="$2"
    
    cat > "$REPORT_FILE" << EOF
# PRP Execution Validation Report

## Execution Information
- **Execution ID**: $EXECUTION_ID
- **Validation Started**: $(date)
- **Validation Level**: $VALIDATION_LEVEL
- **Working Directory**: $(pwd)

## Validation Results Summary
| Check | Status | Details |
|-------|--------|---------|

## Detailed Results

EOF
    
    echo "Validation report initialized: $REPORT_FILE"
}
```

#### Validate Execution State
```bash
# Validate execution state
validate_execution_state() {
    local REPORT_FILE="$1"
    
    echo "Validating execution state..."
    
    # Check if state file exists
    if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ]; then
        local EXECUTION_STATUS=$(grep "Status" "$STATE_FILE" | cut -d':' -f2 | tr -d ' ')
        local CURRENT_TASK=$(grep "Current Task" "$STATE_FILE" | cut -d':' -f2 | tr -d ' ')
        
        # Add to report
        echo "| Execution State | ✅ PASS | Status: $EXECUTION_STATUS, Task: $CURRENT_TASK |" >> "$REPORT_FILE"
        
        # Check if execution completed
        if [ "$EXECUTION_STATUS" = "completed" ]; then
            echo "✅ Execution state: COMPLETED"
            return 0
        else
            echo "⚠️  Execution state: $EXECUTION_STATUS"
            return 1
        fi
    else
        echo "| Execution State | ❌ FAIL | State file not found or invalid |" >> "$REPORT_FILE"
        echo "❌ Execution state: State file not found"
        return 1
    fi
}
```

#### Validate Git State
```bash
# Validate git state
validate_git_state() {
    local REPORT_FILE="$1"
    
    echo "Validating git state..."
    
    # Check if git repository exists
    if [ -d ".git" ]; then
        local GIT_STATUS=$(git status --porcelain 2>/dev/null | wc -l)
        local CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
        local LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "No commits")
        
        # Add to report
        echo "| Git State | ✅ PASS | Branch: $CURRENT_BRANCH, Modified: $GIT_STATUS files |" >> "$REPORT_FILE"
        
        echo "✅ Git state: Branch $CURRENT_BRANCH, $GIT_STATUS modified files"
        return 0
    else
        echo "| Git State | ❌ FAIL | Not a git repository |" >> "$REPORT_FILE"
        echo "❌ Git state: Not a git repository"
        return 1
    fi
}
```

#### Validate File Integrity
```bash
# Validate file integrity
validate_file_integrity() {
    local REPORT_FILE="$1"
    
    echo "Validating file integrity..."
    
    # Check critical files exist
    local CRITICAL_FILES="package.json pyproject.toml requirements.txt README.md"
    local MISSING_FILES=0
    local FOUND_FILES=0
    
    for file in $CRITICAL_FILES; do
        if [ -f "$file" ]; then
            FOUND_FILES=$((FOUND_FILES + 1))
        else
            MISSING_FILES=$((MISSING_FILES + 1))
        fi
    done
    
    # Check for corrupted files
    local CORRUPTED_FILES=0
    find . -name "*.json" -type f -not -path "./.git/*" -not -path "./.ai_workflow/*" | while read -r json_file; do
        if ! python3 -m json.tool "$json_file" > /dev/null 2>&1; then
            echo "Warning: Corrupted JSON file: $json_file"
            CORRUPTED_FILES=$((CORRUPTED_FILES + 1))
        fi
    done
    
    # Add to report
    if [ $MISSING_FILES -eq 0 ] && [ $CORRUPTED_FILES -eq 0 ]; then
        echo "| File Integrity | ✅ PASS | $FOUND_FILES critical files found, no corruption |" >> "$REPORT_FILE"
        echo "✅ File integrity: All critical files present"
        return 0
    else
        echo "| File Integrity | ⚠️ WARN | $MISSING_FILES missing, $CORRUPTED_FILES corrupted |" >> "$REPORT_FILE"
        echo "⚠️ File integrity: $MISSING_FILES missing, $CORRUPTED_FILES corrupted"
        return 1
    fi
}
```

#### Validate Abstract Tools
```bash
# Validate abstract tools functionality
validate_abstract_tools() {
    local REPORT_FILE="$1"
    
    echo "Validating abstract tools..."
    
    # Check if abstract tool engine exists
    if [ -f ".ai_workflow/tools/execute_abstract_tool_call.md" ]; then
        local TOOL_ENGINE_STATUS="✅ Available"
    else
        local TOOL_ENGINE_STATUS="❌ Missing"
    fi
    
    # Check adapters
    local ADAPTER_COUNT=0
    local ADAPTER_STATUS=""
    
    for adapter in .ai_workflow/tools/adapters/*_adapter.md; do
        if [ -f "$adapter" ]; then
            ADAPTER_COUNT=$((ADAPTER_COUNT + 1))
            local adapter_name=$(basename "$adapter" _adapter.md)
            ADAPTER_STATUS="$ADAPTER_STATUS $adapter_name"
        fi
    done
    
    # Test basic abstract tool call
    local TOOL_TEST_RESULT="Unknown"
    if [ -f ".ai_workflow/tools/execute_abstract_tool_call.md" ]; then
        # Simple test - validate a git status call
        export ABSTRACT_CALL="git.status()"
        if source .ai_workflow/tools/validate_tool_call.md && validate_tool_call "git" "status" ""; then
            TOOL_TEST_RESULT="✅ Pass"
        else
            TOOL_TEST_RESULT="❌ Fail"
        fi
    fi
    
    # Add to report
    echo "| Abstract Tools | $TOOL_TEST_RESULT | Engine: $TOOL_ENGINE_STATUS, Adapters: $ADAPTER_COUNT |" >> "$REPORT_FILE"
    
    if [ "$TOOL_TEST_RESULT" = "✅ Pass" ]; then
        echo "✅ Abstract tools: $ADAPTER_COUNT adapters available"
        return 0
    else
        echo "❌ Abstract tools: Validation failed"
        return 1
    fi
}
```

#### Validate Environment Setup
```bash
# Validate environment setup
validate_environment_setup() {
    local REPORT_FILE="$1"
    
    echo "Validating environment setup..."
    
    # Check Node.js environment
    local NODE_STATUS="N/A"
    if [ -f "package.json" ]; then
        if command -v node >/dev/null 2>&1; then
            NODE_STATUS="✅ $(node --version)"
        else
            NODE_STATUS="❌ Missing"
        fi
    fi
    
    # Check NPM
    local NPM_STATUS="N/A"
    if [ -f "package.json" ]; then
        if command -v npm >/dev/null 2>&1; then
            NPM_STATUS="✅ $(npm --version)"
        else
            NPM_STATUS="❌ Missing"
        fi
    fi
    
    # Check Python environment
    local PYTHON_STATUS="N/A"
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        if command -v python3 >/dev/null 2>&1; then
            PYTHON_STATUS="✅ $(python3 --version)"
        else
            PYTHON_STATUS="❌ Missing"
        fi
    fi
    
    # Check Git
    local GIT_STATUS="N/A"
    if command -v git >/dev/null 2>&1; then
        GIT_STATUS="✅ $(git --version)"
    else
        GIT_STATUS="❌ Missing"
    fi
    
    # Add to report
    echo "| Environment | ✅ PASS | Node: $NODE_STATUS, NPM: $NPM_STATUS, Python: $PYTHON_STATUS, Git: $GIT_STATUS |" >> "$REPORT_FILE"
    
    echo "✅ Environment: Node: $NODE_STATUS, NPM: $NPM_STATUS, Python: $PYTHON_STATUS, Git: $GIT_STATUS"
    return 0
}
```

#### Validate Project Structure
```bash
# Validate project structure
validate_project_structure() {
    local REPORT_FILE="$1"
    
    echo "Validating project structure..."
    
    # Check framework structure
    local FRAMEWORK_DIRS=".ai_workflow .ai_workflow/workflows .ai_workflow/tools"
    local MISSING_DIRS=0
    
    for dir in $FRAMEWORK_DIRS; do
        if [ ! -d "$dir" ]; then
            MISSING_DIRS=$((MISSING_DIRS + 1))
        fi
    done
    
    # Check project files based on type
    local PROJECT_FILES=0
    local TOTAL_FILES=$(find . -type f -not -path "./.git/*" -not -path "./.ai_workflow/*" | wc -l)
    
    if [ -f "package.json" ]; then
        PROJECT_FILES=$((PROJECT_FILES + 1))
    fi
    
    if [ -f "README.md" ]; then
        PROJECT_FILES=$((PROJECT_FILES + 1))
    fi
    
    # Add to report
    if [ $MISSING_DIRS -eq 0 ]; then
        echo "| Project Structure | ✅ PASS | Framework dirs: OK, Project files: $PROJECT_FILES |" >> "$REPORT_FILE"
        echo "✅ Project structure: Framework complete, $PROJECT_FILES key files"
        return 0
    else
        echo "| Project Structure | ❌ FAIL | Missing $MISSING_DIRS framework directories |" >> "$REPORT_FILE"
        echo "❌ Project structure: Missing $MISSING_DIRS framework directories"
        return 1
    fi
}
```

#### Validate Dependencies
```bash
# Validate dependencies
validate_dependencies() {
    local REPORT_FILE="$1"
    
    echo "Validating dependencies..."
    
    local DEPENDENCY_STATUS="✅ PASS"
    local DEPENDENCY_DETAILS=""
    
    # Check Node.js dependencies
    if [ -f "package.json" ]; then
        if [ -d "node_modules" ]; then
            local NODE_DEPS=$(find node_modules -maxdepth 1 -type d | wc -l)
            DEPENDENCY_DETAILS="$DEPENDENCY_DETAILS Node: $NODE_DEPS modules"
        else
            DEPENDENCY_STATUS="⚠️ WARN"
            DEPENDENCY_DETAILS="$DEPENDENCY_DETAILS Node: No modules"
        fi
    fi
    
    # Check Python dependencies
    if [ -f "requirements.txt" ]; then
        if command -v pip3 >/dev/null 2>&1; then
            local PIP_DEPS=$(pip3 list 2>/dev/null | wc -l)
            DEPENDENCY_DETAILS="$DEPENDENCY_DETAILS Python: $PIP_DEPS packages"
        else
            DEPENDENCY_STATUS="⚠️ WARN"
            DEPENDENCY_DETAILS="$DEPENDENCY_DETAILS Python: pip not available"
        fi
    fi
    
    # Add to report
    echo "| Dependencies | $DEPENDENCY_STATUS | $DEPENDENCY_DETAILS |" >> "$REPORT_FILE"
    
    if [ "$DEPENDENCY_STATUS" = "✅ PASS" ]; then
        echo "✅ Dependencies: $DEPENDENCY_DETAILS"
        return 0
    else
        echo "⚠️ Dependencies: $DEPENDENCY_DETAILS"
        return 1
    fi
}
```

#### Finalize Validation Report
```bash
# Finalize validation report
finalize_validation_report() {
    local REPORT_FILE="$1"
    local TOTAL_CHECKS="$2"
    local PASSED_CHECKS="$3"
    local FAILED_CHECKS="$4"
    
    cat >> "$REPORT_FILE" << EOF

## Final Summary
- **Total Checks**: $TOTAL_CHECKS
- **Passed**: $PASSED_CHECKS
- **Failed**: $FAILED_CHECKS
- **Success Rate**: $((PASSED_CHECKS * 100 / TOTAL_CHECKS))%
- **Validation Completed**: $(date)

## Recommendations
EOF
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo "- ✅ All validation checks passed successfully" >> "$REPORT_FILE"
        echo "- Framework and project are in good state" >> "$REPORT_FILE"
        echo "- PRP execution completed successfully" >> "$REPORT_FILE"
    else
        echo "- ⚠️ $FAILED_CHECKS validation checks failed" >> "$REPORT_FILE"
        echo "- Review failed checks and address issues" >> "$REPORT_FILE"
        echo "- Consider running rollback if critical issues exist" >> "$REPORT_FILE"
    fi
    
    cat >> "$REPORT_FILE" << EOF

## Next Steps
1. Review any failed validation checks above
2. Address any warnings or failures
3. Re-run validation if issues were fixed
4. Consider creating a rollback point if system is stable

---
*Generated by AI-Assisted Development Framework*
EOF
    
    echo "Validation report finalized: $REPORT_FILE"
}
```

### Quick Validation Functions

#### Quick Health Check
```bash
# Quick health check
quick_health_check() {
    echo "Performing quick health check..."
    
    local ISSUES=0
    
    # Check framework structure
    if [ ! -d ".ai_workflow" ]; then
        echo "❌ Framework directory missing"
        ISSUES=$((ISSUES + 1))
    fi
    
    # Check git repository
    if [ ! -d ".git" ]; then
        echo "❌ Git repository missing"
        ISSUES=$((ISSUES + 1))
    fi
    
    # Check abstract tools
    if [ ! -f ".ai_workflow/tools/execute_abstract_tool_call.md" ]; then
        echo "❌ Abstract tool engine missing"
        ISSUES=$((ISSUES + 1))
    fi
    
    if [ $ISSUES -eq 0 ]; then
        echo "✅ Quick health check: All OK"
        return 0
    else
        echo "❌ Quick health check: $ISSUES issues found"
        return 1
    fi
}
```

#### Validate Single Component
```bash
# Validate single component
validate_component() {
    local COMPONENT="$1"
    
    case "$COMPONENT" in
        "git")
            validate_git_state "/dev/null"
            ;;
        "tools")
            validate_abstract_tools "/dev/null"
            ;;
        "files")
            validate_file_integrity "/dev/null"
            ;;
        "environment")
            validate_environment_setup "/dev/null"
            ;;
        *)
            echo "Unknown component: $COMPONENT"
            echo "Available: git, tools, files, environment"
            return 1
            ;;
    esac
}
```

## Integration with PRP Execution

### Automatic Validation
- Called at the end of PRP execution
- Generates comprehensive validation report
- Provides pass/fail status for execution

### Error Detection
- Identifies incomplete tasks
- Detects system inconsistencies
- Warns about potential issues

### Reporting
- Markdown format reports
- Detailed check results
- Recommendations for fixes

## Usage Examples

### Full Validation
```bash
# Full validation with report
validate_prp_execution "prp_20250714_100000" "full"

# Quick validation
validate_prp_execution "prp_20250714_100000" "basic"
```

### Component Validation
```bash
# Validate specific components
validate_component "git"
validate_component "tools"
validate_component "files"
```

### Health Checks
```bash
# Quick health check
quick_health_check

# Single component check
validate_component "environment"
```

## Notes
- Validation reports are stored in `.ai_workflow/`
- Each execution gets a unique validation report
- Integration with state management for context
- Extensible validation framework for new checks
- Comprehensive coverage of framework components
- Clear pass/fail status for automation