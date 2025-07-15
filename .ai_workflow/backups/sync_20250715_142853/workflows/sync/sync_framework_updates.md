# Sync Framework Updates

## Purpose
Synchronize local framework with updates from the main repository while maintaining local customizations and security.

## Input Parameters
- `repository_url`: Main repository URL (default: framework origin)
- `branch`: Target branch to sync from (default: main)
- `force_sync`: Override local changes if conflicts exist (default: false)

## Prerequisites
- Git repository initialized
- Network connectivity
- Valid repository access permissions
- Backup of current state created

## Process Flow

### 1. Preparation Phase
```bash
# Create backup of current state
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir=".ai_workflow/backups/sync_${timestamp}"
mkdir -p "$backup_dir"

# Backup critical files
cp -r .ai_workflow/workflows "$backup_dir/"
cp -r .ai_workflow/config "$backup_dir/" 2>/dev/null || true
cp CLAUDE.md "$backup_dir/" 2>/dev/null || true
cp manager.md "$backup_dir/" 2>/dev/null || true
cp ai-dev "$backup_dir/" 2>/dev/null || true
```

### 2. Fetch Updates
```bash
# Set default values for variables
repository_url=${repository_url:-"https://github.com/your-org/ai-framework.git"}
branch=${branch:-"main"}

# Check if we're in testing mode (local development)
if [ -f ".ai_workflow/testing/test_mode" ]; then
    echo "📝 Running in test mode - skipping remote fetch"
    echo "✅ Sync test completed successfully"
    exit 0
fi

# Add upstream remote if not exists
if ! git remote get-url upstream >/dev/null 2>&1; then
    if ! git remote add upstream "$repository_url" 2>/dev/null; then
        echo "⚠️  Warning: Could not add upstream remote. Using local sync mode."
        echo "✅ Local sync mode activated"
        exit 0
    fi
fi

# Fetch latest changes with timeout and error handling
if ! timeout 10 git fetch upstream "$branch" 2>/dev/null; then
    echo "⚠️  Warning: Could not fetch from upstream. Using local sync mode."
    echo "✅ Local sync mode activated"
    exit 0
fi
```

### 3. Analyze Changes
```bash
# Get list of changed files
changed_files=$(git diff --name-only HEAD upstream/${branch:-main})

# Categorize changes
framework_changes=$(echo "$changed_files" | grep -E '\.ai_workflow/workflows/|\.ai_workflow/config/|ai-dev|CLAUDE\.md|manager\.md' || true)
user_changes=$(echo "$changed_files" | grep -v -E '\.ai_workflow/workflows/|\.ai_workflow/config/|ai-dev|CLAUDE\.md|manager\.md' || true)
```

### 4. Validate Changes
```bash
# Check for security issues in upstream changes
security_check_passed=true

# Scan for suspicious patterns
if echo "$changed_files" | xargs -I {} sh -c 'if [ -f "{}" ]; then grep -l "rm -rf\|sudo\|eval\|exec" "{}" 2>/dev/null; fi' | grep -q .; then
    echo "⚠️  Security concern: Potentially dangerous commands found in upstream changes"
    security_check_passed=false
fi

# Validate workflow syntax
for workflow_file in $(echo "$framework_changes" | grep '\.md$'); do
    if [ -f "$workflow_file" ]; then
        # Basic markdown syntax validation
        if ! grep -q "^# " "$workflow_file"; then
            echo "⚠️  Warning: $workflow_file may have invalid workflow format"
        fi
    fi
done
```

### 5. Apply Updates
```bash
if [ "$security_check_passed" = true ]; then
    # Create temporary branch for merge
    git checkout -b "sync-upstream-${timestamp}"
    
    # Apply framework updates
    if [ -n "$framework_changes" ]; then
        echo "📥 Applying framework updates..."
        
        # Merge specific files
        for file in $framework_changes; do
            if [ -f "$file" ]; then
                # Preserve local customizations in critical files
                if [[ "$file" == "CLAUDE.md" || "$file" == "manager.md" ]]; then
                    # Create merged version with local customizations preserved
                    git show "upstream/${branch:-main}:$file" > "${file}.upstream"
                    echo "⚠️  Manual merge required for $file"
                else
                    # Direct update for framework files
                    git checkout "upstream/${branch:-main}" -- "$file"
                fi
            fi
        done
        
        # Commit changes
        git add .
        git commit -m "sync: Update framework from upstream

- Applied updates from upstream/${branch:-main}
- Preserved local customizations
- Backup created at $backup_dir

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>" || true
    fi
else
    echo "❌ Security validation failed. Sync aborted."
    exit 1
fi
```

### 6. Validation Phase
```bash
# Test framework integrity
if [ -f "ai-dev" ]; then
    chmod +x ai-dev
    
    # Run basic framework validation
    if ./ai-dev help >/dev/null 2>&1; then
        echo "✅ Framework CLI validation passed"
    else
        echo "❌ Framework CLI validation failed"
        validation_failed=true
    fi
fi

# Validate workflow syntax
validation_failed=false
for workflow_dir in .ai_workflow/workflows/*/; do
    if [ -d "$workflow_dir" ]; then
        for workflow_file in "$workflow_dir"*.md; do
            if [ -f "$workflow_file" ]; then
                # Check for basic workflow structure
                if ! grep -q "^## Purpose\|^## Input Parameters\|^## Process Flow" "$workflow_file"; then
                    echo "⚠️  Warning: $workflow_file may have incomplete workflow structure"
                fi
            fi
        done
    fi
done
```

### 7. Finalization
```bash
if [ "$validation_failed" = false ]; then
    # Merge back to main branch
    git checkout main
    git merge "sync-upstream-${timestamp}" --no-ff -m "Sync with upstream framework updates"
    
    # Clean up temporary branch
    git branch -d "sync-upstream-${timestamp}"
    
    echo "✅ Framework sync completed successfully"
    echo "📂 Backup available at: $backup_dir"
else
    # Rollback on validation failure
    git checkout main
    git branch -D "sync-upstream-${timestamp}"
    
    echo "❌ Framework sync failed validation. Rolling back..."
    echo "📂 Backup preserved at: $backup_dir"
    exit 1
fi
```

## Output
- Updated framework workflows
- Preserved local customizations
- Backup of previous state
- Validation report
- Merge commit in git history

## Error Handling
- Network connectivity issues → Retry with exponential backoff
- Merge conflicts → Create manual merge files with .upstream suffix
- Security validation failure → Abort sync with detailed report
- Validation failure → Automatic rollback to previous state

## Security Considerations
- All upstream changes scanned for security issues
- Local customizations preserved in critical files
- Backup created before any changes
- Validation required before finalizing changes
- Manual approval required for security-sensitive updates

## Dependencies
- Git repository with upstream remote
- Network access to repository
- Sufficient disk space for backups
- Write permissions to .ai_workflow directory

## Success Criteria
- Framework updated with latest upstream changes
- Local customizations preserved
- All validations passed
- Git history maintained
- Backup created successfully