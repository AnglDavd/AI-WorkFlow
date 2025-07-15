# Manage Framework Versions

## Purpose
Control and manage framework versions, handle version compatibility, and provide rollback capabilities for framework updates.

## Input Parameters
- `action`: Action to perform (check, update, rollback, list)
- `target_version`: Specific version to update to or rollback to
- `force`: Force version change ignoring compatibility warnings (default: false)

## Prerequisites
- Git repository initialized
- Version configuration file exists
- Backup system functional
- Network access for version checks

## Process Flow

### 1. Version Detection
```bash
# Initialize version management
version_config=".ai_workflow/config/version.json"
current_version="unknown"
available_versions=()

# Create version config if not exists
if [ ! -f "$version_config" ]; then
    mkdir -p "$(dirname "$version_config")"
    cat > "$version_config" << 'EOF'
{
    "current_version": "1.0.0",
    "last_update": "",
    "update_channel": "stable",
    "auto_update": false,
    "version_history": []
}
EOF
fi

# Read current version
if [ -f "$version_config" ]; then
    current_version=$(grep -o '"current_version": "[^"]*"' "$version_config" | cut -d'"' -f4)
fi

# Detect version from git tags
if git rev-parse --git-dir >/dev/null 2>&1; then
    git_version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
    git_version=${git_version#v}  # Remove 'v' prefix
    
    # Update version config if git version is different
    if [ "$current_version" != "$git_version" ]; then
        current_version="$git_version"
        # Update version in config
        sed -i "s/\"current_version\": \"[^\"]*\"/\"current_version\": \"$current_version\"/" "$version_config"
    fi
fi
```

### 2. Version Compatibility Check
```bash
# Check compatibility with current system
check_compatibility() {
    local target_ver="$1"
    local current_ver="$2"
    
    # Parse version numbers
    IFS='.' read -r target_major target_minor target_patch <<< "$target_ver"
    IFS='.' read -r current_major current_minor current_patch <<< "$current_ver"
    
    # Check for breaking changes
    if [ "$target_major" -gt "$current_major" ]; then
        echo "⚠️  Major version upgrade detected. Breaking changes possible."
        return 1
    elif [ "$target_major" -lt "$current_major" ]; then
        echo "⚠️  Major version downgrade detected. Data loss possible."
        return 1
    fi
    
    return 0
}

# Validate framework structure for version
validate_framework_structure() {
    local required_files=(
        "ai-dev"
        "CLAUDE.md"
        "manager.md"
        ".ai_workflow/workflows/"
        ".ai_workflow/config/"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -e "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "❌ Missing required framework files:"
        printf '  - %s\n' "${missing_files[@]}"
        return 1
    fi
    
    return 0
}
```

### 3. Version Actions
```bash
case "$action" in
    "check")
        echo "📋 Current Framework Version: $current_version"
        
        # Check for updates
        if git rev-parse --git-dir >/dev/null 2>&1; then
            # Check if there are newer tags
            latest_tag=$(git ls-remote --tags origin | grep -v '\^{}' | sort -V | tail -1 | sed 's/.*refs\/tags\///')
            latest_version=${latest_tag#v}
            
            if [ "$current_version" != "$latest_version" ]; then
                echo "📦 Update available: $latest_version"
                echo "Run: ./ai-dev sync --action update --target-version $latest_version"
            else
                echo "✅ Framework is up to date"
            fi
        fi
        
        # Show version history
        if [ -f "$version_config" ]; then
            echo "📜 Version History:"
            grep -o '"version_history": \[[^]]*\]' "$version_config" | sed 's/.*\[\(.*\)\].*/\1/' | tr ',' '\n' | sed 's/[" ]//g'
        fi
        ;;
        
    "update")
        echo "🔄 Updating framework to version: $target_version"
        
        # Validate target version
        if [ -z "$target_version" ]; then
            echo "❌ Target version not specified"
            exit 1
        fi
        
        # Check compatibility
        if ! check_compatibility "$target_version" "$current_version" && [ "$force" != "true" ]; then
            echo "❌ Compatibility check failed. Use --force to override."
            exit 1
        fi
        
        # Create backup
        backup_timestamp=$(date +%Y%m%d_%H%M%S)
        backup_dir=".ai_workflow/backups/version_${current_version}_${backup_timestamp}"
        mkdir -p "$backup_dir"
        
        # Backup current version
        cp -r .ai_workflow/ "$backup_dir/" 2>/dev/null || true
        cp ai-dev "$backup_dir/" 2>/dev/null || true
        cp CLAUDE.md "$backup_dir/" 2>/dev/null || true
        cp manager.md "$backup_dir/" 2>/dev/null || true
        
        # Update to target version
        if git rev-parse --git-dir >/dev/null 2>&1; then
            git checkout "v$target_version" 2>/dev/null || git checkout "$target_version" 2>/dev/null || {
                echo "❌ Failed to checkout version $target_version"
                exit 1
            }
        fi
        
        # Validate framework structure
        if ! validate_framework_structure; then
            echo "❌ Framework structure validation failed"
            echo "🔄 Rolling back to previous version..."
            git checkout main
            exit 1
        fi
        
        # Update version config
        update_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        sed -i "s/\"current_version\": \"[^\"]*\"/\"current_version\": \"$target_version\"/" "$version_config"
        sed -i "s/\"last_update\": \"[^\"]*\"/\"last_update\": \"$update_timestamp\"/" "$version_config"
        
        # Add to version history
        history_entry="\"$current_version->$target_version($update_timestamp)\""
        sed -i "s/\"version_history\": \[\([^]]*\)\]/\"version_history\": [\1,$history_entry]/" "$version_config"
        
        echo "✅ Successfully updated to version $target_version"
        echo "📂 Backup created at: $backup_dir"
        ;;
        
    "rollback")
        echo "🔄 Rolling back to version: $target_version"
        
        if [ -z "$target_version" ]; then
            echo "❌ Target version not specified"
            exit 1
        fi
        
        # Find backup for target version
        backup_pattern=".ai_workflow/backups/version_${target_version}_*"
        backup_dir=$(find . -path "$backup_pattern" -type d | head -1)
        
        if [ -z "$backup_dir" ]; then
            echo "❌ No backup found for version $target_version"
            echo "Available backups:"
            find .ai_workflow/backups/ -name "version_*" -type d | sed 's/.*version_/  - /' | sort
            exit 1
        fi
        
        # Create backup of current state
        current_backup_timestamp=$(date +%Y%m%d_%H%M%S)
        current_backup_dir=".ai_workflow/backups/rollback_${current_version}_${current_backup_timestamp}"
        mkdir -p "$current_backup_dir"
        
        cp -r .ai_workflow/ "$current_backup_dir/" 2>/dev/null || true
        cp ai-dev "$current_backup_dir/" 2>/dev/null || true
        cp CLAUDE.md "$current_backup_dir/" 2>/dev/null || true
        cp manager.md "$current_backup_dir/" 2>/dev/null || true
        
        # Restore from backup
        if [ -d "$backup_dir/.ai_workflow" ]; then
            cp -r "$backup_dir/.ai_workflow"/* .ai_workflow/
        fi
        
        for file in ai-dev CLAUDE.md manager.md; do
            if [ -f "$backup_dir/$file" ]; then
                cp "$backup_dir/$file" .
            fi
        done
        
        # Validate restored framework
        if ! validate_framework_structure; then
            echo "❌ Restored framework structure validation failed"
            exit 1
        fi
        
        # Update version config
        rollback_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        sed -i "s/\"current_version\": \"[^\"]*\"/\"current_version\": \"$target_version\"/" "$version_config"
        sed -i "s/\"last_update\": \"[^\"]*\"/\"last_update\": \"$rollback_timestamp\"/" "$version_config"
        
        echo "✅ Successfully rolled back to version $target_version"
        echo "📂 Current state backed up at: $current_backup_dir"
        ;;
        
    "list")
        echo "📋 Framework Version Information"
        echo "Current Version: $current_version"
        echo ""
        
        # List available versions from git tags
        if git rev-parse --git-dir >/dev/null 2>&1; then
            echo "Available Versions:"
            git tag -l | sort -V | sed 's/^/  - /'
        fi
        
        echo ""
        echo "Available Backups:"
        find .ai_workflow/backups/ -name "version_*" -type d 2>/dev/null | sed 's/.*version_/  - /' | sort || echo "  No backups found"
        ;;
        
    *)
        echo "❌ Unknown action: $action"
        echo "Available actions: check, update, rollback, list"
        exit 1
        ;;
esac
```

### 4. Cleanup and Maintenance
```bash
# Clean up old backups (keep last 5)
cleanup_old_backups() {
    backup_count=$(find .ai_workflow/backups/ -name "version_*" -type d | wc -l)
    
    if [ "$backup_count" -gt 5 ]; then
        echo "🧹 Cleaning up old backups..."
        find .ai_workflow/backups/ -name "version_*" -type d | sort | head -n $((backup_count - 5)) | xargs rm -rf
        echo "✅ Cleaned up $((backup_count - 5)) old backups"
    fi
}

# Run cleanup if not a rollback operation
if [ "$action" != "rollback" ]; then
    cleanup_old_backups
fi
```

## Output
- Current version information
- Version compatibility status
- Update/rollback results
- Backup locations
- Version history

## Error Handling
- Missing target version → Prompt user for version
- Incompatible version → Warn and require force flag
- Missing backups → List available alternatives
- Structure validation failure → Automatic rollback
- Git operations failure → Detailed error reporting

## Security Considerations
- Version authenticity verification
- Backup integrity validation
- Rollback safety checks
- Framework structure validation
- Secure version metadata handling

## Dependencies
- Git repository with version tags
- JSON configuration file
- Backup system
- Framework validation tools
- Network access for remote version checks

## Success Criteria
- Version accurately detected and managed
- Successful updates with backup creation
- Reliable rollback functionality
- Version history maintained
- Framework integrity preserved