# Enhanced CLI Validation and UX

## Purpose
Implement production-ready CLI validation, error handling, and user experience improvements for the AI Development Framework.

## Philosophy
**Production-Grade UX** - Provide clear, actionable feedback with robust error handling and graceful degradation.

## Enhanced CLI Features

### 1. Command Validation and Help System

```bash
#!/bin/bash

# Enhanced Command Validation
validate_command() {
    local command="$1"
    local valid_commands=(
        "setup" "generate" "run" "optimize" "audit" "sync" "configure" 
        "diagnose" "quality" "precommit" "generate-architecture" 
        "update-architecture" "cleanup" "update-gitignore" "maintenance"
        "help" "version" "status" "detect-manual"
    )
    
    # Check if command exists
    if [[ ! " ${valid_commands[*]} " =~ " ${command} " ]]; then
        error "Unknown command: '$command'"
        echo ""
        echo "📋 Available commands:"
        printf '%s\n' "${valid_commands[@]}" | sort | sed 's/^/  /'
        echo ""
        echo "💡 Use './ai-dev help' for detailed information"
        return 1
    fi
    
    return 0
}

# Enhanced Help System with Context
show_contextual_help() {
    local command="$1"
    local project_type="$2"
    
    case "$command" in
        "setup")
            echo "🚀 Setup Command Help"
            echo "===================="
            echo "Initialize a new AI Development Framework project"
            echo ""
            echo "Usage: ./ai-dev setup [options]"
            echo ""
            echo "Options:"
            echo "  --type <type>      Project type (auto-detected by default)"
            echo "  --name <name>      Project name"
            echo "  --skip-docs       Skip documentation generation"
            echo "  --minimal         Minimal setup without optional features"
            echo ""
            echo "Examples:"
            echo "  ./ai-dev setup"
            echo "  ./ai-dev setup --type nodejs --name my-project"
            echo "  ./ai-dev setup --minimal"
            ;;
        "generate")
            echo "📋 Generate Command Help"
            echo "======================"
            echo "Generate tasks from Product Requirements Document"
            echo ""
            echo "Usage: ./ai-dev generate <prd_file> [options]"
            echo ""
            echo "Options:"
            echo "  --output <dir>     Output directory for generated files"
            echo "  --template <type>  Template type (auto-detected by default)"
            echo "  --priority <level> Priority level (high|medium|low)"
            echo ""
            echo "Examples:"
            echo "  ./ai-dev generate docs/prd.md"
            echo "  ./ai-dev generate prd.md --output tasks/ --priority high"
            ;;
        "quality")
            echo "🔍 Quality Command Help"
            echo "====================="
            echo "Run quality validation on project files"
            echo ""
            echo "Usage: ./ai-dev quality [path] [options]"
            echo ""
            echo "Options:"
            echo "  --scope <scope>    Validation scope (full|changed|specific)"
            echo "  --threshold <n>    Quality threshold (0-100)"
            echo "  --fix             Auto-fix issues where possible"
            echo "  --report          Generate detailed report"
            echo ""
            echo "Examples:"
            echo "  ./ai-dev quality"
            echo "  ./ai-dev quality src/ --threshold 85"
            echo "  ./ai-dev quality --scope changed --fix"
            ;;
        *)
            # Default help
            show_help
            ;;
    esac
}

# Smart Error Messages with Suggestions
smart_error_message() {
    local error_type="$1"
    local context="$2"
    
    case "$error_type" in
        "file_not_found")
            error "File not found: $context"
            echo ""
            echo "💡 Suggestions:"
            echo "  - Check if the file path is correct"
            echo "  - Use absolute or relative paths"
            echo "  - Run 'ls' to see available files"
            if [[ "$context" =~ \.md$ ]]; then
                echo "  - For PRD files, try: find . -name '*.md' -type f"
            fi
            ;;
        "permission_denied")
            error "Permission denied: $context"
            echo ""
            echo "💡 Suggestions:"
            echo "  - Check file permissions: ls -la $context"
            echo "  - Try running with appropriate permissions"
            echo "  - Ensure you own the file or have write access"
            ;;
        "invalid_format")
            error "Invalid format: $context"
            echo ""
            echo "💡 Suggestions:"
            echo "  - Check file format and syntax"
            echo "  - Validate JSON files with: jq empty <file>"
            echo "  - Validate markdown structure"
            ;;
        "framework_not_found")
            error "AI Framework not found in current directory"
            echo ""
            echo "💡 Suggestions:"
            echo "  - Initialize framework: ./ai-dev setup"
            echo "  - Navigate to framework directory"
            echo "  - Check if .ai_workflow/ directory exists"
            ;;
        *)
            error "Unknown error: $error_type - $context"
            ;;
    esac
}
```

### 2. Progress Indicators and Feedback

```bash
# Progress Indicator System
show_progress() {
    local message="$1"
    local step="$2"
    local total="$3"
    
    if [[ -n "$step" && -n "$total" ]]; then
        local percentage=$(( (step * 100) / total ))
        printf "\r🔄 %s [%d/%d] %d%%" "$message" "$step" "$total" "$percentage"
    else
        printf "\r🔄 %s..." "$message"
    fi
}

# Complete progress indicator
complete_progress() {
    local message="$1"
    printf "\r✅ %s\n" "$message"
}

# Spinner for long operations
show_spinner() {
    local pid=$!
    local message="$1"
    local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    
    while kill -0 $pid 2>/dev/null; do
        for i in "${spinner[@]}"; do
            printf "\r%s %s" "$i" "$message"
            sleep 0.1
        done
    done
    printf "\r✅ %s\n" "$message"
}

# Interactive confirmation
confirm_action() {
    local message="$1"
    local default="$2"
    
    if [[ "$FORCE_MODE" == "true" ]]; then
        echo "🚀 Force mode: $message - proceeding"
        return 0
    fi
    
    local prompt="$message"
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]"
    else
        prompt="$prompt [y/N]"
    fi
    
    # Use environment variable or default behavior for automation
    if [[ -n "${AUTO_CONFIRM:-}" ]]; then
        REPLY="$AUTO_CONFIRM"
        echo "$message: $REPLY (automated)"
    else
        # Fallback to manual input only if automation not configured
        echo -n "$prompt: "
        read -n 1 -r
        echo
    fi
    
    if [[ $REPLY =~ ^[Yy]$ ]] || ([[ -z $REPLY ]] && [[ "$default" == "y" ]]); then
        return 0
    else
        return 1
    fi
}
```

### 3. Configuration Management

```bash
# Enhanced Configuration System
load_configuration() {
    local config_file="$1"
    
    # Create default configuration if not exists
    if [[ ! -f "$config_file" ]]; then
        create_default_config "$config_file"
    fi
    
    # Load configuration with validation
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$config_file" >/dev/null 2>&1; then
            # Load configuration values
            QUALITY_VALIDATION_ENABLED=$(jq -r '.quality.validation_enabled // "true"' "$config_file")
            QUALITY_VALIDATION_STRICT=$(jq -r '.quality.strict_mode // "false"' "$config_file")
            LOG_LEVEL=$(jq -r '.logging.level // "info"' "$config_file")
            AUTO_CLEANUP_ENABLED=$(jq -r '.maintenance.auto_cleanup // "true"' "$config_file")
        else
            warning "Invalid JSON in configuration file: $config_file"
            create_default_config "$config_file"
        fi
    else
        warning "jq not found - using default configuration"
        set_default_config_values
    fi
}

# Create default configuration
create_default_config() {
    local config_file="$1"
    
    cat > "$config_file" << 'EOF'
{
  "framework": {
    "version": "v0.4.1-beta",
    "name": "AI Development Framework"
  },
  "quality": {
    "validation_enabled": true,
    "strict_mode": false,
    "threshold": 80,
    "auto_fix": false
  },
  "logging": {
    "level": "info",
    "file": ".ai_workflow/cache/ai-dev.log"
  },
  "maintenance": {
    "auto_cleanup": true,
    "cleanup_threshold_days": 30
  },
  "user": {
    "name": "",
    "email": "",
    "preferences": {}
  }
}
EOF
    
    success "Created default configuration: $config_file"
}

# Interactive configuration wizard
configure_framework() {
    local config_file="$1"
    
    echo "🔧 Framework Configuration Wizard"
    echo "================================="
    echo ""
    
    # Quality settings
    echo "📊 Quality Settings"
    echo "=================="
    
    if confirm_action "Enable quality validation" "y"; then
        QUALITY_VALIDATION_ENABLED="true"
        
        if confirm_action "Enable strict mode (blocks on quality issues)" "n"; then
            QUALITY_VALIDATION_STRICT="true"
        else
            QUALITY_VALIDATION_STRICT="false"
        fi
        
        QUALITY_THRESHOLD=${QUALITY_THRESHOLD_INPUT:-80}
    else
        QUALITY_VALIDATION_ENABLED="false"
        QUALITY_VALIDATION_STRICT="false"
        QUALITY_THRESHOLD=80
    fi
    
    # Maintenance settings
    echo ""
    echo "🔧 Maintenance Settings"
    echo "====================="
    
    if confirm_action "Enable automatic cleanup" "y"; then
        AUTO_CLEANUP_ENABLED="true"
        
        CLEANUP_THRESHOLD_DAYS=${CLEANUP_THRESHOLD_DAYS_INPUT:-30}
    else
        AUTO_CLEANUP_ENABLED="false"
        CLEANUP_THRESHOLD_DAYS=30
    fi
    
    # User settings
    echo ""
    echo "👤 User Settings"
    echo "==============="
    
    user_name=${USER_NAME_INPUT:-""}
    user_email=${USER_EMAIL_INPUT:-""}
    
    # Save configuration
    save_configuration "$config_file"
    
    success "Configuration saved successfully"
}

# Save configuration to file
save_configuration() {
    local config_file="$1"
    
    cat > "$config_file" << EOF
{
  "framework": {
    "version": "v0.4.1-beta",
    "name": "AI Development Framework"
  },
  "quality": {
    "validation_enabled": $QUALITY_VALIDATION_ENABLED,
    "strict_mode": $QUALITY_VALIDATION_STRICT,
    "threshold": $QUALITY_THRESHOLD,
    "auto_fix": false
  },
  "logging": {
    "level": "info",
    "file": ".ai_workflow/cache/ai-dev.log"
  },
  "maintenance": {
    "auto_cleanup": $AUTO_CLEANUP_ENABLED,
    "cleanup_threshold_days": $CLEANUP_THRESHOLD_DAYS
  },
  "user": {
    "name": "$user_name",
    "email": "$user_email",
    "preferences": {}
  }
}
EOF
}
```

### 4. Robust Error Handling

```bash
# Enhanced Error Handling System
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local context="$3"
    
    case "$error_code" in
        1)
            smart_error_message "file_not_found" "$context"
            ;;
        2)
            smart_error_message "permission_denied" "$context"
            ;;
        3)
            smart_error_message "invalid_format" "$context"
            ;;
        4)
            smart_error_message "framework_not_found" "$context"
            ;;
        *)
            error "$error_message"
            ;;
    esac
    
    # Log error for debugging
    log "ERROR: Code $error_code - $error_message - Context: $context"
    
    # Provide recovery suggestions
    suggest_recovery "$error_code" "$context"
}

# Recovery suggestions
suggest_recovery() {
    local error_code="$1"
    local context="$2"
    
    echo ""
    echo "🔧 Recovery Options:"
    
    case "$error_code" in
        1|2|3)
            echo "  - Check file permissions and paths"
            echo "  - Run diagnostic: ./ai-dev diagnose"
            echo "  - View logs: tail -f $LOG_FILE"
            ;;
        4)
            echo "  - Initialize framework: ./ai-dev setup"
            echo "  - Check current directory: pwd"
            echo "  - List contents: ls -la"
            ;;
        *)
            echo "  - Run diagnostic: ./ai-dev diagnose"
            echo "  - Check logs: cat $LOG_FILE"
            echo "  - Restart with --verbose flag"
            ;;
    esac
}

# Graceful shutdown
graceful_shutdown() {
    local signal="$1"
    
    echo ""
    warning "Received signal $signal - shutting down gracefully"
    
    # Clean up temporary files
    cleanup_temp_files
    
    # Save current state
    save_current_state
    
    # Log shutdown
    log "Framework shutdown - Signal: $signal"
    
    exit 0
}

# Set up signal handlers
setup_signal_handlers() {
    trap 'graceful_shutdown SIGINT' INT
    trap 'graceful_shutdown SIGTERM' TERM
}
```

## Integration Points

### CLI Script Integration
- Enhanced command validation and help system
- Progress indicators for long operations
- Interactive configuration wizard
- Robust error handling with recovery suggestions

### User Experience Improvements
- **Clear feedback**: Progress indicators and status messages
- **Contextual help**: Command-specific help and examples
- **Smart error messages**: Actionable error messages with suggestions
- **Graceful degradation**: Fallback options when tools are missing

### Production Features
- **Configuration management**: Persistent settings and preferences
- **Error recovery**: Automatic recovery suggestions
- **Signal handling**: Graceful shutdown and cleanup
- **Logging**: Comprehensive logging for debugging

This enhanced CLI system provides a production-ready user experience with robust validation, clear feedback, and comprehensive error handling.