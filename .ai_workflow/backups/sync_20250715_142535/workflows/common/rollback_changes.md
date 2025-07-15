# Rollback Changes

## Overview
This workflow provides robust rollback capabilities for PRP execution, enabling the system to revert to previous states when errors occur or corrections fail. It maintains snapshots of the file system and git state for reliable recovery.

## Workflow Instructions

### For AI Agents
When managing rollback functionality:

1. **Create rollback points** before critical operations
2. **Store file and git state** for complete recovery
3. **Execute rollback operations** when failures occur
4. **Validate rollback success** after restoration

### Rollback Management Functions

#### Create Rollback Point
```bash
# Create a rollback point with full system state
create_rollback_point() {
    local POINT_ID="$1"
    local DESCRIPTION="$2"
    
    if [ -z "$POINT_ID" ]; then
        echo "ERROR: Rollback point ID is required"
        return 1
    fi
    
    # Create rollback directory
    mkdir -p .ai_workflow/rollback_points
    
    local ROLLBACK_DIR=".ai_workflow/rollback_points/$POINT_ID"
    mkdir -p "$ROLLBACK_DIR"
    
    # Create rollback metadata
    cat > "$ROLLBACK_DIR/metadata.md" << EOF
# Rollback Point: $POINT_ID

## Information
- **Point ID**: $POINT_ID
- **Description**: $DESCRIPTION
- **Created**: $(date)
- **Created By**: PRP Execution Engine
- **Working Directory**: $(pwd)

## Git State
- **Current Branch**: $(git branch --show-current 2>/dev/null || echo "N/A")
- **Last Commit**: $(git log --oneline -1 2>/dev/null || echo "N/A")
- **Git Status**: $(git status --porcelain 2>/dev/null | wc -l) modified files

## System State
- **Process ID**: $$
- **Execution ID**: \${EXECUTION_ID:-"N/A"}
- **Current Task**: \${CURRENT_TASK:-"N/A"}

## Files Modified Since Last Rollback
EOF
    
    # Store git state
    create_git_snapshot "$ROLLBACK_DIR"
    
    # Store file system state
    create_file_snapshot "$ROLLBACK_DIR"
    
    # Update workflow state if available
    if [ -n "$STATE_FILE" ]; then
        manage_workflow_state "add_rollback_point" "$POINT_ID $DESCRIPTION $(get_modified_files_count 2>/dev/null || echo '0')"
    fi
    
    echo "Created rollback point: $POINT_ID"
    echo "Location: $ROLLBACK_DIR"
}
```

#### Create Git Snapshot
```bash
# Create a git state snapshot
create_git_snapshot() {
    local ROLLBACK_DIR="$1"
    
    # Create git snapshot directory
    mkdir -p "$ROLLBACK_DIR/git_state"
    
    # Save current branch
    git branch --show-current > "$ROLLBACK_DIR/git_state/current_branch.txt" 2>/dev/null || echo "N/A" > "$ROLLBACK_DIR/git_state/current_branch.txt"
    
    # Save git status
    git status --porcelain > "$ROLLBACK_DIR/git_state/status.txt" 2>/dev/null || echo "" > "$ROLLBACK_DIR/git_state/status.txt"
    
    # Save staged changes
    git diff --cached > "$ROLLBACK_DIR/git_state/staged_changes.patch" 2>/dev/null || echo "" > "$ROLLBACK_DIR/git_state/staged_changes.patch"
    
    # Save unstaged changes
    git diff > "$ROLLBACK_DIR/git_state/unstaged_changes.patch" 2>/dev/null || echo "" > "$ROLLBACK_DIR/git_state/unstaged_changes.patch"
    
    # Save untracked files list
    git ls-files --others --exclude-standard > "$ROLLBACK_DIR/git_state/untracked_files.txt" 2>/dev/null || echo "" > "$ROLLBACK_DIR/git_state/untracked_files.txt"
    
    # Save last commit hash
    git rev-parse HEAD > "$ROLLBACK_DIR/git_state/last_commit.txt" 2>/dev/null || echo "N/A" > "$ROLLBACK_DIR/git_state/last_commit.txt"
    
    echo "Git snapshot created in: $ROLLBACK_DIR/git_state"
}
```

#### Create File Snapshot
```bash
# Create a file system snapshot
create_file_snapshot() {
    local ROLLBACK_DIR="$1"
    
    # Create file snapshot directory
    mkdir -p "$ROLLBACK_DIR/file_state"
    
    # Create list of all files with checksums
    find . -type f -not -path "./.git/*" -not -path "./.ai_workflow/rollback_points/*" -not -path "./.ai_workflow/state/*" | \
        while read -r file; do
            echo "$(md5sum "$file" 2>/dev/null || echo "ERROR $file")"
        done > "$ROLLBACK_DIR/file_state/file_checksums.txt"
    
    # Create backup of critical files
    mkdir -p "$ROLLBACK_DIR/file_state/backups"
    
    # Backup common critical files
    local CRITICAL_FILES="package.json pyproject.toml requirements.txt Dockerfile docker-compose.yml .gitignore README.md"
    
    for file in $CRITICAL_FILES; do
        if [ -f "$file" ]; then
            cp "$file" "$ROLLBACK_DIR/file_state/backups/" 2>/dev/null || echo "Warning: Could not backup $file"
        fi
    done
    
    # Create directory structure snapshot
    find . -type d -not -path "./.git/*" -not -path "./.ai_workflow/rollback_points/*" > "$ROLLBACK_DIR/file_state/directory_structure.txt"
    
    echo "File snapshot created in: $ROLLBACK_DIR/file_state"
}
```

#### List Rollback Points
```bash
# List all available rollback points
list_rollback_points() {
    echo "Available rollback points:"
    
    if [ -d ".ai_workflow/rollback_points" ]; then
        for point_dir in .ai_workflow/rollback_points/*/; do
            if [ -d "$point_dir" ]; then
                local point_id=$(basename "$point_dir")
                local metadata_file="$point_dir/metadata.md"
                
                if [ -f "$metadata_file" ]; then
                    local description=$(grep "Description" "$metadata_file" | cut -d':' -f2 | tr -d ' ')
                    local created=$(grep "Created" "$metadata_file" | cut -d':' -f2- | tr -d ' ')
                    echo "- $point_id: $description (Created: $created)"
                else
                    echo "- $point_id: No metadata available"
                fi
            fi
        done
    else
        echo "No rollback points found"
    fi
}
```

#### Rollback to Point
```bash
# Rollback to a specific point
rollback_to_point() {
    local POINT_ID="$1"
    local FORCE="$2"
    
    if [ -z "$POINT_ID" ]; then
        echo "ERROR: Rollback point ID is required"
        return 1
    fi
    
    local ROLLBACK_DIR=".ai_workflow/rollback_points/$POINT_ID"
    
    if [ ! -d "$ROLLBACK_DIR" ]; then
        echo "ERROR: Rollback point not found: $POINT_ID"
        return 1
    fi
    
    echo "Starting rollback to point: $POINT_ID"
    
    # Confirm rollback if not forced
    if [ "$FORCE" != "true" ]; then
        echo "WARNING: This will revert all changes since the rollback point was created."
        echo "Are you sure you want to continue? (y/N)"
        read -r CONFIRM
        if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
            echo "Rollback cancelled"
            return 1
        fi
    fi
    
    # Create emergency rollback point before rollback
    create_rollback_point "emergency_before_rollback_$(date +%Y%m%d_%H%M%S)" "Emergency backup before rollback to $POINT_ID"
    
    # Restore git state
    restore_git_state "$ROLLBACK_DIR"
    
    # Restore file state
    restore_file_state "$ROLLBACK_DIR"
    
    # Update workflow state if available
    if [ -n "$STATE_FILE" ]; then
        manage_workflow_state "log_rollback" "$(date): ROLLBACK: Restored to point $POINT_ID"
        echo "- $(date): ROLLBACK: Restored to point $POINT_ID" >> "$STATE_FILE"
    fi
    
    echo "Rollback completed successfully"
    echo "Restored to point: $POINT_ID"
}
```

#### Restore Git State
```bash
# Restore git state from snapshot
restore_git_state() {
    local ROLLBACK_DIR="$1"
    local GIT_STATE_DIR="$ROLLBACK_DIR/git_state"
    
    if [ ! -d "$GIT_STATE_DIR" ]; then
        echo "WARNING: No git state found in rollback point"
        return 1
    fi
    
    echo "Restoring git state..."
    
    # Reset git to clean state
    git reset --hard HEAD 2>/dev/null || echo "Warning: Could not reset git"
    git clean -fd 2>/dev/null || echo "Warning: Could not clean git"
    
    # Restore branch if different
    local TARGET_BRANCH=$(cat "$GIT_STATE_DIR/current_branch.txt" 2>/dev/null)
    local CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
    
    if [ -n "$TARGET_BRANCH" ] && [ "$TARGET_BRANCH" != "N/A" ] && [ "$TARGET_BRANCH" != "$CURRENT_BRANCH" ]; then
        git checkout "$TARGET_BRANCH" 2>/dev/null || echo "Warning: Could not checkout branch $TARGET_BRANCH"
    fi
    
    # Restore staged changes
    if [ -f "$GIT_STATE_DIR/staged_changes.patch" ] && [ -s "$GIT_STATE_DIR/staged_changes.patch" ]; then
        git apply --cached "$GIT_STATE_DIR/staged_changes.patch" 2>/dev/null || echo "Warning: Could not restore staged changes"
    fi
    
    # Restore unstaged changes
    if [ -f "$GIT_STATE_DIR/unstaged_changes.patch" ] && [ -s "$GIT_STATE_DIR/unstaged_changes.patch" ]; then
        git apply "$GIT_STATE_DIR/unstaged_changes.patch" 2>/dev/null || echo "Warning: Could not restore unstaged changes"
    fi
    
    echo "Git state restored"
}
```

#### Restore File State
```bash
# Restore file state from snapshot
restore_file_state() {
    local ROLLBACK_DIR="$1"
    local FILE_STATE_DIR="$ROLLBACK_DIR/file_state"
    
    if [ ! -d "$FILE_STATE_DIR" ]; then
        echo "WARNING: No file state found in rollback point"
        return 1
    fi
    
    echo "Restoring file state..."
    
    # Restore critical files from backups
    if [ -d "$FILE_STATE_DIR/backups" ]; then
        for backup_file in "$FILE_STATE_DIR/backups"/*; do
            if [ -f "$backup_file" ]; then
                local filename=$(basename "$backup_file")
                cp "$backup_file" "./$filename" 2>/dev/null || echo "Warning: Could not restore $filename"
            fi
        done
    fi
    
    # Validate file integrity
    if [ -f "$FILE_STATE_DIR/file_checksums.txt" ]; then
        local MISMATCHES=0
        while IFS= read -r line; do
            local checksum=$(echo "$line" | cut -d' ' -f1)
            local filepath=$(echo "$line" | cut -d' ' -f2-)
            
            if [ "$checksum" != "ERROR" ] && [ -f "$filepath" ]; then
                local current_checksum=$(md5sum "$filepath" 2>/dev/null | cut -d' ' -f1)
                if [ "$checksum" != "$current_checksum" ]; then
                    echo "Warning: File checksum mismatch: $filepath"
                    MISMATCHES=$((MISMATCHES + 1))
                fi
            fi
        done < "$FILE_STATE_DIR/file_checksums.txt"
        
        if [ $MISMATCHES -gt 0 ]; then
            echo "Warning: $MISMATCHES files have checksum mismatches"
        fi
    fi
    
    echo "File state restored"
}
```

#### Validate Rollback
```bash
# Validate rollback success
validate_rollback() {
    local POINT_ID="$1"
    
    echo "Validating rollback to point: $POINT_ID"
    
    # Check git status
    local GIT_STATUS=$(git status --porcelain 2>/dev/null | wc -l)
    echo "Git status: $GIT_STATUS modified files"
    
    # Check if project files exist
    local CRITICAL_FILES="package.json pyproject.toml requirements.txt"
    local MISSING_FILES=0
    
    for file in $CRITICAL_FILES; do
        if [ ! -f "$file" ]; then
            MISSING_FILES=$((MISSING_FILES + 1))
        fi
    done
    
    if [ $MISSING_FILES -eq 0 ]; then
        echo "Validation: All critical files present"
    else
        echo "Warning: $MISSING_FILES critical files missing"
    fi
    
    # Try to run basic commands
    if command -v npm >/dev/null 2>&1 && [ -f "package.json" ]; then
        if npm --version >/dev/null 2>&1; then
            echo "Validation: NPM environment functional"
        else
            echo "Warning: NPM environment issues detected"
        fi
    fi
    
    echo "Rollback validation completed"
}
```

#### Clean Old Rollback Points
```bash
# Clean old rollback points
clean_old_rollback_points() {
    local KEEP_COUNT="$1"
    
    if [ -z "$KEEP_COUNT" ]; then
        KEEP_COUNT=10
    fi
    
    echo "Cleaning old rollback points (keeping $KEEP_COUNT newest)"
    
    if [ -d ".ai_workflow/rollback_points" ]; then
        # List rollback points by creation time
        local POINT_COUNT=$(find .ai_workflow/rollback_points -maxdepth 1 -type d -name "*" | wc -l)
        
        if [ $POINT_COUNT -gt $KEEP_COUNT ]; then
            local TO_DELETE=$((POINT_COUNT - KEEP_COUNT))
            echo "Deleting $TO_DELETE old rollback points"
            
            # Delete oldest rollback points
            find .ai_workflow/rollback_points -maxdepth 1 -type d -name "*" -printf '%T+ %p\n' | sort | head -n $TO_DELETE | cut -d' ' -f2- | while read -r old_point; do
                echo "Deleting old rollback point: $(basename "$old_point")"
                rm -rf "$old_point"
            done
        else
            echo "No old rollback points to clean"
        fi
    fi
}
```

### Utility Functions

#### Get Modified Files Count
```bash
# Get count of modified files since last rollback
get_modified_files_count() {
    local MODIFIED_COUNT=0
    
    # Count git modified files
    if command -v git >/dev/null 2>&1; then
        MODIFIED_COUNT=$(git status --porcelain 2>/dev/null | wc -l)
    fi
    
    echo $MODIFIED_COUNT
}
```

#### Check Rollback Point Exists
```bash
# Check if rollback point exists
rollback_point_exists() {
    local POINT_ID="$1"
    
    if [ -d ".ai_workflow/rollback_points/$POINT_ID" ]; then
        return 0
    else
        return 1
    fi
}
```

#### Get Latest Rollback Point
```bash
# Get the most recent rollback point
get_latest_rollback_point() {
    if [ -d ".ai_workflow/rollback_points" ]; then
        local LATEST=$(find .ai_workflow/rollback_points -maxdepth 1 -type d -name "*" -printf '%T+ %p\n' | sort -r | head -1 | cut -d' ' -f2-)
        
        if [ -n "$LATEST" ]; then
            basename "$LATEST"
        else
            echo "No rollback points found"
            return 1
        fi
    else
        echo "No rollback points directory found"
        return 1
    fi
}
```

### Emergency Functions

#### Emergency Rollback
```bash
# Emergency rollback to last known good state
emergency_rollback() {
    echo "EMERGENCY ROLLBACK: Attempting to restore to last known good state"
    
    local LATEST_POINT=$(get_latest_rollback_point)
    
    if [ $? -eq 0 ]; then
        echo "Rolling back to: $LATEST_POINT"
        rollback_to_point "$LATEST_POINT" "true"
    else
        echo "ERROR: No rollback points available for emergency rollback"
        return 1
    fi
}
```

#### Create Emergency Snapshot
```bash
# Create emergency snapshot of current state
create_emergency_snapshot() {
    local REASON="$1"
    local EMERGENCY_ID="emergency_$(date +%Y%m%d_%H%M%S)"
    
    echo "Creating emergency snapshot: $EMERGENCY_ID"
    create_rollback_point "$EMERGENCY_ID" "Emergency snapshot: $REASON"
}
```

## Integration with PRP Execution

### Automatic Rollback Points
- Created before each task execution
- Created before correction attempts
- Created before final validation

### Error Recovery
- Automatic rollback on fatal errors
- User confirmation for manual rollbacks
- Emergency rollback for critical failures

### State Preservation
- Git state (branch, staged/unstaged changes)
- File system state (checksums, critical files)
- Execution context (task progress, variables)

## Usage Examples

### Basic Rollback Operations
```bash
# Create rollback point
create_rollback_point "before_task_1" "Before executing task 1"

# List available points
list_rollback_points

# Rollback to specific point
rollback_to_point "before_task_1"

# Emergency rollback
emergency_rollback
```

### Integration with PRP Execution
```bash
# In PRP execution workflow
create_rollback_point "before_task_$TASK_INDEX" "Before task $TASK_INDEX execution"

# Execute task...
if [ $? -ne 0 ]; then
    echo "Task failed, rolling back..."
    rollback_to_point "before_task_$TASK_INDEX"
fi
```

### Cleanup Operations
```bash
# Clean old rollback points (keep 5 newest)
clean_old_rollback_points 5

# Validate rollback success
validate_rollback "before_task_1"
```

## Notes
- Rollback points are stored in `.ai_workflow/rollback_points/`
- Each rollback point contains git state and file snapshots
- Emergency rollback always goes to the most recent point
- File integrity is validated using checksums
- Git state restoration includes branch, staged, and unstaged changes
- Critical files are backed up for reliable restoration
- Integration with workflow state management for complete recovery