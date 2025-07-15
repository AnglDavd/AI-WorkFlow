# Collect Token Usage

## Overview
This workflow automatically collects token usage data during AI model interactions, providing real-time tracking for the framework's token economy optimization. It integrates with various AI providers to capture accurate usage metrics.

## Workflow Instructions

### For AI Agents
When collecting token usage data:

1. **Initialize tracking** at the start of AI interactions
2. **Capture usage data** from API responses
3. **Store data** in the centralized token usage file
4. **Calculate costs** using current pricing models
5. **Generate alerts** for unusual usage patterns

### Token Collection Functions

#### Initialize Token Tracking
```bash
# Initialize token tracking for a session
init_token_tracking() {
    local SESSION_ID="$1"
    local MODEL_PROVIDER="$2"
    local MODEL_NAME="$3"
    
    if [ -z "$SESSION_ID" ]; then
        SESSION_ID="session_$(date +%Y%m%d_%H%M%S)_$$"
    fi
    
    # Create session tracking file
    local SESSION_DIR=".ai_workflow/monitoring/sessions"
    mkdir -p "$SESSION_DIR"
    
    local SESSION_FILE="$SESSION_DIR/${SESSION_ID}.md"
    
    cat > "$SESSION_FILE" << EOF
# Token Usage Session: $SESSION_ID

## Session Information
- **Session ID**: $SESSION_ID
- **Model Provider**: $MODEL_PROVIDER
- **Model Name**: $MODEL_NAME
- **Started**: $(date)
- **Status**: active

## Usage Tracking
| Call | Timestamp | Input Tokens | Output Tokens | Total Tokens | Cost |
|------|-----------|--------------|---------------|--------------|------|

## Session Summary
- **Total Calls**: 0
- **Total Input Tokens**: 0
- **Total Output Tokens**: 0
- **Total Tokens**: 0
- **Total Cost**: $0.00

EOF
    
    # Export session variables
    export TOKEN_SESSION_ID="$SESSION_ID"
    export TOKEN_SESSION_FILE="$SESSION_FILE"
    export TOKEN_MODEL_PROVIDER="$MODEL_PROVIDER"
    export TOKEN_MODEL_NAME="$MODEL_NAME"
    export TOKEN_CALL_COUNT=0
    export TOKEN_TOTAL_INPUT=0
    export TOKEN_TOTAL_OUTPUT=0
    export TOKEN_TOTAL_TOKENS=0
    export TOKEN_TOTAL_COST=0
    
    echo "Token tracking initialized: $SESSION_ID"
}
```

#### Record Token Usage
```bash
# Record token usage for a single API call
record_token_usage() {
    local INPUT_TOKENS="$1"
    local OUTPUT_TOKENS="$2"
    local PROVIDER="$3"
    local MODEL="$4"
    local ADDITIONAL_INFO="$5"
    
    if [ -z "$TOKEN_SESSION_FILE" ]; then
        echo "ERROR: Token tracking not initialized"
        return 1
    fi
    
    # Calculate totals
    local TOTAL_TOKENS=$((INPUT_TOKENS + OUTPUT_TOKENS))
    local COST=$(calculate_token_cost "$PROVIDER" "$MODEL" "$INPUT_TOKENS" "$OUTPUT_TOKENS")
    
    # Update session counters
    TOKEN_CALL_COUNT=$((TOKEN_CALL_COUNT + 1))
    TOKEN_TOTAL_INPUT=$((TOKEN_TOTAL_INPUT + INPUT_TOKENS))
    TOKEN_TOTAL_OUTPUT=$((TOKEN_TOTAL_OUTPUT + OUTPUT_TOKENS))
    TOKEN_TOTAL_TOKENS=$((TOKEN_TOTAL_TOKENS + TOTAL_TOKENS))
    TOKEN_TOTAL_COST=$(echo "$TOKEN_TOTAL_COST + $COST" | bc -l)
    
    # Add entry to session file
    local TIMESTAMP=$(date)
    echo "| $TOKEN_CALL_COUNT | $TIMESTAMP | $INPUT_TOKENS | $OUTPUT_TOKENS | $TOTAL_TOKENS | \$$COST |" >> "$TOKEN_SESSION_FILE"
    
    # Update session summary
    update_session_summary
    
    # Log to main token usage file
    log_to_main_usage_file "$PROVIDER" "$MODEL" "$INPUT_TOKENS" "$OUTPUT_TOKENS" "$TOTAL_TOKENS" "$COST"
    
    echo "Token usage recorded: $INPUT_TOKENS input, $OUTPUT_TOKENS output, \$$COST cost"
}
```

#### Calculate Token Cost
```bash
# Calculate cost based on provider and model
calculate_token_cost() {
    local PROVIDER="$1"
    local MODEL="$2"
    local INPUT_TOKENS="$3"
    local OUTPUT_TOKENS="$4"
    
    local COST=0
    
    # Pricing as of 2025 (approximate)
    case "$PROVIDER" in
        "openai")
            case "$MODEL" in
                "gpt-4")
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.00003) + ($OUTPUT_TOKENS * 0.00006)" | bc -l)
                    ;;
                "gpt-3.5-turbo")
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.0000015) + ($OUTPUT_TOKENS * 0.000002)" | bc -l)
                    ;;
                *)
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.00003) + ($OUTPUT_TOKENS * 0.00006)" | bc -l)
                    ;;
            esac
            ;;
        "anthropic")
            case "$MODEL" in
                "claude-3-opus")
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.000015) + ($OUTPUT_TOKENS * 0.000075)" | bc -l)
                    ;;
                "claude-3-sonnet")
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.000003) + ($OUTPUT_TOKENS * 0.000015)" | bc -l)
                    ;;
                "claude-3-haiku")
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.00000025) + ($OUTPUT_TOKENS * 0.00000125)" | bc -l)
                    ;;
                *)
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.000015) + ($OUTPUT_TOKENS * 0.000075)" | bc -l)
                    ;;
            esac
            ;;
        "google")
            case "$MODEL" in
                "gemini-1.5-pro")
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.000001) + ($OUTPUT_TOKENS * 0.000003)" | bc -l)
                    ;;
                "gemini-1.5-flash")
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.0000001) + ($OUTPUT_TOKENS * 0.0000003)" | bc -l)
                    ;;
                *)
                    COST=$(echo "scale=6; ($INPUT_TOKENS * 0.000001) + ($OUTPUT_TOKENS * 0.000003)" | bc -l)
                    ;;
            esac
            ;;
        *)
            # Default generic pricing
            COST=$(echo "scale=6; ($INPUT_TOKENS * 0.00001) + ($OUTPUT_TOKENS * 0.00003)" | bc -l)
            ;;
    esac
    
    echo "$COST"
}
```

#### Update Session Summary
```bash
# Update session summary in session file
update_session_summary() {
    if [ -z "$TOKEN_SESSION_FILE" ]; then
        return 1
    fi
    
    # Update summary section
    sed -i "/Total Calls/c\- **Total Calls**: $TOKEN_CALL_COUNT" "$TOKEN_SESSION_FILE"
    sed -i "/Total Input Tokens/c\- **Total Input Tokens**: $TOKEN_TOTAL_INPUT" "$TOKEN_SESSION_FILE"
    sed -i "/Total Output Tokens/c\- **Total Output Tokens**: $TOKEN_TOTAL_OUTPUT" "$TOKEN_SESSION_FILE"
    sed -i "/Total Tokens/c\- **Total Tokens**: $TOKEN_TOTAL_TOKENS" "$TOKEN_SESSION_FILE"
    sed -i "/Total Cost/c\- **Total Cost**: \$$TOKEN_TOTAL_COST" "$TOKEN_SESSION_FILE"
}
```

#### Log to Main Usage File
```bash
# Log token usage to main usage file
log_to_main_usage_file() {
    local PROVIDER="$1"
    local MODEL="$2"
    local INPUT_TOKENS="$3"
    local OUTPUT_TOKENS="$4"
    local TOTAL_TOKENS="$5"
    local COST="$6"
    
    local USAGE_FILE=".ai_workflow/work_journal/token_usage.md"
    
    # Create new session entry
    local SESSION_COUNT=$(grep -c "#### Session" "$USAGE_FILE")
    local NEW_SESSION_COUNT=$((SESSION_COUNT + 1))
    
    # Add new session entry
    cat >> "$USAGE_FILE" << EOF

#### Session $NEW_SESSION_COUNT - $PROVIDER $MODEL
- **Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Model Provider**: $PROVIDER
- **Model Name**: $MODEL
- **Input Tokens**: $INPUT_TOKENS
- **Output Tokens**: $OUTPUT_TOKENS
- **Total Tokens**: $TOTAL_TOKENS
- **Cost Estimate**: \$$COST (approx.)
EOF
    
    # Update summary table
    update_main_usage_summary "$PROVIDER" "$MODEL" "$TOTAL_TOKENS" "$COST"
}
```

#### Update Main Usage Summary
```bash
# Update main usage summary table
update_main_usage_summary() {
    local PROVIDER="$1"
    local MODEL="$2"
    local TOTAL_TOKENS="$3"
    local COST="$4"
    
    local USAGE_FILE=".ai_workflow/work_journal/token_usage.md"
    
    # Read current summary and update
    local CURRENT_SESSIONS=$(grep -c "#### Session" "$USAGE_FILE")
    local CURRENT_TOTAL_TOKENS=$(grep "| \*\*TOTAL\*\*" "$USAGE_FILE" | cut -d'|' -f5 | tr -d ' ,')
    local CURRENT_TOTAL_COST=$(grep "Total Estimated Cost" "$USAGE_FILE" | cut -d'$' -f2 | cut -d' ' -f1)
    
    # Calculate new totals
    local NEW_TOTAL_TOKENS=$((CURRENT_TOTAL_TOKENS + TOTAL_TOKENS))
    local NEW_TOTAL_COST=$(echo "$CURRENT_TOTAL_COST + $COST" | bc -l)
    local NEW_AVERAGE=$((NEW_TOTAL_TOKENS / CURRENT_SESSIONS))
    
    # Update summary table
    sed -i "/| \*\*TOTAL\*\*.*|/c\| **TOTAL** | **All Models** | **$CURRENT_SESSIONS** | **$NEW_TOTAL_TOKENS** | **$NEW_AVERAGE** |" "$USAGE_FILE"
    
    # Update cost estimate
    sed -i "/Total Estimated Cost/c\- **Total Estimated Cost**: \$$NEW_TOTAL_COST" "$USAGE_FILE"
}
```

#### Finalize Token Session
```bash
# Finalize token tracking session
finalize_token_session() {
    local SESSION_NOTES="$1"
    
    if [ -z "$TOKEN_SESSION_FILE" ]; then
        echo "ERROR: Token tracking not initialized"
        return 1
    fi
    
    # Update session status
    sed -i "/Status/c\- **Status**: completed" "$TOKEN_SESSION_FILE"
    
    # Add completion information
    cat >> "$TOKEN_SESSION_FILE" << EOF

## Session Completion
- **Completed**: $(date)
- **Final Status**: completed
- **Notes**: $SESSION_NOTES
- **Average Tokens per Call**: $((TOKEN_TOTAL_TOKENS / TOKEN_CALL_COUNT))
- **Average Cost per Call**: \$$(echo "scale=4; $TOKEN_TOTAL_COST / $TOKEN_CALL_COUNT" | bc -l)

## Cost Breakdown
- **Input Cost**: \$$(echo "scale=4; $TOKEN_TOTAL_INPUT * 0.00003" | bc -l)
- **Output Cost**: \$$(echo "scale=4; $TOKEN_TOTAL_OUTPUT * 0.00006" | bc -l)
- **Total Cost**: \$$TOKEN_TOTAL_COST

## Efficiency Metrics
- **Input/Output Ratio**: $(echo "scale=2; $TOKEN_TOTAL_INPUT / $TOKEN_TOTAL_OUTPUT" | bc -l)
- **Cost per Token**: \$$(echo "scale=6; $TOKEN_TOTAL_COST / $TOKEN_TOTAL_TOKENS" | bc -l)

---
*Session finalized by Token Collection System*
EOF
    
    echo "Token session finalized: $TOKEN_SESSION_ID"
    echo "Total cost: \$$TOKEN_TOTAL_COST"
    echo "Session file: $TOKEN_SESSION_FILE"
    
    # Clear session variables
    unset TOKEN_SESSION_ID TOKEN_SESSION_FILE TOKEN_MODEL_PROVIDER TOKEN_MODEL_NAME
    unset TOKEN_CALL_COUNT TOKEN_TOTAL_INPUT TOKEN_TOTAL_OUTPUT TOKEN_TOTAL_TOKENS TOKEN_TOTAL_COST
}
```

### Automatic Collection Functions

#### Auto-Collect from API Response
```bash
# Auto-collect token usage from API response
auto_collect_from_response() {
    local API_RESPONSE="$1"
    local PROVIDER="$2"
    local MODEL="$3"
    
    local INPUT_TOKENS=0
    local OUTPUT_TOKENS=0
    
    # Parse response based on provider
    case "$PROVIDER" in
        "openai")
            INPUT_TOKENS=$(echo "$API_RESPONSE" | jq -r '.usage.prompt_tokens // 0')
            OUTPUT_TOKENS=$(echo "$API_RESPONSE" | jq -r '.usage.completion_tokens // 0')
            ;;
        "anthropic")
            INPUT_TOKENS=$(echo "$API_RESPONSE" | jq -r '.usage.input_tokens // 0')
            OUTPUT_TOKENS=$(echo "$API_RESPONSE" | jq -r '.usage.output_tokens // 0')
            ;;
        "google")
            INPUT_TOKENS=$(echo "$API_RESPONSE" | jq -r '.usageMetadata.promptTokenCount // 0')
            OUTPUT_TOKENS=$(echo "$API_RESPONSE" | jq -r '.usageMetadata.candidatesTokenCount // 0')
            ;;
        *)
            echo "Unknown provider: $PROVIDER"
            return 1
            ;;
    esac
    
    # Record usage if tokens found
    if [ "$INPUT_TOKENS" -gt 0 ] || [ "$OUTPUT_TOKENS" -gt 0 ]; then
        record_token_usage "$INPUT_TOKENS" "$OUTPUT_TOKENS" "$PROVIDER" "$MODEL"
    fi
}
```

#### Monitor Token Usage Patterns
```bash
# Monitor token usage patterns for anomalies
monitor_usage_patterns() {
    local CURRENT_USAGE="$1"
    local THRESHOLD_MULTIPLIER="$2"
    
    if [ -z "$THRESHOLD_MULTIPLIER" ]; then
        THRESHOLD_MULTIPLIER=3
    fi
    
    # Calculate average usage from recent sessions
    local RECENT_SESSIONS=$(grep "#### Session" .ai_workflow/work_journal/token_usage.md | tail -10)
    local AVERAGE_USAGE=2917  # Default based on existing data
    
    # Check if current usage exceeds threshold
    local THRESHOLD=$((AVERAGE_USAGE * THRESHOLD_MULTIPLIER))
    
    if [ "$CURRENT_USAGE" -gt "$THRESHOLD" ]; then
        echo "⚠️  HIGH USAGE ALERT: $CURRENT_USAGE tokens (threshold: $THRESHOLD)"
        
        # Log alert
        echo "$(date): HIGH_USAGE_ALERT: $CURRENT_USAGE tokens exceeded threshold $THRESHOLD" >> .ai_workflow/monitoring/usage_alerts.log
        
        return 1
    fi
    
    return 0
}
```

### Integration Functions

#### Integrate with Abstract Tools
```bash
# Integrate token collection with abstract tool calls
collect_tokens_for_tool_call() {
    local TOOL_CALL="$1"
    local PROVIDER="$2"
    local MODEL="$3"
    
    # Estimate tokens for tool call (basic estimation)
    local ESTIMATED_INPUT=$(echo "$TOOL_CALL" | wc -c)
    local ESTIMATED_INPUT_TOKENS=$((ESTIMATED_INPUT / 4))  # Rough estimate: 4 chars per token
    
    # Record estimated usage
    record_token_usage "$ESTIMATED_INPUT_TOKENS" 0 "$PROVIDER" "$MODEL" "tool_call_estimate"
}
```

#### Integrate with Workflow State
```bash
# Integrate token collection with workflow state
integrate_with_workflow_state() {
    local WORKFLOW_STATE_FILE="$1"
    
    if [ -n "$TOKEN_SESSION_ID" ] && [ -f "$WORKFLOW_STATE_FILE" ]; then
        # Add token tracking info to workflow state
        echo "- $(date): TOKEN_TRACKING: Session $TOKEN_SESSION_ID - $TOKEN_TOTAL_TOKENS tokens, \$$TOKEN_TOTAL_COST" >> "$WORKFLOW_STATE_FILE"
    fi
}
```

### Reporting Functions

#### Generate Usage Report
```bash
# Generate usage report for specific timeframe
generate_usage_report() {
    local START_DATE="$1"
    local END_DATE="$2"
    local REPORT_TYPE="$3"
    
    if [ -z "$START_DATE" ]; then
        START_DATE=$(date -d "7 days ago" +"%Y-%m-%d")
    fi
    
    if [ -z "$END_DATE" ]; then
        END_DATE=$(date +"%Y-%m-%d")
    fi
    
    if [ -z "$REPORT_TYPE" ]; then
        REPORT_TYPE="summary"
    fi
    
    local REPORT_FILE=".ai_workflow/monitoring/usage_report_$(date +%Y%m%d).md"
    
    cat > "$REPORT_FILE" << EOF
# Token Usage Report

## Report Information
- **Period**: $START_DATE to $END_DATE
- **Report Type**: $REPORT_TYPE
- **Generated**: $(date)

## Usage Summary
$(grep -A 20 "Usage Summary" .ai_workflow/work_journal/token_usage.md)

## Recent Sessions
$(grep -A 50 "Detailed Usage Log" .ai_workflow/work_journal/token_usage.md | tail -30)

## Efficiency Analysis
$(grep -A 20 "Usage Analysis" .ai_workflow/work_journal/token_usage.md)

---
*Generated by Token Collection System*
EOF
    
    echo "Usage report generated: $REPORT_FILE"
}
```

### Configuration Functions

#### Set Collection Preferences
```bash
# Set token collection preferences
set_collection_preferences() {
    local AUTO_COLLECT="$1"
    local ALERT_THRESHOLD="$2"
    local REPORT_FREQUENCY="$3"
    
    local CONFIG_FILE=".ai_workflow/monitoring/token_collection_config.md"
    
    cat > "$CONFIG_FILE" << EOF
# Token Collection Configuration

## Collection Settings
- **Auto Collection**: $AUTO_COLLECT
- **Alert Threshold**: $ALERT_THRESHOLD tokens
- **Report Frequency**: $REPORT_FREQUENCY
- **Updated**: $(date)

## Provider Settings
- **OpenAI**: enabled
- **Anthropic**: enabled
- **Google**: enabled

## Cost Calculation
- **Auto Calculate**: enabled
- **Currency**: USD
- **Pricing Updated**: $(date)

EOF
    
    export TOKEN_AUTO_COLLECT="$AUTO_COLLECT"
    export TOKEN_ALERT_THRESHOLD="$ALERT_THRESHOLD"
    export TOKEN_REPORT_FREQUENCY="$REPORT_FREQUENCY"
    
    echo "Token collection preferences updated"
}
```

## Integration with Framework

### With PRP Execution
- Automatic token tracking during PRP execution
- Integration with workflow state management
- Cost tracking for entire PRP runs

### With Abstract Tools
- Token estimation for tool calls
- Actual usage tracking when available
- Cost attribution to specific operations

### With Error Handling
- Token usage logging for failed operations
- Cost tracking for retry attempts
- Efficiency analysis for error scenarios

## Usage Examples

### Basic Usage
```bash
# Initialize tracking
init_token_tracking "my_session" "openai" "gpt-4"

# Record usage
record_token_usage 1500 800 "openai" "gpt-4"

# Finalize session
finalize_token_session "Completed successfully"
```

### Automatic Collection
```bash
# Auto-collect from API response
API_RESPONSE='{"usage": {"prompt_tokens": 1500, "completion_tokens": 800}}'
auto_collect_from_response "$API_RESPONSE" "openai" "gpt-4"
```

### Monitoring
```bash
# Monitor usage patterns
monitor_usage_patterns 5000 3  # 5000 tokens, 3x threshold

# Generate report
generate_usage_report "2025-07-01" "2025-07-14" "detailed"
```

## Notes
- Token tracking is automatic during framework operations
- Cost calculations use current market pricing
- Integration with all major AI providers
- Real-time monitoring and alerting
- Comprehensive reporting and analysis
- Configuration options for different use cases