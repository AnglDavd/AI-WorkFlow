# Prevent Infinite Loops

## Overview
This workflow detects and prevents infinite loops in error correction attempts, workflow execution, and system operations. It implements intelligent pattern recognition, circuit breaker mechanisms, and escalation protocols to maintain system stability.

## Workflow Instructions

### For AI Agents
When implementing loop prevention:

1. **Monitor execution patterns** for repetitive behaviors
2. **Track attempt counts** and failure patterns
3. **Implement circuit breakers** for critical operations
4. **Detect recursive error patterns** before they become problematic
5. **Escalate intelligently** when loops are detected

### Loop Prevention Functions

#### Main Loop Prevention Function
```bash
# Main loop prevention function
prevent_infinite_loops() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local MAX_ATTEMPTS="$3"
    local TIME_WINDOW="$4"
    local OUTPUT_FILE="$5"
    
    if [ -z "$OPERATION_TYPE" ]; then
        echo "ERROR: Operation type is required"
        return 1
    fi
    
    if [ -z "$OPERATION_ID" ]; then
        OPERATION_ID="default_$(date +%s)"
    fi
    
    if [ -z "$MAX_ATTEMPTS" ]; then
        MAX_ATTEMPTS=5
    fi
    
    if [ -z "$TIME_WINDOW" ]; then
        TIME_WINDOW=300  # 5 minutes
    fi
    
    if [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE=".ai_workflow/loops/loop_prevention_$(date +%Y%m%d_%H%M%S).md"
    fi
    
    echo "Starting loop prevention monitoring..."
    echo "Operation Type: $OPERATION_TYPE"
    echo "Operation ID: $OPERATION_ID"
    echo "Max Attempts: $MAX_ATTEMPTS"
    echo "Time Window: $TIME_WINDOW seconds"
    echo "Output File: $OUTPUT_FILE"
    
    # Initialize loop monitoring
    init_loop_monitoring "$OUTPUT_FILE" "$OPERATION_TYPE" "$OPERATION_ID"
    
    # Check for existing loop patterns
    if check_existing_loops "$OPERATION_TYPE" "$OPERATION_ID" "$TIME_WINDOW" "$OUTPUT_FILE"; then
        echo "Loop detected - preventing execution"
        return 1
    fi
    
    # Register operation attempt
    register_operation_attempt "$OPERATION_TYPE" "$OPERATION_ID" "$OUTPUT_FILE"
    
    # Monitor for loop conditions
    if monitor_loop_conditions "$OPERATION_TYPE" "$OPERATION_ID" "$MAX_ATTEMPTS" "$TIME_WINDOW" "$OUTPUT_FILE"; then
        echo "Loop prevention successful"
        return 0
    else
        echo "Loop detected - circuit breaker activated"
        activate_circuit_breaker "$OPERATION_TYPE" "$OPERATION_ID" "$OUTPUT_FILE"
        return 1
    fi
}
```

#### Initialize Loop Monitoring
```bash
# Initialize loop monitoring
init_loop_monitoring() {
    local OUTPUT_FILE="$1"
    local OPERATION_TYPE="$2"
    local OPERATION_ID="$3"
    
    # Create monitoring directory
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    mkdir -p ".ai_workflow/loops/registry"
    mkdir -p ".ai_workflow/logs"
    
    cat > "$OUTPUT_FILE" << EOF
# Loop Prevention Report

## Monitoring Information
- **Operation Type**: $OPERATION_TYPE
- **Operation ID**: $OPERATION_ID
- **Monitoring Started**: $(date)
- **Prevention System**: Active

## Loop Detection Status
*Monitoring in progress...*

## Pattern Analysis
*Pattern analysis in progress...*

## Circuit Breaker Status
*Circuit breaker monitoring active...*

## Prevention Actions
*Actions will be logged here...*

EOF
    
    echo "Loop monitoring initialized: $OUTPUT_FILE"
}
```

#### Check Existing Loops
```bash
# Check for existing loop patterns
check_existing_loops() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local TIME_WINDOW="$3"
    local OUTPUT_FILE="$4"
    
    echo "Checking for existing loops..."
    
    local REGISTRY_FILE=".ai_workflow/loops/registry/${OPERATION_TYPE}_${OPERATION_ID}.log"
    local CURRENT_TIME=$(date +%s)
    local CUTOFF_TIME=$((CURRENT_TIME - TIME_WINDOW))
    
    # Check operation history
    if [ -f "$REGISTRY_FILE" ]; then
        local RECENT_ATTEMPTS=$(awk -v cutoff="$CUTOFF_TIME" '$1 > cutoff {print $0}' "$REGISTRY_FILE" | wc -l)
        
        if [ $RECENT_ATTEMPTS -gt 3 ]; then
            cat >> "$OUTPUT_FILE" << EOF
### Loop Detection Alert

#### Existing Loop Pattern Detected
- **Operation**: $OPERATION_TYPE - $OPERATION_ID
- **Recent Attempts**: $RECENT_ATTEMPTS in last $TIME_WINDOW seconds
- **Pattern**: Repetitive execution detected
- **Action**: Preventing new execution

#### Pattern Analysis
$(analyze_attempt_pattern "$REGISTRY_FILE" "$CUTOFF_TIME")

#### Recommended Actions
$(recommend_loop_resolution "$OPERATION_TYPE" "$RECENT_ATTEMPTS")

EOF
            
            # Log loop detection
            log_loop_detection "$OPERATION_TYPE" "$OPERATION_ID" "EXISTING_LOOP" "$RECENT_ATTEMPTS"
            
            return 0  # Loop detected
        fi
    fi
    
    # Check for recursive error patterns
    if check_recursive_error_patterns "$OPERATION_TYPE" "$OPERATION_ID" "$TIME_WINDOW" "$OUTPUT_FILE"; then
        return 0  # Recursive pattern detected
    fi
    
    # Check for circular dependencies
    if check_circular_dependencies "$OPERATION_TYPE" "$OPERATION_ID" "$OUTPUT_FILE"; then
        return 0  # Circular dependency detected
    fi
    
    return 1  # No loops detected
}
```

#### Register Operation Attempt
```bash
# Register operation attempt
register_operation_attempt() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local OUTPUT_FILE="$3"
    
    local REGISTRY_FILE=".ai_workflow/loops/registry/${OPERATION_TYPE}_${OPERATION_ID}.log"
    local CURRENT_TIME=$(date +%s)
    local TIMESTAMP=$(date)
    
    # Register the attempt
    echo "$CURRENT_TIME $TIMESTAMP $OPERATION_TYPE $OPERATION_ID" >> "$REGISTRY_FILE"
    
    # Log to main loop log
    local LOOP_LOG=".ai_workflow/logs/loop_operations.log"
    echo "$(date): REGISTERED: $OPERATION_TYPE - $OPERATION_ID" >> "$LOOP_LOG"
    
    cat >> "$OUTPUT_FILE" << EOF
### Operation Registration

#### Attempt Registered
- **Timestamp**: $TIMESTAMP
- **Operation**: $OPERATION_TYPE - $OPERATION_ID
- **Registry File**: $REGISTRY_FILE
- **Status**: Monitoring active

EOF
    
    echo "Operation attempt registered"
}
```

#### Monitor Loop Conditions
```bash
# Monitor loop conditions
monitor_loop_conditions() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local MAX_ATTEMPTS="$3"
    local TIME_WINDOW="$4"
    local OUTPUT_FILE="$5"
    
    echo "Monitoring loop conditions..."
    
    local REGISTRY_FILE=".ai_workflow/loops/registry/${OPERATION_TYPE}_${OPERATION_ID}.log"
    local CURRENT_TIME=$(date +%s)
    local CUTOFF_TIME=$((CURRENT_TIME - TIME_WINDOW))
    
    # Count recent attempts
    local RECENT_ATTEMPTS=0
    if [ -f "$REGISTRY_FILE" ]; then
        RECENT_ATTEMPTS=$(awk -v cutoff="$CUTOFF_TIME" '$1 > cutoff {print $0}' "$REGISTRY_FILE" | wc -l)
    fi
    
    # Check attempt threshold
    if [ $RECENT_ATTEMPTS -ge $MAX_ATTEMPTS ]; then
        cat >> "$OUTPUT_FILE" << EOF
### Loop Condition Alert

#### Threshold Exceeded
- **Recent Attempts**: $RECENT_ATTEMPTS
- **Max Allowed**: $MAX_ATTEMPTS
- **Time Window**: $TIME_WINDOW seconds
- **Detection Time**: $(date)

#### Loop Pattern Analysis
$(analyze_loop_pattern "$REGISTRY_FILE" "$CUTOFF_TIME")

#### Circuit Breaker Activation
- **Status**: ACTIVATED
- **Reason**: Attempt threshold exceeded
- **Cooldown Period**: $(calculate_cooldown_period "$RECENT_ATTEMPTS") seconds

EOF
        
        # Log loop condition
        log_loop_detection "$OPERATION_TYPE" "$OPERATION_ID" "THRESHOLD_EXCEEDED" "$RECENT_ATTEMPTS"
        
        return 1  # Loop condition detected
    fi
    
    # Check for rapid successive attempts
    if check_rapid_succession "$REGISTRY_FILE" "$TIME_WINDOW" "$OUTPUT_FILE"; then
        log_loop_detection "$OPERATION_TYPE" "$OPERATION_ID" "RAPID_SUCCESSION" "$RECENT_ATTEMPTS"
        return 1  # Rapid succession detected
    fi
    
    # Check for identical error patterns
    if check_identical_error_patterns "$OPERATION_TYPE" "$OPERATION_ID" "$OUTPUT_FILE"; then
        log_loop_detection "$OPERATION_TYPE" "$OPERATION_ID" "IDENTICAL_ERRORS" "$RECENT_ATTEMPTS"
        return 1  # Identical error pattern detected
    fi
    
    cat >> "$OUTPUT_FILE" << EOF
### Loop Monitoring Status

#### Current Status
- **Recent Attempts**: $RECENT_ATTEMPTS
- **Max Allowed**: $MAX_ATTEMPTS
- **Status**: Within normal parameters
- **Circuit Breaker**: OPEN (allowing operations)

EOF
    
    return 0  # No loop conditions detected
}
```

#### Analyze Attempt Pattern
```bash
# Analyze attempt pattern
analyze_attempt_pattern() {
    local REGISTRY_FILE="$1"
    local CUTOFF_TIME="$2"
    
    echo "**Pattern Analysis Results:**"
    echo ""
    
    if [ -f "$REGISTRY_FILE" ]; then
        local ATTEMPTS=$(awk -v cutoff="$CUTOFF_TIME" '$1 > cutoff {print $0}' "$REGISTRY_FILE")
        local ATTEMPT_COUNT=$(echo "$ATTEMPTS" | wc -l)
        
        if [ $ATTEMPT_COUNT -gt 0 ]; then
            local FIRST_ATTEMPT=$(echo "$ATTEMPTS" | head -1 | awk '{print $2}')
            local LAST_ATTEMPT=$(echo "$ATTEMPTS" | tail -1 | awk '{print $2}')
            local TIME_SPAN=$(echo "$ATTEMPTS" | head -1 | awk -v last="$(echo "$ATTEMPTS" | tail -1 | awk '{print $1}')" '{print last - $1}')
            
            echo "- **Attempt Count**: $ATTEMPT_COUNT"
            echo "- **Time Span**: $TIME_SPAN seconds"
            echo "- **First Attempt**: $FIRST_ATTEMPT"
            echo "- **Last Attempt**: $LAST_ATTEMPT"
            echo "- **Average Interval**: $(echo "scale=2; $TIME_SPAN / ($ATTEMPT_COUNT - 1)" | bc -l 2>/dev/null || echo "N/A") seconds"
            
            # Check for patterns
            if [ $TIME_SPAN -lt 60 ] && [ $ATTEMPT_COUNT -gt 3 ]; then
                echo "- **Pattern Type**: Rapid succession (high frequency)"
            elif [ $ATTEMPT_COUNT -gt 5 ]; then
                echo "- **Pattern Type**: Persistent retries (high volume)"
            else
                echo "- **Pattern Type**: Normal operation pattern"
            fi
        else
            echo "- **No recent attempts found**"
        fi
    else
        echo "- **No registry file found**"
    fi
}
```

#### Check Recursive Error Patterns
```bash
# Check for recursive error patterns
check_recursive_error_patterns() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local TIME_WINDOW="$3"
    local OUTPUT_FILE="$4"
    
    local ERROR_LOG=".ai_workflow/logs/error_history.log"
    local CURRENT_TIME=$(date +%s)
    local CUTOFF_TIME=$((CURRENT_TIME - TIME_WINDOW))
    
    if [ -f "$ERROR_LOG" ]; then
        # Check for identical error messages
        local RECENT_ERRORS=$(grep "$OPERATION_TYPE" "$ERROR_LOG" | tail -10)
        local UNIQUE_ERRORS=$(echo "$RECENT_ERRORS" | sort | uniq | wc -l)
        local TOTAL_ERRORS=$(echo "$RECENT_ERRORS" | wc -l)
        
        if [ $TOTAL_ERRORS -gt 0 ] && [ $UNIQUE_ERRORS -lt 3 ] && [ $TOTAL_ERRORS -gt 5 ]; then
            cat >> "$OUTPUT_FILE" << EOF
### Recursive Error Pattern Detected

#### Error Analysis
- **Total Recent Errors**: $TOTAL_ERRORS
- **Unique Error Types**: $UNIQUE_ERRORS
- **Pattern**: Same error recurring multiple times
- **Risk**: High likelihood of infinite error loop

#### Most Common Error
$(echo "$RECENT_ERRORS" | sort | uniq -c | sort -nr | head -1)

EOF
            return 0  # Recursive pattern detected
        fi
    fi
    
    return 1  # No recursive pattern
}
```

#### Check Circular Dependencies
```bash
# Check for circular dependencies
check_circular_dependencies() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local OUTPUT_FILE="$3"
    
    local DEPENDENCY_LOG=".ai_workflow/logs/dependency_chain.log"
    
    # Check if operation is waiting for itself
    if [ -f "$DEPENDENCY_LOG" ]; then
        local CIRCULAR_DEPS=$(grep "$OPERATION_ID" "$DEPENDENCY_LOG" | grep "WAITING_FOR" | grep "$OPERATION_ID")
        
        if [ -n "$CIRCULAR_DEPS" ]; then
            cat >> "$OUTPUT_FILE" << EOF
### Circular Dependency Detected

#### Dependency Analysis
- **Operation**: $OPERATION_ID
- **Circular Reference**: Operation waiting for itself
- **Risk**: Deadlock condition

#### Dependency Chain
$CIRCULAR_DEPS

EOF
            return 0  # Circular dependency detected
        fi
    fi
    
    return 1  # No circular dependencies
}
```

#### Check Rapid Succession
```bash
# Check for rapid succession attempts
check_rapid_succession() {
    local REGISTRY_FILE="$1"
    local TIME_WINDOW="$2"
    local OUTPUT_FILE="$3"
    
    if [ -f "$REGISTRY_FILE" ]; then
        local RECENT_ATTEMPTS=$(tail -5 "$REGISTRY_FILE")
        local ATTEMPT_COUNT=$(echo "$RECENT_ATTEMPTS" | wc -l)
        
        if [ $ATTEMPT_COUNT -ge 3 ]; then
            local FIRST_TIME=$(echo "$RECENT_ATTEMPTS" | head -1 | awk '{print $1}')
            local LAST_TIME=$(echo "$RECENT_ATTEMPTS" | tail -1 | awk '{print $1}')
            local TIME_DIFF=$((LAST_TIME - FIRST_TIME))
            
            # If 3+ attempts in less than 30 seconds
            if [ $TIME_DIFF -lt 30 ]; then
                cat >> "$OUTPUT_FILE" << EOF
### Rapid Succession Alert

#### Rapid Execution Pattern
- **Attempts**: $ATTEMPT_COUNT in $TIME_DIFF seconds
- **Pattern**: High-frequency execution
- **Risk**: Resource exhaustion or system overload

EOF
                return 0  # Rapid succession detected
            fi
        fi
    fi
    
    return 1  # No rapid succession
}
```

#### Check Identical Error Patterns
```bash
# Check for identical error patterns
check_identical_error_patterns() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local OUTPUT_FILE="$3"
    
    local ERROR_LOG=".ai_workflow/logs/error_history.log"
    
    if [ -f "$ERROR_LOG" ]; then
        # Get recent errors for this operation
        local RECENT_ERRORS=$(grep "$OPERATION_TYPE.*$OPERATION_ID" "$ERROR_LOG" | tail -5)
        
        if [ -n "$RECENT_ERRORS" ]; then
            # Check if all errors are identical
            local UNIQUE_ERRORS=$(echo "$RECENT_ERRORS" | awk '{$1=""; $2=""; print $0}' | sort | uniq | wc -l)
            local TOTAL_ERRORS=$(echo "$RECENT_ERRORS" | wc -l)
            
            if [ $TOTAL_ERRORS -ge 3 ] && [ $UNIQUE_ERRORS -eq 1 ]; then
                cat >> "$OUTPUT_FILE" << EOF
### Identical Error Pattern Alert

#### Error Repetition Analysis
- **Total Identical Errors**: $TOTAL_ERRORS
- **Error Message**: $(echo "$RECENT_ERRORS" | head -1 | awk '{$1=""; $2=""; print $0}')
- **Pattern**: Exact same error recurring
- **Risk**: Error handling loop

EOF
                return 0  # Identical pattern detected
            fi
        fi
    fi
    
    return 1  # No identical patterns
}
```

#### Activate Circuit Breaker
```bash
# Activate circuit breaker
activate_circuit_breaker() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local OUTPUT_FILE="$3"
    
    echo "Activating circuit breaker..."
    
    local BREAKER_FILE=".ai_workflow/loops/circuit_breakers/${OPERATION_TYPE}_${OPERATION_ID}.breaker"
    local CURRENT_TIME=$(date +%s)
    local COOLDOWN_PERIOD=$(calculate_cooldown_period "5")
    local RELEASE_TIME=$((CURRENT_TIME + COOLDOWN_PERIOD))
    
    # Create circuit breaker file
    mkdir -p "$(dirname "$BREAKER_FILE")"
    cat > "$BREAKER_FILE" << EOF
# Circuit Breaker Status
OPERATION_TYPE=$OPERATION_TYPE
OPERATION_ID=$OPERATION_ID
ACTIVATED_TIME=$CURRENT_TIME
RELEASE_TIME=$RELEASE_TIME
COOLDOWN_PERIOD=$COOLDOWN_PERIOD
STATUS=ACTIVE
REASON=Loop prevention
EOF
    
    cat >> "$OUTPUT_FILE" << EOF
### Circuit Breaker Activated

#### Breaker Information
- **Operation**: $OPERATION_TYPE - $OPERATION_ID
- **Activation Time**: $(date)
- **Cooldown Period**: $COOLDOWN_PERIOD seconds
- **Release Time**: $(date -d "@$RELEASE_TIME")
- **Breaker File**: $BREAKER_FILE

#### During Cooldown Period
- **Operation Status**: BLOCKED
- **New Attempts**: Will be rejected
- **Monitoring**: Continues in background
- **Recovery**: Automatic after cooldown

#### Recovery Actions
$(define_recovery_actions "$OPERATION_TYPE")

EOF
    
    # Log circuit breaker activation
    local LOOP_LOG=".ai_workflow/logs/loop_operations.log"
    echo "$(date): CIRCUIT_BREAKER_ACTIVATED: $OPERATION_TYPE - $OPERATION_ID - Cooldown: $COOLDOWN_PERIOD seconds" >> "$LOOP_LOG"
    
    echo "Circuit breaker activated: $BREAKER_FILE"
}
```

#### Calculate Cooldown Period
```bash
# Calculate cooldown period based on attempt count
calculate_cooldown_period() {
    local ATTEMPT_COUNT="$1"
    
    # Exponential backoff: base 30 seconds, doubles for each attempt over 3
    local BASE_COOLDOWN=30
    local EXTRA_ATTEMPTS=$((ATTEMPT_COUNT - 3))
    
    if [ $EXTRA_ATTEMPTS -gt 0 ]; then
        local MULTIPLIER=$((2 ** EXTRA_ATTEMPTS))
        local COOLDOWN=$((BASE_COOLDOWN * MULTIPLIER))
        
        # Cap at 30 minutes
        if [ $COOLDOWN -gt 1800 ]; then
            COOLDOWN=1800
        fi
        
        echo "$COOLDOWN"
    else
        echo "$BASE_COOLDOWN"
    fi
}
```

#### Recommend Loop Resolution
```bash
# Recommend loop resolution actions
recommend_loop_resolution() {
    local OPERATION_TYPE="$1"
    local ATTEMPT_COUNT="$2"
    
    echo "**Recommended Resolution Actions:**"
    echo ""
    
    case "$OPERATION_TYPE" in
        "error_correction")
            echo "1. **Review error analysis** for accuracy and completeness"
            echo "2. **Check correction strategies** for effectiveness"
            echo "3. **Consider manual intervention** for complex errors"
            echo "4. **Update error patterns** if this is a new error type"
            ;;
        "tool_execution")
            echo "1. **Validate tool parameters** for correctness"
            echo "2. **Check tool availability** and configuration"
            echo "3. **Review tool dependencies** and requirements"
            echo "4. **Consider alternative tools** if available"
            ;;
        "workflow_execution")
            echo "1. **Review workflow definition** for logical errors"
            echo "2. **Check input parameters** and conditions"
            echo "3. **Validate workflow dependencies** are met"
            echo "4. **Consider workflow simplification** or breaking into steps"
            ;;
        "file_operation")
            echo "1. **Verify file paths** and permissions"
            echo "2. **Check file system space** and availability"
            echo "3. **Validate file formats** and content"
            echo "4. **Review file operation logic** for errors"
            ;;
        *)
            echo "1. **Analyze operation parameters** for correctness"
            echo "2. **Review operation logic** for potential issues"
            echo "3. **Check external dependencies** and requirements"
            echo "4. **Consider alternative approaches** to achieve the goal"
            ;;
    esac
    
    echo ""
    echo "**Escalation Actions:**"
    echo "- If attempts > 5: Escalate to user immediately"
    echo "- If attempts > 10: Consider system-level intervention"
    echo "- If pattern persists: Review framework logic for bugs"
}
```

#### Check Circuit Breaker Status
```bash
# Check if circuit breaker is active
check_circuit_breaker_status() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    
    local BREAKER_FILE=".ai_workflow/loops/circuit_breakers/${OPERATION_TYPE}_${OPERATION_ID}.breaker"
    local CURRENT_TIME=$(date +%s)
    
    if [ -f "$BREAKER_FILE" ]; then
        source "$BREAKER_FILE"
        
        if [ "$STATUS" = "ACTIVE" ] && [ $CURRENT_TIME -lt $RELEASE_TIME ]; then
            local REMAINING=$((RELEASE_TIME - CURRENT_TIME))
            echo "BLOCKED:$REMAINING"
            return 0
        else
            # Circuit breaker expired, remove it
            rm -f "$BREAKER_FILE"
            echo "OPEN"
            return 1
        fi
    else
        echo "OPEN"
        return 1
    fi
}
```

#### Log Loop Detection
```bash
# Log loop detection event
log_loop_detection() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local DETECTION_TYPE="$3"
    local ATTEMPT_COUNT="$4"
    
    local LOOP_LOG=".ai_workflow/logs/loop_detections.log"
    mkdir -p "$(dirname "$LOOP_LOG")"
    
    echo "$(date): LOOP_DETECTED: $DETECTION_TYPE - $OPERATION_TYPE - $OPERATION_ID - Attempts: $ATTEMPT_COUNT" >> "$LOOP_LOG"
    
    # Also log to main system log
    local SYSTEM_LOG=".ai_workflow/logs/system.log"
    echo "$(date): LOOP_PREVENTION: $DETECTION_TYPE detected for $OPERATION_TYPE ($OPERATION_ID)" >> "$SYSTEM_LOG"
}
```

#### Define Recovery Actions
```bash
# Define recovery actions for circuit breaker
define_recovery_actions() {
    local OPERATION_TYPE="$1"
    
    echo "**Automatic Recovery Actions:**"
    echo "- Circuit breaker will automatically reset after cooldown"
    echo "- Operation history will be cleared"
    echo "- Fresh execution context will be established"
    echo ""
    echo "**Manual Recovery Options:**"
    echo "- Review and fix underlying issues before retry"
    echo "- Clear circuit breaker manually if issue is resolved"
    echo "- Escalate to user if problem persists"
    echo ""
    echo "**Prevention Measures:**"
    echo "- Implement better error handling for $OPERATION_TYPE"
    echo "- Add input validation to prevent problematic scenarios"
    echo "- Consider implementing operation timeouts"
}
```

#### Analyze Loop Pattern
```bash
# Analyze detected loop pattern
analyze_loop_pattern() {
    local REGISTRY_FILE="$1"
    local CUTOFF_TIME="$2"
    
    echo "**Loop Pattern Analysis:**"
    echo ""
    
    if [ -f "$REGISTRY_FILE" ]; then
        local ATTEMPTS=$(awk -v cutoff="$CUTOFF_TIME" '$1 > cutoff {print $0}' "$REGISTRY_FILE")
        
        if [ -n "$ATTEMPTS" ]; then
            local ATTEMPT_COUNT=$(echo "$ATTEMPTS" | wc -l)
            local TIME_SPAN=$(echo "$ATTEMPTS" | awk 'NR==1{first=$1} END{print $1-first}')
            local AVG_INTERVAL=$(echo "scale=2; $TIME_SPAN / ($ATTEMPT_COUNT - 1)" | bc -l 2>/dev/null || echo "N/A")
            
            echo "- **Loop Characteristics:**"
            echo "  - Total attempts in pattern: $ATTEMPT_COUNT"
            echo "  - Time span: $TIME_SPAN seconds"
            echo "  - Average interval: $AVG_INTERVAL seconds"
            
            if [ $(echo "$AVG_INTERVAL < 10" | bc -l 2>/dev/null || echo "0") -eq 1 ]; then
                echo "  - Pattern type: High-frequency loop (very rapid)"
            elif [ $(echo "$AVG_INTERVAL < 60" | bc -l 2>/dev/null || echo "0") -eq 1 ]; then
                echo "  - Pattern type: Medium-frequency loop (rapid)"
            else
                echo "  - Pattern type: Low-frequency loop (persistent)"
            fi
            
            echo ""
            echo "- **Risk Assessment:**"
            if [ $ATTEMPT_COUNT -gt 10 ]; then
                echo "  - Risk level: HIGH (excessive attempts)"
            elif [ $ATTEMPT_COUNT -gt 5 ]; then
                echo "  - Risk level: MEDIUM (concerning pattern)"
            else
                echo "  - Risk level: LOW (manageable pattern)"
            fi
        fi
    fi
}
```

### Advanced Loop Prevention

#### Clear Circuit Breaker
```bash
# Clear circuit breaker manually
clear_circuit_breaker() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    local REASON="$3"
    
    local BREAKER_FILE=".ai_workflow/loops/circuit_breakers/${OPERATION_TYPE}_${OPERATION_ID}.breaker"
    
    if [ -f "$BREAKER_FILE" ]; then
        local REASON_TEXT="${REASON:-Manual override}"
        
        # Log the clearing
        echo "$(date): CIRCUIT_BREAKER_CLEARED: $OPERATION_TYPE - $OPERATION_ID - Reason: $REASON_TEXT" >> ".ai_workflow/logs/loop_operations.log"
        
        # Remove the breaker file
        rm -f "$BREAKER_FILE"
        
        echo "Circuit breaker cleared for $OPERATION_TYPE - $OPERATION_ID"
        return 0
    else
        echo "No active circuit breaker found for $OPERATION_TYPE - $OPERATION_ID"
        return 1
    fi
}
```

#### Reset Loop Monitoring
```bash
# Reset loop monitoring for an operation
reset_loop_monitoring() {
    local OPERATION_TYPE="$1"
    local OPERATION_ID="$2"
    
    local REGISTRY_FILE=".ai_workflow/loops/registry/${OPERATION_TYPE}_${OPERATION_ID}.log"
    local BREAKER_FILE=".ai_workflow/loops/circuit_breakers/${OPERATION_TYPE}_${OPERATION_ID}.breaker"
    
    # Clear registry
    if [ -f "$REGISTRY_FILE" ]; then
        rm -f "$REGISTRY_FILE"
        echo "Registry cleared: $REGISTRY_FILE"
    fi
    
    # Clear circuit breaker
    if [ -f "$BREAKER_FILE" ]; then
        rm -f "$BREAKER_FILE"
        echo "Circuit breaker cleared: $BREAKER_FILE"
    fi
    
    # Log the reset
    echo "$(date): LOOP_MONITORING_RESET: $OPERATION_TYPE - $OPERATION_ID" >> ".ai_workflow/logs/loop_operations.log"
    
    echo "Loop monitoring reset for $OPERATION_TYPE - $OPERATION_ID"
}
```

#### Get Loop Statistics
```bash
# Get loop prevention statistics
get_loop_statistics() {
    local TIME_PERIOD="$1"
    
    if [ -z "$TIME_PERIOD" ]; then
        TIME_PERIOD=86400  # 24 hours
    fi
    
    local CURRENT_TIME=$(date +%s)
    local CUTOFF_TIME=$((CURRENT_TIME - TIME_PERIOD))
    local LOOP_LOG=".ai_workflow/logs/loop_detections.log"
    
    echo "Loop Prevention Statistics (Last $((TIME_PERIOD / 3600)) hours):"
    echo ""
    
    if [ -f "$LOOP_LOG" ]; then
        local TOTAL_DETECTIONS=$(awk -v cutoff="$CUTOFF_TIME" '$1 > cutoff' "$LOOP_LOG" | wc -l)
        local THRESHOLD_EXCEEDED=$(grep "THRESHOLD_EXCEEDED" "$LOOP_LOG" | awk -v cutoff="$CUTOFF_TIME" '$1 > cutoff' | wc -l)
        local RAPID_SUCCESSION=$(grep "RAPID_SUCCESSION" "$LOOP_LOG" | awk -v cutoff="$CUTOFF_TIME" '$1 > cutoff' | wc -l)
        local IDENTICAL_ERRORS=$(grep "IDENTICAL_ERRORS" "$LOOP_LOG" | awk -v cutoff="$CUTOFF_TIME" '$1 > cutoff' | wc -l)
        
        echo "- Total loop detections: $TOTAL_DETECTIONS"
        echo "- Threshold exceeded: $THRESHOLD_EXCEEDED"
        echo "- Rapid succession: $RAPID_SUCCESSION"
        echo "- Identical errors: $IDENTICAL_ERRORS"
        
        # Active circuit breakers
        local ACTIVE_BREAKERS=$(find ".ai_workflow/loops/circuit_breakers" -name "*.breaker" 2>/dev/null | wc -l)
        echo "- Active circuit breakers: $ACTIVE_BREAKERS"
    else
        echo "- No loop detection data available"
    fi
}
```

## Integration with Framework

### With Error Management
- Prevents infinite error correction loops
- Integrates with auto-correction attempt limits
- Coordinates with escalation mechanisms

### With Workflow Execution
- Monitors workflow retry patterns
- Prevents recursive workflow calls
- Maintains execution state consistency

### With Tool Abstraction
- Tracks tool execution patterns
- Prevents tool call loops
- Monitors abstract tool performance

### With State Management
- Coordinates with rollback mechanisms
- Maintains state consistency during recovery
- Supports circuit breaker state persistence

## Usage Examples

### Basic Loop Prevention
```bash
# Monitor error correction attempts
prevent_infinite_loops "error_correction" "syntax_error_fix" 3 300

# Check circuit breaker status
check_circuit_breaker_status "error_correction" "syntax_error_fix"

# Clear circuit breaker if needed
clear_circuit_breaker "error_correction" "syntax_error_fix" "Issue resolved"
```

### Workflow Integration
```bash
# Before critical operation
OPERATION_ID="workflow_$(date +%s)"
if prevent_infinite_loops "workflow_execution" "$OPERATION_ID" 5 600; then
    # Proceed with operation
    execute_workflow
else
    echo "Operation blocked by loop prevention"
fi
```

### Advanced Monitoring
```bash
# Get statistics
get_loop_statistics 86400

# Reset monitoring for problematic operation
reset_loop_monitoring "tool_execution" "git_operation"

# Check for active circuit breakers
find .ai_workflow/loops/circuit_breakers -name "*.breaker" -type f
```

## Notes
- Loop prevention is proactive and intelligent
- Circuit breakers provide automatic recovery
- Pattern recognition prevents various loop types
- Integration with all framework error handling
- Supports manual intervention when needed
- Comprehensive logging for analysis and debugging
- Designed to maintain system stability without blocking legitimate operations