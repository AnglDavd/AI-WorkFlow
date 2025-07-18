# Centralized Version Management System

## Overview
The AI-Assisted Development Framework now uses a centralized version management system to ensure consistency across all components and avoid version mismatches.

## Architecture

### Core Components
- **`.ai_workflow/VERSION`**: Single source of truth for framework version
- **`.ai_workflow/scripts/version_utils.sh`**: Utility functions for version operations
- **Updated scripts**: All framework scripts now reference the centralized version

### Benefits
- ✅ **Single Source of Truth**: One file controls all version references
- ✅ **Consistency**: No more hardcoded versions in multiple files
- ✅ **Easy Updates**: Change version in one place, applies everywhere
- ✅ **Validation**: Built-in semantic versioning validation
- ✅ **Automation**: Scriptable version management for CI/CD

## Usage

### Basic Version Operations
```bash
# Get current version
./.ai_workflow/scripts/version_utils.sh get
# Output: v1.0.0

# Get version with prefix
./.ai_workflow/scripts/version_utils.sh get-with-prefix
# Output: v1.0.0

# Get version number only
./.ai_workflow/scripts/version_utils.sh get-number
# Output: 1.0.0

# Show detailed version information
./.ai_workflow/scripts/version_utils.sh info
```

### Administrative Operations
```bash
# Update framework version
./.ai_workflow/scripts/version_utils.sh update v1.1.0

# Validate version format
./.ai_workflow/scripts/version_utils.sh validate 1.2.0-beta

# Get version info as JSON
./.ai_workflow/scripts/version_utils.sh json
```

### Integration in Scripts
```bash
#!/bin/bash

# Load version utilities
source "$(dirname "${BASH_SOURCE[0]}")/.ai_workflow/scripts/version_utils.sh"

# Use version in your script
echo "Running Framework version: $(get_framework_version)"

# Check if version is valid
if is_valid_version "1.0.0"; then
    echo "Valid version format"
fi

# Get version info as JSON for API responses
VERSION_INFO=$(get_version_info_json)
echo "$VERSION_INFO"
```

## Implementation Details

### File Structure
```
.ai_workflow/
├── VERSION                           # Single source of truth
└── scripts/
    └── version_utils.sh             # Utility functions
```

### Version File Format
The `.ai_workflow/VERSION` file contains just the version number:
```
v1.0.0
```

### Supported Version Formats
- `1.0.0` (semantic versioning)
- `v1.0.0` (with v prefix)
- `1.0.0-beta` (with pre-release suffix)
- `v1.0.0-alpha.1` (with detailed pre-release)

## Migration Guide

### Before (Hardcoded Versions)
```bash
# In multiple files
echo "Framework Version: v1.0.0"
"version": "v1.0.0"
VERSION="1.0.0"
```

### After (Centralized System)
```bash
# Load utilities and use functions
source ".ai_workflow/scripts/version_utils.sh"
echo "Framework Version: $(get_framework_version)"

# In config files, use placeholders replaced during creation
"version": "PLACEHOLDER_VERSION"
# Then replace: sed -i "s/PLACEHOLDER_VERSION/$(get_framework_version)/g" config.json
```

## Examples

### Example 1: Workflow Script Integration
```bash
#!/bin/bash
# .ai_workflow/workflows/example/versioned_workflow.md

source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/version_utils.sh"

echo "🚀 Starting workflow with Framework $(get_framework_version)"

# Create output with version metadata
cat > output.json << EOF
{
  "workflow": "example",
  "framework_version": "$(get_framework_version)",
  "timestamp": "$(date -Iseconds)"
}
EOF
```

### Example 2: Configuration File Creation
```bash
create_config_with_version() {
    local config_file="$1"
    
    cat > "$config_file" << 'EOF'
{
  "framework": {
    "version": "PLACEHOLDER_VERSION",
    "name": "AI Development Framework"
  }
}
EOF
    
    # Replace placeholder with actual version
    local framework_version="$(get_framework_version)"
    sed -i "s/PLACEHOLDER_VERSION/$framework_version/g" "$config_file"
}
```

### Example 3: API Response with Version
```bash
generate_api_response() {
    local status="$1"
    local message="$2"
    
    cat << EOF
{
  "status": "$status",
  "message": "$message",
  "metadata": {
    "framework_version": "$(get_framework_version)",
    "timestamp": "$(date -Iseconds)"
  }
}
EOF
}
```

## Best Practices

### DO ✅
- Always source `version_utils.sh` when you need version info
- Use `PLACEHOLDER_VERSION` in config templates, then replace
- Validate version format before updates
- Include version info in logs and API responses
- Use semantic versioning (MAJOR.MINOR.PATCH)

### DON'T ❌
- Hardcode version numbers in scripts
- Manually edit version in multiple files
- Use non-semantic version formats
- Skip version validation
- Forget to update version after changes

## Troubleshooting

### Common Issues

**Issue**: `get_framework_version` returns "unknown"
```bash
# Solution: Check if VERSION file exists
ls -la .ai_workflow/VERSION
# If missing, create it
echo "v1.0.0" > .ai_workflow/VERSION
```

**Issue**: Version utils not found
```bash
# Solution: Use absolute path or check location
source "$(dirname "${BASH_SOURCE[0]}")/.ai_workflow/scripts/version_utils.sh"
```

**Issue**: Permission denied on version_utils.sh
```bash
# Solution: Make script executable
chmod +x .ai_workflow/scripts/version_utils.sh
```

## Future Enhancements

### Planned Features
- [ ] Automatic version bumping (patch/minor/major)
- [ ] Git tag integration for releases
- [ ] Version change changelog generation
- [ ] Backward compatibility checking
- [ ] Multi-component version tracking

### Integration Opportunities
- CI/CD pipeline version automation
- Release workflow integration
- Dependency version tracking
- Cross-project version synchronization

## Maintenance

### Regular Tasks
1. **Version Updates**: Use `version_utils.sh update` command
2. **Validation**: Periodically validate all version references
3. **Cleanup**: Remove old hardcoded version references
4. **Documentation**: Keep this guide updated with new features

### Monitoring
- Check for hardcoded versions: `grep -r "v[0-9]\+\.[0-9]\+\.[0-9]\+" --exclude-dir=.git`
- Validate version consistency: Run framework audits
- Test version utilities: Include in integration tests

---

## Summary

The centralized version management system provides:
- **Consistency**: Single source of truth for all version references
- **Maintainability**: Easy updates and validation
- **Automation**: Scriptable for CI/CD and workflows
- **Reliability**: Built-in validation and error handling

This system eliminates version inconsistencies and makes framework maintenance significantly easier.