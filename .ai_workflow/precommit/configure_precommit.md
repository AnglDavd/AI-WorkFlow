# Configure Pre-commit System Workflow

## Purpose
Configure and customize the pre-commit validation system for the AI Development Framework.

## When to Use
- Initial setup of pre-commit validation rules
- Adjusting quality thresholds and validation parameters
- Enabling/disabling specific validation categories
- Customizing validation behavior for project needs

## Prerequisites
- Git repository initialized
- Framework properly configured
- Pre-commit system architecture in place

## Configuration Process

### 1. Initialize Configuration Environment
```bash
echo "=== Pre-commit Configuration ==="
echo "Framework: AI Development Framework"
echo "Date: $(date)"
echo ""

# Configuration paths
CONFIG_DIR=".ai_workflow/precommit/config"
CONFIG_FILE="$CONFIG_DIR/validation_rules.json"
BACKUP_DIR=".ai_workflow/precommit/backup_config"

# Ensure directories exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"
mkdir -p ".ai_workflow/precommit/reports"

echo "✅ Configuration environment initialized"
echo "  Config directory: $CONFIG_DIR"
echo "  Config file: $CONFIG_FILE"
echo ""
```

### 2. Backup Existing Configuration
```bash
echo "=== Backing Up Existing Configuration ==="

if [ -f "$CONFIG_FILE" ]; then
    BACKUP_FILE="$BACKUP_DIR/validation_rules_$(date +%Y%m%d_%H%M%S).json"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "✅ Existing configuration backed up to: $BACKUP_FILE"
else
    echo "ℹ️  No existing configuration found"
fi
echo ""
```

### 3. Interactive Configuration Setup
```bash
echo "=== Interactive Configuration Setup ==="

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt="$1"
    local default="$2"
    local response
    
    while true; do
        if [ "$default" = "y" ]; then
            read -p "$prompt [Y/n]: " response
            response=${response:-y}
        else
            read -p "$prompt [y/N]: " response
            response=${response:-n}
        fi
        
        case "$response" in
            [yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][oO]) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# Function to prompt for number
prompt_number() {
    local prompt="$1"
    local default="$2"
    local min="$3"
    local max="$4"
    local response
    
    while true; do
        read -p "$prompt [$default]: " response
        response=${response:-$default}
        
        if [[ "$response" =~ ^[0-9]+$ ]] && [ "$response" -ge "$min" ] && [ "$response" -le "$max" ]; then
            echo "$response"
            return 0
        else
            echo "Please enter a number between $min and $max."
        fi
    done
}

echo "🔧 Let's configure your pre-commit validation system"
echo ""

# Code Quality Configuration
echo "📋 Code Quality Settings:"
if prompt_yes_no "Enable code quality validation?" "y"; then
    CODE_QUALITY_ENABLED="true"
    MAX_COMPLEXITY=$(prompt_number "Maximum code complexity (1-20)" "10" "1" "20")
    MAX_FUNCTION_LINES=$(prompt_number "Maximum function lines (20-200)" "50" "20" "200")
    REQUIRE_DOCS=$(prompt_yes_no "Require documentation?" "y" && echo "true" || echo "false")
else
    CODE_QUALITY_ENABLED="false"
    MAX_COMPLEXITY="10"
    MAX_FUNCTION_LINES="50"
    REQUIRE_DOCS="false"
fi

echo ""

# Security Configuration
echo "🔒 Security Settings:"
if prompt_yes_no "Enable security validation?" "y"; then
    SECURITY_ENABLED="true"
    BLOCK_SENSITIVE_DATA=$(prompt_yes_no "Block sensitive data in commits?" "y" && echo "true" || echo "false")
    REQUIRE_SECURE_PATHS=$(prompt_yes_no "Require secure file paths?" "y" && echo "true" || echo "false")
    SCAN_DEPENDENCIES=$(prompt_yes_no "Scan dependency security?" "y" && echo "true" || echo "false")
else
    SECURITY_ENABLED="false"
    BLOCK_SENSITIVE_DATA="false"
    REQUIRE_SECURE_PATHS="false"
    SCAN_DEPENDENCIES="false"
fi

echo ""

# Framework Compliance Configuration
echo "📋 Framework Compliance Settings:"
if prompt_yes_no "Enable framework compliance validation?" "y"; then
    COMPLIANCE_ENABLED="true"
    REQUIRE_CLAUDE_UPDATES=$(prompt_yes_no "Require CLAUDE.md updates?" "y" && echo "true" || echo "false")
    VALIDATE_WORKFLOW_STRUCTURE=$(prompt_yes_no "Validate workflow structure?" "y" && echo "true" || echo "false")
    ENFORCE_NAMING=$(prompt_yes_no "Enforce naming conventions?" "y" && echo "true" || echo "false")
else
    COMPLIANCE_ENABLED="false"
    REQUIRE_CLAUDE_UPDATES="false"
    VALIDATE_WORKFLOW_STRUCTURE="false"
    ENFORCE_NAMING="false"
fi

echo ""

# Quality Gates Configuration
echo "🚪 Quality Gates Settings:"
MIN_SCORE=$(prompt_number "Minimum quality score (0-100)" "85" "0" "100")
BLOCK_SECURITY=$(prompt_yes_no "Block commits with security issues?" "y" && echo "true" || echo "false")
BLOCK_CRITICAL=$(prompt_yes_no "Block commits with critical errors?" "y" && echo "true" || echo "false")
ALLOW_OVERRIDE=$(prompt_yes_no "Allow quality gate override?" "n" && echo "true" || echo "false")

echo ""

# Hook Configuration
echo "🔗 Git Hooks Settings:"
PRECOMMIT_ENABLED=$(prompt_yes_no "Enable pre-commit hook?" "y" && echo "true" || echo "false")
PREPUSH_ENABLED=$(prompt_yes_no "Enable pre-push hook?" "y" && echo "true" || echo "false")
COMMITMSG_ENABLED=$(prompt_yes_no "Enable commit message validation?" "y" && echo "true" || echo "false")

if [ "$PRECOMMIT_ENABLED" = "true" ]; then
    PRECOMMIT_TIMEOUT=$(prompt_number "Pre-commit timeout (seconds)" "30" "10" "120")
else
    PRECOMMIT_TIMEOUT="30"
fi

if [ "$PREPUSH_ENABLED" = "true" ]; then
    PREPUSH_TIMEOUT=$(prompt_number "Pre-push timeout (seconds)" "60" "30" "300")
else
    PREPUSH_TIMEOUT="60"
fi

echo ""
echo "✅ Configuration collection complete"
echo ""
```

### 4. Generate Configuration File
```bash
echo "=== Generating Configuration File ==="

# Create the configuration JSON
cat > "$CONFIG_FILE" << EOF
{
  "validation_rules": {
    "code_quality": {
      "enabled": $CODE_QUALITY_ENABLED,
      "max_complexity": $MAX_COMPLEXITY,
      "max_function_lines": $MAX_FUNCTION_LINES,
      "require_documentation": $REQUIRE_DOCS,
      "check_bash_syntax": true,
      "validate_markdown": true,
      "check_json_yaml": true
    },
    "security": {
      "enabled": $SECURITY_ENABLED,
      "block_sensitive_data": $BLOCK_SENSITIVE_DATA,
      "require_secure_paths": $REQUIRE_SECURE_PATHS,
      "scan_dependencies": $SCAN_DEPENDENCIES,
      "check_permissions": true,
      "validate_commands": true
    },
    "framework_compliance": {
      "enabled": $COMPLIANCE_ENABLED,
      "require_claude_md_updates": $REQUIRE_CLAUDE_UPDATES,
      "validate_workflow_structure": $VALIDATE_WORKFLOW_STRUCTURE,
      "check_integration_tests": false,
      "enforce_naming_conventions": $ENFORCE_NAMING,
      "validate_todo_updates": true
    },
    "documentation": {
      "enabled": true,
      "sync_readme": true,
      "validate_comments": true,
      "check_changelog": false,
      "require_examples": false
    }
  },
  "quality_gates": {
    "minimum_score": $MIN_SCORE,
    "block_on_security_issues": $BLOCK_SECURITY,
    "block_on_critical_errors": $BLOCK_CRITICAL,
    "allow_override": $ALLOW_OVERRIDE,
    "require_manual_review": false
  },
  "file_patterns": {
    "include": [
      "*.sh",
      "*.md",
      "*.json",
      "*.yml",
      "*.yaml",
      "ai-dev"
    ],
    "exclude": [
      ".git/**",
      ".ai_workflow/cache/**",
      ".ai_workflow/logs/**",
      "*.log",
      "*.tmp",
      "capturas/**",
      "*.png",
      "*.jpg",
      "*.jpeg",
      "*.gif"
    ]
  },
  "hooks": {
    "pre_commit": {
      "enabled": $PRECOMMIT_ENABLED,
      "timeout_seconds": $PRECOMMIT_TIMEOUT,
      "fail_fast": true
    },
    "pre_push": {
      "enabled": $PREPUSH_ENABLED,
      "timeout_seconds": $PREPUSH_TIMEOUT,
      "additional_checks": true
    },
    "commit_msg": {
      "enabled": $COMMITMSG_ENABLED,
      "enforce_conventional_commits": true,
      "max_length": 100
    }
  },
  "metadata": {
    "created": "$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")",
    "framework_version": "v0.4.0-beta",
    "configuration_version": "1.0"
  }
}
EOF

echo "✅ Configuration file generated: $CONFIG_FILE"
echo ""
```

### 5. Validate Configuration
```bash
echo "=== Validating Configuration ==="

# Check if configuration is valid JSON
if command -v python3 >/dev/null 2>&1; then
    if python3 -c "
import json
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    print('✅ Configuration file is valid JSON')
    
    # Check required sections
    required_sections = ['validation_rules', 'quality_gates', 'file_patterns', 'hooks']
    for section in required_sections:
        if section in config:
            print(f'✅ Section {section} present')
        else:
            print(f'❌ Section {section} missing')
    
except Exception as e:
    print(f'❌ Configuration validation failed: {e}')
    exit(1)
" 2>/dev/null; then
        echo "✅ Configuration validation passed"
    else
        echo "❌ Configuration validation failed"
        exit 1
    fi
else
    echo "⚠️  Python3 not available for validation"
    # Basic validation with jq if available
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$CONFIG_FILE" 2>/dev/null; then
            echo "✅ Configuration file is valid JSON (jq)"
        else
            echo "❌ Configuration file is invalid JSON (jq)"
            exit 1
        fi
    else
        echo "⚠️  Cannot validate JSON format"
    fi
fi

echo ""
```

### 6. Test Configuration
```bash
echo "=== Testing Configuration ==="

# Test configuration loading
echo "🧪 Testing configuration loading..."

if [ -f "$CONFIG_FILE" ]; then
    # Test basic configuration access
    echo "📋 Configuration Summary:"
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    
    # Show configuration summary
    validation_rules = config.get('validation_rules', {})
    quality_gates = config.get('quality_gates', {})
    hooks = config.get('hooks', {})
    
    print('  Code Quality:', 'enabled' if validation_rules.get('code_quality', {}).get('enabled') else 'disabled')
    print('  Security:', 'enabled' if validation_rules.get('security', {}).get('enabled') else 'disabled')
    print('  Compliance:', 'enabled' if validation_rules.get('framework_compliance', {}).get('enabled') else 'disabled')
    print('  Minimum Score:', quality_gates.get('minimum_score', 'not set'))
    print('  Pre-commit Hook:', 'enabled' if hooks.get('pre_commit', {}).get('enabled') else 'disabled')
    print('  Pre-push Hook:', 'enabled' if hooks.get('pre_push', {}).get('enabled') else 'disabled')
    
except Exception as e:
    print(f'Error reading configuration: {e}')
" 2>/dev/null
    else
        echo "  Configuration file exists and is accessible"
    fi
    
    echo "✅ Configuration test passed"
else
    echo "❌ Configuration file not found"
    exit 1
fi

echo ""
```

### 7. Generate Configuration Report
```bash
echo "=== Generating Configuration Report ==="

REPORT_FILE=".ai_workflow/precommit/reports/configuration_$(date +%Y%m%d_%H%M%S).txt"

{
    echo "Pre-commit Configuration Report"
    echo "Generated: $(date)"
    echo "Framework: AI Development Framework v0.4.0-beta"
    echo ""
    echo "Configuration File: $CONFIG_FILE"
    echo "Backup Location: $BACKUP_DIR"
    echo ""
    echo "Settings Summary:"
    echo "  Code Quality: $([ "$CODE_QUALITY_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
    echo "  Security: $([ "$SECURITY_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
    echo "  Compliance: $([ "$COMPLIANCE_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
    echo "  Minimum Score: $MIN_SCORE%"
    echo "  Pre-commit Hook: $([ "$PRECOMMIT_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
    echo "  Pre-push Hook: $([ "$PREPUSH_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
    echo ""
    echo "Quality Gates:"
    echo "  Block Security Issues: $([ "$BLOCK_SECURITY" = "true" ] && echo "yes" || echo "no")"
    echo "  Block Critical Errors: $([ "$BLOCK_CRITICAL" = "true" ] && echo "yes" || echo "no")"
    echo "  Allow Override: $([ "$ALLOW_OVERRIDE" = "true" ] && echo "yes" || echo "no")"
    echo ""
    echo "Configuration is active and ready for use."
} > "$REPORT_FILE"

echo "📄 Configuration report saved: $REPORT_FILE"
echo ""
```

### 8. Final Instructions
```bash
echo "=== Configuration Complete ==="
echo ""
echo "🎉 Pre-commit system has been configured successfully!"
echo ""
echo "📋 Configuration Summary:"
echo "  • Code Quality: $([ "$CODE_QUALITY_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
echo "  • Security: $([ "$SECURITY_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
echo "  • Compliance: $([ "$COMPLIANCE_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
echo "  • Minimum Score: $MIN_SCORE%"
echo "  • Pre-commit Hook: $([ "$PRECOMMIT_ENABLED" = "true" ] && echo "enabled" || echo "disabled")"
echo ""
echo "🔧 Next Steps:"
echo "  1. Install hooks: ./ai-dev precommit install-hooks"
echo "  2. Test validation: ./ai-dev precommit validate"
echo "  3. Generate report: ./ai-dev precommit report"
echo ""
echo "💡 To modify configuration later:"
echo "  • Run: ./ai-dev precommit configure"
echo "  • Edit: $CONFIG_FILE"
echo ""
echo "✅ Pre-commit system is now configured and ready to use!"
```

## Success Criteria
- Interactive configuration completed successfully
- Valid JSON configuration file generated
- Configuration validated and tested
- Appropriate defaults set for all options
- Configuration report generated
- User instructions provided

## Error Handling
- Backup existing configuration before changes
- Validate JSON format after generation
- Handle missing dependencies gracefully
- Provide clear error messages
- Rollback capability available

## Integration Points
- Git hooks system integration
- CLI command integration
- Validation workflow integration
- Reporting system integration
- Configuration management system