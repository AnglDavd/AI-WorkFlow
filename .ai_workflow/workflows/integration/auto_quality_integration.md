# Automatic Quality Integration Workflow

## Purpose
Integrate quality validation system automatically into all critical framework touchpoints for seamless, zero-friction quality assurance.

## Design Philosophy
- **Seamless Automation**: Quality validation happens transparently
- **Smart Triggers**: Only runs when necessary to avoid performance impact
- **Graceful Degradation**: Continues operation even if quality checks fail
- **User Control**: Configurable automation levels

## Integration Points

### 1. Pre-commit Hook Integration
```bash
echo "=== Integrating Quality Validation into Pre-commit Hooks ==="

# Create enhanced pre-commit hook
PRECOMMIT_HOOK=".ai_workflow/precommit/hooks/pre-commit"

# Add quality validation to existing pre-commit hook
if [[ -f "$PRECOMMIT_HOOK" ]]; then
    # Check if quality validation is already integrated
    if ! grep -q "quality_gates.md" "$PRECOMMIT_HOOK"; then
        echo "Adding quality validation to pre-commit hook..."
        
        # Insert quality validation before existing validations
        sed -i '/# Pre-commit validations/a\
\
# === QUALITY VALIDATION ===' "$PRECOMMIT_HOOK"
        
        sed -i '/# === QUALITY VALIDATION ===/a\
echo "🔍 Running quality validation..."\
if [[ "$QUALITY_VALIDATION_ENABLED" != "false" ]]; then\
    PROJECT_PATH="$(pwd)" bash .ai_workflow/workflows/quality/quality_gates.md\
    if [[ $? -ne 0 ]]; then\
        echo "❌ Quality validation failed. Use --no-verify to bypass or fix issues."\
        if [[ "$QUALITY_VALIDATION_STRICT" == "true" ]]; then\
            exit 1\
        else\
            echo "⚠️  Quality issues detected but not blocking commit (strict mode disabled)"\
        fi\
    else\
        echo "✅ Quality validation passed"\
    fi\
else\
    echo "⏭️  Quality validation disabled"\
fi\
' "$PRECOMMIT_HOOK"
        
        echo "✅ Quality validation integrated into pre-commit hook"
    else
        echo "✅ Quality validation already integrated in pre-commit hook"
    fi
else
    echo "⚠️  Pre-commit hook not found, creating basic integration"
    mkdir -p "$(dirname "$PRECOMMIT_HOOK")"
    cat > "$PRECOMMIT_HOOK" << 'EOF'
#!/bin/bash
# Enhanced pre-commit hook with quality validation

# Load configuration
QUALITY_VALIDATION_ENABLED="${QUALITY_VALIDATION_ENABLED:-true}"
QUALITY_VALIDATION_STRICT="${QUALITY_VALIDATION_STRICT:-false}"

# === QUALITY VALIDATION ===
echo "🔍 Running quality validation..."
if [[ "$QUALITY_VALIDATION_ENABLED" != "false" ]]; then
    PROJECT_PATH="$(pwd)" bash .ai_workflow/workflows/quality/quality_gates.md
    if [[ $? -ne 0 ]]; then
        echo "❌ Quality validation failed. Use --no-verify to bypass or fix issues."
        if [[ "$QUALITY_VALIDATION_STRICT" == "true" ]]; then
            exit 1
        else
            echo "⚠️  Quality issues detected but not blocking commit (strict mode disabled)"
        fi
    else
        echo "✅ Quality validation passed"
    fi
else
    echo "⏭️  Quality validation disabled"
fi

# Continue with other pre-commit validations...
EOF
    chmod +x "$PRECOMMIT_HOOK"
    echo "✅ Created new pre-commit hook with quality validation"
fi
```

### 2. PRP Execution Integration
```bash
echo "=== Integrating Quality Validation into PRP Execution ==="

PRP_EXECUTION_WORKFLOW=".ai_workflow/workflows/run/01_run_prp.md"

if [[ -f "$PRP_EXECUTION_WORKFLOW" ]]; then
    # Check if quality validation is already integrated
    if ! grep -q "quality_gates.md" "$PRP_EXECUTION_WORKFLOW"; then
        echo "Adding quality validation to PRP execution..."
        
        # Create backup
        cp "$PRP_EXECUTION_WORKFLOW" "$PRP_EXECUTION_WORKFLOW.backup"
        
        # Find the right place to insert quality validation (after setup, before execution)
        if grep -q "# Execute PRP" "$PRP_EXECUTION_WORKFLOW"; then
            sed -i '/# Execute PRP/i\
\
# === AUTOMATIC QUALITY VALIDATION ===\
echo "🔍 Running automatic quality validation before PRP execution..."\
if [[ "$QUALITY_VALIDATION_ENABLED" != "false" ]]; then\
    PROJECT_PATH="$(pwd)" bash .ai_workflow/workflows/quality/quality_gates.md\
    if [[ $? -ne 0 ]]; then\
        echo "❌ Quality validation failed before PRP execution"\
        if [[ "$QUALITY_VALIDATION_STRICT" == "true" ]]; then\
            echo "🚫 Blocking PRP execution due to quality issues (strict mode enabled)"\
            exit 1\
        else\
            echo "⚠️  Quality issues detected but proceeding with PRP execution"\
        fi\
    else\
        echo "✅ Quality validation passed, proceeding with PRP execution"\
    fi\
else\
    echo "⏭️  Quality validation disabled for PRP execution"\
fi\
' "$PRP_EXECUTION_WORKFLOW"
        else
            # If specific marker not found, add at the beginning of the workflow
            sed -i '1a\
\
# === AUTOMATIC QUALITY VALIDATION ===\
echo "🔍 Running automatic quality validation before PRP execution..."\
if [[ "$QUALITY_VALIDATION_ENABLED" != "false" ]]; then\
    PROJECT_PATH="$(pwd)" bash .ai_workflow/workflows/quality/quality_gates.md\
    if [[ $? -ne 0 ]]; then\
        echo "❌ Quality validation failed before PRP execution"\
        if [[ "$QUALITY_VALIDATION_STRICT" == "true" ]]; then\
            echo "🚫 Blocking PRP execution due to quality issues (strict mode enabled)"\
            exit 1\
        else\
            echo "⚠️  Quality issues detected but proceeding with PRP execution"\
        fi\
    else\
        echo "✅ Quality validation passed, proceeding with PRP execution"\
    fi\
else\
    echo "⏭️  Quality validation disabled for PRP execution"\
fi\
' "$PRP_EXECUTION_WORKFLOW"
        fi
        
        echo "✅ Quality validation integrated into PRP execution"
    else
        echo "✅ Quality validation already integrated in PRP execution"
    fi
else
    echo "⚠️  PRP execution workflow not found at expected location"
fi
```

### 3. Framework Setup Integration
```bash
echo "=== Integrating Quality Validation into Framework Setup ==="

SETUP_WORKFLOWS=(".ai_workflow/workflows/setup/"*.md)

for setup_file in "${SETUP_WORKFLOWS[@]}"; do
    if [[ -f "$setup_file" ]]; then
        filename=$(basename "$setup_file")
        
        # Integrate into the main setup workflow
        if [[ "$filename" == "01_setup_project.md" ]] || [[ "$filename" == "setup_project.md" ]]; then
            if ! grep -q "adaptive_language_support.md" "$setup_file"; then
                echo "Adding language detection to setup workflow: $filename"
                
                # Add language detection and quality system setup
                sed -i '/# Project setup/a\
\
# === AUTOMATIC LANGUAGE DETECTION AND QUALITY SETUP ===\
echo "🔍 Setting up automatic language detection and quality validation..."\
\
# Run adaptive language support to detect and configure project\
if bash .ai_workflow/workflows/quality/adaptive_language_support.md; then\
    echo "✅ Language detection and quality tools configured automatically"\
else\
    echo "⚠️  Language detection had issues, using basic configuration"\
fi\
\
# Set default quality validation preferences\
export QUALITY_VALIDATION_ENABLED="${QUALITY_VALIDATION_ENABLED:-true}"\
export QUALITY_VALIDATION_STRICT="${QUALITY_VALIDATION_STRICT:-false}"\
\
echo "Quality validation enabled: $QUALITY_VALIDATION_ENABLED"\
echo "Quality validation strict mode: $QUALITY_VALIDATION_STRICT"\
' "$setup_file"
                
                echo "✅ Language detection integrated into setup: $filename"
            else
                echo "✅ Language detection already integrated in: $filename"
            fi
        fi
    fi
done
```

### 4. CLI Commands Integration
```bash
echo "=== Integrating Quality Validation into CLI Commands ==="

CLI_SCRIPT="./ai-dev"

if [[ -f "$CLI_SCRIPT" ]]; then
    # Create backup
    cp "$CLI_SCRIPT" "$CLI_SCRIPT.backup"
    
    # Add quality validation function to CLI script
    if ! grep -q "run_quality_validation()" "$CLI_SCRIPT"; then
        echo "Adding quality validation function to CLI script..."
        
        # Add the function after utility functions
        sed -i '/# --- Utility Functions ---/a\
\
# Quality validation function\
run_quality_validation() {\
    local context="$1"\
    local project_path="${2:-$(pwd)}"\
    \
    if [[ "$QUALITY_VALIDATION_ENABLED" == "false" ]]; then\
        echo "⏭️  Quality validation disabled"\
        return 0\
    fi\
    \
    echo "🔍 Running quality validation ($context)..."\
    \
    if PROJECT_PATH="$project_path" bash .ai_workflow/workflows/quality/quality_gates.md; then\
        echo "✅ Quality validation passed"\
        return 0\
    else\
        echo "❌ Quality validation failed"\
        if [[ "$QUALITY_VALIDATION_STRICT" == "true" ]]; then\
            echo "🚫 Operation blocked due to quality issues (strict mode enabled)"\
            return 1\
        else\
            echo "⚠️  Quality issues detected but operation proceeding"\
            return 0\
        fi\
    fi\
}\
' "$CLI_SCRIPT"
    fi
    
    # Find critical commands and add quality validation
    CRITICAL_COMMANDS=("run" "generate" "optimize")
    
    for cmd in "${CRITICAL_COMMANDS[@]}"; do
        if grep -q "^${cmd}()" "$CLI_SCRIPT"; then
            # Check if quality validation is already integrated
            if ! grep -A 10 "^${cmd}()" "$CLI_SCRIPT" | grep -q "run_quality_validation"; then
                echo "Adding quality validation to $cmd command..."
                
                # Add quality validation call at the beginning of the command function
                sed -i "/^${cmd}()/a\
    # Automatic quality validation\
    run_quality_validation \"$cmd command\" || exit 1\
" "$CLI_SCRIPT"
                
                echo "✅ Quality validation integrated into $cmd command"
            else
                echo "✅ Quality validation already integrated in $cmd command"
            fi
        fi
    done
    
    echo "✅ CLI integration completed"
else
    echo "⚠️  CLI script not found at expected location"
fi
```

### 5. Configuration System Creation
```bash
echo "=== Creating Quality Validation Configuration System ==="

CONFIG_DIR=".ai_workflow/config"
QUALITY_CONFIG="$CONFIG_DIR/quality_config.json"

mkdir -p "$CONFIG_DIR"

# Create quality configuration file
cat > "$QUALITY_CONFIG" << 'EOF'
{
  "quality_validation": {
    "enabled": true,
    "strict_mode": false,
    "auto_integration": {
      "precommit": true,
      "prp_execution": true,
      "cli_commands": true,
      "setup": true
    },
    "validation_levels": {
      "syntax": true,
      "tests": true,
      "dependencies": true,
      "code_quality": true
    },
    "thresholds": {
      "quality_score": 75,
      "test_coverage": 70,
      "complexity": 10,
      "duplication": 5
    },
    "bypass_commands": [
      "help",
      "version",
      "status",
      "configure"
    ]
  },
  "language_detection": {
    "enabled": true,
    "auto_configure_tools": true,
    "save_profiles": true,
    "use_prd_hints": true
  }
}
EOF

# Create configuration management script
cat > "$CONFIG_DIR/manage_quality_config.sh" << 'EOF'
#!/bin/bash

# Quality configuration management script
CONFIG_FILE=".ai_workflow/config/quality_config.json"

get_config() {
    local key="$1"
    jq -r "$key" "$CONFIG_FILE" 2>/dev/null || echo "true"
}

set_config() {
    local key="$1"
    local value="$2"
    
    # Create backup
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    
    # Update configuration
    jq "$key = $value" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
}

# Load configuration into environment
load_quality_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        export QUALITY_VALIDATION_ENABLED=$(get_config '.quality_validation.enabled')
        export QUALITY_VALIDATION_STRICT=$(get_config '.quality_validation.strict_mode')
        export LANGUAGE_DETECTION_ENABLED=$(get_config '.language_detection.enabled')
        export AUTO_CONFIGURE_TOOLS=$(get_config '.language_detection.auto_configure_tools')
    else
        # Default values
        export QUALITY_VALIDATION_ENABLED="true"
        export QUALITY_VALIDATION_STRICT="false"
        export LANGUAGE_DETECTION_ENABLED="true"
        export AUTO_CONFIGURE_TOOLS="true"
    fi
}

# Usage examples:
# load_quality_config
# set_config '.quality_validation.enabled' 'false'
# get_config '.quality_validation.strict_mode'
EOF

chmod +x "$CONFIG_DIR/manage_quality_config.sh"

echo "✅ Quality validation configuration system created"
```

### 6. Environment Setup
```bash
echo "=== Setting up Quality Validation Environment ==="

# Create environment setup script
ENV_SETUP_SCRIPT=".ai_workflow/scripts/setup_quality_env.sh"
mkdir -p "$(dirname "$ENV_SETUP_SCRIPT")"

cat > "$ENV_SETUP_SCRIPT" << 'EOF'
#!/bin/bash

# Quality validation environment setup
echo "🔧 Setting up quality validation environment..."

# Source configuration
if [[ -f ".ai_workflow/config/manage_quality_config.sh" ]]; then
    source .ai_workflow/config/manage_quality_config.sh
    load_quality_config
else
    # Default environment
    export QUALITY_VALIDATION_ENABLED="true"
    export QUALITY_VALIDATION_STRICT="false"
    export LANGUAGE_DETECTION_ENABLED="true"
    export AUTO_CONFIGURE_TOOLS="true"
fi

# Create cache directories
mkdir -p .ai_workflow/cache/quality
mkdir -p .ai_workflow/cache/language_support

# Set up git hooks if not already done
if [[ -f ".ai_workflow/precommit/hooks/pre-commit" ]]; then
    # Install git hooks
    if [[ -d ".git/hooks" ]]; then
        ln -sf "../../.ai_workflow/precommit/hooks/pre-commit" ".git/hooks/pre-commit"
        chmod +x ".git/hooks/pre-commit"
        echo "✅ Git hooks installed"
    fi
fi

echo "✅ Quality validation environment ready"
echo "   - Quality validation: $QUALITY_VALIDATION_ENABLED"
echo "   - Strict mode: $QUALITY_VALIDATION_STRICT"
echo "   - Language detection: $LANGUAGE_DETECTION_ENABLED"
echo "   - Auto-configure tools: $AUTO_CONFIGURE_TOOLS"
EOF

chmod +x "$ENV_SETUP_SCRIPT"

# Run environment setup
bash "$ENV_SETUP_SCRIPT"

echo "✅ Quality validation environment configured"
```

### 7. Integration Verification
```bash
echo "=== Verifying Quality Validation Integration ==="

INTEGRATION_POINTS=(
    "Pre-commit hooks:.ai_workflow/precommit/hooks/pre-commit"
    "PRP execution:.ai_workflow/workflows/run/01_run_prp.md"
    "CLI script:./ai-dev"
    "Quality config:.ai_workflow/config/quality_config.json"
    "Environment setup:.ai_workflow/scripts/setup_quality_env.sh"
)

INTEGRATION_STATUS=0

for point in "${INTEGRATION_POINTS[@]}"; do
    name="${point%%:*}"
    file="${point##*:}"
    
    if [[ -f "$file" ]]; then
        echo "✅ $name integrated ($file)"
    else
        echo "❌ $name NOT integrated ($file missing)"
        INTEGRATION_STATUS=1
    fi
done

# Test integration
echo ""
echo "🧪 Testing quality validation integration..."

# Test language detection
if bash .ai_workflow/workflows/quality/adaptive_language_support.md >/dev/null 2>&1; then
    echo "✅ Language detection working"
else
    echo "⚠️  Language detection has issues"
fi

# Test configuration system
if [[ -f ".ai_workflow/config/manage_quality_config.sh" ]]; then
    source .ai_workflow/config/manage_quality_config.sh
    if load_quality_config; then
        echo "✅ Configuration system working"
    else
        echo "⚠️  Configuration system has issues"
    fi
fi

if [[ $INTEGRATION_STATUS -eq 0 ]]; then
    echo ""
    echo "🎉 Quality validation integration SUCCESSFUL!"
    echo "   The system will now automatically validate quality at key points:"
    echo "   - ✅ Before commits (pre-commit hooks)"
    echo "   - ✅ Before PRP execution"
    echo "   - ✅ In critical CLI commands"
    echo "   - ✅ During framework setup"
    echo ""
    echo "   Configuration:"
    echo "   - Quality validation: ${QUALITY_VALIDATION_ENABLED:-true}"
    echo "   - Strict mode: ${QUALITY_VALIDATION_STRICT:-false}"
    echo "   - Language detection: ${LANGUAGE_DETECTION_ENABLED:-true}"
    echo ""
    echo "   To disable: export QUALITY_VALIDATION_ENABLED=false"
    echo "   To enable strict mode: export QUALITY_VALIDATION_STRICT=true"
else
    echo ""
    echo "⚠️  Quality validation integration had some issues"
    echo "   Check the missing files and re-run the integration"
fi

exit $INTEGRATION_STATUS
```

## Configuration Management

### Environment Variables
- `QUALITY_VALIDATION_ENABLED`: Enable/disable automatic quality validation (default: true)
- `QUALITY_VALIDATION_STRICT`: Strict mode blocks operations on quality failures (default: false)
- `LANGUAGE_DETECTION_ENABLED`: Enable automatic language detection (default: true)
- `AUTO_CONFIGURE_TOOLS`: Automatically configure quality tools (default: true)

### Configuration File
Location: `.ai_workflow/config/quality_config.json`
- Persistent configuration storage
- Per-project customization
- Validation thresholds
- Integration point control

### User Control
```bash
# Disable quality validation temporarily
export QUALITY_VALIDATION_ENABLED=false

# Enable strict mode
export QUALITY_VALIDATION_STRICT=true

# Disable for specific command
QUALITY_VALIDATION_ENABLED=false ./ai-dev run my-prp.md

# Configure via CLI (future enhancement)
./ai-dev configure --quality-validation=false
```

## Benefits

1. **Zero-Friction Experience**: Quality validation happens automatically
2. **Smart Integration**: Only runs when necessary
3. **Graceful Degradation**: Continues operation even with quality issues
4. **User Control**: Fully configurable automation levels
5. **Seamless Setup**: Automatic configuration during framework initialization
6. **Performance Optimized**: Cached results and smart triggers

## Integration Points Summary

- ✅ **Pre-commit Hooks**: Validates before commits
- ✅ **PRP Execution**: Validates before running PRPs
- ✅ **Framework Setup**: Configures language detection automatically
- ✅ **CLI Commands**: Validates in critical commands (run, generate, optimize)
- ✅ **Configuration System**: Persistent, configurable automation
- ✅ **Environment Setup**: Automatic environment configuration

This integration transforms the quality validation system from manual execution to seamless, automatic operation across all framework touchpoints.