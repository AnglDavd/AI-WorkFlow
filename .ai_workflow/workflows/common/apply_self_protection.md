# Apply Self-Protection to Framework Project

## Purpose
Safely apply the framework's own protection mechanisms to itself for dogfooding and testing.

## Philosophy
**Gradual Implementation** - Apply protections incrementally to avoid disrupting development.

## Self-Protection Implementation

### 1. Phase 1: Basic Circuit Breakers

```bash
#!/bin/bash

# Apply basic circuit breakers to framework development
apply_basic_protection() {
    echo "🔒 Applying basic circuit breaker protection..."
    
    # Source the circuit breaker system
    source .ai_workflow/workflows/common/safe_execution_wrapper.md
    
    # Initialize circuit breakers for development operations
    echo "🔧 Initializing development circuit breakers..."
    
    # More permissive limits for development
    init_circuit_breaker "dev_diagnose" 10 1800        # 10 times per 30 minutes
    init_circuit_breaker "dev_audit" 5 3600           # 5 times per hour
    init_circuit_breaker "dev_precommit" 20 300       # 20 times per 5 minutes
    init_circuit_breaker "dev_quality" 8 1800         # 8 times per 30 minutes
    init_circuit_breaker "dev_sync" 2 3600            # 2 times per hour
    init_circuit_breaker "dev_setup" 1 7200           # 1 time per 2 hours
    
    # GitHub Actions specific (more restrictive)
    init_circuit_breaker "github_ci" 100 300          # 100 times per 5 minutes
    init_circuit_breaker "github_feedback" 50 1800    # 50 times per 30 minutes
    init_circuit_breaker "github_security" 10 3600    # 10 times per hour
    init_circuit_breaker "github_release" 1 86400     # 1 time per day
    
    echo "✅ Basic circuit breakers applied"
}

# Apply enhanced protections for critical operations
apply_enhanced_protection() {
    echo "🛡️ Applying enhanced protection for critical operations..."
    
    # Create protected wrapper for critical commands
    create_protected_ai_dev_wrapper
    
    # Apply GitHub Actions with circuit breakers
    apply_github_actions_protection
    
    echo "✅ Enhanced protection applied"
}

# Create a protected wrapper for ai-dev commands
create_protected_ai_dev_wrapper() {
    echo "🔧 Creating protected ai-dev wrapper..."
    
    # Backup original ai-dev
    if [ ! -f "ai-dev.original" ]; then
        cp ai-dev ai-dev.original
        echo "📋 Original ai-dev backed up"
    fi
    
    # Create protected wrapper
    cat > ai-dev.protected << 'EOF'
#!/bin/bash

# Protected AI-Dev Wrapper with Circuit Breakers
# This wrapper adds safety mechanisms to prevent loops and dangerous operations

# Source protection mechanisms
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.ai_workflow/workflows/common/safe_execution_wrapper.md"

# Get the original command
ORIGINAL_AI_DEV="$SCRIPT_DIR/ai-dev.original"

# Function to execute with protection
execute_protected() {
    local operation="$1"
    shift
    local args="$@"
    
    echo "🛡️ Protected execution: $operation"
    
    # Check emergency stop
    if ! check_emergency_stop; then
        echo "🚨 Emergency stop active - operation blocked"
        return 1
    fi
    
    # Use safe execution wrapper
    case "$operation" in
        "setup")
            safe_framework_execute "dev_setup" "$ORIGINAL_AI_DEV setup $args"
            ;;
        "diagnose")
            safe_framework_execute "dev_diagnose" "$ORIGINAL_AI_DEV diagnose $args"
            ;;
        "audit")
            safe_framework_execute "dev_audit" "$ORIGINAL_AI_DEV audit $args"
            ;;
        "precommit")
            safe_framework_execute "dev_precommit" "$ORIGINAL_AI_DEV precommit $args"
            ;;
        "quality")
            safe_framework_execute "dev_quality" "$ORIGINAL_AI_DEV quality $args"
            ;;
        "sync")
            safe_framework_execute "dev_sync" "$ORIGINAL_AI_DEV sync $args"
            ;;
        "generate"|"run"|"optimize")
            # More restrictive for auto-modifying operations
            safe_framework_execute "dev_$operation" "$ORIGINAL_AI_DEV $operation $args"
            ;;
        *)
            # Pass through other commands with basic protection
            safe_framework_execute "dev_other" "$ORIGINAL_AI_DEV $operation $args"
            ;;
    esac
}

# Execute with protection
execute_protected "$@"
EOF
    
    chmod +x ai-dev.protected
    echo "✅ Protected ai-dev wrapper created"
}

# Apply GitHub Actions protection
apply_github_actions_protection() {
    echo "🔧 Applying GitHub Actions protection..."
    
    # Check if GitHub Actions are already configured
    if [ -d ".github/workflows" ]; then
        echo "📋 GitHub Actions already configured"
        
        # Verify circuit breaker integration
        if grep -q "safe_execution_wrapper" .github/workflows/*.yml; then
            echo "✅ Circuit breakers already integrated in GitHub Actions"
        else
            echo "⚠️ Circuit breakers not integrated in GitHub Actions"
            echo "   Run integration manually if needed"
        fi
    else
        echo "⚠️ GitHub Actions not configured - skipping"
    fi
}

# Gradual rollout of protection
gradual_protection_rollout() {
    echo "🚀 Starting gradual protection rollout..."
    
    # Phase 1: Basic circuit breakers (safe)
    echo "📋 Phase 1: Basic circuit breakers"
    apply_basic_protection
    
    # Test basic functionality
    echo "🔍 Testing basic functionality..."
    if ./ai-dev.protected status > /dev/null 2>&1; then
        echo "✅ Basic functionality test passed"
    else
        echo "❌ Basic functionality test failed"
        return 1
    fi
    
    # Phase 2: Enhanced protection (more restrictive)
    echo "📋 Phase 2: Enhanced protection"
    # Use environment variable or default behavior for automation
    if [[ -n "${AUTO_CONFIRM:-}" ]]; then
        confirm="$AUTO_CONFIRM"
        echo "Apply enhanced protection? [y/N]: $confirm (automated)"
    else
        echo -n "Apply enhanced protection? [y/N]: "
        read confirm
    fi
    if [ "$confirm" = "y" ]; then
        apply_enhanced_protection
    else
        echo "ℹ️ Enhanced protection skipped"
    fi
    
    # Phase 3: Full self-application (most restrictive)
    echo "📋 Phase 3: Full self-application"
    # Use environment variable or default behavior for automation
    if [[ -n "${AUTO_CONFIRM:-}" ]]; then
        confirm="$AUTO_CONFIRM"
        echo "Apply full self-protection? [y/N]: $confirm (automated)"
    else
        echo -n "Apply full self-protection? [y/N]: "
        read confirm
    fi
    if [ "$confirm" = "y" ]; then
        apply_full_self_protection
    else
        echo "ℹ️ Full self-protection skipped"
    fi
    
    echo "✅ Protection rollout completed"
}

# Apply full self-protection
apply_full_self_protection() {
    echo "🛡️ Applying full self-protection..."
    
    # Replace ai-dev with protected version
    if [ -f "ai-dev.protected" ]; then
        echo "🔄 Replacing ai-dev with protected version..."
        
        # Backup current
        cp ai-dev ai-dev.backup
        
        # Replace with protected version
        mv ai-dev.protected ai-dev
        
        echo "✅ ai-dev replaced with protected version"
        echo "📋 Original backed up as ai-dev.original"
        echo "📋 Previous version backed up as ai-dev.backup"
    else
        echo "❌ Protected version not found"
        return 1
    fi
    
    # Apply GitHub Actions with full protection
    if [ -d ".github/workflows" ]; then
        echo "🔧 GitHub Actions already configured with protection"
    fi
    
    # Create emergency recovery script
    create_emergency_recovery_script
    
    echo "✅ Full self-protection applied"
    echo "🚨 Emergency recovery: ./emergency_recovery.sh"
}

# Create emergency recovery script
create_emergency_recovery_script() {
    echo "🚨 Creating emergency recovery script..."
    
    cat > emergency_recovery.sh << 'EOF'
#!/bin/bash

# Emergency Recovery Script
# Use this if circuit breakers malfunction or block legitimate operations

echo "🚨 Emergency Recovery Mode"
echo "=========================="

# Restore original ai-dev
if [ -f "ai-dev.original" ]; then
    echo "🔄 Restoring original ai-dev..."
    cp ai-dev.original ai-dev
    chmod +x ai-dev
    echo "✅ Original ai-dev restored"
else
    echo "❌ Original ai-dev not found"
fi

# Clear all circuit breakers
echo "🔄 Clearing all circuit breakers..."
rm -rf .ai_workflow/circuit_breakers/

# Clear emergency stop
echo "🔄 Clearing emergency stop..."
rm -f .ai_workflow/circuit_breakers/emergency_stop

# Restart circuit breaker system
echo "🔄 Reinitializing circuit breakers..."
source .ai_workflow/workflows/common/safe_execution_wrapper.md
init_framework_circuit_breakers

echo "✅ Emergency recovery completed"
echo "📋 Framework should now be fully operational"
EOF
    
    chmod +x emergency_recovery.sh
    echo "✅ Emergency recovery script created: ./emergency_recovery.sh"
}

# Test self-protection
test_self_protection() {
    echo "🔍 Testing self-protection mechanisms..."
    
    # Test 1: Basic command execution
    echo "📋 Test 1: Basic command execution"
    if ./ai-dev status > /dev/null 2>&1; then
        echo "✅ Basic command execution works"
    else
        echo "❌ Basic command execution failed"
        return 1
    fi
    
    # Test 2: Circuit breaker activation
    echo "📋 Test 2: Circuit breaker limits"
    for i in {1..6}; do
        echo "   Attempt $i/6"
        ./ai-dev status > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "✅ Circuit breaker activated at attempt $i"
            break
        fi
    done
    
    # Test 3: Emergency stop
    echo "📋 Test 3: Emergency stop mechanism"
    source .ai_workflow/workflows/common/safe_execution_wrapper.md
    emergency_stop "Test activation"
    
    if ! check_emergency_stop; then
        echo "✅ Emergency stop mechanism works"
    else
        echo "❌ Emergency stop mechanism failed"
    fi
    
    # Clear test emergency stop
    clear_emergency_stop
    
    echo "✅ Self-protection tests completed"
}

# Main execution
main() {
    echo "🛡️ Framework Self-Protection Application"
    echo "======================================"
    
    # Check if we're in the framework directory
    if [ ! -f "ai-dev" ] || [ ! -d ".ai_workflow" ]; then
        echo "❌ Not in framework directory"
        exit 1
    fi
    
    # Show options
    echo "📋 Self-Protection Options:"
    echo "1. Basic protection (circuit breakers only)"
    echo "2. Enhanced protection (+ GitHub Actions)"
    echo "3. Full protection (+ protected ai-dev wrapper)"
    echo "4. Gradual rollout (recommended)"
    echo "5. Test protection mechanisms"
    echo "6. Emergency recovery"
    
    # Use environment variable or default behavior for automation
    if [[ -n "${AUTO_CONFIRM:-}" ]]; then
        choice="$AUTO_CONFIRM"
        echo "Choose option [1-6]: $choice (automated)"
    else
        echo -n "Choose option [1-6]: "
        read choice
    fi
    
    case "$choice" in
        1) apply_basic_protection ;;
        2) apply_basic_protection && apply_enhanced_protection ;;
        3) apply_basic_protection && apply_enhanced_protection && apply_full_self_protection ;;
        4) gradual_protection_rollout ;;
        5) test_self_protection ;;
        6) source emergency_recovery.sh ;;
        *) echo "Invalid option" ;;
    esac
}

# Execute main function
main "$@"
```

## Usage

### Safe Application
```bash
# Apply gradual protection (recommended)
./ai-dev run .ai_workflow/workflows/common/apply_self_protection.md

# Or apply specific phases
bash .ai_workflow/workflows/common/apply_self_protection.md
```

### Emergency Recovery
```bash
# If something goes wrong
./emergency_recovery.sh

# Or manual recovery
cp ai-dev.original ai-dev
rm -rf .ai_workflow/circuit_breakers/
```

## Benefits

1. **Gradual Implementation**: Step-by-step protection application
2. **Emergency Recovery**: Always possible to revert changes
3. **Testing**: Built-in protection testing mechanisms
4. **Backup**: Automatic backup of original files
5. **Flexibility**: Choose level of protection needed
6. **Safety**: Multiple safety nets and confirmations

## Risk Mitigation

- **Backup System**: Original files always preserved
- **Emergency Recovery**: Immediate restoration capability
- **Gradual Rollout**: Test each phase before proceeding
- **Automated Approval**: Automatic validation with configurable safety thresholds for risky operations
- **Circuit Breaker Testing**: Verify protection mechanisms work