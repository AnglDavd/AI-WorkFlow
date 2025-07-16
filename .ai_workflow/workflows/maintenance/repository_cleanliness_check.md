# Repository Cleanliness Check

## Purpose
Validate repository cleanliness and remove unnecessary files that should not be tracked in version control.

## Philosophy
Maintain clean, professional repositories by preventing temporary files, backups, and internal development artifacts from being committed.

## Execution Context
- **Frequency**: Pre-commit validation, periodic maintenance
- **Scope**: All tracked files in git repository
- **Approach**: Automated detection and removal with configurable validation

## Repository Cleanliness Workflow

```bash
#!/bin/bash

# Repository Cleanliness Check
echo "🧹 Repository Cleanliness Check"
echo "==============================="

# Configuration
CLEANUP_LOG=".ai_workflow/logs/cleanup_$(date +%Y%m%d_%H%M%S).log"
UNNECESSARY_FILES=()

# Create logs directory
mkdir -p .ai_workflow/logs

# Initialize cleanup log
echo "📝 Cleanup Log - $(date)" > "$CLEANUP_LOG"

# Define patterns for unnecessary files
UNNECESSARY_PATTERNS=(
    "*.backup.*"
    "backup_*"
    "*.tmp"
    "*.temp"
    "*.log"
    "*_$(date +%Y%m%d)_*"
    "reports/installation_*"
    "analysis/plan_de_trabajo_impact_analysis.md"
    "precommit/backup_*"
    "precommit/reports/*"
    ".gitignore.backup.*"
)

echo "🔍 Scanning for unnecessary files..."
echo "$(date): Starting repository cleanliness scan" >> "$CLEANUP_LOG"

# Check for unnecessary files in git
for pattern in "${UNNECESSARY_PATTERNS[@]}"; do
    echo "📋 Checking pattern: $pattern"
    
    # Find files matching pattern that are tracked by git
    FOUND_FILES=$(git ls-files | grep -E "$pattern" || true)
    
    if [[ -n "$FOUND_FILES" ]]; then
        echo "⚠️  Found unnecessary files matching pattern: $pattern"
        echo "$FOUND_FILES" | while read -r file; do
            echo "    - $file"
            UNNECESSARY_FILES+=("$file")
            echo "$(date): Found unnecessary file: $file" >> "$CLEANUP_LOG"
        done
    fi
done

# Check for specific file types that shouldn't be in repository
echo "🔍 Checking for specific file types..."

# Backup files
BACKUP_FILES=$(git ls-files | grep -E "\.(bak|backup|orig|save)$" || true)
if [[ -n "$BACKUP_FILES" ]]; then
    echo "⚠️  Found backup files:"
    echo "$BACKUP_FILES" | sed 's/^/    /'
    echo "$BACKUP_FILES" | while read -r file; do
        UNNECESSARY_FILES+=("$file")
        echo "$(date): Found backup file: $file" >> "$CLEANUP_LOG"
    done
fi

# Log files
LOG_FILES=$(git ls-files | grep -E "\.log$" || true)
if [[ -n "$LOG_FILES" ]]; then
    echo "⚠️  Found log files:"
    echo "$LOG_FILES" | sed 's/^/    /'
    echo "$LOG_FILES" | while read -r file; do
        UNNECESSARY_FILES+=("$file")
        echo "$(date): Found log file: $file" >> "$CLEANUP_LOG"
    done
fi

# Temporary files
TEMP_FILES=$(git ls-files | grep -E "\.(tmp|temp)$" || true)
if [[ -n "$TEMP_FILES" ]]; then
    echo "⚠️  Found temporary files:"
    echo "$TEMP_FILES" | sed 's/^/    /'
    echo "$TEMP_FILES" | while read -r file; do
        UNNECESSARY_FILES+=("$file")
        echo "$(date): Found temporary file: $file" >> "$CLEANUP_LOG"
    done
fi

# Get all unnecessary files
ALL_UNNECESSARY=$(git ls-files | grep -E "(backup|logs|temp|cache|reports)" | grep -v "workflows/optimization/cache_workflow_results.md" | grep -v "workflows/common/attempt_auto_correction.md" | grep -v "PRPs/templates/" || true)

if [[ -n "$ALL_UNNECESSARY" ]]; then
    echo ""
    echo "🚫 REPOSITORY CLEANLINESS VIOLATION"
    echo "=================================="
    echo ""
    echo "📋 Files that should not be in repository:"
    echo "$ALL_UNNECESSARY" | sed 's/^/    /'
    echo ""
    echo "🔧 Recommended actions:"
    echo "  1. Remove these files from git tracking"
    echo "  2. Update .gitignore to prevent future occurrences"
    echo "  3. Use ./ai-dev cleanup to manage obsolete files properly"
    echo ""
    echo "💡 Commands to fix:"
    echo "  git rm --cached <file>  # Remove from git but keep local copy"
    echo "  git rm <file>          # Remove completely"
    echo ""
    echo "🤖 Automated cleanup available:"
    echo "  ./ai-dev cleanup --auto  # Automated cleanup"
    echo ""
    echo "$(date): Repository cleanliness violation detected" >> "$CLEANUP_LOG"
    
    # Return error code to block commit
    exit 1
else
    echo "✅ Repository cleanliness check passed"
    echo "📊 Repository status:"
    echo "  - No unnecessary backup files found"
    echo "  - No log files in repository"
    echo "  - No temporary files tracked"
    echo "  - Clean repository structure maintained"
    echo ""
    echo "$(date): Repository cleanliness check passed" >> "$CLEANUP_LOG"
fi

echo "📝 Cleanup log: $CLEANUP_LOG"
echo "✅ Repository cleanliness validation complete"
```

## Integration Points

### Pre-commit Hook Integration
- Add to `.ai_workflow/precommit/hooks/pre-commit`
- Validate repository cleanliness before each commit
- Block commits that include unnecessary files

### Periodic Maintenance
- Run weekly via `./ai-dev maintenance weekly`
- Automated cleanup of development artifacts
- Proactive repository health monitoring

### Quality Gates Integration
- Include in quality validation workflow
- Ensure clean repository as part of quality standards
- Automatic remediation suggestions

## Benefits

### Professional Repository Management
- Clean, professional repository appearance
- Reduced repository size and complexity
- Improved collaboration experience

### Development Workflow Efficiency
- Prevent accidental commits of development artifacts
- Maintain focus on essential project files
- Automated cleanup reduces manual maintenance

### Framework Integrity
- Separate internal development artifacts from user-facing framework
- Maintain framework usability and clarity
- Prevent confusion from temporary files in repository