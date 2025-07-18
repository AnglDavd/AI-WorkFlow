#!/bin/bash

# Deploy Circuit Breaker Protection to User Projects
# This script is called during framework setup to deploy protection

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"
MODE="${2:-production}"

echo "🛡️  Deploying Circuit Breaker Protection"
echo "======================================"
echo "Framework: $FRAMEWORK_DIR"
echo "Target: $TARGET_DIR"
echo "Mode: $MODE"

# Check if target directory is valid
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Target directory does not exist: $TARGET_DIR"
    exit 1
fi

# Check if framework directory exists
if [ ! -d "$FRAMEWORK_DIR" ]; then
    echo "❌ Framework directory does not exist: $FRAMEWORK_DIR"
    exit 1
fi

# Create protection directory in target
PROTECTION_DIR="$TARGET_DIR/.ai_framework/protection"
mkdir -p "$PROTECTION_DIR"

# Copy protection scripts
echo "📦 Copying protection scripts..."
cp "$FRAMEWORK_DIR/scripts/simple_circuit_breaker.sh" "$PROTECTION_DIR/"
cp "$FRAMEWORK_DIR/scripts/mode_manager.sh" "$PROTECTION_DIR/"

# Make scripts executable
chmod +x "$PROTECTION_DIR/simple_circuit_breaker.sh"
chmod +x "$PROTECTION_DIR/mode_manager.sh"

# Create user-specific protection wrapper
echo "🔧 Creating user protection wrapper..."
cat > "$PROTECTION_DIR/user_protection.sh" << 'EOF'
#!/bin/bash

# User Project Protection Wrapper
# Provides circuit breaker protection for user projects

PROTECTION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$PROTECTION_DIR/../.." && pwd)"

# Source circuit breaker functions
source "$PROTECTION_DIR/simple_circuit_breaker.sh"

# User-specific safe execution
user_safe_execute() {
    local operation="$1"
    local command="$2"
    local file_path="${3:-}"
    
    echo "🛡️  User project protection: $operation"
    
    # Check if protection is enabled
    if [ -f "$PROTECTION_DIR/.protection_enabled" ]; then
        # Use circuit breaker protection
        safe_execute "$operation" "$command" "$file_path"
    else
        # Direct execution (protection disabled)
        echo "ℹ️  Protection disabled - executing directly"
        eval "$command"
    fi
}

# Enable/disable protection
enable_protection() {
    touch "$PROTECTION_DIR/.protection_enabled"
    echo "✅ Protection enabled for user project"
}

disable_protection() {
    rm -f "$PROTECTION_DIR/.protection_enabled"
    echo "❌ Protection disabled for user project"
}

# Check protection status
protection_status() {
    if [ -f "$PROTECTION_DIR/.protection_enabled" ]; then
        echo "✅ Protection: ENABLED"
        "$PROTECTION_DIR/mode_manager.sh" status
    else
        echo "❌ Protection: DISABLED"
    fi
}

# Main execution
case "$1" in
    "enable")
        enable_protection
        ;;
    "disable")
        disable_protection
        ;;
    "status")
        protection_status
        ;;
    "safe")
        shift
        user_safe_execute "$@"
        ;;
    "mode")
        shift
        "$PROTECTION_DIR/mode_manager.sh" "$@"
        ;;
    *)
        echo "User Project Protection"
        echo "Usage: $0 {enable|disable|status|safe|mode}"
        echo ""
        echo "Commands:"
        echo "  enable                     - Enable protection"
        echo "  disable                    - Disable protection"
        echo "  status                     - Show protection status"
        echo "  safe <op> <cmd> [file]     - Execute command with protection"
        echo "  mode <mode_cmd>            - Manage protection modes"
        ;;
esac
EOF

chmod +x "$PROTECTION_DIR/user_protection.sh"

# Initialize protection with specified mode
echo "🔧 Initializing protection with mode: $MODE"
cd "$TARGET_DIR"
"$PROTECTION_DIR/mode_manager.sh" init
"$PROTECTION_DIR/mode_manager.sh" set "$MODE"

# Create user-friendly protection commands
echo "📋 Creating user-friendly commands..."

# Create protection toggle script
cat > "$TARGET_DIR/.ai_framework/protection_toggle.sh" << 'EOF'
#!/bin/bash

# User-friendly protection toggle
PROTECTION_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/protection/user_protection.sh"

case "$1" in
    "on"|"enable")
        "$PROTECTION_SCRIPT" enable
        ;;
    "off"|"disable")
        "$PROTECTION_SCRIPT" disable
        ;;
    "status")
        "$PROTECTION_SCRIPT" status
        ;;
    "mode")
        shift
        "$PROTECTION_SCRIPT" mode "$@"
        ;;
    *)
        echo "🛡️  AI Framework Protection Toggle"
        echo "Usage: $0 {on|off|status|mode}"
        echo ""
        echo "Commands:"
        echo "  on/enable              - Enable protection"
        echo "  off/disable            - Disable protection"
        echo "  status                 - Show protection status"
        echo "  mode <command>         - Manage protection modes"
        echo ""
        echo "Examples:"
        echo "  $0 on                  - Enable protection"
        echo "  $0 mode set production - Set production mode"
        echo "  $0 mode list           - List available modes"
        ;;
esac
EOF

chmod +x "$TARGET_DIR/.ai_framework/protection_toggle.sh"

# Update ai-dev script to use protection
echo "🔧 Updating ai-dev script for protection..."
AI_DEV_SCRIPT="$TARGET_DIR/.ai_framework/ai-dev"

if [ -f "$AI_DEV_SCRIPT" ]; then
    # Backup original
    cp "$AI_DEV_SCRIPT" "$AI_DEV_SCRIPT.original"
    
    # Create protected version
    cat > "$AI_DEV_SCRIPT.protected" << 'EOF'
#!/bin/bash

# AI-Dev with Circuit Breaker Protection
# This version includes optional protection for user projects

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTECTION_SCRIPT="$FRAMEWORK_DIR/protection/user_protection.sh"
ORIGINAL_SCRIPT="$FRAMEWORK_DIR/ai-dev.original"

# Function to execute with optional protection
protected_execute() {
    local operation="$1"
    shift
    local args="$@"
    
    # Check if protection is available and enabled
    if [ -f "$PROTECTION_SCRIPT" ]; then
        "$PROTECTION_SCRIPT" safe "$operation" "$ORIGINAL_SCRIPT $operation $args"
    else
        # Fallback to direct execution
        "$ORIGINAL_SCRIPT" "$operation" $args
    fi
}

# Main execution
case "$1" in
    "setup"|"sync"|"generate"|"run"|"optimize")
        # Protected operations
        protected_execute "$@"
        ;;
    "diagnose"|"audit"|"precommit"|"quality")
        # Conditionally protected operations
        protected_execute "$@"
        ;;
    "help"|"version"|"status")
        # Pass through operations
        "$ORIGINAL_SCRIPT" "$@"
        ;;
    "protection")
        # Protection management
        shift
        "$FRAMEWORK_DIR/protection_toggle.sh" "$@"
        ;;
    *)
        # Default to protected execution
        protected_execute "$@"
        ;;
esac
EOF
    
    chmod +x "$AI_DEV_SCRIPT.protected"
    
    # Ask user if they want to enable protection
    echo ""
    echo "🛡️  Protection deployment complete!"
    echo ""
    echo "📋 Available options:"
    echo "1. Enable protection immediately (recommended)"
    echo "2. Leave protection disabled (manual activation)"
    echo "3. Enable protection with custom mode"
    echo ""
    
    # Use environment variable or default behavior for automation
    if [[ -n "${AUTO_CONFIRM:-}" ]]; then
        choice="$AUTO_CONFIRM"
        echo "Choose option [1-3]: $choice (automated)"
    else
        echo -n "Choose option [1-3]: "
        read choice
    fi
    
    case "$choice" in
        1)
            mv "$AI_DEV_SCRIPT.protected" "$AI_DEV_SCRIPT"
            "$PROTECTION_SCRIPT" enable
            echo "✅ Protection enabled with $MODE mode"
            ;;
        2)
            echo "ℹ️  Protection available but disabled"
            echo "    To enable: $TARGET_DIR/.ai_framework/protection_toggle.sh on"
            ;;
        3)
            echo "📋 Available modes:"
            "$PROTECTION_DIR/mode_manager.sh" list
            echo ""
            # Use environment variable or default behavior for automation
            if [[ -n "${CUSTOM_MODE:-}" ]]; then
                custom_mode="$CUSTOM_MODE"
                echo "Enter mode: $custom_mode (automated)"
            else
                echo -n "Enter mode: "
                read custom_mode
            fi
            mv "$AI_DEV_SCRIPT.protected" "$AI_DEV_SCRIPT"
            "$PROTECTION_DIR/mode_manager.sh" set "$custom_mode"
            "$PROTECTION_SCRIPT" enable
            echo "✅ Protection enabled with $custom_mode mode"
            ;;
    esac
else
    echo "⚠️  ai-dev script not found - protection scripts deployed but not integrated"
fi

echo ""
echo "🎉 Circuit Breaker Protection Deployment Complete!"
echo ""
echo "📋 User Commands:"
echo "  $TARGET_DIR/.ai_framework/protection_toggle.sh on/off"
echo "  $TARGET_DIR/.ai_framework/ai-dev protection status"
echo "  $TARGET_DIR/.ai_framework/ai-dev protection mode list"
echo ""
echo "📊 Protection Status:"
if [ -f "$PROTECTION_SCRIPT" ]; then
    "$PROTECTION_SCRIPT" status
else
    echo "❌ Protection not available"
fi