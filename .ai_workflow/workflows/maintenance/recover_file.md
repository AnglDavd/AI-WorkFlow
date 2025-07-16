# File Recovery Workflow

## Purpose
Recover specific archived files from the obsolete files management system.

## Execution Context
- **Command**: `./ai-dev cleanup --recover <file>`
- **Environment Variable**: `RECOVER_FILE_PATH` - File to recover
- **Approach**: Safe file recovery with validation
- **Safety**: Reversible operation with user confirmation

## Recovery Workflow

```bash
#!/bin/bash

# File Recovery System
echo "🔄 File Recovery System"
echo "======================"

# Configuration
OBSOLETE_DIR=".ai_workflow/obsolete_files"
RECOVER_FILE="${RECOVER_FILE_PATH:-}"
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)

# Validate input
if [[ -z "$RECOVER_FILE" ]]; then
    echo "❌ Error: No file specified for recovery"
    echo "Usage: ./ai-dev cleanup --recover <file>"
    exit 1
fi

# Check if obsolete system exists
if [[ ! -d "$OBSOLETE_DIR" ]]; then
    echo "❌ Error: Obsolete files management system not initialized"
    echo "💡 Run './ai-dev cleanup --auto' first to initialize the system"
    exit 1
fi

echo "🔍 Searching for archived file: $RECOVER_FILE"

# === SEARCH FOR ARCHIVED FILE ===
FOUND_FILES=()
SEARCH_PATTERN="*${RECOVER_FILE}*"

# Search in all categories
for category in logs captures testing cache documentation; do
    category_dir="$OBSOLETE_DIR/framework/$category"
    if [[ -d "$category_dir" ]]; then
        while IFS= read -r -d '' file; do
            FOUND_FILES+=("$file")
        done < <(find "$category_dir" -type f -name "$SEARCH_PATTERN" -print0 2>/dev/null)
    fi
done

# Search in user projects
user_dir="$OBSOLETE_DIR/user_projects"
if [[ -d "$user_dir" ]]; then
    while IFS= read -r -d '' file; do
        FOUND_FILES+=("$file")
    done < <(find "$user_dir" -type f -name "$SEARCH_PATTERN" -print0 2>/dev/null)
fi

# === DISPLAY SEARCH RESULTS ===
if [[ ${#FOUND_FILES[@]} -eq 0 ]]; then
    echo "❌ No archived files found matching: $RECOVER_FILE"
    echo ""
    echo "💡 Available options:"
    echo "  - Check exact filename (archived files have timestamps)"
    echo "  - Use './ai-dev cleanup --status' to see all archived files"
    echo "  - Search pattern examples:"
    echo "    ./ai-dev cleanup --recover 'test_*.md'"
    echo "    ./ai-dev cleanup --recover 'diagnostic_*.txt'"
    exit 1
fi

echo "✅ Found ${#FOUND_FILES[@]} matching file(s):"
echo ""

# Display found files with details
for i in "${!FOUND_FILES[@]}"; do
    file="${FOUND_FILES[$i]}"
    basename_file=$(basename "$file")
    category=$(echo "$file" | sed "s|$OBSOLETE_DIR/framework/||" | cut -d'/' -f1)
    size=$(ls -lh "$file" 2>/dev/null | awk '{print $5}' || echo "unknown")
    date_archived=$(echo "$basename_file" | cut -d'_' -f1-2)
    
    echo "[$((i+1))] $basename_file"
    echo "    Category: $category"
    echo "    Size: $size"
    echo "    Archived: $date_archived"
    echo "    Full path: $file"
    echo ""
done

# === FILE SELECTION ===
if [[ ${#FOUND_FILES[@]} -eq 1 ]]; then
    SELECTED_FILE="${FOUND_FILES[0]}"
    echo "🎯 Single file found, selecting automatically."
else
    echo "🔢 Multiple files found. Please select which file to recover:"
    echo "Enter number (1-${#FOUND_FILES[@]}) or 'q' to quit:"
    read -r selection
    
    if [[ "$selection" == "q" ]]; then
        echo "❌ Recovery cancelled by user"
        exit 0
    fi
    
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#FOUND_FILES[@]} ]]; then
        echo "❌ Invalid selection: $selection"
        exit 1
    fi
    
    SELECTED_FILE="${FOUND_FILES[$((selection-1))]}"
fi

# === RECOVERY PROCESS ===
echo "🔄 Recovering file: $(basename "$SELECTED_FILE")"

# Extract original path from metadata (simplified approach)
ORIGINAL_PATH=""
BASENAME_FILE=$(basename "$SELECTED_FILE")
ORIGINAL_NAME=$(echo "$BASENAME_FILE" | sed 's/^[0-9]*_[0-9]*_//')

# Try to determine original path
if [[ "$SELECTED_FILE" == *"/logs/"* ]]; then
    # Log files typically go to .ai_workflow/logs/
    ORIGINAL_PATH=".ai_workflow/logs/$ORIGINAL_NAME"
elif [[ "$SELECTED_FILE" == *"/captures/"* ]]; then
    # Capture files typically go to capturas/
    ORIGINAL_PATH="capturas/$ORIGINAL_NAME"
elif [[ "$SELECTED_FILE" == *"/testing/"* ]]; then
    # Test files typically go to .ai_workflow/testing/
    ORIGINAL_PATH=".ai_workflow/testing/$ORIGINAL_NAME"
elif [[ "$SELECTED_FILE" == *"/cache/"* ]]; then
    # Cache files - various locations
    if [[ "$ORIGINAL_NAME" == *"ai-dev"* ]]; then
        ORIGINAL_PATH=".ai_workflow/cache/$ORIGINAL_NAME"
    else
        ORIGINAL_PATH="$ORIGINAL_NAME"
    fi
elif [[ "$SELECTED_FILE" == *"/documentation/"* ]]; then
    # Documentation files
    ORIGINAL_PATH=".ai_workflow/$ORIGINAL_NAME"
fi

# If we couldn't determine original path, ask user
if [[ -z "$ORIGINAL_PATH" ]]; then
    echo "❓ Could not determine original path automatically."
    echo "Please enter the target path for recovery (or press Enter for current directory):"
    read -r user_path
    if [[ -z "$user_path" ]]; then
        ORIGINAL_PATH="$ORIGINAL_NAME"
    else
        ORIGINAL_PATH="$user_path"
    fi
fi

# Check if target path already exists
if [[ -e "$ORIGINAL_PATH" ]]; then
    echo "⚠️  Target path already exists: $ORIGINAL_PATH"
    echo "Options:"
    echo "  1) Overwrite existing file"
    echo "  2) Create backup and recover"
    echo "  3) Cancel recovery"
    echo "Enter choice (1-3):"
    read -r choice
    
    case "$choice" in
        1)
            echo "🔄 Overwriting existing file..."
            ;;
        2)
            backup_path="${ORIGINAL_PATH}.backup.${CURRENT_DATE}"
            mv "$ORIGINAL_PATH" "$backup_path"
            echo "💾 Existing file backed up to: $backup_path"
            ;;
        3)
            echo "❌ Recovery cancelled by user"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice, cancelling recovery"
            exit 1
            ;;
    esac
fi

# Create target directory if needed
TARGET_DIR=$(dirname "$ORIGINAL_PATH")
if [[ ! -d "$TARGET_DIR" ]]; then
    mkdir -p "$TARGET_DIR"
    echo "📁 Created directory: $TARGET_DIR"
fi

# Perform recovery
cp "$SELECTED_FILE" "$ORIGINAL_PATH"
if [[ $? -eq 0 ]]; then
    echo "✅ File recovered successfully!"
    echo "   From: $SELECTED_FILE"
    echo "   To: $ORIGINAL_PATH"
    
    # Ask if user wants to remove from archive
    echo ""
    echo "❓ Remove file from archive now that it's recovered? (y/n):"
    read -r remove_choice
    
    if [[ "$remove_choice" == "y" || "$remove_choice" == "Y" ]]; then
        rm "$SELECTED_FILE"
        echo "🗑️  File removed from archive"
        
        # Update cleanup log
        cleanup_log="$OBSOLETE_DIR/cleanup_log.md"
        echo "- **$(date)**: Recovered and removed from archive: \`$ORIGINAL_PATH\`" >> "$cleanup_log"
    else
        echo "📦 File kept in archive (can be recovered again if needed)"
        
        # Update cleanup log
        cleanup_log="$OBSOLETE_DIR/cleanup_log.md"
        echo "- **$(date)**: Recovered from archive: \`$ORIGINAL_PATH\`" >> "$cleanup_log"
    fi
else
    echo "❌ Recovery failed!"
    exit 1
fi

# === SUCCESS SUMMARY ===
echo ""
echo "🎉 Recovery Complete!"
echo "===================="
echo "✅ File: $ORIGINAL_NAME"
echo "✅ Location: $ORIGINAL_PATH"
echo "✅ Size: $(ls -lh "$ORIGINAL_PATH" | awk '{print $5}')"
echo "✅ Status: Ready for use"
echo ""
echo "💡 Next steps:"
echo "  - Verify file contents are correct"
echo "  - Consider running quality validation if needed"
echo "  - Check if file should be added to .gitignore"
```

## Safety Features
- **Search validation**: Confirms file exists before recovery
- **User confirmation**: Multiple confirmation steps
- **Collision handling**: Backup existing files before overwrite
- **Audit trail**: Complete recovery history maintained
- **Directory creation**: Automatically creates target directories

## Integration Points
- Called by `./ai-dev cleanup --recover <file>`
- Integrates with obsolete files management system
- Updates cleanup log with recovery actions
- Provides user-friendly file selection interface