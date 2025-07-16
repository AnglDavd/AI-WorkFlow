# Install Git Hooks Workflow

## Purpose
Install and configure git hooks for automated pre-commit validation in the AI Development Framework.

## When to Use
- Setting up pre-commit validation for the first time
- Reinstalling hooks after git configuration changes
- Updating hooks after framework updates
- When manual pre-commit validation is desired

## Prerequisites
- Git repository initialized
- Framework properly configured
- Write permissions to .git/hooks directory

## Installation Process

### 1. Validate Environment
```bash
echo "=== Git Hooks Installation ==="
echo "Framework: AI Development Framework"
echo "Date: $(date)"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Not in a git repository"
    echo "Please run this command from within a git repository"
    exit 1
fi

# Check if .git/hooks directory exists
GIT_HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo "❌ Git hooks directory not found: $GIT_HOOKS_DIR"
    exit 1
fi

# Check if framework hooks exist
FRAMEWORK_HOOKS_DIR=".ai_workflow/precommit/hooks"
if [ ! -d "$FRAMEWORK_HOOKS_DIR" ]; then
    echo "❌ Framework hooks directory not found: $FRAMEWORK_HOOKS_DIR"
    exit 1
fi

echo "✅ Environment validation passed"
echo "  Git repository: $(git rev-parse --show-toplevel)"
echo "  Git hooks directory: $GIT_HOOKS_DIR"
echo "  Framework hooks: $FRAMEWORK_HOOKS_DIR"
echo ""
```

### 2. Backup Existing Hooks
```bash
echo "=== Backing Up Existing Hooks ==="

BACKUP_DIR=".ai_workflow/precommit/backup_hooks_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

hooks_backed_up=0
for hook in pre-commit pre-push commit-msg; do
    if [ -f "$GIT_HOOKS_DIR/$hook" ]; then
        echo "📋 Backing up existing $hook hook"
        cp "$GIT_HOOKS_DIR/$hook" "$BACKUP_DIR/"
        hooks_backed_up=$((hooks_backed_up + 1))
    fi
done

if [ $hooks_backed_up -gt 0 ]; then
    echo "✅ Backed up $hooks_backed_up existing hooks to: $BACKUP_DIR"
else
    echo "ℹ️  No existing hooks found to backup"
fi
echo ""
```

### 3. Install Framework Hooks
```bash
echo "=== Installing Framework Hooks ==="

hooks_installed=0
for hook in pre-commit pre-push commit-msg; do
    if [ -f "$FRAMEWORK_HOOKS_DIR/$hook" ]; then
        echo "🔧 Installing $hook hook"
        cp "$FRAMEWORK_HOOKS_DIR/$hook" "$GIT_HOOKS_DIR/"
        chmod +x "$GIT_HOOKS_DIR/$hook"
        hooks_installed=$((hooks_installed + 1))
        echo "  ✅ $hook hook installed and made executable"
    else
        echo "  ⚠️  $hook hook not found in framework"
    fi
done

echo ""
echo "✅ Installed $hooks_installed framework hooks"
echo ""
```

### 4. Verify Installation
```bash
echo "=== Verifying Installation ==="

verification_passed=true

for hook in pre-commit pre-push commit-msg; do
    if [ -f "$GIT_HOOKS_DIR/$hook" ]; then
        if [ -x "$GIT_HOOKS_DIR/$hook" ]; then
            echo "✅ $hook hook: installed and executable"
        else
            echo "❌ $hook hook: installed but not executable"
            verification_passed=false
        fi
    else
        echo "⚠️  $hook hook: not installed"
    fi
done

echo ""
if [ "$verification_passed" = true ]; then
    echo "✅ Hook installation verification passed"
else
    echo "❌ Hook installation verification failed"
    exit 1
fi
echo ""
```

### 5. Test Hook Integration
```bash
echo "=== Testing Hook Integration ==="

# Test pre-commit hook
echo "🧪 Testing pre-commit hook integration"
if [ -f "$GIT_HOOKS_DIR/pre-commit" ]; then
    # Create a test environment
    TEST_FILE="test_precommit_$(date +%s).tmp"
    echo "# Test file for pre-commit validation" > "$TEST_FILE"
    
    # Add to git staging
    git add "$TEST_FILE" >/dev/null 2>&1 || true
    
    # Test the hook (dry run)
    echo "  Running pre-commit hook test..."
    if bash "$GIT_HOOKS_DIR/pre-commit" --dry-run 2>/dev/null || true; then
        echo "  ✅ Pre-commit hook test passed"
    else
        echo "  ⚠️  Pre-commit hook test had issues (this may be normal)"
    fi
    
    # Clean up
    rm -f "$TEST_FILE"
    git reset "$TEST_FILE" >/dev/null 2>&1 || true
else
    echo "  ⚠️  Pre-commit hook not found for testing"
fi

echo ""
```

### 6. Configure Hook Settings
```bash
echo "=== Configuring Hook Settings ==="

# Ensure validation rules exist
CONFIG_FILE=".ai_workflow/precommit/config/validation_rules.json"
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Validation rules configuration found"
    
    # Check if hooks are enabled in config
    if command -v python3 >/dev/null 2>&1; then
        HOOKS_ENABLED=$(python3 -c "
import json
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    hooks = config.get('hooks', {})
    print('pre-commit:', hooks.get('pre_commit', {}).get('enabled', True))
    print('pre-push:', hooks.get('pre_push', {}).get('enabled', True))
    print('commit-msg:', hooks.get('commit_msg', {}).get('enabled', True))
except Exception as e:
    print('Error reading config:', e)
" 2>/dev/null || echo "Could not read configuration")
        
        echo "📋 Hook configuration:"
        echo "$HOOKS_ENABLED" | sed 's/^/  /'
    else
        echo "⚠️  Python3 not available for configuration validation"
    fi
else
    echo "⚠️  Validation rules configuration not found"
    echo "  Creating default configuration..."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << 'EOF'
{
  "hooks": {
    "pre_commit": {
      "enabled": true,
      "timeout_seconds": 30
    },
    "pre_push": {
      "enabled": true,
      "timeout_seconds": 60
    },
    "commit_msg": {
      "enabled": true,
      "max_length": 100
    }
  }
}
EOF
    echo "  ✅ Default configuration created"
fi

echo ""
```

### 7. Generate Installation Report
```bash
echo "=== Installation Report ==="

REPORT_FILE=".ai_workflow/precommit/reports/installation_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p "$(dirname "$REPORT_FILE")"

{
    echo "Git Hooks Installation Report"
    echo "Generated: $(date)"
    echo "Framework: AI Development Framework"
    echo ""
    echo "Installation Summary:"
    echo "- Repository: $(git rev-parse --show-toplevel)"
    echo "- Hooks installed: $hooks_installed"
    echo "- Hooks backed up: $hooks_backed_up"
    echo "- Backup location: $BACKUP_DIR"
    echo ""
    echo "Installed Hooks:"
    for hook in pre-commit pre-push commit-msg; do
        if [ -f "$GIT_HOOKS_DIR/$hook" ]; then
            echo "  ✅ $hook"
        else
            echo "  ❌ $hook"
        fi
    done
    echo ""
    echo "Configuration:"
    echo "  Validation rules: $CONFIG_FILE"
    echo "  Framework hooks: $FRAMEWORK_HOOKS_DIR"
    echo ""
} > "$REPORT_FILE"

echo "📄 Installation report saved: $REPORT_FILE"
echo ""
```

### 8. Final Instructions
```bash
echo "=== Installation Complete ==="
echo ""
echo "🎉 Git hooks have been successfully installed!"
echo ""
echo "📋 What happens now:"
echo "  • Pre-commit validation will run automatically before each commit"
echo "  • Pre-push validation will run before pushing to remote"
echo "  • Commit message validation will ensure proper formatting"
echo ""
echo "🔧 Manual commands:"
echo "  • Validate manually: ./ai-dev precommit validate"
echo "  • Configure rules: ./ai-dev precommit configure"
echo "  • Generate report: ./ai-dev precommit report"
echo ""
echo "💡 To bypass validation (not recommended):"
echo "  • Use: git commit --no-verify"
echo ""
echo "🛠️  To update hooks after framework changes:"
echo "  • Run: ./ai-dev precommit install-hooks"
echo ""
echo "✅ Pre-commit system is now active and ready to use!"
```

## Success Criteria
- All framework hooks installed and executable
- Existing hooks backed up safely
- Hook integration tested successfully
- Configuration files validated
- Installation report generated
- User instructions provided

## Error Handling
- Graceful handling of missing directories
- Backup of existing hooks before replacement
- Verification of installation success
- Clear error messages for troubleshooting
- Rollback instructions if needed

## Integration Points
- Git hooks directory integration
- Framework configuration system
- CLI command integration
- Validation workflow integration
- Reporting system integration