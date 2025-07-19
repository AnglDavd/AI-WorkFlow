#!/bin/bash

# Emergency Recovery Script for AI Framework
# Enhanced version with comprehensive recovery capabilities
# Use this if circuit breakers malfunction or block legitimate operations

echo "🚨 Emergency Recovery Mode"
echo "=========================="
echo "Framework Emergency Recovery System v1.0"
echo ""

# Function to restore critical files
restore_critical_files() {
    echo "🔄 Restoring critical framework files..."
    
    # Restore manager.md if missing
    if [ ! -f "manager.md" ]; then
        echo "📝 Recreating manager.md..."
        cat > manager.md << 'EOF'
# AI Development Manager

This file contains instructions for AI agents working with this project.

## Project Context
Use the AI Development Framework located in `.ai_workflow/` to assist with development tasks.

## Available Commands
- `./ai-dev setup` - Initialize project
- `./ai-dev generate <prd>` - Generate tasks from PRD
- `./ai-dev run <prp>` - Execute Project Response Plans
- `./ai-dev quality <path>` - Validate code quality
- `./ai-dev audit` - Security audit
- `./ai-dev help` - Show all commands

## Guidelines
1. Follow workflows in `.ai_workflow/workflows/`
2. Use structured templates from `.ai_workflow/PRPs/templates/`
3. Maintain security-first approach
4. Document all significant changes
EOF
        echo "✅ manager.md restored"
    fi
    
    # Restore ai-dev if missing or corrupted
    if [ ! -x "ai-dev" ]; then
        echo "🔧 ai-dev script missing or not executable"
        if [ -f "ai-dev.backup" ]; then
            echo "🔄 Restoring from backup..."
            cp ai-dev.backup ai-dev
            chmod +x ai-dev
            echo "✅ ai-dev restored from backup"
        else
            echo "❌ No backup found - manual restoration required"
        fi
    fi
}

# Function to clear circuit breakers
clear_circuit_breakers() {
    echo "🔄 Clearing all circuit breakers..."
    
    if [ -d ".ai_workflow/circuit_breakers" ]; then
        find .ai_workflow/circuit_breakers -name "*_state" -type f -delete
        echo "✅ Circuit breaker states cleared"
    fi
    
    # Reset any temporary locks
    if [ -d ".ai_workflow/state" ]; then
        find .ai_workflow/state -name "*.lock" -type f -delete
        echo "✅ Temporary locks cleared"
    fi
}

# Function to validate framework integrity
validate_framework() {
    echo "🔍 Validating framework integrity..."
    
    local critical_dirs=(
        ".ai_workflow"
        ".ai_workflow/workflows"
        ".ai_workflow/scripts"
        ".ai_workflow/config"
    )
    
    local missing_dirs=()
    for dir in "${critical_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -gt 0 ]; then
        echo "❌ Missing critical directories:"
        printf '  - %s\n' "${missing_dirs[@]}"
        return 1
    else
        echo "✅ All critical directories present"
        return 0
    fi
}

# Function to reset permissions
reset_permissions() {
    echo "🔐 Resetting file permissions..."
    
    # Make scripts executable
    find .ai_workflow/scripts -name "*.sh" -type f -exec chmod +x {} \;
    chmod +x ai-dev 2>/dev/null || true
    
    # Set proper directory permissions
    find .ai_workflow -type d -exec chmod 755 {} \;
    
    echo "✅ Permissions reset"
}

# Main recovery process
main() {
    echo "Starting emergency recovery process..."
    echo ""
    
    # Step 1: Validate current state
    validate_framework
    framework_status=$?
    
    # Step 2: Clear circuit breakers
    clear_circuit_breakers
    
    # Step 3: Restore critical files
    restore_critical_files
    
    # Step 4: Reset permissions
    reset_permissions
    
    # Step 5: Final validation
    echo ""
    echo "🔍 Final validation..."
    if ./ai-dev status >/dev/null 2>&1; then
        echo "✅ Framework recovery successful"
        echo "🚀 Framework is operational"
    else
        echo "⚠️  Framework partially recovered"
        echo "   Run './ai-dev diagnose' for detailed analysis"
    fi
    
    echo ""
    echo "🎯 Recovery process completed"
    echo "   Log: $(date) - Emergency recovery executed" >> .ai_workflow/logs/emergency_recovery.log
}

# Run main function
main "$@"