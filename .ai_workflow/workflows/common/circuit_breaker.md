# Circuit Breaker Protection System

## Purpose
Prevent infinite loops and dangerous recursive operations in the AI Development Framework.

## Philosophy
**Safety First** - Always prefer stopping execution over risking system damage or infinite loops.

## Circuit Breaker Implementation

### 1. Execution Counter Protection

```bash
#!/bin/bash

# Circuit Breaker Configuration
CIRCUIT_BREAKER_DIR=".ai_workflow/circuit_breakers"
EXECUTION_LIMITS_FILE="$CIRCUIT_BREAKER_DIR/execution_limits.json"
CIRCUIT_STATE_FILE="$CIRCUIT_BREAKER_DIR/circuit_state.json"

# Initialize circuit breaker system
init_circuit_breaker() {
    local operation="$1"
    local max_executions="${2:-5}"
    local time_window="${3:-3600}"  # 1 hour default
    
    echo "🔒 Initializing circuit breaker for: $operation"
    
    # Create circuit breaker directory
    mkdir -p "$CIRCUIT_BREAKER_DIR"
    
    # Initialize execution limits if not exists
    if [ ! -f "$EXECUTION_LIMITS_FILE" ]; then
        echo "{}" > "$EXECUTION_LIMITS_FILE"
    fi
    
    # Set or update limits for this operation
    local temp_file=$(mktemp)
    jq --arg op "$operation" --argjson max "$max_executions" --argjson window "$time_window" \
       '.[$op] = {max_executions: $max, time_window: $window}' \
       "$EXECUTION_LIMITS_FILE" > "$temp_file" && mv "$temp_file" "$EXECUTION_LIMITS_FILE"
    
    # Initialize circuit state if not exists
    if [ ! -f "$CIRCUIT_STATE_FILE" ]; then
        echo "{}" > "$CIRCUIT_STATE_FILE"
    fi
    
    echo "✅ Circuit breaker initialized: $operation (max: $max_executions, window: ${time_window}s)"
}

# Check if operation is allowed by circuit breaker
check_circuit_breaker() {
    local operation="$1"
    local current_time=$(date +%s)
    
    echo "🔍 Checking circuit breaker for: $operation"
    
    # Ensure circuit breaker is initialized
    if [ ! -f "$EXECUTION_LIMITS_FILE" ] || [ ! -f "$CIRCUIT_STATE_FILE" ]; then
        echo "⚠️  Circuit breaker not initialized for $operation"
        init_circuit_breaker "$operation"
        return 0
    fi
    
    # Get limits for this operation
    local limits=$(jq -r --arg op "$operation" '.[$op]' "$EXECUTION_LIMITS_FILE")
    if [ "$limits" = "null" ]; then
        echo "⚠️  No limits defined for $operation - initializing defaults"
        init_circuit_breaker "$operation"
        return 0
    fi
    
    local max_executions=$(echo "$limits" | jq -r '.max_executions')
    local time_window=$(echo "$limits" | jq -r '.time_window')
    
    # Get current state for this operation
    local state=$(jq -r --arg op "$operation" '.[$op]' "$CIRCUIT_STATE_FILE")
    
    if [ "$state" = "null" ]; then
        # First execution - initialize state
        local temp_file=$(mktemp)
        jq --arg op "$operation" --argjson time "$current_time" --argjson count 1 \
           '.[$op] = {last_reset: $time, executions: [$time], count: $count}' \
           "$CIRCUIT_STATE_FILE" > "$temp_file" && mv "$temp_file" "$CIRCUIT_STATE_FILE"
        
        echo "✅ Circuit breaker: First execution allowed ($operation)"
        return 0
    fi
    
    # Parse current state
    local last_reset=$(echo "$state" | jq -r '.last_reset')
    local executions=$(echo "$state" | jq -r '.executions')
    local count=$(echo "$state" | jq -r '.count')
    
    # Check if we need to reset the time window
    local time_since_reset=$((current_time - last_reset))
    if [ $time_since_reset -ge $time_window ]; then
        echo "🔄 Circuit breaker: Time window expired, resetting counter ($operation)"
        local temp_file=$(mktemp)
        jq --arg op "$operation" --argjson time "$current_time" --argjson count 1 \
           '.[$op] = {last_reset: $time, executions: [$time], count: $count}' \
           "$CIRCUIT_STATE_FILE" > "$temp_file" && mv "$temp_file" "$CIRCUIT_STATE_FILE"
        
        echo "✅ Circuit breaker: Execution allowed after reset ($operation)"
        return 0
    fi
    
    # Check if we've exceeded the limit
    if [ $count -ge $max_executions ]; then
        echo "🚨 Circuit breaker: EXECUTION BLOCKED ($operation)"
        echo "   Max executions: $max_executions"
        echo "   Current count: $count"
        echo "   Time until reset: $((time_window - time_since_reset))s"
        echo "   Last executions: $(echo "$executions" | jq -r '.[]' | tail -5 | xargs -I {} date -d @{} '+%H:%M:%S')"
        
        # Log the circuit breaker activation
        echo "$(date): Circuit breaker activated for $operation (count: $count, limit: $max_executions)" >> "$CIRCUIT_BREAKER_DIR/circuit_breaker.log"
        
        return 1
    fi
    
    # Update execution count
    local new_count=$((count + 1))
    local temp_file=$(mktemp)
    jq --arg op "$operation" --argjson time "$current_time" --argjson count "$new_count" \
       '.[$op].executions += [$time] | .[$op].count = $count' \
       "$CIRCUIT_STATE_FILE" > "$temp_file" && mv "$temp_file" "$CIRCUIT_STATE_FILE"
    
    echo "✅ Circuit breaker: Execution allowed ($operation - $new_count/$max_executions)"
    return 0
}

# Force reset circuit breaker (emergency use)
reset_circuit_breaker() {
    local operation="$1"
    
    echo "🔄 Force resetting circuit breaker for: $operation"
    
    local temp_file=$(mktemp)
    jq --arg op "$operation" 'del(.[$op])' "$CIRCUIT_STATE_FILE" > "$temp_file" && mv "$temp_file" "$CIRCUIT_STATE_FILE"
    
    echo "✅ Circuit breaker reset: $operation"
}

# Get circuit breaker status
get_circuit_breaker_status() {
    local operation="$1"
    
    if [ ! -f "$CIRCUIT_STATE_FILE" ]; then
        echo "No circuit breaker state found"
        return 1
    fi
    
    local state=$(jq -r --arg op "$operation" '.[$op]' "$CIRCUIT_STATE_FILE")
    if [ "$state" = "null" ]; then
        echo "No state for operation: $operation"
        return 1
    fi
    
    local current_time=$(date +%s)
    local last_reset=$(echo "$state" | jq -r '.last_reset')
    local count=$(echo "$state" | jq -r '.count')
    local time_since_reset=$((current_time - last_reset))
    
    echo "Circuit breaker status for: $operation"
    echo "  Executions: $count"
    echo "  Time since reset: ${time_since_reset}s"
    echo "  Last reset: $(date -d @$last_reset '+%Y-%m-%d %H:%M:%S')"
}
```

### 2. Dangerous Operation Detection

```bash
# Detect potentially dangerous operations
is_dangerous_operation() {
    local command="$1"
    local file_path="$2"
    
    # Define dangerous patterns
    local dangerous_patterns=(
        "rm -rf"
        "rm -f /"
        "chmod 777"
        "chown -R"
        "find . -delete"
        "git reset --hard"
        "git push --force"
        "sudo rm"
        "eval.*\$"
        "exec.*\$"
        "system.*\$"
    )
    
    # Check command for dangerous patterns
    for pattern in "${dangerous_patterns[@]}"; do
        if echo "$command" | grep -E "$pattern" >/dev/null; then
            echo "🚨 Dangerous operation detected: $pattern"
            return 0
        fi
    done
    
    # Check for critical files
    local critical_files=(
        "ai-dev"
        "CLAUDE.md"
        "ARCHITECTURE.md"
        ".git/"
        ".github/"
        ".ai_workflow/"
    )
    
    for file in "${critical_files[@]}"; do
        if [[ "$file_path" == *"$file"* ]]; then
            echo "🚨 Critical file operation detected: $file"
            return 0
        fi
    done
    
    return 1
}

# Safe execution wrapper
safe_execute() {
    local operation="$1"
    local command="$2"
    local file_path="${3:-}"
    
    echo "🛡️  Safe execution check: $operation"
    
    # Check circuit breaker
    if ! check_circuit_breaker "$operation"; then
        echo "❌ Operation blocked by circuit breaker: $operation"
        return 1
    fi
    
    # Check for dangerous operations
    if is_dangerous_operation "$command" "$file_path"; then
        echo "❌ Dangerous operation blocked: $operation"
        echo "   Command: $command"
        echo "   File: $file_path"
        
        # Require manual confirmation for dangerous operations
        if [ "$FORCE_DANGEROUS_OPERATIONS" != "true" ]; then
            # Use environment variable or default behavior for automation
            if [[ -n "${AUTO_CONFIRM:-}" ]]; then
                confirm="$AUTO_CONFIRM"
                echo "⚠️  Continue with dangerous operation? [y/N]: $confirm (automated)"
            else
                echo -n "⚠️  Continue with dangerous operation? [y/N]: "
                read confirm
            fi
            if [ "$confirm" != "y" ]; then
                echo "Operation cancelled by user"
                return 1
            fi
        fi
    fi
    
    # Execute the command
    echo "✅ Executing: $operation"
    eval "$command"
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo "❌ Command failed with exit code: $exit_code"
        echo "   Operation: $operation"
        echo "   Command: $command"
    fi
    
    return $exit_code
}
```

### 3. Anti-Loop Patterns

```bash
# Detect potential loops in workflow execution
detect_loop_pattern() {
    local operation="$1"
    local execution_log="$CIRCUIT_BREAKER_DIR/execution_sequence.log"
    
    # Log this execution
    echo "$(date +%s):$operation" >> "$execution_log"
    
    # Keep only last 20 executions
    tail -20 "$execution_log" > "$execution_log.tmp" && mv "$execution_log.tmp" "$execution_log"
    
    # Check for immediate loops (same operation repeated)
    local recent_ops=$(tail -5 "$execution_log" | cut -d: -f2)
    local unique_ops=$(echo "$recent_ops" | sort -u | wc -l)
    local total_ops=$(echo "$recent_ops" | wc -l)
    
    if [ $unique_ops -eq 1 ] && [ $total_ops -ge 3 ]; then
        echo "🔄 Potential immediate loop detected: $operation"
        return 0
    fi
    
    # Check for alternating loops (A->B->A->B)
    local last_4=$(tail -4 "$execution_log" | cut -d: -f2)
    if [ $(echo "$last_4" | wc -l) -eq 4 ]; then
        local op1=$(echo "$last_4" | sed -n '1p')
        local op2=$(echo "$last_4" | sed -n '2p')
        local op3=$(echo "$last_4" | sed -n '3p')
        local op4=$(echo "$last_4" | sed -n '4p')
        
        if [ "$op1" = "$op3" ] && [ "$op2" = "$op4" ] && [ "$op1" != "$op2" ]; then
            echo "🔄 Potential alternating loop detected: $op1 <-> $op2"
            return 0
        fi
    fi
    
    return 1
}

# Enhanced safe execution with loop detection
safe_execute_with_loop_detection() {
    local operation="$1"
    local command="$2"
    local file_path="${3:-}"
    
    echo "🛡️  Enhanced safe execution: $operation"
    
    # Check for loop patterns
    if detect_loop_pattern "$operation"; then
        echo "🚨 Loop pattern detected - blocking execution"
        echo "   Operation: $operation"
        echo "   Recent pattern: $(tail -5 "$CIRCUIT_BREAKER_DIR/execution_sequence.log" | cut -d: -f2 | xargs)"
        
        # Require manual confirmation for potential loops
        if [ "$ALLOW_POTENTIAL_LOOPS" != "true" ]; then
            # Use environment variable or default behavior for automation
            if [[ -n "${AUTO_CONFIRM:-}" ]]; then
                confirm="$AUTO_CONFIRM"
                echo "⚠️  Continue despite loop risk? [y/N]: $confirm (automated)"
            else
                echo -n "⚠️  Continue despite loop risk? [y/N]: "
                read confirm
            fi
            if [ "$confirm" != "y" ]; then
                echo "Operation cancelled due to loop risk"
                return 1
            fi
        fi
    fi
    
    # Use regular safe execution
    safe_execute "$operation" "$command" "$file_path"
}
```

### 4. Emergency Stop Mechanism

```bash
# Emergency stop mechanism
emergency_stop() {
    local reason="$1"
    local emergency_file="$CIRCUIT_BREAKER_DIR/emergency_stop"
    
    echo "🚨 EMERGENCY STOP ACTIVATED"
    echo "Reason: $reason"
    echo "$(date): Emergency stop activated - $reason" > "$emergency_file"
    
    # Kill any running framework processes
    pkill -f "ai-dev" || true
    pkill -f ".ai_workflow" || true
    
    echo "✅ Emergency stop completed"
    exit 1
}

# Check emergency stop status
check_emergency_stop() {
    local emergency_file="$CIRCUIT_BREAKER_DIR/emergency_stop"
    
    if [ -f "$emergency_file" ]; then
        echo "🚨 Emergency stop is active"
        echo "Reason: $(cat "$emergency_file")"
        echo "To clear: rm $emergency_file"
        return 1
    fi
    
    return 0
}

# Clear emergency stop
clear_emergency_stop() {
    local emergency_file="$CIRCUIT_BREAKER_DIR/emergency_stop"
    
    if [ -f "$emergency_file" ]; then
        echo "🔄 Clearing emergency stop..."
        rm "$emergency_file"
        echo "✅ Emergency stop cleared"
    else
        echo "ℹ️  No emergency stop active"
    fi
}
```

## Usage Examples

### Basic Circuit Breaker
```bash
# Initialize circuit breaker for sync operation (max 3 times per hour)
init_circuit_breaker "sync_feedback" 3 3600

# Check before executing
if check_circuit_breaker "sync_feedback"; then
    echo "Executing sync..."
    ./ai-dev sync feedback
else
    echo "Sync blocked by circuit breaker"
fi
```

### Safe Execution
```bash
# Safe file operation
safe_execute "update_config" "sed -i 's/old/new/g' config.json" "config.json"

# Safe with loop detection
safe_execute_with_loop_detection "auto_optimize" "./ai-dev optimize" ""
```

### Emergency Procedures
```bash
# Emergency stop
emergency_stop "Infinite loop detected in feedback processing"

# Check and clear
check_emergency_stop && echo "Safe to proceed" || echo "Emergency stop active"
clear_emergency_stop
```

## Integration Points

This circuit breaker system should be integrated into:
- All GitHub Actions workflows
- External feedback processing
- Auto-optimization features
- Critical file operations
- Recursive workflow calls

## Benefits

1. **Loop Prevention**: Detects and blocks infinite loops
2. **Rate Limiting**: Prevents overwhelming the system
3. **Dangerous Operation Protection**: Blocks potentially harmful commands
4. **Emergency Recovery**: Provides emergency stop mechanism
5. **Audit Trail**: Logs all circuit breaker activations
6. **Configurable**: Adjustable limits per operation
7. **Pattern Detection**: Identifies complex loop patterns