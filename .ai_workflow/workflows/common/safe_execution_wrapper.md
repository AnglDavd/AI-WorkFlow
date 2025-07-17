# Safe Execution Wrapper

## Purpose
Provides a secure execution environment for all framework operations with circuit breaker protection.

## Implementation

### 1. Main Safe Execution Function

```bash
#!/bin/bash

# Source circuit breaker functions
source "$(dirname "$0")/circuit_breaker.md"

# Initialize framework-wide circuit breakers
init_framework_circuit_breakers() {
    echo "🔒 Initializing framework circuit breakers..."
    
    # Core operations with conservative limits
    init_circuit_breaker "setup" 2 7200          # 2 times per 2 hours
    init_circuit_breaker "sync_feedback" 3 3600  # 3 times per hour
    init_circuit_breaker "auto_optimize" 1 1800  # 1 time per 30 minutes
    init_circuit_breaker "diagnose" 5 1800       # 5 times per 30 minutes
    init_circuit_breaker "audit" 3 3600          # 3 times per hour
    init_circuit_breaker "precommit" 10 300      # 10 times per 5 minutes
    init_circuit_breaker "quality" 5 1800        # 5 times per 30 minutes
    init_circuit_breaker "generate" 2 3600       # 2 times per hour
    init_circuit_breaker "run" 3 1800            # 3 times per 30 minutes
    
    # GitHub Actions specific limits
    init_circuit_breaker "github_feedback_validate" 20 300  # 20 times per 5 minutes
    init_circuit_breaker "github_sync" 1 1800               # 1 time per 30 minutes
    init_circuit_breaker "github_release" 1 86400           # 1 time per day
    
    echo "✅ Framework circuit breakers initialized"
}

# Enhanced safe command execution with all protections
safe_framework_execute() {
    local operation="$1"
    local command="$2"
    local file_path="${3:-}"
    local allow_dangerous="${4:-false}"
    
    echo "🛡️  Framework safe execution: $operation"
    
    # Check emergency stop first
    if ! check_emergency_stop; then
        echo "❌ Emergency stop active - all operations blocked"
        return 1
    fi
    
    # Check circuit breaker
    if ! check_circuit_breaker "$operation"; then
        echo "❌ Operation blocked by circuit breaker: $operation"
        return 1
    fi
    
    # Check for loop patterns
    if detect_loop_pattern "$operation"; then
        echo "🚨 Loop pattern detected for: $operation"
        if [ "$allow_dangerous" != "true" ]; then
            emergency_stop "Loop pattern detected in $operation"
            return 1
        fi
    fi
    
    # Check for dangerous operations
    if is_dangerous_operation "$command" "$file_path"; then
        echo "🚨 Dangerous operation detected: $operation"
        echo "   Command: $command"
        echo "   File: $file_path"
        
        if [ "$allow_dangerous" != "true" ] && [ "$FORCE_DANGEROUS_OPERATIONS" != "true" ]; then
            echo "❌ Dangerous operation blocked for safety"
            return 1
        fi
        
        # Log dangerous operation
        echo "$(date): Dangerous operation executed: $operation - $command" >> "$CIRCUIT_BREAKER_DIR/dangerous_operations.log"
    fi
    
    # Pre-execution validation
    if ! validate_execution_environment "$operation"; then
        echo "❌ Execution environment validation failed"
        return 1
    fi
    
    # Execute with timeout protection
    execute_with_timeout "$operation" "$command" 300  # 5 minute timeout
    local exit_code=$?
    
    # Post-execution validation
    if [ $exit_code -eq 0 ]; then
        validate_execution_results "$operation" "$command"
    else
        handle_execution_failure "$operation" "$command" $exit_code
    fi
    
    return $exit_code
}

# Execution environment validation
validate_execution_environment() {
    local operation="$1"
    
    # Check disk space
    local available_space=$(df . | awk 'NR==2 {print $4}')
    if [ $available_space -lt 100000 ]; then  # Less than 100MB
        echo "⚠️  Low disk space: ${available_space}KB available"
        return 1
    fi
    
    # Check memory usage
    local memory_usage=$(free | awk 'NR==2{printf "%.2f%%", $3*100/$2}')
    if [ "$(echo "$memory_usage" | cut -d'%' -f1 | cut -d'.' -f1)" -gt 90 ]; then
        echo "⚠️  High memory usage: $memory_usage"
        return 1
    fi
    
    # Check for required files
    local required_files=(
        ".ai_workflow/"
        "ai-dev"
        "CLAUDE.md"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -e "$file" ]; then
            echo "⚠️  Required file missing: $file"
            return 1
        fi
    done
    
    # Check for active processes that might conflict
    if pgrep -f "ai-dev" > /dev/null && [ "$operation" != "status" ]; then
        echo "⚠️  Another ai-dev process is running"
        return 1
    fi
    
    return 0
}

# Execute with timeout protection
execute_with_timeout() {
    local operation="$1"
    local command="$2"
    local timeout="${3:-300}"  # 5 minutes default
    
    echo "⏱️  Executing with timeout: ${timeout}s"
    
    # Create timeout wrapper
    (
        # Set timeout
        trap 'echo "⏰ Timeout reached for: $operation"; kill $$' TERM
        
        # Execute command in subshell
        (
            eval "$command"
        ) &
        
        local cmd_pid=$!
        
        # Start timeout timer
        (
            sleep $timeout
            if kill -0 $cmd_pid 2>/dev/null; then
                echo "🚨 Timeout exceeded for: $operation"
                kill -TERM $cmd_pid
                emergency_stop "Timeout in operation: $operation"
            fi
        ) &
        
        local timeout_pid=$!
        
        # Wait for command to complete
        wait $cmd_pid
        local exit_code=$?
        
        # Kill timeout timer
        kill $timeout_pid 2>/dev/null
        
        exit $exit_code
    )
}

# Validate execution results
validate_execution_results() {
    local operation="$1"
    local command="$2"
    
    echo "🔍 Validating execution results: $operation"
    
    # Check for common failure indicators
    if [ -f ".ai_workflow/logs/error.log" ]; then
        local recent_errors=$(tail -10 ".ai_workflow/logs/error.log" | grep "$(date +%Y-%m-%d)" | wc -l)
        if [ $recent_errors -gt 5 ]; then
            echo "⚠️  High error rate detected: $recent_errors errors today"
            return 1
        fi
    fi
    
    # Check for file system corruption
    if ! ls .ai_workflow/ > /dev/null 2>&1; then
        echo "🚨 Framework directory corruption detected"
        emergency_stop "File system corruption in .ai_workflow/"
        return 1
    fi
    
    # Operation-specific validations
    case "$operation" in
        "setup")
            if [ ! -f ".ai_workflow/temp_state.vars" ] && [ ! -f ".ai_workflow/.setup_complete" ]; then
                echo "⚠️  Setup validation failed - no state files found"
                return 1
            fi
            ;;
        "sync_feedback")
            if [ ! -d ".ai_workflow/feedback" ]; then
                echo "⚠️  Feedback sync validation failed - no feedback directory"
                return 1
            fi
            ;;
        "diagnose")
            if [ ! -f ".ai_workflow/logs/diagnostic_$(date +%Y%m%d)_"*.txt ]; then
                echo "⚠️  Diagnostic validation failed - no diagnostic log found"
                return 1
            fi
            ;;
    esac
    
    echo "✅ Execution results validated"
    return 0
}

# Handle execution failure
handle_execution_failure() {
    local operation="$1"
    local command="$2"
    local exit_code="$3"
    
    echo "❌ Execution failed: $operation (exit code: $exit_code)"
    
    # Log failure
    local failure_log="$CIRCUIT_BREAKER_DIR/execution_failures.log"
    echo "$(date): FAILURE - $operation (exit: $exit_code) - $command" >> "$failure_log"
    
    # Check for critical failures
    if [ $exit_code -eq 130 ]; then  # SIGINT
        echo "🚨 Operation interrupted by user"
    elif [ $exit_code -eq 137 ]; then  # SIGKILL
        echo "🚨 Operation killed (possibly by timeout)"
        emergency_stop "Operation killed: $operation"
    elif [ $exit_code -eq 139 ]; then  # SIGSEGV
        echo "🚨 Segmentation fault detected"
        emergency_stop "Segmentation fault in: $operation"
    fi
    
    # Increment failure counter
    local failure_count_file="$CIRCUIT_BREAKER_DIR/failure_count_$operation"
    local current_count=$(cat "$failure_count_file" 2>/dev/null || echo "0")
    local new_count=$((current_count + 1))
    echo "$new_count" > "$failure_count_file"
    
    # Check if we should emergency stop
    if [ $new_count -ge 3 ]; then
        echo "🚨 Too many failures for: $operation ($new_count)"
        emergency_stop "Too many failures: $operation"
    fi
    
    return $exit_code
}

# Framework-specific safe operations
safe_setup() {
    safe_framework_execute "setup" "./ai-dev setup" ""
}

safe_sync_feedback() {
    safe_framework_execute "sync_feedback" "./ai-dev sync feedback" ""
}

safe_diagnose() {
    safe_framework_execute "diagnose" "./ai-dev diagnose" ""
}

safe_audit() {
    safe_framework_execute "audit" "./ai-dev audit" ""
}

safe_precommit() {
    local action="${1:-validate}"
    safe_framework_execute "precommit" "./ai-dev precommit $action" ""
}

safe_quality() {
    local path="${1:-.}"
    safe_framework_execute "quality" "./ai-dev quality $path" "$path"
}

# Emergency recovery procedures
emergency_recovery() {
    echo "🚨 Starting emergency recovery procedures..."
    
    # Stop all running processes
    pkill -f "ai-dev" || true
    pkill -f ".ai_workflow" || true
    
    # Clear all circuit breakers
    echo "🔄 Clearing all circuit breakers..."
    rm -f "$CIRCUIT_BREAKER_DIR/circuit_state.json"
    
    # Reset execution sequence
    rm -f "$CIRCUIT_BREAKER_DIR/execution_sequence.log"
    
    # Clear emergency stop
    clear_emergency_stop
    
    # Reinitialize circuit breakers
    init_framework_circuit_breakers
    
    echo "✅ Emergency recovery completed"
}

# Health check for circuit breaker system
circuit_breaker_health_check() {
    echo "🔍 Circuit breaker health check..."
    
    # Check if circuit breaker directory exists
    if [ ! -d "$CIRCUIT_BREAKER_DIR" ]; then
        echo "⚠️  Circuit breaker directory missing - initializing..."
        init_framework_circuit_breakers
        return 1
    fi
    
    # Check for corrupted state files
    if [ -f "$CIRCUIT_STATE_FILE" ]; then
        if ! jq empty "$CIRCUIT_STATE_FILE" 2>/dev/null; then
            echo "⚠️  Corrupted circuit state file - resetting..."
            echo "{}" > "$CIRCUIT_STATE_FILE"
        fi
    fi
    
    # Check for old log files
    find "$CIRCUIT_BREAKER_DIR" -name "*.log" -mtime +7 -delete
    
    echo "✅ Circuit breaker health check completed"
    return 0
}

# Initialize on source
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    # Being sourced - initialize circuit breakers
    init_framework_circuit_breakers
    circuit_breaker_health_check
fi
```

## Usage in Framework

### Integration Example
```bash
# In ai-dev script
source .ai_workflow/workflows/common/safe_execution_wrapper.md

# Replace direct calls with safe calls
case "$1" in
    "setup")
        safe_setup
        ;;
    "sync")
        case "$2" in
            "feedback")
                safe_sync_feedback
                ;;
        esac
        ;;
    "diagnose")
        safe_diagnose
        ;;
    "audit")
        safe_audit
        ;;
    "precommit")
        safe_precommit "$2"
        ;;
    "quality")
        safe_quality "$2"
        ;;
esac
```

### GitHub Actions Integration
```yaml
- name: Safe Framework Operation
  run: |
    source .ai_workflow/workflows/common/safe_execution_wrapper.md
    safe_diagnose
```

## Benefits

1. **Complete Loop Protection**: Prevents all types of infinite loops
2. **Resource Protection**: Monitors disk space, memory, and processes
3. **Timeout Protection**: Prevents hanging operations
4. **Emergency Recovery**: Provides complete system recovery
5. **Audit Trail**: Logs all operations and failures
6. **Configurable Limits**: Adjustable per operation
7. **Health Monitoring**: Continuous system health checks