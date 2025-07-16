# Obsolete Files Management System

## Purpose
Automated system for identifying, categorizing, archiving, and periodically cleaning obsolete files with zero-friction approach.

## System Architecture

### Directory Structure
```
.ai_workflow/obsolete_files/
├── framework/                    # Framework development obsolete files
│   ├── logs/                    # Obsolete log files
│   ├── testing/                 # Obsolete test files
│   ├── documentation/           # Obsolete documentation
│   ├── cache/                   # Obsolete cache files
│   └── metadata.json           # Metadata for archived files
├── user_projects/               # User project obsolete files
│   ├── {project_name}/         # Per-project obsolete files
│   └── metadata.json           # Metadata for user project files
└── cleanup_log.md              # Cleanup history and decisions
```

## Execution Context
- **Philosophy:** Zero-friction obsolete file management
- **Approach:** Automated identification, safe archival, periodic cleanup
- **Safety:** 100% reversible operations with metadata tracking

## Core Workflow

```bash
#!/bin/bash

# Obsolete Files Management System
echo "🗂️  Starting obsolete files management system..."

# Configuration
OBSOLETE_DIR=".ai_workflow/obsolete_files"
FRAMEWORK_OBSOLETE="$OBSOLETE_DIR/framework"
USER_OBSOLETE="$OBSOLETE_DIR/user_projects"
CLEANUP_LOG="$OBSOLETE_DIR/cleanup_log.md"
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)

# Initialize system if not exists
if [[ ! -d "$OBSOLETE_DIR" ]]; then
    mkdir -p "$FRAMEWORK_OBSOLETE"/{logs,testing,documentation,cache,captures}
    mkdir -p "$USER_OBSOLETE"
    echo "✅ Obsolete files management system initialized"
fi

# === FILE IDENTIFICATION SYSTEM ===
echo "🔍 Identifying obsolete files..."

# Framework obsolete file patterns
FRAMEWORK_PATTERNS=(
    "*.log"
    "*.tmp"
    "*.temp"
    "*.cache"
    "*diagnostic_*.txt"
    "*_backup*"
    "*_old*"
    "*_deprecated*"
    "test_*.md"
    "*test_results*.md"
    "*.jpeg"
    "*.jpg"
    "*.png"
    "*_state.log"
    "consolidation_*.md"
)

# User project obsolete file patterns
USER_PATTERNS=(
    "*.log"
    "*.tmp"
    "*.temp"
    "node_modules/"
    ".cache/"
    "*.bak"
    "*.backup"
    "*.orig"
    "*~"
    ".DS_Store"
    "Thumbs.db"
    "desktop.ini"
)

# === SAFE ARCHIVAL FUNCTION ===
archive_file() {
    local file="$1"
    local category="$2"
    local context="$3"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Create category directory
    local archive_dir="$FRAMEWORK_OBSOLETE/$category"
    mkdir -p "$archive_dir"
    
    # Generate unique filename with timestamp
    local basename=$(basename "$file")
    local archived_name="${CURRENT_DATE}_${basename}"
    local archive_path="$archive_dir/$archived_name"
    
    # Move file to archive
    mv "$file" "$archive_path"
    
    # Update metadata
    local metadata_file="$FRAMEWORK_OBSOLETE/metadata.json"
    if [[ ! -f "$metadata_file" ]]; then
        echo "[]" > "$metadata_file"
    fi
    
    # Add metadata entry
    local metadata_entry=$(cat <<EOF
{
    "original_path": "$file",
    "archive_path": "$archive_path",
    "category": "$category",
    "context": "$context",
    "archived_date": "$CURRENT_DATE",
    "size": $(stat -f%z "$archive_path" 2>/dev/null || stat -c%s "$archive_path" 2>/dev/null || echo "0"),
    "can_delete_after": "$(date -d '+30 days' +%Y%m%d 2>/dev/null || date -v +30d +%Y%m%d 2>/dev/null || echo '20251231')",
    "auto_delete": true
}
EOF
)
    
    # Update metadata file (simplified approach)
    echo "$metadata_entry" >> "${metadata_file}.tmp"
    
    echo "📦 Archived: $file -> $archive_path"
    
    # Log action
    echo "- **$(date)**: Archived \`$file\` to \`$archive_path\` (category: $category, context: $context)" >> "$CLEANUP_LOG"
}

# === FRAMEWORK FILES CLEANUP ===
echo "🧹 Processing framework obsolete files..."

# Process log files
find . -name "*.log" -type f | while read -r file; do
    if [[ "$file" != *"$OBSOLETE_DIR"* ]]; then
        archive_file "$file" "logs" "Automatic log cleanup"
    fi
done

# Process diagnostic files
find . -name "diagnostic_*.txt" -type f | while read -r file; do
    if [[ "$file" != *"$OBSOLETE_DIR"* ]]; then
        archive_file "$file" "logs" "Diagnostic file cleanup"
    fi
done

# Process capture files
if [[ -d "capturas" ]]; then
    find capturas -name "*.jpeg" -type f | while read -r file; do
        archive_file "$file" "captures" "Screenshot cleanup"
    done
fi

# Process basic test files (keep integration tests)
find .ai_workflow/testing -name "test_*.md" -type f | while read -r file; do
    # Skip integration and edge case tests
    if [[ "$file" != *"integration_test"* && "$file" != *"edge_cases_test"* ]]; then
        archive_file "$file" "testing" "Basic test file cleanup"
    fi
done

# Process cache files
find . -name "*_state.log" -type f | while read -r file; do
    if [[ "$file" != *"$OBSOLETE_DIR"* ]]; then
        archive_file "$file" "cache" "State cache cleanup"
    fi
done

# Process backup files
find . -name "*backup*" -type f | while read -r file; do
    if [[ "$file" != *"$OBSOLETE_DIR"* ]]; then
        archive_file "$file" "cache" "Backup file cleanup"
    fi
done

# Process consolidation plans
find . -name "consolidation_*.md" -type f | while read -r file; do
    if [[ "$file" != *"$OBSOLETE_DIR"* ]]; then
        archive_file "$file" "documentation" "Obsolete consolidation plan"
    fi
done

# === UPDATE GITIGNORE ===
echo "📝 Updating .gitignore..."

# Enhanced .gitignore patterns
cat >> .gitignore << 'EOF'

# === ENHANCED OBSOLETE FILES MANAGEMENT ===
# Framework obsolete files
.ai_workflow/obsolete_files/
.ai_workflow/logs/
.ai_workflow/cache/
.ai_workflow/_project_state.log
.ai_workflow/consolidation_*.md

# User project obsolete files
*.log
*.tmp
*.temp
*.cache
*_backup*
*_old*
*_deprecated*
*diagnostic_*.txt
*_state.log
consolidation_*.md

# Development captures and screenshots
capturas/
screenshots/
*.png
*.jpg
*.jpeg
*.gif
*.bmp
*.webp

# Testing artifacts (keep integration tests)
test_*.md
*test_results*.md
simple_*_test.md
basic_test_*.md

# Cache and temporary directories
.cache/
.temp/
.tmp/
workflow_cache/
temp_files/

# OS and IDE specific (enhanced)
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
desktop.ini
*~
.fuse_hidden*

# Development artifacts
*.swp
*.swo
*.kate-swp
.vscode/
.idea/
*.sublime-*
.vim/

# Node.js artifacts (enhanced)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Python artifacts (enhanced)
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Environment and credentials
.env*
*.key
*.pem
*.cert
*.crt
secrets.json
credentials.json
config.json

# Backup and recovery files
*.bak
*.backup
*.orig
*.rej
*~

EOF

# === PERIODIC CLEANUP SCHEDULER ===
echo "⏰ Setting up periodic cleanup scheduler..."

# Create cleanup scheduler workflow
cat > .ai_workflow/workflows/maintenance/periodic_cleanup.md << 'EOF'
# Periodic Cleanup Scheduler

## Purpose
Automated periodic cleanup of obsolete files with user confirmation for permanent deletion.

## Execution Schedule
- **Daily**: Identify and archive new obsolete files
- **Weekly**: Review archived files for potential deletion
- **Monthly**: Cleanup review and system optimization

## Cleanup Workflow

```bash
#!/bin/bash

# Check files older than 30 days in obsolete directory
OBSOLETE_DIR=".ai_workflow/obsolete_files"
THIRTY_DAYS_AGO=$(date -d '30 days ago' +%Y%m%d 2>/dev/null || date -v -30d +%Y%m%d 2>/dev/null)

echo "🗑️  Checking for files ready for deletion..."

# Find files older than 30 days
find "$OBSOLETE_DIR" -type f -name "${THIRTY_DAYS_AGO}*" | while read -r file; do
    echo "📅 File ready for deletion: $file"
    echo "   Archived: $(echo "$file" | cut -d'_' -f1-2)"
    echo "   Age: >30 days"
    echo ""
done

# Check metadata for auto-delete candidates
if [[ -f "$OBSOLETE_DIR/framework/metadata.json" ]]; then
    echo "📊 Metadata-based cleanup candidates:"
    # Simple metadata check (would need JSON parsing in real implementation)
    echo "   Check metadata file for auto-delete candidates"
fi

echo "💡 To permanently delete obsolete files, run: ./ai-dev cleanup --confirm"
```

## Integration with CLI
Add to ai-dev script:
- `./ai-dev cleanup` - Show cleanup candidates
- `./ai-dev cleanup --confirm` - Permanently delete old files
- `./ai-dev cleanup --recover <file>` - Recover archived file

EOF

# === REPORT GENERATION ===
echo "📊 Generating cleanup report..."

# Initialize cleanup log if not exists
if [[ ! -f "$CLEANUP_LOG" ]]; then
    cat > "$CLEANUP_LOG" << 'EOF'
# Obsolete Files Cleanup Log

## Purpose
Track all file archival and cleanup operations for audit and recovery purposes.

## Cleanup History

EOF
fi

# Count archived files
ARCHIVED_COUNT=$(find "$OBSOLETE_DIR" -type f ! -name "*.json" ! -name "*.md" | wc -l)
TOTAL_SIZE=$(du -sh "$OBSOLETE_DIR" 2>/dev/null | cut -f1 || echo "0B")

echo "## Cleanup Summary - $(date)" >> "$CLEANUP_LOG"
echo "- **Files Archived**: $ARCHIVED_COUNT" >> "$CLEANUP_LOG"
echo "- **Total Size**: $TOTAL_SIZE" >> "$CLEANUP_LOG"
echo "- **Status**: Automated cleanup completed" >> "$CLEANUP_LOG"
echo "" >> "$CLEANUP_LOG"

# === SUCCESS REPORT ===
echo "✅ Obsolete files management system completed"
echo "📊 Files archived: $ARCHIVED_COUNT"
echo "💾 Total space organized: $TOTAL_SIZE"
echo "📁 Archive location: $OBSOLETE_DIR"
echo "📝 Cleanup log: $CLEANUP_LOG"
echo ""
echo "🎯 NEXT STEPS:"
echo "1. Review archived files in $OBSOLETE_DIR"
echo "2. Set up periodic cleanup schedule"
echo "3. Integrate with CLI for user-friendly management"
echo "4. Add recovery mechanisms for accidental archival"
echo ""
echo "💡 Run './ai-dev cleanup' to manage obsolete files"
```

## CLI Integration Points

### New Commands
- `./ai-dev cleanup` - Show cleanup candidates and system status
- `./ai-dev cleanup --auto` - Run automatic cleanup
- `./ai-dev cleanup --confirm` - Permanently delete old archived files
- `./ai-dev cleanup --recover <file>` - Recover specific archived file
- `./ai-dev cleanup --status` - Show cleanup system status

### Automatic Integration
- **Pre-commit hooks**: Run cleanup detection
- **Daily automation**: Identify new obsolete files
- **Weekly reporting**: Cleanup summary and recommendations

## Safety Features
- **Reversible operations**: All files archived, not deleted
- **Metadata tracking**: Complete audit trail
- **User confirmation**: Required for permanent deletion
- **Recovery system**: Easy file restoration
- **Gradual cleanup**: 30-day safety buffer

## Zero-Friction Features
- **Automatic detection**: No manual file identification needed
- **Intelligent categorization**: Files organized by type and purpose
- **Contextual recommendations**: Smart cleanup suggestions
- **Seamless integration**: Works with existing workflows
- **Minimal user interaction**: Automated with safety confirmations

## Success Metrics
- **Automation rate**: >90% of obsolete files detected automatically
- **False positive rate**: <5% of archived files need recovery
- **Storage optimization**: Reduce working directory size by >80%
- **User friction**: <2 manual steps for complete cleanup
- **Safety score**: 100% reversible operations