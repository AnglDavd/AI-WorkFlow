# Cleanup Status Workflow

## Purpose
Show current status of the obsolete files management system and cleanup candidates.

## Execution Context
- **Command**: `./ai-dev cleanup` or `./ai-dev cleanup --status`
- **Approach**: Display system status and recommendations
- **Safety**: Read-only status display

## Status Display Workflow

```bash
#!/bin/bash

# Cleanup Status Display
echo "📊 Obsolete Files Management System Status"
echo "========================================"

# Configuration
OBSOLETE_DIR=".ai_workflow/obsolete_files"
CLEANUP_LOG="$OBSOLETE_DIR/cleanup_log.md"
CURRENT_DATE=$(date +%Y%m%d)
THIRTY_DAYS_AGO=$(date -d '30 days ago' +%Y%m%d 2>/dev/null || date -v -30d +%Y%m%d 2>/dev/null || echo '20250615')

# Check if system is initialized
if [[ ! -d "$OBSOLETE_DIR" ]]; then
    echo "❌ Obsolete files management system not initialized"
    echo "💡 Run './ai-dev cleanup --auto' to initialize and run first cleanup"
    exit 0
fi

# === CURRENT STATUS ===
echo ""
echo "🔍 Current System Status:"
echo "========================"

# Count archived files by category
LOGS_COUNT=$(find "$OBSOLETE_DIR/framework/logs" -type f 2>/dev/null | wc -l)
CAPTURES_COUNT=$(find "$OBSOLETE_DIR/framework/captures" -type f 2>/dev/null | wc -l)
TESTING_COUNT=$(find "$OBSOLETE_DIR/framework/testing" -type f 2>/dev/null | wc -l)
CACHE_COUNT=$(find "$OBSOLETE_DIR/framework/cache" -type f 2>/dev/null | wc -l)
DOC_COUNT=$(find "$OBSOLETE_DIR/framework/documentation" -type f 2>/dev/null | wc -l)
TOTAL_ARCHIVED=$((LOGS_COUNT + CAPTURES_COUNT + TESTING_COUNT + CACHE_COUNT + DOC_COUNT))

echo "📦 Archived Files by Category:"
echo "  - Logs: $LOGS_COUNT files"
echo "  - Captures: $CAPTURES_COUNT files"
echo "  - Testing: $TESTING_COUNT files"
echo "  - Cache: $CACHE_COUNT files"
echo "  - Documentation: $DOC_COUNT files"
echo "  - Total: $TOTAL_ARCHIVED files"

# Calculate storage usage
STORAGE_USAGE=$(du -sh "$OBSOLETE_DIR" 2>/dev/null | cut -f1 || echo "0B")
echo "💾 Storage Usage: $STORAGE_USAGE"

# === CLEANUP CANDIDATES ===
echo ""
echo "🗑️  Cleanup Candidates:"
echo "======================"

# Find files ready for deletion (>30 days old)
OLD_FILES=$(find "$OBSOLETE_DIR" -type f -name "*${THIRTY_DAYS_AGO}*" 2>/dev/null | wc -l)
if [[ $OLD_FILES -gt 0 ]]; then
    echo "⏰ Files ready for permanent deletion: $OLD_FILES"
    echo "   (Files older than 30 days)"
    echo "   💡 Run './ai-dev cleanup --confirm' to permanently delete these files"
else
    echo "✅ No files ready for permanent deletion"
fi

# Check for new obsolete files in working directory
echo ""
echo "🔍 New Obsolete Files Detection:"
echo "==============================="

NEW_LOGS=$(find . -maxdepth 3 -name "*.log" -not -path "./$OBSOLETE_DIR/*" 2>/dev/null | wc -l)
NEW_TEMP=$(find . -maxdepth 3 -name "*.tmp" -o -name "*.temp" -not -path "./$OBSOLETE_DIR/*" 2>/dev/null | wc -l)
NEW_CACHE=$(find . -maxdepth 3 -name "*_state.log" -o -name "*backup*" -not -path "./$OBSOLETE_DIR/*" 2>/dev/null | wc -l)
NEW_CAPTURES=$(find . -maxdepth 2 -name "*.jpeg" -o -name "*.jpg" -o -name "*.png" -not -path "./$OBSOLETE_DIR/*" 2>/dev/null | wc -l)

NEW_TOTAL=$((NEW_LOGS + NEW_TEMP + NEW_CACHE + NEW_CAPTURES))

if [[ $NEW_TOTAL -gt 0 ]]; then
    echo "🆕 New obsolete files detected: $NEW_TOTAL"
    echo "  - Logs: $NEW_LOGS files"
    echo "  - Temp files: $NEW_TEMP files"
    echo "  - Cache files: $NEW_CACHE files"
    echo "  - Captures: $NEW_CAPTURES files"
    echo "  💡 Run './ai-dev cleanup --auto' to archive these files"
else
    echo "✅ No new obsolete files detected"
fi

# === RECENT ACTIVITY ===
echo ""
echo "📈 Recent Activity:"
echo "=================="

if [[ -f "$CLEANUP_LOG" ]]; then
    echo "📝 Recent cleanup operations:"
    tail -n 5 "$CLEANUP_LOG" | sed 's/^/  /'
else
    echo "📝 No cleanup history found"
fi

# === RECOMMENDATIONS ===
echo ""
echo "💡 Recommendations:"
echo "=================="

if [[ $NEW_TOTAL -gt 0 ]]; then
    echo "🔄 Run automatic cleanup to archive $NEW_TOTAL new obsolete files"
    echo "   Command: ./ai-dev cleanup --auto"
fi

if [[ $OLD_FILES -gt 0 ]]; then
    echo "🗑️  Consider permanently deleting $OLD_FILES old archived files"
    echo "   Command: ./ai-dev cleanup --confirm"
fi

if [[ $NEW_TOTAL -eq 0 && $OLD_FILES -eq 0 ]]; then
    echo "✅ System is clean and up-to-date"
    echo "🔄 Automatic cleanup runs daily to maintain system cleanliness"
fi

# === NEXT STEPS ===
echo ""
echo "🎯 Available Commands:"
echo "===================="
echo "  ./ai-dev cleanup --auto      # Archive new obsolete files"
echo "  ./ai-dev cleanup --confirm    # Permanently delete old files"
echo "  ./ai-dev cleanup --recover    # Recover specific archived file"
echo "  ./ai-dev cleanup --help       # Show detailed help"

# === SAFETY REMINDER ===
echo ""
echo "🛡️  Safety Features:"
echo "==================="
echo "  ✅ All operations are reversible (except --confirm)"
echo "  ✅ 30-day safety buffer before permanent deletion"
echo "  ✅ Complete audit trail maintained"
echo "  ✅ Metadata tracking for all archived files"

echo ""
echo "📊 Status check completed at $(date)"
```

## Output Format
- **System Status**: Current state of archived files
- **Cleanup Candidates**: Files ready for permanent deletion
- **New Detections**: Recently created obsolete files
- **Recent Activity**: Latest cleanup operations
- **Recommendations**: Suggested next actions
- **Available Commands**: User options for cleanup management

## Integration Points
- Called by `./ai-dev cleanup` (default action)
- Called by `./ai-dev cleanup --status`
- Provides actionable insights for users
- Integrates with automated cleanup workflows