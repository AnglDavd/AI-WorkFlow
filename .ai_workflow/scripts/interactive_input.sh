#!/bin/bash
# Interactive Input Handler - Robust terminal input across different environments
set -euo pipefail

# Function to safely read user input across different terminal types
safe_read_input() {
    local prompt="$1"
    local default_value="${2:-}"
    local env_var_name="${3:-}"
    local auto_confirm="${AUTO_CONFIRM:-false}"
    local result=""
    
    # Check if environment variable is set
    if [[ -n "$env_var_name" ]]; then
        local env_value
        env_value=$(eval "echo \${${env_var_name}:-}")
        if [[ -n "$env_value" ]]; then
            echo "Using $env_var_name from environment: $env_value" >&2
            echo "$env_value"
            return 0
        fi
    fi
    
    # Check auto-confirmation mode
    if [[ "$auto_confirm" == "true" ]]; then
        echo "Auto-confirmation enabled, using default: $default_value" >&2
        echo "$default_value"
        return 0
    fi
    
    # Detect environment type
    local is_interactive=false
    local input_method=""
    
    if [[ -t 0 ]] && [[ -t 1 ]] && [[ -t 2 ]]; then
        is_interactive=true
        input_method="standard"
    elif [[ -r /dev/tty ]] && [[ -w /dev/tty ]]; then
        is_interactive=true
        input_method="tty"
    elif [[ "${TERM:-}" != "" ]] && [[ "${TERM}" != "dumb" ]]; then
        is_interactive=true
        input_method="terminal"
    else
        is_interactive=false
        input_method="non-interactive"
    fi
    
    # Show prompt
    echo -n "$prompt"
    if [[ -n "$default_value" ]]; then
        echo -n " (default: $default_value)"
    fi
    echo -n ": "
    
    # Get input based on environment
    if [[ "$is_interactive" == "true" ]]; then
        case "$input_method" in
            "standard")
                read -r result || result=""
                ;;
            "tty")
                exec 3< /dev/tty
                read -r result <&3 || result=""
                exec 3<&-
                ;;
            "terminal")
                read -r result || result=""
                ;;
        esac
    else
        echo ""
        echo "Non-interactive environment detected, using default value"
        result="$default_value"
    fi
    
    # Handle empty input
    if [[ -z "$result" ]] && [[ -n "$default_value" ]]; then
        result="$default_value"
        echo "Using default value: $result" >&2
    elif [[ -z "$result" ]]; then
        echo "No input provided and no default available" >&2
        return 1
    fi
    
    echo "$result"
    return 0
}

# Function to validate project name
validate_project_name() {
    local name="$1"
    
    # Remove invalid characters and convert to lowercase
    name=$(echo "$name" | sed 's/[^a-zA-Z0-9._-]/-/g' | tr '[:upper:]' '[:lower:]')
    
    # Remove leading/trailing hyphens
    name=$(echo "$name" | sed 's/^-*//;s/-*$//')
    
    # Ensure it's not empty
    if [[ -z "$name" ]]; then
        name="my-project"
    fi
    
    echo "$name"
}

# Function to get project name with full validation
get_project_name() {
    local prompt="Enter your project name (e.g., my-awesome-app)"
    local default="my-awesome-app"
    local current_dir
    current_dir=$(basename "$(pwd)" 2>/dev/null || echo "project")
    
    # Use current directory as better default if it looks like a project name
    if [[ "$current_dir" =~ ^[a-zA-Z0-9._-]+$ ]] && [[ "$current_dir" != "." ]]; then
        default="$current_dir"
    fi
    
    local raw_name
    raw_name=$(safe_read_input "$prompt" "$default" "PROJECT_NAME")
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to get project name, using fallback"
        raw_name="$default"
    fi
    
    # Validate and clean the name
    local clean_name
    clean_name=$(validate_project_name "$raw_name")
    
    if [[ "$clean_name" != "$raw_name" ]]; then
        echo "Project name cleaned: '$raw_name' -> '$clean_name'" >&2
    fi
    
    echo "$clean_name"
}

# Function to get yes/no confirmation
get_confirmation() {
    local prompt="$1"
    local default="${2:-y}"
    
    local result
    result=$(safe_read_input "$prompt (y/n)" "$default" "")
    
    case "${result,,}" in
        y|yes|true|1)
            return 0
            ;;
        n|no|false|0)
            return 1
            ;;
        *)
            if [[ "$default" == "y" ]]; then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

# Function to test interactive capabilities
test_interactive_input() {
    echo "🧪 Testing Interactive Input Capabilities"
    echo "========================================"
    echo ""
    
    echo "📊 Environment Analysis:"
    echo "  Terminal type: ${TERM:-unset}"
    echo "  stdin is terminal: $(if [[ -t 0 ]]; then echo "yes"; else echo "no"; fi)"
    echo "  stdout is terminal: $(if [[ -t 1 ]]; then echo "yes"; else echo "no"; fi)"
    echo "  stderr is terminal: $(if [[ -t 2 ]]; then echo "yes"; else echo "no"; fi)"
    echo "  /dev/tty readable: $(if [[ -r /dev/tty ]]; then echo "yes"; else echo "no"; fi)"
    echo "  Auto-confirm mode: ${AUTO_CONFIRM:-false}"
    echo ""
    
    echo "🔧 Testing project name input..."
    local test_name
    test_name=$(get_project_name)
    echo "Result: '$test_name'"
    echo ""
    
    echo "✅ Interactive input test completed"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-test}" in
        "test")
            test_interactive_input
            ;;
        "project-name")
            get_project_name
            ;;
        "confirm")
            if get_confirmation "${2:-Proceed}"; then
                echo "Confirmed"
                exit 0
            else
                echo "Declined"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 [test|project-name|confirm]"
            echo ""
            echo "Commands:"
            echo "  test         - Test interactive capabilities"
            echo "  project-name - Get project name from user"
            echo "  confirm      - Get yes/no confirmation"
            exit 1
            ;;
    esac
fi