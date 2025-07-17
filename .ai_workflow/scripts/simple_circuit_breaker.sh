#!/bin/bash

# Simple Circuit Breaker Implementation
# Prevents infinite loops and dangerous operations

CIRCUIT_BREAKER_DIR=".ai_workflow/circuit_breakers"
CIRCUIT_STATE_FILE="$CIRCUIT_BREAKER_DIR/circuit_state.json"
EXECUTION_LOG="$CIRCUIT_BREAKER_DIR/execution_sequence.log"

# Initialize circuit breaker system
init_circuit_breaker() {
    local operation="$1"
    local max_executions="${2:-5}"
    local time_window="${3:-3600}"
    
    echo "🔒 Initializing circuit breaker for: $operation"
    
    # Create circuit breaker directory
    mkdir -p "$CIRCUIT_BREAKER_DIR"
    
    # Initialize state file if not exists
    if [ ! -f "$CIRCUIT_STATE_FILE" ]; then
        echo "{}" > "$CIRCUIT_STATE_FILE"
    fi
    
    # Use simple file-based tracking instead of jq
    local state_file="$CIRCUIT_BREAKER_DIR/${operation}_state"
    echo "max_executions=$max_executions" > "$state_file"
    echo "time_window=$time_window" >> "$state_file"
    echo "count=0" >> "$state_file"
    echo "last_reset=$(date +%s)" >> "$state_file"
    
    echo "✅ Circuit breaker initialized: $operation"
}

# Check if operation is allowed
check_circuit_breaker() {
    local operation="$1"
    local current_time=$(date +%s)
    local state_file="$CIRCUIT_BREAKER_DIR/${operation}_state"
    
    echo "🔍 Checking circuit breaker for: $operation"
    
    # Initialize if not exists
    if [ ! -f "$state_file" ]; then
        echo "⚠️  Circuit breaker not initialized for $operation"
        init_circuit_breaker "$operation"
        return 0
    fi
    
    # Read state
    local max_executions=$(grep "max_executions=" "$state_file" | cut -d'=' -f2)
    local time_window=$(grep "time_window=" "$state_file" | cut -d'=' -f2)
    local count=$(grep "count=" "$state_file" | cut -d'=' -f2)
    local last_reset=$(grep "last_reset=" "$state_file" | cut -d'=' -f2)
    
    # Check if we need to reset
    local time_since_reset=$((current_time - last_reset))
    if [ $time_since_reset -ge $time_window ]; then
        echo "🔄 Circuit breaker: Time window expired, resetting counter"
        echo "max_executions=$max_executions" > "$state_file"
        echo "time_window=$time_window" >> "$state_file"
        echo "count=1" >> "$state_file"
        echo "last_reset=$current_time" >> "$state_file"
        echo "✅ Circuit breaker: Execution allowed after reset"
        return 0
    fi
    
    # Check if we've exceeded the limit
    if [ $count -ge $max_executions ]; then
        echo "🚨 Circuit breaker: EXECUTION BLOCKED ($operation)"
        echo "   Max executions: $max_executions"
        echo "   Current count: $count"
        echo "   Time until reset: $((time_window - time_since_reset))s"
        return 1
    fi
    
    # Update count
    local new_count=$((count + 1))
    echo "max_executions=$max_executions" > "$state_file"
    echo "time_window=$time_window" >> "$state_file"
    echo "count=$new_count" >> "$state_file"
    echo "last_reset=$last_reset" >> "$state_file"
    
    echo "✅ Circuit breaker: Execution allowed ($operation - $new_count/$max_executions)"
    return 0
}

# Check for dangerous operations
is_dangerous_operation() {
    local command="$1"
    local file_path="$2"
    
    # Define dangerous patterns
    if echo "$command" | grep -E "(rm -rf|rm -f /|chmod 777|sudo rm|git reset --hard|git push --force)" >/dev/null; then
        echo "🚨 Dangerous operation detected"
        return 0
    fi
    
    # Check for critical files
    if [[ "$file_path" == *"ai-dev"* ]] || [[ "$file_path" == *".git/"* ]] || [[ "$file_path" == *".ai_workflow/"* ]]; then
        echo "🚨 Critical file operation detected"
        return 0
    fi
    
    return 1
}

# Emergency stop mechanism
emergency_stop() {
    local reason="$1"
    local emergency_file="$CIRCUIT_BREAKER_DIR/emergency_stop"
    
    echo "🚨 EMERGENCY STOP ACTIVATED"
    echo "Reason: $reason"
    echo "$(date): Emergency stop activated - $reason" > "$emergency_file"
    
    echo "✅ Emergency stop completed"
    exit 1
}

# Check emergency stop
check_emergency_stop() {
    local emergency_file="$CIRCUIT_BREAKER_DIR/emergency_stop"
    
    if [ -f "$emergency_file" ]; then
        echo "🚨 Emergency stop is active"
        echo "Reason: $(cat "$emergency_file")"
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

# Safe execution wrapper
safe_execute() {
    local operation="$1"
    local command="$2"
    local file_path="${3:-}"
    
    echo "🛡️  Safe execution check: $operation"
    
    # Check emergency stop
    if ! check_emergency_stop; then
        echo "❌ Operation blocked by emergency stop"
        return 1
    fi
    
    # Check circuit breaker
    if ! check_circuit_breaker "$operation"; then
        echo "❌ Operation blocked by circuit breaker"
        return 1
    fi
    
    # Check for dangerous operations
    if is_dangerous_operation "$command" "$file_path"; then
        echo "❌ Dangerous operation detected"
        read -p "⚠️  Continue? [y/N]: " confirm
        if [ "$confirm" != "y" ]; then
            echo "Operation cancelled"
            return 1
        fi
    fi
    
    # Log execution
    echo "$(date +%s):$operation" >> "$EXECUTION_LOG"
    
    # Execute command
    echo "✅ Executing: $operation"
    eval "$command"
    return $?
}

# Initialize framework circuit breakers
init_framework_protection() {
    echo "🔒 Initializing framework circuit breakers..."
    
    # Core operations with conservative limits
    init_circuit_breaker "setup" 2 7200          # 2 times per 2 hours
    init_circuit_breaker "sync_feedback" 3 3600  # 3 times per hour
    init_circuit_breaker "diagnose" 5 1800       # 5 times per 30 minutes
    init_circuit_breaker "audit" 3 3600          # 3 times per hour
    init_circuit_breaker "precommit" 10 300      # 10 times per 5 minutes
    init_circuit_breaker "quality" 5 1800        # 5 times per 30 minutes
    
    echo "✅ Framework circuit breakers initialized"
}

# Emergency recovery
emergency_recovery() {
    echo "🚨 Starting emergency recovery..."
    
    # Stop all processes
    pkill -f "ai-dev" 2>/dev/null || true
    
    # Clear circuit breakers
    rm -rf "$CIRCUIT_BREAKER_DIR"
    
    # Reinitialize
    init_framework_protection
    
    echo "✅ Emergency recovery completed"
}

# Main execution
if [ "$1" = "init" ]; then
    init_framework_protection
elif [ "$1" = "check" ]; then
    check_circuit_breaker "$2"
elif [ "$1" = "safe" ]; then
    safe_execute "$2" "$3" "$4"
elif [ "$1" = "emergency" ]; then
    emergency_recovery
elif [ "$1" = "stop" ]; then
    emergency_stop "$2"
elif [ "$1" = "clear" ]; then
    clear_emergency_stop
else
    echo "Usage: $0 {init|check|safe|emergency|stop|clear}"
    echo "  init                     - Initialize circuit breakers"
    echo "  check <operation>        - Check if operation is allowed"
    echo "  safe <op> <cmd> [file]   - Execute command safely"
    echo "  emergency                - Emergency recovery"
    echo "  stop <reason>            - Emergency stop"
    echo "  clear                    - Clear emergency stop"
fi