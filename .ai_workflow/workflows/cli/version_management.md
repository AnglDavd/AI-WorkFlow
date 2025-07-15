# Version Management Workflow

## Overview
This workflow manages framework versioning, release criteria validation, and version lifecycle management for the AI Development Framework.

## Purpose
- Validate release criteria for different phases (alpha, beta, production)
- Create new releases with proper versioning
- Track version history and changelog
- Ensure quality gates are met before releases

## Prerequisites
- Version configuration files must exist
- Framework must be in a git repository
- jq utility must be installed

## Version Phase Definitions

### Alpha Phase (v0.x.x-alpha)
**Purpose**: Framework core development and stabilization
**Criteria**:
- Framework core 100% functional
- Interdependencies resolved
- Native parser implemented
- CLI commands working
- Basic testing completed

### Beta Phase (v1.x.x-beta)  
**Purpose**: Production-ready features and integration
**Criteria**:
- End-to-end workflows functional
- CRO knowledge base integrated
- CI/CD pipeline implemented
- Performance metrics active
- Comprehensive testing

### Production Phase (v2.x.x)
**Purpose**: Enterprise-grade framework with advanced features
**Criteria**:
- Multi-agent system
- Advanced UI/UX features
- Full monitoring and alerting
- External integrations
- Security certification

## Workflow Commands

### Check Current Version
```bash
echo "Current framework version:"
./.ai_workflow/scripts/version_manager.sh current
```

### Show Version Information
```bash
echo "=== Framework Version Information ==="
./.ai_workflow/scripts/version_manager.sh info
```

### Check Release Criteria
```bash
# Check current phase criteria
echo "Checking release criteria for current phase..."
./.ai_workflow/scripts/version_manager.sh check

# Check specific phase criteria
echo "Checking alpha criteria..."
./.ai_workflow/scripts/version_manager.sh check alpha

echo "Checking beta criteria..."
./.ai_workflow/scripts/version_manager.sh check beta

echo "Checking production criteria..."
./.ai_workflow/scripts/version_manager.sh check production
```

### Create New Release
```bash
# Example: Create new alpha release
NEW_VERSION="v0.4.0-alpha"
DESCRIPTION="Enhanced functionality and bug fixes"

echo "Creating new release: $NEW_VERSION"
./.ai_workflow/scripts/version_manager.sh release "$NEW_VERSION" "$DESCRIPTION"
```

### Validate Framework Health
```bash
echo "=== Framework Health Check ==="

# Check workflow functionality
WORKFLOW_COUNT=$(find .ai_workflow/workflows -name "*.md" | wc -l)
echo "Total workflows: $WORKFLOW_COUNT"

# Check for interdependency issues
INTERDEP_ISSUES=$(grep -r "source .ai_workflow/" .ai_workflow/workflows || true)
if [ -z "$INTERDEP_ISSUES" ]; then
    echo "✅ No interdependency issues found"
else
    echo "⚠️  Interdependency issues detected"
fi

# Check CLI functionality
if [ -x "./ai-dev" ]; then
    echo "✅ CLI script is executable"
    CLI_COMMANDS=$(./ai-dev help 2>/dev/null | grep -E "^\s+[a-z]" | wc -l)
    echo "Available CLI commands: $CLI_COMMANDS"
else
    echo "❌ CLI script not found or not executable"
fi
```

## Version Lifecycle Management

### Pre-Release Checklist
```bash
echo "=== Pre-Release Checklist ==="

# 1. Check git status
echo "1. Checking git status..."
if [ -d ".git" ]; then
    git status --porcelain
    if [ $? -eq 0 ]; then
        echo "✅ Git repository is clean"
    else
        echo "⚠️  Uncommitted changes detected"
    fi
else
    echo "❌ Not in a git repository"
fi

# 2. Run framework tests
echo "2. Running framework tests..."
./ai-dev test-workflow-calling > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Workflow calling tests passed"
else
    echo "❌ Workflow calling tests failed"
fi

# 3. Check security audit
echo "3. Running security audit..."
./ai-dev audit > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Security audit passed"
else
    echo "❌ Security audit failed"
fi

# 4. Validate configuration
echo "4. Validating configuration..."
if [ -f ".ai_workflow/config/framework.json" ]; then
    jq empty .ai_workflow/config/framework.json > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Framework configuration is valid"
    else
        echo "❌ Framework configuration is invalid"
    fi
else
    echo "❌ Framework configuration not found"
fi
```

### Post-Release Actions
```bash
echo "=== Post-Release Actions ==="

# 1. Update plan_de_trabajo.md
echo "1. Updating project plan..."
CURRENT_VERSION=$(./.ai_workflow/scripts/version_manager.sh current)
echo "Current version: $CURRENT_VERSION"

# 2. Create backup
echo "2. Creating release backup..."
BACKUP_DIR=".ai_workflow/backups/release_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r .ai_workflow/workflows "$BACKUP_DIR/"
cp -r .ai_workflow/config "$BACKUP_DIR/"
cp ai-dev "$BACKUP_DIR/"
echo "Backup created: $BACKUP_DIR"

# 3. Generate changelog
echo "3. Generating changelog..."
CHANGELOG_FILE="CHANGELOG.md"
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "# Changelog" > "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
fi

# Add new version to changelog
echo "## $CURRENT_VERSION ($(date +%Y-%m-%d))" >> "$CHANGELOG_FILE"
echo "" >> "$CHANGELOG_FILE"
echo "### Added" >> "$CHANGELOG_FILE"
echo "- New features and improvements" >> "$CHANGELOG_FILE"
echo "" >> "$CHANGELOG_FILE"
echo "### Fixed" >> "$CHANGELOG_FILE"
echo "- Bug fixes and stability improvements" >> "$CHANGELOG_FILE"
echo "" >> "$CHANGELOG_FILE"
```

## Version Validation Rules

### Semantic Versioning
- **Major version** (2.x.x): Breaking changes, major features
- **Minor version** (x.1.x): New features, backwards compatible
- **Patch version** (x.x.1): Bug fixes, minor improvements

### Phase Transitions
- **Alpha to Beta**: All alpha criteria met + additional beta requirements
- **Beta to Production**: All beta criteria met + production requirements
- **Hotfix releases**: Can be created from any phase for critical fixes

### Quality Gates
```bash
echo "=== Quality Gates Check ==="

# Functionality gate
FUNCTIONALITY=$(jq -r '.metrics.functionality_percentage' .ai_workflow/config/framework.json)
if [ "$FUNCTIONALITY" -eq 100 ]; then
    echo "✅ Functionality gate: $FUNCTIONALITY%"
else
    echo "❌ Functionality gate: $FUNCTIONALITY% (minimum 100%)"
fi

# Workflow gate
WORKFLOW_COUNT=$(jq -r '.metrics.total_workflows' .ai_workflow/config/framework.json)
if [ "$WORKFLOW_COUNT" -ge 40 ]; then
    echo "✅ Workflow gate: $WORKFLOW_COUNT workflows"
else
    echo "❌ Workflow gate: $WORKFLOW_COUNT workflows (minimum 40)"
fi

# Command gate
COMMAND_COUNT=$(jq -r '.metrics.commands_available' .ai_workflow/config/framework.json)
if [ "$COMMAND_COUNT" -ge 10 ]; then
    echo "✅ Command gate: $COMMAND_COUNT commands"
else
    echo "❌ Command gate: $COMMAND_COUNT commands (minimum 10)"
fi
```

## Integration with CI/CD

### GitHub Actions Integration
```bash
echo "=== GitHub Actions Integration ==="

# Check if CI configuration exists
if [ -f ".github/workflows/ci.yml" ]; then
    echo "✅ CI configuration found"
else
    echo "❌ CI configuration not found"
    echo "Creating basic CI configuration..."
    
    mkdir -p .github/workflows
    cat > .github/workflows/ci.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Test Framework
      run: |
        chmod +x ./ai-dev
        ./ai-dev test-workflow-calling
        ./ai-dev audit
        ./ai-dev diagnose
EOF
    echo "✅ Basic CI configuration created"
fi
```

## Error Handling

### Version Validation Errors
```bash
validate_version_format() {
    local version="$1"
    
    if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-alpha|-beta)?$ ]]; then
        echo "❌ Invalid version format: $version"
        echo "Expected format: vX.Y.Z[-alpha|-beta]"
        return 1
    fi
    
    return 0
}

check_version_sequence() {
    local current_version="$1"
    local new_version="$2"
    
    # Extract version numbers
    local current_nums=$(echo "$current_version" | sed 's/v\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1.\2.\3/')
    local new_nums=$(echo "$new_version" | sed 's/v\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1.\2.\3/')
    
    # Simple version comparison (in production, use proper version comparison)
    if [[ "$new_nums" < "$current_nums" ]]; then
        echo "❌ Version $new_version is lower than current $current_version"
        return 1
    fi
    
    return 0
}
```

## Usage Examples

### Standard Release Process
```bash
# 1. Check current status
./.ai_workflow/scripts/version_manager.sh info

# 2. Validate release criteria
./.ai_workflow/scripts/version_manager.sh check alpha

# 3. Create new release
./.ai_workflow/scripts/version_manager.sh release v0.4.0-alpha "Enhanced features"

# 4. Verify release
./.ai_workflow/scripts/version_manager.sh info
```

### Emergency Hotfix
```bash
# 1. Create hotfix branch
git checkout -b hotfix/v0.3.1-alpha

# 2. Apply fix
# ... make changes ...

# 3. Create hotfix release
./.ai_workflow/scripts/version_manager.sh release v0.3.1-alpha "Critical security fix"

# 4. Merge back to main
git checkout main
git merge hotfix/v0.3.1-alpha
```

## Monitoring and Metrics

### Release Metrics
```bash
echo "=== Release Metrics ==="

# Version history
echo "Version History:"
jq -r '.version_history[] | "\(.version) - \(.date) - \(.description)"' .ai_workflow/config/version_config.json

# Release frequency
echo "Release Frequency:"
RELEASE_COUNT=$(jq -r '.version_history | length' .ai_workflow/config/version_config.json)
echo "Total releases: $RELEASE_COUNT"

# Current phase progress
CURRENT_PHASE=$(./.ai_workflow/scripts/version_manager.sh phase)
echo "Current phase: $CURRENT_PHASE"
```

## Notes
- This workflow integrates with the main framework configuration
- Version information is stored in JSON format for easy parsing
- Git tags are automatically created for releases
- Release criteria are validated before version creation
- Changelog is automatically maintained