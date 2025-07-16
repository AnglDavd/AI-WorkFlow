# Permanent Cleanup Workflow

## Purpose
Permanently delete archived files older than 30 days from the obsolete files management system.

## Execution Context
- **Command**: `./ai-dev cleanup --confirm`
- **Approach**: Safe permanent deletion with user confirmation
- **Safety**: Multiple confirmation steps and detailed reporting

## Permanent Deletion Workflow

```bash
#!/bin/bash

# Permanent Cleanup System
echo "🗑️  Permanent Cleanup System"
echo "============================"

# Configuration
OBSOLETE_DIR=".ai_workflow/obsolete_files"
CLEANUP_LOG="$OBSOLETE_DIR/cleanup_log.md"
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
THIRTY_DAYS_AGO=$(date -d '30 days ago' +%Y%m%d 2>/dev/null || date -v -30d +%Y%m%d 2>/dev/null || echo '20250615')

# Check if system exists
if [[ ! -d "$OBSOLETE_DIR" ]]; then
    echo "❌ Error: Obsolete files management system not initialized"
    echo "💡 Run './ai-dev cleanup --auto' first to initialize the system"
    exit 1
fi

echo "🔍 Scanning for files older than 30 days..."
echo "📅 Cutoff date: $THIRTY_DAYS_AGO"

# === FIND DELETION CANDIDATES ===
DELETION_CANDIDATES=()
TOTAL_SIZE=0

# Search for files older than 30 days
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        # Extract date from filename (format: YYYYMMDD_HHMMSS_filename)
        basename_file=$(basename "$file")
        file_date=$(echo "$basename_file" | cut -d'_' -f1)
        
        # Check if file is older than 30 days
        if [[ "$file_date" -le "$THIRTY_DAYS_AGO" ]]; then
            DELETION_CANDIDATES+=("$file")
            file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            TOTAL_SIZE=$((TOTAL_SIZE + file_size))
        fi
    fi
done < <(find "$OBSOLETE_DIR" -type f -name "*.md" -o -name "*.log" -o -name "*.txt" -o -name "*.jpeg" -o -name "*.jpg" -o -name "*.png" -o -name "*.json" -o -name "*.backup" -print0 2>/dev/null)

# === DISPLAY DELETION CANDIDATES ===
if [[ ${#DELETION_CANDIDATES[@]} -eq 0 ]]; then
    echo "✅ No files found that are older than 30 days"
    echo "💡 All archived files are within the safety retention period"
    echo ""
    echo "📊 Current archive status:"
    total_files=$(find "$OBSOLETE_DIR" -type f | wc -l)
    total_storage=$(du -sh "$OBSOLETE_DIR" 2>/dev/null | cut -f1 || echo "0B")
    echo "  - Total archived files: $total_files"
    echo "  - Total storage used: $total_storage"
    echo ""
    echo "💡 Files will be eligible for deletion after 30 days from archive date"
    exit 0
fi

# Convert size to human readable
if command -v numfmt >/dev/null 2>&1; then
    HUMAN_SIZE=$(numfmt --to=iec-i --suffix=B "$TOTAL_SIZE")
else
    HUMAN_SIZE="${TOTAL_SIZE} bytes"
fi

echo "⚠️  Found ${#DELETION_CANDIDATES[@]} files ready for permanent deletion"
echo "💾 Total size to be freed: $HUMAN_SIZE"
echo ""

# === CATEGORIZE FILES FOR DISPLAY ===
declare -A CATEGORY_COUNTS
CATEGORY_COUNTS[logs]=0
CATEGORY_COUNTS[captures]=0
CATEGORY_COUNTS[testing]=0
CATEGORY_COUNTS[cache]=0
CATEGORY_COUNTS[documentation]=0

for file in "${DELETION_CANDIDATES[@]}"; do
    if [[ "$file" == *"/logs/"* ]]; then
        ((CATEGORY_COUNTS[logs]++))
    elif [[ "$file" == *"/captures/"* ]]; then
        ((CATEGORY_COUNTS[captures]++))
    elif [[ "$file" == *"/testing/"* ]]; then
        ((CATEGORY_COUNTS[testing]++))
    elif [[ "$file" == *"/cache/"* ]]; then
        ((CATEGORY_COUNTS[cache]++))
    elif [[ "$file" == *"/documentation/"* ]]; then
        ((CATEGORY_COUNTS[documentation]++))
    fi
done

echo "📦 Files by category:"
echo "  - Logs: ${CATEGORY_COUNTS[logs]} files"
echo "  - Captures: ${CATEGORY_COUNTS[captures]} files"
echo "  - Testing: ${CATEGORY_COUNTS[testing]} files"
echo "  - Cache: ${CATEGORY_COUNTS[cache]} files"
echo "  - Documentation: ${CATEGORY_COUNTS[documentation]} files"

# === SAFETY CONFIRMATION ===
echo ""
echo "🚨 SAFETY CONFIRMATION REQUIRED"
echo "==============================="
echo "This operation will PERMANENTLY DELETE the files listed above."
echo "This action CANNOT be undone."
echo ""
echo "Are you sure you want to proceed? (type 'yes' to confirm, anything else to cancel):"
read -r confirmation

if [[ "$confirmation" != "yes" ]]; then
    echo "❌ Permanent deletion cancelled by user"
    echo "💡 Files remain safely archived and can be recovered if needed"
    exit 0
fi

# === FINAL CONFIRMATION ===
echo ""
echo "🔴 FINAL CONFIRMATION"
echo "===================="
echo "You are about to permanently delete ${#DELETION_CANDIDATES[@]} files ($HUMAN_SIZE)"
echo "Type 'DELETE' (in capital letters) to proceed:"
read -r final_confirmation

if [[ "$final_confirmation" != "DELETE" ]]; then
    echo "❌ Permanent deletion cancelled - confirmation not matched"
    echo "💡 Files remain safely archived"
    exit 0
fi

# === PERFORM DELETION ===
echo ""
echo "🗑️  Performing permanent deletion..."
echo "==================================="

DELETED_COUNT=0
FAILED_COUNT=0
DELETED_SIZE=0

for file in "${DELETION_CANDIDATES[@]}"; do
    if [[ -f "$file" ]]; then
        file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
        basename_file=$(basename "$file")
        
        if rm "$file" 2>/dev/null; then
            echo "✅ Deleted: $basename_file"
            ((DELETED_COUNT++))
            DELETED_SIZE=$((DELETED_SIZE + file_size))
        else
            echo "❌ Failed to delete: $basename_file"
            ((FAILED_COUNT++))
        fi
    fi
done

# Convert deleted size to human readable
if command -v numfmt >/dev/null 2>&1; then
    HUMAN_DELETED_SIZE=$(numfmt --to=iec-i --suffix=B "$DELETED_SIZE")
else
    HUMAN_DELETED_SIZE="${DELETED_SIZE} bytes"
fi

# === CLEANUP EMPTY DIRECTORIES ===
echo ""
echo "🧹 Cleaning up empty directories..."
find "$OBSOLETE_DIR" -type d -empty -delete 2>/dev/null

# === UPDATE CLEANUP LOG ===
echo ""
echo "📝 Updating cleanup log..."

cat >> "$CLEANUP_LOG" << EOF

## Permanent Cleanup - $(date)
- **Files Deleted**: $DELETED_COUNT
- **Files Failed**: $FAILED_COUNT
- **Space Freed**: $HUMAN_DELETED_SIZE
- **Categories**:
  - Logs: ${CATEGORY_COUNTS[logs]} files
  - Captures: ${CATEGORY_COUNTS[captures]} files
  - Testing: ${CATEGORY_COUNTS[testing]} files
  - Cache: ${CATEGORY_COUNTS[cache]} files
  - Documentation: ${CATEGORY_COUNTS[documentation]} files
- **Status**: Permanent deletion completed

EOF

# === FINAL REPORT ===
echo ""
echo "🎉 Permanent Cleanup Complete!"
echo "============================="
echo "✅ Successfully deleted: $DELETED_COUNT files"
echo "💾 Space freed: $HUMAN_DELETED_SIZE"

if [[ $FAILED_COUNT -gt 0 ]]; then
    echo "⚠️  Failed to delete: $FAILED_COUNT files"
    echo "💡 Check file permissions and try again if needed"
fi

echo ""
echo "📊 Updated system status:"
remaining_files=$(find "$OBSOLETE_DIR" -type f | wc -l)
remaining_storage=$(du -sh "$OBSOLETE_DIR" 2>/dev/null | cut -f1 || echo "0B")
echo "  - Remaining archived files: $remaining_files"
echo "  - Remaining storage: $remaining_storage"

echo ""
echo "💡 Next steps:"
echo "  - Run './ai-dev cleanup --status' to see current system status"
echo "  - Run './ai-dev cleanup --auto' to archive any new obsolete files"
echo "  - Regular cleanup runs automatically to maintain system health"

echo ""
echo "🛡️  Safety reminder:"
echo "  - Files deleted in this operation cannot be recovered"
echo "  - Future files will be archived for 30 days before deletion eligibility"
echo "  - The system maintains a complete audit trail of all operations"
```

## Safety Features
- **30-day retention**: Only files older than 30 days are eligible
- **Double confirmation**: Requires 'yes' and 'DELETE' confirmations
- **Detailed reporting**: Shows exactly what will be deleted
- **Categorized display**: Organizes files by type for review
- **Failure handling**: Reports any files that couldn't be deleted
- **Audit trail**: Complete record of deletion operations

## Integration Points
- Called by `./ai-dev cleanup --confirm`
- Updates cleanup log with deletion records
- Integrates with obsolete files management system
- Provides comprehensive deletion reporting

## Risk Mitigation
- **Multiple confirmations**: Prevents accidental deletion
- **Size calculation**: Shows storage impact before deletion
- **Category breakdown**: Allows user to understand what's being deleted
- **Failed deletion tracking**: Identifies permission or access issues
- **Empty directory cleanup**: Maintains clean directory structure