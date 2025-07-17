#!/bin/bash

# Circuit Breaker Mode Manager
# Allows switching between different protection modes

MODE_CONFIG_FILE=".ai_workflow/config/circuit_breaker_mode.json"
CIRCUIT_BREAKER_SCRIPT=".ai_workflow/scripts/simple_circuit_breaker.sh"

# Mode definitions
declare -A MODES

# Development Mode - Permissive for active development
MODES["development"]='
{
    "name": "Development Mode",
    "description": "Permissive limits for active development work",
    "limits": {
        "setup": {"max": 5, "window": 7200},
        "sync_feedback": {"max": 8, "window": 3600},
        "diagnose": {"max": 20, "window": 1800},
        "audit": {"max": 10, "window": 3600},
        "precommit": {"max": 50, "window": 300},
        "quality": {"max": 15, "window": 1800},
        "generate": {"max": 5, "window": 3600},
        "run": {"max": 8, "window": 1800}
    },
    "dangerous_operations": "prompt",
    "loop_detection": "warn"
}'

# Production Mode - Balanced for normal use
MODES["production"]='
{
    "name": "Production Mode", 
    "description": "Balanced limits for normal framework usage",
    "limits": {
        "setup": {"max": 2, "window": 7200},
        "sync_feedback": {"max": 3, "window": 3600},
        "diagnose": {"max": 5, "window": 1800},
        "audit": {"max": 3, "window": 3600},
        "precommit": {"max": 10, "window": 300},
        "quality": {"max": 5, "window": 1800},
        "generate": {"max": 2, "window": 3600},
        "run": {"max": 3, "window": 1800}
    },
    "dangerous_operations": "block",
    "loop_detection": "block"
}'

# Enterprise Mode - Strict for enterprise environments
MODES["enterprise"]='
{
    "name": "Enterprise Mode",
    "description": "Strict limits for enterprise/CI environments",
    "limits": {
        "setup": {"max": 1, "window": 14400},
        "sync_feedback": {"max": 2, "window": 7200},
        "diagnose": {"max": 3, "window": 3600},
        "audit": {"max": 2, "window": 7200},
        "precommit": {"max": 5, "window": 600},
        "quality": {"max": 3, "window": 3600},
        "generate": {"max": 1, "window": 7200},
        "run": {"max": 2, "window": 3600}
    },
    "dangerous_operations": "block",
    "loop_detection": "emergency_stop"
}'

# Testing Mode - Very permissive for testing
MODES["testing"]='
{
    "name": "Testing Mode",
    "description": "Very permissive limits for testing and debugging",
    "limits": {
        "setup": {"max": 10, "window": 3600},
        "sync_feedback": {"max": 20, "window": 1800},
        "diagnose": {"max": 100, "window": 600},
        "audit": {"max": 50, "window": 1800},
        "precommit": {"max": 200, "window": 300},
        "quality": {"max": 50, "window": 600},
        "generate": {"max": 10, "window": 1800},
        "run": {"max": 20, "window": 1800}
    },
    "dangerous_operations": "prompt",
    "loop_detection": "warn"
}'

# CI/CD Mode - Optimized for automated systems
MODES["cicd"]='
{
    "name": "CI/CD Mode",
    "description": "Optimized for automated CI/CD pipelines",
    "limits": {
        "setup": {"max": 1, "window": 86400},
        "sync_feedback": {"max": 5, "window": 3600},
        "diagnose": {"max": 10, "window": 1800},
        "audit": {"max": 5, "window": 3600},
        "precommit": {"max": 100, "window": 300},
        "quality": {"max": 20, "window": 1800},
        "generate": {"max": 3, "window": 7200},
        "run": {"max": 5, "window": 3600}
    },
    "dangerous_operations": "block",
    "loop_detection": "emergency_stop"
}'

# Initialize mode configuration
init_mode_config() {
    echo "🔧 Initializing mode configuration..."
    
    mkdir -p "$(dirname "$MODE_CONFIG_FILE")"
    
    # Default to development mode if no config exists
    if [ ! -f "$MODE_CONFIG_FILE" ]; then
        set_mode "development"
    fi
    
    echo "✅ Mode configuration initialized"
}

# Set mode
set_mode() {
    local mode="$1"
    
    if [ -z "${MODES[$mode]}" ]; then
        echo "❌ Invalid mode: $mode"
        echo "📋 Available modes: ${!MODES[@]}"
        return 1
    fi
    
    echo "🔄 Setting mode to: $mode"
    
    # Save mode configuration
    echo "${MODES[$mode]}" > "$MODE_CONFIG_FILE"
    
    # Apply mode settings
    apply_mode_settings "$mode"
    
    echo "✅ Mode set to: $mode"
}

# Apply mode settings
apply_mode_settings() {
    local mode="$1"
    
    echo "🔧 Applying $mode settings..."
    
    # Clear existing circuit breakers
    rm -rf .ai_workflow/circuit_breakers/
    
    # Initialize circuit breaker with mode-specific limits
    if [ -f "$CIRCUIT_BREAKER_SCRIPT" ]; then
        # Extract limits from mode config
        local config="${MODES[$mode]}"
        
        # Use jq to parse and apply limits
        if command -v jq >/dev/null 2>&1; then
            echo "$config" | jq -r '.limits | to_entries[] | "\(.key) \(.value.max) \(.value.window)"' | while read -r operation max window; do
                "$CIRCUIT_BREAKER_SCRIPT" init "$operation" "$max" "$window"
            done
        else
            # Fallback without jq
            "$CIRCUIT_BREAKER_SCRIPT" init
        fi
    fi
    
    echo "✅ Mode settings applied"
}

# Get current mode
get_current_mode() {
    if [ ! -f "$MODE_CONFIG_FILE" ]; then
        echo "none"
        return 1
    fi
    
    local mode_name=$(jq -r '.name' "$MODE_CONFIG_FILE" 2>/dev/null || echo "unknown")
    
    # Try to match mode name to mode key
    for mode_key in "${!MODES[@]}"; do
        local check_name=$(echo "${MODES[$mode_key]}" | jq -r '.name' 2>/dev/null)
        if [ "$check_name" = "$mode_name" ]; then
            echo "$mode_key"
            return 0
        fi
    done
    
    echo "unknown"
    return 1
}

# Show current mode status
show_mode_status() {
    echo "🛡️  Circuit Breaker Mode Status"
    echo "=============================="
    
    local current_mode=$(get_current_mode)
    
    if [ "$current_mode" = "none" ] || [ "$current_mode" = "unknown" ]; then
        echo "❌ No mode configured"
        return 1
    fi
    
    echo "📋 Current Mode: $current_mode"
    
    if [ -f "$MODE_CONFIG_FILE" ]; then
        echo "📝 Mode Details:"
        if command -v jq >/dev/null 2>&1; then
            echo "   Name: $(jq -r '.name' "$MODE_CONFIG_FILE")"
            echo "   Description: $(jq -r '.description' "$MODE_CONFIG_FILE")"
            echo ""
            echo "🔒 Current Limits:"
            jq -r '.limits | to_entries[] | "   \(.key): \(.value.max) times per \(.value.window)s"' "$MODE_CONFIG_FILE"
            echo ""
            echo "🚨 Dangerous Operations: $(jq -r '.dangerous_operations' "$MODE_CONFIG_FILE")"
            echo "🔄 Loop Detection: $(jq -r '.loop_detection' "$MODE_CONFIG_FILE")"
        else
            echo "   (jq not available - showing raw config)"
            cat "$MODE_CONFIG_FILE"
        fi
    fi
    
    echo ""
    echo "🔍 Circuit Breaker Status:"
    if [ -d ".ai_workflow/circuit_breakers" ]; then
        local breaker_count=$(find .ai_workflow/circuit_breakers -name "*_state" 2>/dev/null | wc -l)
        echo "   Active breakers: $breaker_count"
        
        for state_file in .ai_workflow/circuit_breakers/*_state; do
            if [ -f "$state_file" ]; then
                local op=$(basename "$state_file" _state)
                local count=$(grep "count=" "$state_file" | cut -d'=' -f2)
                local max=$(grep "max_executions=" "$state_file" | cut -d'=' -f2)
                echo "   $op: $count/$max"
            fi
        done
    else
        echo "   No active circuit breakers"
    fi
}

# List available modes
list_modes() {
    echo "🛡️  Available Circuit Breaker Modes"
    echo "================================="
    
    for mode in "${!MODES[@]}"; do
        local config="${MODES[$mode]}"
        local name=$(echo "$config" | jq -r '.name' 2>/dev/null)
        local desc=$(echo "$config" | jq -r '.description' 2>/dev/null)
        
        echo "📋 $mode"
        echo "   Name: $name"
        echo "   Description: $desc"
        echo ""
    done
}

# Interactive mode selection
interactive_mode_selection() {
    echo "🛡️  Interactive Mode Selection"
    echo "============================"
    
    echo "📋 Available modes:"
    local i=1
    local mode_array=()
    
    for mode in "${!MODES[@]}"; do
        local config="${MODES[$mode]}"
        local name=$(echo "$config" | jq -r '.name' 2>/dev/null)
        local desc=$(echo "$config" | jq -r '.description' 2>/dev/null)
        
        echo "$i. $mode - $name"
        echo "   $desc"
        echo ""
        
        mode_array+=("$mode")
        ((i++))
    done
    
    read -p "Select mode [1-${#mode_array[@]}]: " choice
    
    if [ "$choice" -ge 1 ] && [ "$choice" -le "${#mode_array[@]}" ]; then
        local selected_mode="${mode_array[$((choice-1))]}"
        set_mode "$selected_mode"
    else
        echo "❌ Invalid selection"
        return 1
    fi
}

# Reset circuit breakers
reset_circuit_breakers() {
    echo "🔄 Resetting circuit breakers..."
    
    if [ -f "$CIRCUIT_BREAKER_SCRIPT" ]; then
        "$CIRCUIT_BREAKER_SCRIPT" emergency
    fi
    
    echo "✅ Circuit breakers reset"
}

# Main execution
main() {
    case "$1" in
        "init")
            init_mode_config
            ;;
        "set")
            if [ -z "$2" ]; then
                echo "Usage: $0 set <mode>"
                echo "Available modes: ${!MODES[@]}"
                exit 1
            fi
            set_mode "$2"
            ;;
        "get")
            get_current_mode
            ;;
        "status")
            show_mode_status
            ;;
        "list")
            list_modes
            ;;
        "select")
            interactive_mode_selection
            ;;
        "reset")
            reset_circuit_breakers
            ;;
        *)
            echo "Circuit Breaker Mode Manager"
            echo "Usage: $0 {init|set|get|status|list|select|reset}"
            echo ""
            echo "Commands:"
            echo "  init                 - Initialize mode configuration"
            echo "  set <mode>          - Set specific mode"
            echo "  get                 - Get current mode"
            echo "  status              - Show current mode status"
            echo "  list                - List available modes"
            echo "  select              - Interactive mode selection"
            echo "  reset               - Reset circuit breakers"
            echo ""
            echo "Available modes: ${!MODES[@]}"
            ;;
    esac
}

main "$@"