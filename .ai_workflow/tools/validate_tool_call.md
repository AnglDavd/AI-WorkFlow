# Validate Tool Call

## Overview
This workflow validates abstract tool calls before execution, ensuring they are properly formatted, contain required parameters, and are safe to execute. It acts as a security and quality gate for the tool abstraction system.

## Workflow Instructions

### For AI Agents
When validating tool calls, this workflow will:

1. **Parse the abstract call syntax** to ensure it's properly formatted
2. **Validate tool and action existence** in the framework
3. **Check required parameters** are provided
4. **Validate parameter types and values** for safety
5. **Perform security checks** to prevent malicious operations

### Main Validation Function
```bash
# Main validation function - called by execute_abstract_tool_call.md
validate_tool_call() {
    local TOOL_NAME="$1"
    local ACTION="$2"
    local PARAMS="$3"
    
    # Step 1: Validate tool name
    if ! validate_tool_name "$TOOL_NAME"; then
        return 1
    fi
    
    # Step 2: Validate action exists for tool
    if ! validate_action_exists "$TOOL_NAME" "$ACTION"; then
        return 1
    fi
    
    # Step 3: Validate parameters
    if ! validate_parameters "$TOOL_NAME" "$ACTION" "$PARAMS"; then
        return 1
    fi
    
    # Step 4: Security validation
    if ! validate_security "$TOOL_NAME" "$ACTION" "$PARAMS"; then
        return 1
    fi
    
    return 0
}
```

### Tool Name Validation
```bash
validate_tool_name() {
    local TOOL_NAME="$1"
    
    # List of supported tools
    local SUPPORTED_TOOLS="git npm file http"
    
    if [ -z "$TOOL_NAME" ]; then
        echo "ERROR: Tool name is required"
        return 1
    fi
    
    # Check if tool is in supported list
    if ! echo "$SUPPORTED_TOOLS" | grep -q "\b$TOOL_NAME\b"; then
        echo "ERROR: Unsupported tool - $TOOL_NAME"
        echo "Supported tools: $SUPPORTED_TOOLS"
        return 1
    fi
    
    # Check if adapter exists
    local ADAPTER_FILE=".ai_workflow/tools/adapters/${TOOL_NAME}_adapter.md"
    if [ ! -f "$ADAPTER_FILE" ]; then
        echo "ERROR: Adapter not found - $ADAPTER_FILE"
        return 1
    fi
    
    return 0
}
```

### Action Validation
```bash
validate_action_exists() {
    local TOOL_NAME="$1"
    local ACTION="$2"
    
    if [ -z "$ACTION" ]; then
        echo "ERROR: Action is required"
        return 1
    fi
    
    # Tool-specific action validation
    case "$TOOL_NAME" in
        "git")
            validate_git_action "$ACTION"
            ;;
        "npm")
            validate_npm_action "$ACTION"
            ;;
        "file")
            validate_file_action "$ACTION"
            ;;
        "http")
            validate_http_action "$ACTION"
            ;;
        *)
            echo "ERROR: Unknown tool for action validation - $TOOL_NAME"
            return 1
            ;;
    esac
}
```

### Git Action Validation
```bash
validate_git_action() {
    local ACTION="$1"
    
    local VALID_ACTIONS="add add_all commit push pull checkout_branch status diff log"
    
    if ! echo "$VALID_ACTIONS" | grep -q "\b$ACTION\b"; then
        echo "ERROR: Invalid Git action - $ACTION"
        echo "Valid Git actions: $VALID_ACTIONS"
        return 1
    fi
    
    return 0
}
```

### NPM Action Validation
```bash
validate_npm_action() {
    local ACTION="$1"
    
    local VALID_ACTIONS="install run_script test init start build update uninstall version list"
    
    if ! echo "$VALID_ACTIONS" | grep -q "\b$ACTION\b"; then
        echo "ERROR: Invalid NPM action - $ACTION"
        echo "Valid NPM actions: $VALID_ACTIONS"
        return 1
    fi
    
    return 0
}
```

### File Action Validation
```bash
validate_file_action() {
    local ACTION="$1"
    
    local VALID_ACTIONS="write read delete exists create_directory"
    
    if ! echo "$VALID_ACTIONS" | grep -q "\b$ACTION\b"; then
        echo "ERROR: Invalid File action - $ACTION"
        echo "Valid File actions: $VALID_ACTIONS"
        return 1
    fi
    
    return 0
}
```

### HTTP Action Validation
```bash
validate_http_action() {
    local ACTION="$1"
    
    local VALID_ACTIONS="get post put delete patch"
    
    if ! echo "$VALID_ACTIONS" | grep -q "\b$ACTION\b"; then
        echo "ERROR: Invalid HTTP action - $ACTION"
        echo "Valid HTTP actions: $VALID_ACTIONS"
        return 1
    fi
    
    return 0
}
```

### Parameter Validation
```bash
validate_parameters() {
    local TOOL_NAME="$1"
    local ACTION="$2"
    local PARAMS="$3"
    
    # Tool and action specific parameter validation
    case "$TOOL_NAME" in
        "git")
            validate_git_parameters "$ACTION" "$PARAMS"
            ;;
        "npm")
            validate_npm_parameters "$ACTION" "$PARAMS"
            ;;
        "file")
            validate_file_parameters "$ACTION" "$PARAMS"
            ;;
        "http")
            validate_http_parameters "$ACTION" "$PARAMS"
            ;;
        *)
            echo "ERROR: Unknown tool for parameter validation - $TOOL_NAME"
            return 1
            ;;
    esac
}
```

### Git Parameter Validation
```bash
validate_git_parameters() {
    local ACTION="$1"
    local PARAMS="$2"
    
    case "$ACTION" in
        "add")
            # Require file_path parameter
            if ! echo "$PARAMS" | grep -q "file_path="; then
                echo "ERROR: git.add requires file_path parameter"
                return 1
            fi
            ;;
        "commit")
            # Require message parameter
            if ! echo "$PARAMS" | grep -q "message="; then
                echo "ERROR: git.commit requires message parameter"
                return 1
            fi
            ;;
        "checkout_branch")
            # Require branch_name parameter
            if ! echo "$PARAMS" | grep -q "branch_name="; then
                echo "ERROR: git.checkout_branch requires branch_name parameter"
                return 1
            fi
            ;;
        "push"|"pull")
            # Optional parameters, no validation needed
            ;;
        "add_all"|"status"|"diff"|"log")
            # No required parameters
            ;;
        *)
            echo "ERROR: Unknown git action for parameter validation - $ACTION"
            return 1
            ;;
    esac
    
    return 0
}
```

### NPM Parameter Validation
```bash
validate_npm_parameters() {
    local ACTION="$1"
    local PARAMS="$2"
    
    case "$ACTION" in
        "run_script")
            # Require script_name parameter
            if ! echo "$PARAMS" | grep -q "script_name="; then
                echo "ERROR: npm.run_script requires script_name parameter"
                return 1
            fi
            ;;
        "uninstall")
            # Require package parameter
            if ! echo "$PARAMS" | grep -q "package="; then
                echo "ERROR: npm.uninstall requires package parameter"
                return 1
            fi
            ;;
        "install"|"test"|"init"|"start"|"build"|"update"|"version"|"list")
            # Optional parameters, no validation needed
            ;;
        *)
            echo "ERROR: Unknown npm action for parameter validation - $ACTION"
            return 1
            ;;
    esac
    
    return 0
}
```

### File Parameter Validation
```bash
validate_file_parameters() {
    local ACTION="$1"
    local PARAMS="$2"
    
    case "$ACTION" in
        "write"|"read"|"delete"|"exists")
            # Require path parameter
            if ! echo "$PARAMS" | grep -q "path="; then
                echo "ERROR: file.$ACTION requires path parameter"
                return 1
            fi
            ;;
        "create_directory")
            # Require path parameter
            if ! echo "$PARAMS" | grep -q "path="; then
                echo "ERROR: file.create_directory requires path parameter"
                return 1
            fi
            ;;
        *)
            echo "ERROR: Unknown file action for parameter validation - $ACTION"
            return 1
            ;;
    esac
    
    return 0
}
```

### HTTP Parameter Validation
```bash
validate_http_parameters() {
    local ACTION="$1"
    local PARAMS="$2"
    
    case "$ACTION" in
        "get"|"post"|"put"|"delete"|"patch")
            # Require url parameter
            if ! echo "$PARAMS" | grep -q "url="; then
                echo "ERROR: http.$ACTION requires url parameter"
                return 1
            fi
            ;;
        *)
            echo "ERROR: Unknown http action for parameter validation - $ACTION"
            return 1
            ;;
    esac
    
    return 0
}
```

### Security Validation
```bash
validate_security() {
    local TOOL_NAME="$1"
    local ACTION="$2"
    local PARAMS="$3"
    
    # Path traversal prevention
    if echo "$PARAMS" | grep -q "\.\./"; then
        echo "ERROR: Path traversal detected in parameters"
        return 1
    fi
    
    # Command injection prevention
    if echo "$PARAMS" | grep -q "[;&|<>]"; then
        echo "ERROR: Potentially dangerous characters detected in parameters"
        return 1
    fi
    
    # File path validation
    if echo "$PARAMS" | grep -q "path="; then
        if ! validate_file_path "$PARAMS"; then
            return 1
        fi
    fi
    
    if echo "$PARAMS" | grep -q "file_path="; then
        if ! validate_file_path "$PARAMS"; then
            return 1
        fi
    fi
    
    # URL validation for HTTP calls
    if [ "$TOOL_NAME" = "http" ]; then
        if ! validate_url "$PARAMS"; then
            return 1
        fi
    fi
    
    return 0
}
```

### File Path Security Validation
```bash
validate_file_path() {
    local PARAMS="$1"
    
    # Extract path from parameters
    local PATH_VALUE=$(echo "$PARAMS" | sed -n 's/.*path="\([^"]*\)".*/\1/p')
    if [ -z "$PATH_VALUE" ]; then
        PATH_VALUE=$(echo "$PARAMS" | sed -n 's/.*file_path="\([^"]*\)".*/\1/p')
    fi
    
    if [ -z "$PATH_VALUE" ]; then
        echo "ERROR: Could not extract path from parameters"
        return 1
    fi
    
    # Check for absolute paths outside project
    if echo "$PATH_VALUE" | grep -q "^/"; then
        echo "ERROR: Absolute paths outside project are not allowed"
        return 1
    fi
    
    # Check for system directories
    local FORBIDDEN_PATHS="/etc /sys /proc /dev /root"
    for FORBIDDEN in $FORBIDDEN_PATHS; do
        if echo "$PATH_VALUE" | grep -q "^$FORBIDDEN"; then
            echo "ERROR: Access to system directory not allowed - $FORBIDDEN"
            return 1
        fi
    done
    
    # Check for hidden files/directories (optional security measure)
    if echo "$PATH_VALUE" | grep -q "/\."; then
        echo "WARNING: Access to hidden files/directories detected"
        # Allow but warn - some legitimate cases exist
    fi
    
    return 0
}
```

### URL Validation
```bash
validate_url() {
    local PARAMS="$1"
    
    # Extract URL from parameters
    local URL_VALUE=$(echo "$PARAMS" | sed -n 's/.*url="\([^"]*\)".*/\1/p')
    
    if [ -z "$URL_VALUE" ]; then
        echo "ERROR: Could not extract URL from parameters"
        return 1
    fi
    
    # Basic URL format validation
    if ! echo "$URL_VALUE" | grep -q "^https\?://"; then
        echo "ERROR: URL must start with http:// or https://"
        return 1
    fi
    
    # Check for localhost/internal network access
    if echo "$URL_VALUE" | grep -q "localhost\|127\.0\.0\.1\|192\.168\.\|10\.\|172\.1[6-9]\.\|172\.2[0-9]\.\|172\.3[0-1]\."; then
        echo "WARNING: Access to local/internal network detected"
        # Allow but warn - some legitimate cases exist
    fi
    
    return 0
}
```

### Parameter Extraction Helpers
```bash
# Extract parameter value from parameter string
extract_parameter() {
    local PARAMS="$1"
    local PARAM_NAME="$2"
    
    # Try quoted value first
    local VALUE=$(echo "$PARAMS" | sed -n "s/.*${PARAM_NAME}=\"\([^\"]*\)\".*/\1/p")
    
    # If not found, try unquoted value
    if [ -z "$VALUE" ]; then
        VALUE=$(echo "$PARAMS" | sed -n "s/.*${PARAM_NAME}=\([^,)]*\).*/\1/p")
    fi
    
    echo "$VALUE"
}

# Check if parameter exists
parameter_exists() {
    local PARAMS="$1"
    local PARAM_NAME="$2"
    
    if echo "$PARAMS" | grep -q "${PARAM_NAME}="; then
        return 0
    else
        return 1
    fi
}
```

### Abstract Call Syntax Validation
```bash
validate_abstract_call_syntax() {
    local ABSTRACT_CALL="$1"
    
    # Check basic format: TOOL.ACTION(parameters)
    if ! echo "$ABSTRACT_CALL" | grep -q "^[a-zA-Z][a-zA-Z0-9_]*\.[a-zA-Z][a-zA-Z0-9_]*(.*)\$"; then
        echo "ERROR: Invalid abstract call syntax"
        echo "Expected format: TOOL.ACTION(param1=value1, param2=value2)"
        return 1
    fi
    
    # Check for balanced parentheses
    local OPEN_PARENS=$(echo "$ABSTRACT_CALL" | tr -cd '(' | wc -c)
    local CLOSE_PARENS=$(echo "$ABSTRACT_CALL" | tr -cd ')' | wc -c)
    
    if [ "$OPEN_PARENS" -ne "$CLOSE_PARENS" ]; then
        echo "ERROR: Unbalanced parentheses in abstract call"
        return 1
    fi
    
    return 0
}
```

### Integration Notes
- Called by `execute_abstract_tool_call.md` before execution
- Provides comprehensive validation for all tool types
- Implements security checks to prevent malicious operations
- Returns clear error messages for debugging
- Extensible for new tools and actions

### Usage Examples
```bash
# Validate a git call
validate_tool_call "git" "add" "file_path=\"src/main.js\""

# Validate an npm call
validate_tool_call "npm" "install" "package=\"express\""

# Validate a file call
validate_tool_call "file" "write" "path=\"config.json\", content=\"{}\""

# Validate an HTTP call
validate_tool_call "http" "get" "url=\"https://api.example.com/data\""
```

### Error Handling
- **Syntax Errors**: Invalid abstract call format
- **Unknown Tools**: Tool not supported by framework
- **Invalid Actions**: Action not available for tool
- **Missing Parameters**: Required parameters not provided
- **Security Violations**: Potentially dangerous operations detected
- **Path Traversal**: Attempts to access files outside project
- **Command Injection**: Malicious characters in parameters

### Security Features
- **Path Validation**: Prevents access to system directories
- **Command Injection Prevention**: Blocks dangerous characters
- **URL Validation**: Ensures proper URL format for HTTP calls
- **Parameter Sanitization**: Validates parameter values
- **Access Control**: Restricts file operations to project directory

## Notes
- This workflow is critical for framework security
- All tool calls must pass validation before execution
- New tools require updating validation functions
- Security rules can be customized per project needs
- Validation errors should be logged for audit purposes