# Validate Architecture Documentation Synchronization

## Purpose
Ensure that the project's ARCHITECTURE.md file stays synchronized with the actual project structure and dependencies. This workflow is integrated with the quality validation system to automatically check documentation consistency.

## Execution Context
- **Trigger:** Automatically during quality validation, pre-commit hooks, or manually
- **Goal:** Validate that architecture documentation matches current project state
- **Input:** Project directory with ARCHITECTURE.md file
- **Output:** Validation results and recommendations for updates

## Implementation

```bash
#!/bin/bash

# Validate Architecture Documentation Synchronization
echo "📋 Validating architecture documentation synchronization..."

# Variables
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
ARCHITECTURE_FILE="$PROJECT_ROOT/ARCHITECTURE.md"
VALIDATION_PASSED=true
ISSUES_FOUND=()

# Check if architecture documentation exists
if [[ ! -f "$ARCHITECTURE_FILE" ]]; then
    echo "❌ ARCHITECTURE.md not found in project root"
    echo "💡 Run './ai-dev generate-architecture' to create it"
    exit 1
fi

echo "📄 Found ARCHITECTURE.md, validating synchronization..."

# === TECHNOLOGY DETECTION ===
# Detect current project technologies
DETECTED_LANGUAGES=()
DETECTED_FRAMEWORKS=()
DETECTED_BUILD_TOOLS=()

# Language Detection
if [[ -f "package.json" ]]; then
    DETECTED_LANGUAGES+=("JavaScript/TypeScript")
    DETECTED_BUILD_TOOLS+=("npm/yarn")
fi

if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
    DETECTED_LANGUAGES+=("Python")
    DETECTED_BUILD_TOOLS+=("pip/poetry")
fi

if [[ -f "pom.xml" ]]; then
    DETECTED_LANGUAGES+=("Java")
    DETECTED_BUILD_TOOLS+=("Maven")
fi

if [[ -f "build.gradle" ]]; then
    DETECTED_LANGUAGES+=("Java")
    DETECTED_BUILD_TOOLS+=("Gradle")
fi

if [[ -f "Cargo.toml" ]]; then
    DETECTED_LANGUAGES+=("Rust")
    DETECTED_BUILD_TOOLS+=("Cargo")
fi

if [[ -f "go.mod" ]]; then
    DETECTED_LANGUAGES+=("Go")
    DETECTED_BUILD_TOOLS+=("go modules")
fi

if [[ -f "Dockerfile" ]]; then
    DETECTED_BUILD_TOOLS+=("Docker")
fi

# === VALIDATE DOCUMENTED TECHNOLOGIES ===
echo "🔍 Validating documented technologies..."

# Check if documented languages match detected languages
for lang in "${DETECTED_LANGUAGES[@]}"; do
    if ! grep -q "$lang" "$ARCHITECTURE_FILE"; then
        ISSUES_FOUND+=("Language '$lang' detected but not documented in ARCHITECTURE.md")
        VALIDATION_PASSED=false
    fi
done

# Check if documented build tools match detected build tools
for tool in "${DETECTED_BUILD_TOOLS[@]}"; do
    if ! grep -q "$tool" "$ARCHITECTURE_FILE"; then
        ISSUES_FOUND+=("Build tool '$tool' detected but not documented in ARCHITECTURE.md")
        VALIDATION_PASSED=false
    fi
done

# === VALIDATE DEPENDENCY INFORMATION ===
echo "🔍 Validating dependency information..."

# Check if dependency files are documented
if [[ -f "package.json" ]]; then
    if ! grep -q "package.json" "$ARCHITECTURE_FILE"; then
        ISSUES_FOUND+=("package.json exists but not documented in ARCHITECTURE.md")
        VALIDATION_PASSED=false
    fi
fi

if [[ -f "requirements.txt" ]]; then
    if ! grep -q "requirements.txt" "$ARCHITECTURE_FILE"; then
        ISSUES_FOUND+=("requirements.txt exists but not documented in ARCHITECTURE.md")
        VALIDATION_PASSED=false
    fi
fi

if [[ -f "pom.xml" ]]; then
    if ! grep -q "pom.xml" "$ARCHITECTURE_FILE"; then
        ISSUES_FOUND+=("pom.xml exists but not documented in ARCHITECTURE.md")
        VALIDATION_PASSED=false
    fi
fi

# === VALIDATE DOCUMENTATION FRESHNESS ===
echo "🔍 Validating documentation freshness..."

# Check if ARCHITECTURE.md is older than key configuration files
ARCHITECTURE_TIMESTAMP=$(stat -c %Y "$ARCHITECTURE_FILE" 2>/dev/null || stat -f %m "$ARCHITECTURE_FILE" 2>/dev/null || echo "0")

for config_file in package.json requirements.txt pom.xml build.gradle Cargo.toml; do
    if [[ -f "$config_file" ]]; then
        CONFIG_TIMESTAMP=$(stat -c %Y "$config_file" 2>/dev/null || stat -f %m "$config_file" 2>/dev/null || echo "0")
        
        if [[ "$CONFIG_TIMESTAMP" -gt "$ARCHITECTURE_TIMESTAMP" ]]; then
            ISSUES_FOUND+=("$config_file is newer than ARCHITECTURE.md - documentation may be outdated")
            VALIDATION_PASSED=false
        fi
    fi
done

# === VALIDATE FRAMEWORK INTEGRATION ===
echo "🔍 Validating framework integration..."

# Check if AI framework integration is documented
if ! grep -q "AI Framework Integration" "$ARCHITECTURE_FILE"; then
    ISSUES_FOUND+=("AI Framework Integration section missing from ARCHITECTURE.md")
    VALIDATION_PASSED=false
fi

# Check if quality validation is documented
if ! grep -q "Quality Validation" "$ARCHITECTURE_FILE"; then
    ISSUES_FOUND+=("Quality Validation section missing from ARCHITECTURE.md")
    VALIDATION_PASSED=false
fi

# === VALIDATE STRUCTURAL CONSISTENCY ===
echo "🔍 Validating structural consistency..."

# Check if project structure in docs matches actual structure
if grep -q "Project Structure" "$ARCHITECTURE_FILE"; then
    # Extract documented directories
    DOCUMENTED_DIRS=$(grep -A 20 "Project Structure" "$ARCHITECTURE_FILE" | grep "├──" | sed 's/.*├── //' | sort)
    
    # Check if documented directories exist
    while IFS= read -r dir; do
        if [[ -n "$dir" ]] && [[ ! -d "$dir" ]]; then
            ISSUES_FOUND+=("Documented directory '$dir' not found in project")
            VALIDATION_PASSED=false
        fi
    done <<< "$DOCUMENTED_DIRS"
fi

# === GENERATE VALIDATION REPORT ===
echo ""
echo "📊 Architecture Documentation Validation Report"
echo "=============================================="

if [[ "$VALIDATION_PASSED" == "true" ]]; then
    echo "✅ VALIDATION PASSED"
    echo "Architecture documentation is synchronized with project state"
    echo ""
    echo "Validated components:"
    echo "- Technology stack: ${DETECTED_LANGUAGES[*]:-None}"
    echo "- Build tools: ${DETECTED_BUILD_TOOLS[*]:-None}"
    echo "- Dependency files: $(find . -maxdepth 1 -name "*.json" -o -name "*.txt" -o -name "*.toml" -o -name "*.xml" | wc -l) files"
    echo "- Documentation freshness: Current"
    echo "- Framework integration: Complete"
    
    exit 0
else
    echo "❌ VALIDATION FAILED"
    echo "Architecture documentation is out of sync with project state"
    echo ""
    echo "Issues found:"
    for issue in "${ISSUES_FOUND[@]}"; do
        echo "  - $issue"
    done
    echo ""
    echo "🔧 Recommended actions:"
    echo "  1. Run './ai-dev update-architecture' to refresh documentation"
    echo "  2. Review and update technology stack sections manually"
    echo "  3. Ensure all configuration files are properly documented"
    echo ""
    echo "💡 Quick fix: ./ai-dev update-architecture"
    
    exit 1
fi
```

## Integration Points

This workflow integrates with:
- **Quality validation system** - Runs automatically during quality checks
- **Pre-commit hooks** - Ensures documentation stays current before commits
- **CLI commands** - Can be run manually for validation
- **Architecture generation** - Validates output of architecture generation

## Quality Gate Configuration

Add to `.ai_workflow/config/quality_config.json`:
```json
{
  "documentation_validation": {
    "enabled": true,
    "check_architecture_sync": true,
    "fail_on_outdated": false,
    "auto_update_suggestion": true
  }
}
```

## Output

Provides:
- **Validation status** - Pass/fail with detailed issues
- **Synchronization report** - What's documented vs. detected
- **Actionable recommendations** - Specific steps to fix issues
- **Integration with quality system** - Seamless quality gate integration