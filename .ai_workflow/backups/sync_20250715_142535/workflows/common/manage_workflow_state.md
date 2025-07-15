# Manage Workflow State

## Overview
This workflow manages runtime state during PRP execution, providing persistence and recovery capabilities for complex multi-step workflows. It maintains execution context across tool calls and enables rollback functionality.

## Workflow Instructions

### For AI Agents
When managing workflow state during PRP execution:

1. **Initialize state** at the beginning of workflow execution
2. **Update state** after each successful operation
3. **Query state** to understand current execution context
4. **Persist state** for recovery and rollback capabilities

### State Management Functions

#### Initialize Workflow State
```bash
# Initialize workflow state for PRP execution
init_workflow_state() {
    local PRP_FILE="$1"
    local EXECUTION_ID="$2"
    
    # Create state directory
    mkdir -p .ai_workflow/state/executions
    
    # Generate execution ID if not provided
    if [ -z "$EXECUTION_ID" ]; then
        EXECUTION_ID="prp_$(date +%Y%m%d_%H%M%S)_$$"
    fi
    
    # Create state file
    STATE_FILE=".ai_workflow/state/executions/${EXECUTION_ID}.md"
    
    cat > "$STATE_FILE" << EOF
# Workflow State: $EXECUTION_ID

## Execution Information
- **PRP File**: $PRP_FILE
- **Execution ID**: $EXECUTION_ID
- **Started**: $(date)
- **Status**: initialized
- **Current Task**: 0
- **Total Tasks**: 0

## State Variables
\`\`\`bash
export EXECUTION_ID="$EXECUTION_ID"
export PRP_FILE="$PRP_FILE"
export STATE_FILE="$STATE_FILE"
export CURRENT_TASK=0
export TOTAL_TASKS=0
export EXECUTION_STATUS="initialized"
\`\`\`

## Execution Log
- $(date): Workflow state initialized

## Task Progress
| Task | Status | Started | Completed | Duration |
|------|--------|---------|-----------|----------|

## Rollback Points
| Point ID | Description | Created | Files Modified |
|----------|-------------|---------|----------------|

## Error History
| Task | Error | Attempt | Resolution |
|------|-------|---------|------------|

EOF
    
    echo "Workflow state initialized: $STATE_FILE"
    export EXECUTION_ID STATE_FILE
}
```

#### Update Current Task
```bash
# Update current task information
update_current_task() {
    local TASK_INDEX="$1"
    local TASK_NAME="$2"
    local STATUS="$3"
    
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    # Update state variables
    export CURRENT_TASK="$TASK_INDEX"
    export EXECUTION_STATUS="$STATUS"
    
    # Update state file
    sed -i "s/- \*\*Current Task\*\*: .*/- **Current Task**: $TASK_INDEX ($TASK_NAME)/" "$STATE_FILE"
    sed -i "s/- \*\*Status\*\*: .*/- **Status**: $STATUS/" "$STATE_FILE"
    
    # Update bash variables section
    sed -i "s/export CURRENT_TASK=.*/export CURRENT_TASK=\"$TASK_INDEX\"/" "$STATE_FILE"
    sed -i "s/export EXECUTION_STATUS=.*/export EXECUTION_STATUS=\"$STATUS\"/" "$STATE_FILE"
    
    # Add to execution log
    echo "- $(date): Task $TASK_INDEX ($TASK_NAME) - $STATUS" >> "$STATE_FILE"
    
    echo "Updated current task: $TASK_INDEX ($TASK_NAME) - $STATUS"
}
```

#### Update Task Progress
```bash
# Update task progress table
update_task_progress() {
    local TASK_INDEX="$1"
    local TASK_NAME="$2"
    local STATUS="$3"
    local STARTED="$4"
    local COMPLETED="$5"
    
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    # Calculate duration if both times provided
    local DURATION=""
    if [ -n "$STARTED" ] && [ -n "$COMPLETED" ]; then
        local START_SEC=$(date -d "$STARTED" +%s)
        local END_SEC=$(date -d "$COMPLETED" +%s)
        DURATION="${$((END_SEC - START_SEC))}s"
    fi
    
    # Check if task already exists in table
    if grep -q "| $TASK_INDEX |" "$STATE_FILE"; then
        # Update existing row
        sed -i "/| $TASK_INDEX |/c\| $TASK_INDEX | $STATUS | $STARTED | $COMPLETED | $DURATION |" "$STATE_FILE"
    else
        # Add new row after table header
        sed -i "/|------|--------|---------|-----------|----------|/a\| $TASK_INDEX | $STATUS | $STARTED | $COMPLETED | $DURATION |" "$STATE_FILE"
    fi
    
    echo "Updated task progress: $TASK_INDEX - $STATUS"
}
```

#### Log Abstract Tool Call
```bash
# Log an abstract tool call execution
log_abstract_tool_call() {
    local TOOL_CALL="$1"
    local RESULT="$2"
    local DURATION="$3"
    
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    # Add to execution log
    echo "- $(date): TOOL_CALL: $TOOL_CALL - $RESULT (${DURATION}s)" >> "$STATE_FILE"
    
    echo "Logged tool call: $TOOL_CALL - $RESULT"
}
```

#### Log Error
```bash
# Log an error with task context
log_error() {
    local TASK_INDEX="$1"
    local ERROR_MSG="$2"
    local ATTEMPT="$3"
    local RESOLUTION="$4"
    
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    # Add to error history table
    sed -i "/|------|-------|---------|------------|/a\| $TASK_INDEX | $ERROR_MSG | $ATTEMPT | $RESOLUTION |" "$STATE_FILE"
    
    # Add to execution log
    echo "- $(date): ERROR: Task $TASK_INDEX - $ERROR_MSG (Attempt $ATTEMPT)" >> "$STATE_FILE"
    
    echo "Logged error: Task $TASK_INDEX - $ERROR_MSG"
}
```

#### Add Rollback Point
```bash
# Add a rollback point
add_rollback_point() {
    local POINT_ID="$1"
    local DESCRIPTION="$2"
    local FILES_MODIFIED="$3"
    
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    # Add to rollback points table
    sed -i "/|----------|-------------|---------|----------------|/a\| $POINT_ID | $DESCRIPTION | $(date) | $FILES_MODIFIED |" "$STATE_FILE"
    
    # Add to execution log
    echo "- $(date): ROLLBACK_POINT: $POINT_ID - $DESCRIPTION" >> "$STATE_FILE"
    
    echo "Added rollback point: $POINT_ID - $DESCRIPTION"
}
```

#### Get Current State
```bash
# Get current workflow state
get_current_state() {
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    echo "Current workflow state:"
    echo "- Execution ID: $EXECUTION_ID"
    echo "- Current Task: $CURRENT_TASK"
    echo "- Status: $EXECUTION_STATUS"
    echo "- State File: $STATE_FILE"
}
```

#### Set Total Tasks
```bash
# Set total number of tasks
set_total_tasks() {
    local TOTAL="$1"
    
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    export TOTAL_TASKS="$TOTAL"
    
    # Update state file
    sed -i "s/- \*\*Total Tasks\*\*: .*/- **Total Tasks**: $TOTAL/" "$STATE_FILE"
    sed -i "s/export TOTAL_TASKS=.*/export TOTAL_TASKS=\"$TOTAL\"/" "$STATE_FILE"
    
    echo "Set total tasks: $TOTAL"
}
```

#### Finalize Workflow State
```bash
# Finalize workflow state
finalize_workflow_state() {
    local FINAL_STATUS="$1"
    local FINAL_MESSAGE="$2"
    
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    # Update final status
    export EXECUTION_STATUS="$FINAL_STATUS"
    
    # Update state file
    sed -i "s/- \*\*Status\*\*: .*/- **Status**: $FINAL_STATUS/" "$STATE_FILE"
    sed -i "s/export EXECUTION_STATUS=.*/export EXECUTION_STATUS=\"$FINAL_STATUS\"/" "$STATE_FILE"
    
    # Add completion information
    cat >> "$STATE_FILE" << EOF

## Final Results
- **Completed**: $(date)
- **Final Status**: $FINAL_STATUS
- **Message**: $FINAL_MESSAGE
- **Total Duration**: $(($(date +%s) - $(date -d "$(grep "Started" "$STATE_FILE" | head -1 | cut -d':' -f2-)" +%s)))s

EOF
    
    echo "Workflow finalized: $FINAL_STATUS - $FINAL_MESSAGE"
}
```

### State Query Functions

#### Check If Task Completed
```bash
# Check if a specific task was completed
is_task_completed() {
    local TASK_INDEX="$1"
    
    if [ -z "$STATE_FILE" ]; then
        return 1
    fi
    
    if grep -q "| $TASK_INDEX | completed |" "$STATE_FILE"; then
        return 0
    else
        return 1
    fi
}
```

#### Get Last Rollback Point
```bash
# Get the most recent rollback point
get_last_rollback_point() {
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    # Get last rollback point from table
    local LAST_POINT=$(grep "^|.*|.*|.*|.*|$" "$STATE_FILE" | grep -A1 "rollback_point" | tail -1 | cut -d'|' -f2 | tr -d ' ')
    
    if [ -n "$LAST_POINT" ]; then
        echo "$LAST_POINT"
    else
        echo "No rollback points found"
        return 1
    fi
}
```

#### Get Execution Summary
```bash
# Get execution summary
get_execution_summary() {
    if [ -z "$STATE_FILE" ]; then
        echo "ERROR: Workflow state not initialized"
        return 1
    fi
    
    echo "=== Execution Summary ==="
    echo "Execution ID: $EXECUTION_ID"
    echo "Status: $EXECUTION_STATUS"
    echo "Current Task: $CURRENT_TASK/$TOTAL_TASKS"
    echo ""
    echo "=== Task Progress ==="
    grep "^| [0-9]" "$STATE_FILE" | head -5
    echo ""
    echo "=== Recent Log Entries ==="
    grep "^- " "$STATE_FILE" | tail -5
}
```

### Integration with Abstract Tools

#### Wrap Abstract Tool Call
```bash
# Wrapper for abstract tool calls with state management
execute_abstract_tool_with_state() {
    local ABSTRACT_CALL="$1"
    local TASK_INDEX="$2"
    
    # Log tool call start
    local START_TIME=$(date +%s)
    echo "- $(date): STARTING: $ABSTRACT_CALL" >> "$STATE_FILE"
    
    # Execute abstract tool call
    export ABSTRACT_CALL
    if execute_abstract_tool "$ABSTRACT_CALL"; then
        local END_TIME=$(date +%s)
        local DURATION=$((END_TIME - START_TIME))
        log_abstract_tool_call "$ABSTRACT_CALL" "SUCCESS" "$DURATION"
        return 0
    else
        local END_TIME=$(date +%s)
        local DURATION=$((END_TIME - START_TIME))
        log_abstract_tool_call "$ABSTRACT_CALL" "FAILED" "$DURATION"
        return 1
    fi
}
```

### Recovery Functions

#### Load State from File
```bash
# Load state from existing state file
load_workflow_state() {
    local STATE_FILE_PATH="$1"
    
    if [ ! -f "$STATE_FILE_PATH" ]; then
        echo "ERROR: State file not found: $STATE_FILE_PATH"
        return 1
    fi
    
    # Source the state variables
    source <(grep "^export " "$STATE_FILE_PATH")
    
    export STATE_FILE="$STATE_FILE_PATH"
    
    echo "Loaded workflow state from: $STATE_FILE_PATH"
    echo "Execution ID: $EXECUTION_ID"
    echo "Current Task: $CURRENT_TASK"
    echo "Status: $EXECUTION_STATUS"
}
```

#### List Active Executions
```bash
# List all active executions
list_active_executions() {
    echo "Active workflow executions:"
    
    if [ -d ".ai_workflow/state/executions" ]; then
        for state_file in .ai_workflow/state/executions/*.md; do
            if [ -f "$state_file" ]; then
                local exec_id=$(basename "$state_file" .md)
                local status=$(grep "Status" "$state_file" | cut -d':' -f2 | tr -d ' ')
                local current_task=$(grep "Current Task" "$state_file" | cut -d':' -f2 | tr -d ' ')
                echo "- $exec_id: $status (Task: $current_task)"
            fi
        done
    else
        echo "No active executions found"
    fi
}
```

## Integration Notes

### With PRP Execution
- Initialize state at start of PRP execution
- Update state after each task completion
- Log all abstract tool calls
- Maintain rollback points for recovery

### With Error Handling
- Log errors with full context
- Track retry attempts
- Enable rollback to previous states
- Preserve error history for analysis

### With Abstract Tools
- Wrap all tool calls with state management
- Track execution times and results
- Enable debugging and performance analysis
- Provide audit trail for all operations

## Usage Examples

### Basic Usage
```bash
# Initialize workflow state
init_workflow_state "path/to/prp.md" "custom_execution_id"

# Set total tasks
set_total_tasks 5

# Start a task
update_current_task 1 "Setup Environment" "running"

# Execute abstract tool with state tracking
execute_abstract_tool_with_state "npm.install()" 1

# Complete task
update_task_progress 1 "Setup Environment" "completed" "2025-07-14 10:00:00" "2025-07-14 10:02:30"

# Finalize
finalize_workflow_state "completed" "All tasks completed successfully"
```

### Error Recovery
```bash
# Load existing state
load_workflow_state ".ai_workflow/state/executions/prp_20250714_100000_1234.md"

# Check current state
get_current_state

# Resume from current task
update_current_task $CURRENT_TASK "Resume Task" "running"
```

## Notes
- State files are stored in `.ai_workflow/state/executions/`
- Each execution gets a unique ID and state file
- State is persisted in markdown format for transparency
- Integration with rollback system for recovery
- Comprehensive logging for debugging and analysis