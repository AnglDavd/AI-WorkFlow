# Periodic Repository Maintenance

## Purpose
Automatically maintain repository cleanliness for both framework and user projects with zero-friction approach.

## Philosophy
Proactive repository health management - prevent problems before they occur, maintain clean repositories automatically.

## Execution Context
- **Frequency**: Daily (via cron or git hooks), Weekly (comprehensive), Monthly (deep clean)
- **Scope**: Framework repository + User projects using the framework
- **Approach**: Zero-friction, transparent, user-beneficial

## Maintenance Workflow

```bash
#!/bin/bash

# Periodic Repository Maintenance System
echo "🔄 Starting Periodic Repository Maintenance..."

# Configuration
MAINTENANCE_LOG=".ai_workflow/maintenance_$(date +%Y%m%d_%H%M%S).log"
CURRENT_DIR="$(pwd)"
FRAMEWORK_DIR=".ai_workflow"

# Initialize maintenance log
echo "📝 Maintenance Log - $(date)" > "$MAINTENANCE_LOG"
echo "==============================" >> "$MAINTENANCE_LOG"

# === DETECT MAINTENANCE LEVEL ===
MAINTENANCE_LEVEL="${1:-daily}"

case "$MAINTENANCE_LEVEL" in
    daily)
        echo "🔄 Running daily maintenance tasks..."
        ;;
    weekly)
        echo "🔄 Running weekly maintenance tasks..."
        ;;
    monthly)
        echo "🔄 Running monthly maintenance tasks..."
        ;;
    *)
        echo "❌ Invalid maintenance level: $MAINTENANCE_LEVEL"
        echo "Available levels: daily, weekly, monthly"
        exit 1
        ;;
esac

# === TASK 1: UPDATE .GITIGNORE ===
echo "🛡️  Task 1: Updating .gitignore patterns..."
echo "$(date): Starting .gitignore update" >> "$MAINTENANCE_LOG"

if [[ -f "$FRAMEWORK_DIR/workflows/setup/auto_gitignore_setup.md" ]]; then
    # Execute auto .gitignore update
    sed -n '/^```bash/,/^```/p' "$FRAMEWORK_DIR/workflows/setup/auto_gitignore_setup.md" | sed '/^```/d' | bash
    
    if [[ $? -eq 0 ]]; then
        echo "✅ .gitignore updated successfully"
        echo "$(date): .gitignore update completed successfully" >> "$MAINTENANCE_LOG"
    else
        echo "⚠️  .gitignore update failed"
        echo "$(date): .gitignore update failed" >> "$MAINTENANCE_LOG"
    fi
else
    echo "⚠️  Auto .gitignore setup workflow not found"
    echo "$(date): Auto .gitignore setup workflow not found" >> "$MAINTENANCE_LOG"
fi

# === TASK 2: CLEAN OBSOLETE FILES ===
echo "🧹 Task 2: Cleaning obsolete files..."
echo "$(date): Starting obsolete files cleanup" >> "$MAINTENANCE_LOG"

if [[ -f "$FRAMEWORK_DIR/workflows/maintenance/manage_obsolete_files.md" ]]; then
    # Execute obsolete files cleanup
    sed -n '/^```bash/,/^```/p' "$FRAMEWORK_DIR/workflows/maintenance/manage_obsolete_files.md" | sed '/^```/d' | bash
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Obsolete files cleanup completed"
        echo "$(date): Obsolete files cleanup completed" >> "$MAINTENANCE_LOG"
    else
        echo "⚠️  Obsolete files cleanup failed"
        echo "$(date): Obsolete files cleanup failed" >> "$MAINTENANCE_LOG"
    fi
else
    echo "⚠️  Obsolete files management workflow not found"
    echo "$(date): Obsolete files management workflow not found" >> "$MAINTENANCE_LOG"
fi

# === TASK 3: REPOSITORY HEALTH CHECK ===
echo "🏥 Task 3: Repository health check..."
echo "$(date): Starting repository health check" >> "$MAINTENANCE_LOG"

# Check repository size
REPO_SIZE=$(du -sh .git 2>/dev/null | cut -f1 || echo "unknown")
WORK_SIZE=$(du -sh . --exclude=.git 2>/dev/null | cut -f1 || echo "unknown")

# Check for large files
LARGE_FILES=$(find . -type f -size +10M -not -path "./.git/*" -not -path "./.ai_workflow/obsolete_files/*" | head -5)

# Check tracked files count
TRACKED_FILES=$(git ls-files 2>/dev/null | wc -l)

# Check for untracked files that should be ignored
UNTRACKED_COUNT=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)

echo "📊 Repository Health Report:"
echo "  - Repository size: $REPO_SIZE"
echo "  - Working directory: $WORK_SIZE"
echo "  - Tracked files: $TRACKED_FILES"
echo "  - Untracked files: $UNTRACKED_COUNT"

# Log health metrics
echo "$(date): Repository health - Size: $REPO_SIZE, Tracked: $TRACKED_FILES, Untracked: $UNTRACKED_COUNT" >> "$MAINTENANCE_LOG"

if [[ -n "$LARGE_FILES" ]]; then
    echo "⚠️  Large files detected:"
    echo "$LARGE_FILES" | sed 's/^/    /'
    echo "$(date): Large files detected: $LARGE_FILES" >> "$MAINTENANCE_LOG"
fi

# === TASK 4: WEEKLY TASKS ===
if [[ "$MAINTENANCE_LEVEL" == "weekly" ]] || [[ "$MAINTENANCE_LEVEL" == "monthly" ]]; then
    echo "📅 Task 4: Weekly maintenance tasks..."
    echo "$(date): Starting weekly maintenance tasks" >> "$MAINTENANCE_LOG"
    
    # Check for permanent deletion candidates
    if [[ -d "$FRAMEWORK_DIR/obsolete_files" ]]; then
        THIRTY_DAYS_AGO=$(date -d '30 days ago' +%Y%m%d 2>/dev/null || date -v -30d +%Y%m%d 2>/dev/null || echo '20250615')
        OLD_FILES=$(find "$FRAMEWORK_DIR/obsolete_files" -type f -name "*${THIRTY_DAYS_AGO}*" 2>/dev/null | wc -l)
        
        if [[ $OLD_FILES -gt 0 ]]; then
            echo "💡 $OLD_FILES files are ready for permanent deletion (>30 days old)"
            echo "   Run: ./ai-dev cleanup --confirm"
            echo "$(date): $OLD_FILES files ready for permanent deletion" >> "$MAINTENANCE_LOG"
        fi
    fi
    
    # Update documentation if needed
    if [[ -f "$FRAMEWORK_DIR/workflows/documentation/generate_project_architecture.md" ]]; then
        echo "📋 Updating project architecture documentation..."
        bash "$FRAMEWORK_DIR/workflows/documentation/generate_project_architecture.md" >/dev/null 2>&1
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Architecture documentation updated"
            echo "$(date): Architecture documentation updated" >> "$MAINTENANCE_LOG"
        fi
    fi
fi

# === TASK 5: MONTHLY TASKS ===
if [[ "$MAINTENANCE_LEVEL" == "monthly" ]]; then
    echo "📅 Task 5: Monthly maintenance tasks..."
    echo "$(date): Starting monthly maintenance tasks" >> "$MAINTENANCE_LOG"
    
    # Deep repository analysis
    echo "🔍 Deep repository analysis..."
    
    # Check for duplicate files
    DUPLICATES=$(find . -type f -not -path "./.git/*" -not -path "./.ai_workflow/obsolete_files/*" -exec md5sum {} + 2>/dev/null | sort | uniq -d -w32 | wc -l)
    
    if [[ $DUPLICATES -gt 0 ]]; then
        echo "⚠️  $DUPLICATES potential duplicate files found"
        echo "$(date): $DUPLICATES duplicate files found" >> "$MAINTENANCE_LOG"
    fi
    
    # Check git history size
    GIT_OBJECTS=$(git count-objects -v 2>/dev/null | grep "count" | cut -d' ' -f2)
    
    if [[ $GIT_OBJECTS -gt 10000 ]]; then
        echo "💡 Git history has $GIT_OBJECTS objects - consider cleanup"
        echo "$(date): Git history has $GIT_OBJECTS objects" >> "$MAINTENANCE_LOG"
    fi
fi

# === TASK 6: FRAMEWORK SPECIFIC MAINTENANCE ===
if [[ -f "$FRAMEWORK_DIR/ARCHITECTURE.md" ]]; then
    echo "🔧 Task 6: Framework-specific maintenance..."
    echo "$(date): Starting framework-specific maintenance" >> "$MAINTENANCE_LOG"
    
    # Check framework file integrity
    ESSENTIAL_FILES=(
        "ai-dev"
        "manager.md"
        "$FRAMEWORK_DIR/workflows/setup/01_start_setup.md"
        "$FRAMEWORK_DIR/workflows/run/01_run_prp.md"
        "$FRAMEWORK_DIR/ARCHITECTURE.md"
    )
    
    MISSING_FILES=()
    for file in "${ESSENTIAL_FILES[@]}"; do
        if [[ ! -f "$file" ]]; then
            MISSING_FILES+=("$file")
        fi
    done
    
    if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
        echo "❌ Missing essential framework files:"
        printf '%s\n' "${MISSING_FILES[@]}" | sed 's/^/    /'
        echo "$(date): Missing essential files: ${MISSING_FILES[*]}" >> "$MAINTENANCE_LOG"
    else
        echo "✅ All essential framework files present"
        echo "$(date): All essential framework files present" >> "$MAINTENANCE_LOG"
    fi
fi

# === GENERATE MAINTENANCE REPORT ===
echo ""
echo "📊 Maintenance Summary"
echo "===================="
echo "✅ .gitignore patterns updated"
echo "✅ Obsolete files cleaned"
echo "✅ Repository health checked"

if [[ "$MAINTENANCE_LEVEL" == "weekly" ]] || [[ "$MAINTENANCE_LEVEL" == "monthly" ]]; then
    echo "✅ Weekly maintenance completed"
fi

if [[ "$MAINTENANCE_LEVEL" == "monthly" ]]; then
    echo "✅ Monthly deep analysis completed"
fi

echo "📝 Maintenance log: $MAINTENANCE_LOG"

# === FINAL RECOMMENDATIONS ===
echo ""
echo "💡 Recommendations:"

if [[ $UNTRACKED_COUNT -gt 10 ]]; then
    echo "  - Consider reviewing $UNTRACKED_COUNT untracked files"
fi

if [[ -n "$LARGE_FILES" ]]; then
    echo "  - Review large files for potential optimization"
fi

if [[ "$MAINTENANCE_LEVEL" == "daily" ]]; then
    echo "  - Run weekly maintenance: ./ai-dev maintenance weekly"
fi

echo ""
echo "🎯 Next automatic maintenance: $(date -d '+1 day' 2>/dev/null || date -v +1d 2>/dev/null || echo 'tomorrow')"

# Complete maintenance log
echo "$(date): Maintenance completed successfully" >> "$MAINTENANCE_LOG"
echo "✅ Periodic repository maintenance completed successfully"
```

## Integration with Framework

### 1. CLI Integration
```bash
# Add to ai-dev script
./ai-dev maintenance [daily|weekly|monthly]
```

### 2. Git Hook Integration
```bash
# Pre-commit hook
echo "Running daily maintenance..."
bash .ai_workflow/workflows/maintenance/periodic_repository_maintenance.md daily
```

### 3. Cron Job Integration
```bash
# Daily maintenance
0 2 * * * cd /path/to/project && ./ai-dev maintenance daily

# Weekly maintenance
0 3 * * 0 cd /path/to/project && ./ai-dev maintenance weekly

# Monthly maintenance
0 4 1 * * cd /path/to/project && ./ai-dev maintenance monthly
```

## User Benefits

### Zero-Friction Experience
- **Automatic**: Runs without user intervention
- **Transparent**: User sees benefits without complexity
- **Proactive**: Prevents problems before they occur
- **Adaptive**: Adjusts to project changes

### Repository Health
- **Always Clean**: Obsolete files automatically managed
- **Optimized**: .gitignore patterns always up-to-date
- **Efficient**: Repository size optimized
- **Reliable**: Essential files integrity verified

### Development Productivity
- **Focus on Code**: No manual repository maintenance
- **Consistent**: Same experience across all projects
- **Preventive**: Issues caught before they impact development
- **Scalable**: Works for projects of any size

## Framework Integration Points
- **Setup**: Integrated into project initialization
- **CLI**: Available as maintenance command
- **Hooks**: Integrated into git workflow
- **Monitoring**: Provides health metrics
- **Reporting**: Detailed maintenance logs