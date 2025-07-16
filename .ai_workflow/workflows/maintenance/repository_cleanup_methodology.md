# Repository Cleanup Methodology

## Purpose
Define clear methodology for determining which files should be in the repository vs. gitignored, and implement automated cleanup.

## Core Principles

### 🟢 **SHOULD BE IN REPOSITORY** (Essential for Users)
1. **Framework Core**
   - `ai-dev` - Main CLI script
   - `manager.md` - Main documentation entry point
   - `QUICK_START.md` - Quick start guide
   - `ABOUT.md` - Framework overview
   - `CHANGELOG.md` - Version history
   - `README.md` - Repository documentation

2. **Core Workflows** (Essential for functionality)
   - `.ai_workflow/workflows/` - Core workflow implementations
   - `.ai_workflow/commands/` - AI agent commands
   - `.ai_workflow/PRPs/templates/` - PRP templates
   - `.ai_workflow/ARCHITECTURE.md` - Architecture documentation
   - `.ai_workflow/GLOBAL_AI_RULES.md` - Core behavioral rules
   - `.ai_workflow/AGENT_GUIDE.md` - AI agent guidelines
   - `.ai_workflow/FRAMEWORK_GUIDE.md` - Framework documentation

3. **Configuration Templates**
   - `.ai_workflow/config/` - Configuration templates (NOT user configs)
   - `.ai_workflow/precommit/config/` - Pre-commit configuration templates
   - `.github/workflows/` - GitHub Actions workflows

### 🔴 **SHOULD NOT BE IN REPOSITORY** (User-specific/Generated)
1. **Development/Internal Files**
   - `.dev_workspace/` - Development workspace (internal use)
   - `plan_de_trabajo.md` - Internal planning (temporary exception)
   - `capturas/` - Screenshots and captures
   - `CLAUDE.md` - Claude-specific instructions

2. **Generated/Runtime Files**
   - `.ai_workflow/logs/` - Log files
   - `.ai_workflow/cache/` - Cache files
   - `.ai_workflow/obsolete_files/` - Archived files
   - `.ai_workflow/audit_reports/` - Generated reports
   - `.ai_workflow/backups/` - Backup files
   - `.ai_workflow/_project_state.log` - Runtime state

3. **Testing/Temporary Files**
   - `.ai_workflow/testing/test_*.md` - Basic test files (keep integration tests)
   - `.ai_workflow/consolidation_*.md` - Consolidation plans
   - `integration_test_report.md` - Generated reports
   - `*_backup*` - Backup files
   - `*.tmp`, `*.temp`, `*.log` - Temporary files

4. **User Project Files**
   - User-generated PRPs (in `.ai_workflow/PRPs/` but not templates)
   - User-specific configurations
   - Project-specific logs and cache

## Implementation Workflow

```bash
#!/bin/bash

# Repository Cleanup Methodology Implementation
echo "🧹 Repository Cleanup - Methodology Implementation"
echo "================================================="

# Current date for backup
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
CLEANUP_LOG=".ai_workflow/repository_cleanup_${CURRENT_DATE}.log"

echo "📝 Starting repository cleanup at $(date)" > "$CLEANUP_LOG"

# === IDENTIFY PROBLEMATIC FILES ===
echo "🔍 Identifying files that shouldn't be in repository..."

# Get list of all tracked files
TRACKED_FILES=$(git ls-files)

# Patterns for files that should NOT be in repository
PROBLEMATIC_PATTERNS=(
    "\.ai_workflow/logs/"
    "\.ai_workflow/cache/"
    "\.ai_workflow/obsolete_files/"
    "\.ai_workflow/audit_reports/"
    "\.ai_workflow/backups/"
    "\.ai_workflow/_project_state\.log"
    "\.ai_workflow/consolidation_.*\.md"
    "\.ai_workflow/testing/test_.*\.md"
    "capturas/"
    "\.dev_workspace/"
    "plan_de_trabajo\.md"
    "integration_test_report\.md"
    ".*_backup.*"
    ".*\.tmp"
    ".*\.temp"
    ".*\.log"
)

# Find problematic files
PROBLEMATIC_FILES=()
for pattern in "${PROBLEMATIC_PATTERNS[@]}"; do
    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            # Skip integration tests and edge cases (these should stay)
            if [[ "$file" == *"integration_test"* || "$file" == *"edge_cases_test"* ]]; then
                continue
            fi
            PROBLEMATIC_FILES+=("$file")
        fi
    done < <(echo "$TRACKED_FILES" | grep -E "$pattern")
done

# Remove duplicates
UNIQUE_FILES=($(printf '%s\n' "${PROBLEMATIC_FILES[@]}" | sort -u))

echo "❌ Found ${#UNIQUE_FILES[@]} files that should not be in repository"

# === UPDATE .gitignore ===
echo "📝 Updating .gitignore with comprehensive patterns..."

# Backup current .gitignore
cp .gitignore ".gitignore.backup.$CURRENT_DATE"

# Enhanced .gitignore
cat > .gitignore << 'EOF'
# === CORE FRAMEWORK .gitignore ===
# This file defines what should NOT be in the repository
# Goal: Keep only essential files for framework functionality

# === DEVELOPMENT/INTERNAL FILES ===
# Development workspace (internal use only)
.dev_workspace/
plan_de_trabajo.md
roadmap_interno.md
internal_planning.md

# Claude and AI tool configurations
.claude/
.anthropic/
.openai/
claude_sessions/
*.claude
CLAUDE.md
claude_instructions.md

# === GENERATED/RUNTIME FILES ===
# Framework logs and cache
.ai_workflow/logs/
.ai_workflow/cache/
.ai_workflow/obsolete_files/
.ai_workflow/audit_reports/
.ai_workflow/backups/
.ai_workflow/_project_state.log
.ai_workflow/consolidation_*.md

# User project runtime files
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

# === TESTING/TEMPORARY FILES ===
# Basic test files (keep integration tests)
.ai_workflow/testing/test_*.md
.ai_workflow/testing/simple_*.md
.ai_workflow/testing/basic_*.md
!.ai_workflow/testing/integration_test*.md
!.ai_workflow/testing/edge_cases_test*.md

# Generated reports
integration_test_report.md
*_test_report*.md

# === CAPTURES AND MEDIA ===
# Screenshots and captures
capturas/
screenshots/
*.png
*.jpg
*.jpeg
*.gif
*.bmp
*.webp

# === OS AND IDE SPECIFIC ===
# macOS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes

# Windows
ehthumbs.db
Thumbs.db
desktop.ini

# Linux
*~
.fuse_hidden*

# IDE and editors
.vscode/
.idea/
*.swp
*.swo
*.kate-swp
*.sublime-*
.vim/

# === LANGUAGE SPECIFIC ===
# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Python
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

# === SECURITY AND CREDENTIALS ===
# Environment variables
.env*
*.key
*.pem
*.cert
*.crt
secrets.json
credentials.json

# === BACKUP AND RECOVERY ===
*.bak
*.backup
*.orig
*.rej

# === CACHE AND TEMPORARY DIRECTORIES ===
.cache/
.temp/
.tmp/
workflow_cache/
temp_files/
EOF

echo "✅ Updated .gitignore with comprehensive patterns"

# === REMOVE FILES FROM GIT TRACKING ===
echo "🗑️  Removing problematic files from git tracking..."

REMOVED_COUNT=0
FAILED_COUNT=0

for file in "${UNIQUE_FILES[@]}"; do
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
        if git rm --cached "$file" >/dev/null 2>&1; then
            echo "✅ Removed from tracking: $file" | tee -a "$CLEANUP_LOG"
            ((REMOVED_COUNT++))
        else
            echo "❌ Failed to remove: $file" | tee -a "$CLEANUP_LOG"
            ((FAILED_COUNT++))
        fi
    fi
done

# === COMMIT CHANGES ===
echo "💾 Committing cleanup changes..."

git add .gitignore
git commit -m "chore: Repository cleanup - Remove ${REMOVED_COUNT} files from tracking

- Updated .gitignore with comprehensive patterns
- Removed logs, cache, backups, and test files from tracking
- Kept only essential framework files for users
- Follows repository cleanup methodology

Files removed: ${REMOVED_COUNT}
Files failed: ${FAILED_COUNT}

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# === FINAL REPORT ===
echo ""
echo "🎉 Repository Cleanup Complete!"
echo "=============================="
echo "✅ Files removed from tracking: $REMOVED_COUNT"
echo "❌ Files failed to remove: $FAILED_COUNT"
echo "📝 Updated .gitignore with comprehensive patterns"
echo "💾 Changes committed to repository"
echo ""
echo "📊 Repository Status After Cleanup:"
TOTAL_TRACKED=$(git ls-files | wc -l)
REPO_SIZE=$(du -sh .git 2>/dev/null | cut -f1 || echo "unknown")
echo "  - Total tracked files: $TOTAL_TRACKED"
echo "  - Repository size: $REPO_SIZE"
echo ""
echo "💡 Next Steps:"
echo "1. Review repository to ensure only essential files remain"
echo "2. Test framework functionality after cleanup"
echo "3. Update documentation if needed"
echo "4. Consider running framework tests to ensure nothing broke"
echo ""
echo "📋 Cleanup log saved to: $CLEANUP_LOG"
```

## Repository File Categories

### 🟢 **ESSENTIAL FILES** (Must be in repository)
```
ai-dev                           # Main CLI
manager.md                       # Main documentation
QUICK_START.md                   # Quick start guide
ABOUT.md                         # Framework overview
CHANGELOG.md                     # Version history
README.md                        # Repository documentation
.ai_workflow/workflows/          # Core workflows
.ai_workflow/commands/           # AI agent commands
.ai_workflow/PRPs/templates/     # PRP templates
.ai_workflow/ARCHITECTURE.md     # Architecture documentation
.ai_workflow/GLOBAL_AI_RULES.md  # Core behavioral rules
.ai_workflow/AGENT_GUIDE.md      # AI agent guidelines
.ai_workflow/FRAMEWORK_GUIDE.md  # Framework documentation
.ai_workflow/config/             # Configuration templates
.ai_workflow/precommit/config/   # Pre-commit templates
.github/workflows/               # GitHub Actions
```

### 🔴 **SHOULD BE GITIGNORED** (User-specific/Generated)
```
.dev_workspace/                  # Development workspace
plan_de_trabajo.md              # Internal planning
capturas/                       # Screenshots
CLAUDE.md                       # Claude instructions
.ai_workflow/logs/              # Log files
.ai_workflow/cache/             # Cache files
.ai_workflow/obsolete_files/    # Archived files
.ai_workflow/audit_reports/     # Generated reports
.ai_workflow/backups/           # Backup files
.ai_workflow/testing/test_*.md  # Basic test files
*.log, *.tmp, *.temp           # Temporary files
*_backup*                      # Backup files
```

## Quality Gates

### Before Adding Files to Repository:
1. **Is it essential for framework functionality?**
2. **Will users need this file to use the framework?**
3. **Is it generated/runtime data?**
4. **Is it user-specific or project-specific?**
5. **Does it contain sensitive information?**

### Repository Health Metrics:
- **Essential files ratio**: >80% of files should be essential
- **Generated files**: 0% should be in repository
- **User-specific files**: 0% should be in repository
- **Repository size**: Should be minimal and clean

## Automation Integration
- Run repository cleanup as part of pre-commit hooks
- Regular automated audits of repository contents
- Automated .gitignore updates based on detected patterns
- Integration with framework's cleanup system