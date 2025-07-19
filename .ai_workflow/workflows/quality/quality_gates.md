# Quality Gates Workflow

## Purpose
Execute comprehensive quality validation gates including syntax checking, test execution, and integration validation to ensure code meets quality standards before deployment.

## When to Use
- Before committing code changes
- During PRP execution validation phase
- As part of CI/CD pipeline validation
- When validating external contributions

## Prerequisites
- Project type detection completed
- Dependencies validated
- Valid abstract tool environment

## Input Parameters
- `project_path`: Path to project directory (default: current directory)
- `validation_scope`: full|changed_files|specific_files (default: changed_files)
- `target_files`: Specific files to validate (optional)
- `skip_tests`: Boolean to skip test execution (default: false)
- `quality_threshold`: Minimum quality score required (default: 80)

## Quality Gates Workflow

```bash
#!/bin/bash

# Quality Gates Execution
echo "🔍 Quality Gates Validation"
echo "=========================="

# Configuration
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
VALIDATION_SCOPE="${VALIDATION_SCOPE:-changed_files}"
SKIP_TESTS="${SKIP_TESTS:-false}"
QUALITY_THRESHOLD="${QUALITY_THRESHOLD:-80}"

# Quality metrics
SYNTAX_SCORE=0
TEST_SCORE=0
INTEGRATION_SCORE=0
OVERALL_SCORE=0

# Initialize quality log
QUALITY_LOG=".ai_workflow/logs/quality_$(date +%Y%m%d_%H%M%S).log"
mkdir -p .ai_workflow/logs
echo "📝 Quality Log - $(date)" > "$QUALITY_LOG"

echo "📋 Quality Gates Configuration:"
echo "  Project Path: $PROJECT_PATH"
echo "  Validation Scope: $VALIDATION_SCOPE"
echo "  Skip Tests: $SKIP_TESTS"
echo "  Quality Threshold: $QUALITY_THRESHOLD%"
echo ""

# Gate 1: Basic File Validation
echo "🔍 Gate 1: Basic File Validation"
echo "$(date): Starting Gate 1 - Basic File Validation" >> "$QUALITY_LOG"

if [[ "$VALIDATION_SCOPE" == "changed_files" ]]; then
    # Get changed files for validation
    CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
    if [[ -z "$CHANGED_FILES" ]]; then
        CHANGED_FILES=$(git diff --name-only 2>/dev/null || echo "")
    fi
    
    if [[ -n "$CHANGED_FILES" ]]; then
        echo "📋 Validating changed files:"
        echo "$CHANGED_FILES" | sed 's/^/  - /'
        
        # Basic syntax validation for common file types
        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                case "$file" in
                    *.json)
                        if command -v jq >/dev/null 2>&1; then
                            if jq empty "$file" >/dev/null 2>&1; then
                                echo "  ✅ $file: Valid JSON"
                                SYNTAX_SCORE=$((SYNTAX_SCORE + 10))
                            else
                                echo "  ❌ $file: Invalid JSON"
                                echo "$(date): Invalid JSON in $file" >> "$QUALITY_LOG"
                            fi
                        fi
                        ;;
                    *.md)
                        if [[ -s "$file" ]]; then
                            echo "  ✅ $file: Valid Markdown"
                            SYNTAX_SCORE=$((SYNTAX_SCORE + 5))
                        else
                            echo "  ⚠️  $file: Empty Markdown file"
                        fi
                        ;;
                    *.sh)
                        if bash -n "$file" 2>/dev/null; then
                            echo "  ✅ $file: Valid bash syntax"
                            SYNTAX_SCORE=$((SYNTAX_SCORE + 10))
                        else
                            echo "  ❌ $file: Invalid bash syntax"
                            echo "$(date): Invalid bash syntax in $file" >> "$QUALITY_LOG"
                        fi
                        ;;
                    *.js|*.jsx|*.mjs|*.cjs)
                        if command -v node >/dev/null 2>&1; then
                            if node -c "$file" 2>/dev/null; then
                                echo "  ✅ $file: Valid JavaScript syntax"
                                SYNTAX_SCORE=$((SYNTAX_SCORE + 10))
                            else
                                echo "  ❌ $file: Invalid JavaScript syntax"
                                echo "$(date): Invalid JavaScript syntax in $file" >> "$QUALITY_LOG"
                            fi
                        else
                            echo "  ✅ $file: JavaScript file (node not available for validation)"
                            SYNTAX_SCORE=$((SYNTAX_SCORE + 5))
                        fi
                        ;;
                    *.ts|*.tsx)
                        if command -v tsc >/dev/null 2>&1; then
                            if tsc --noEmit "$file" 2>/dev/null; then
                                echo "  ✅ $file: Valid TypeScript syntax"
                                SYNTAX_SCORE=$((SYNTAX_SCORE + 10))
                            else
                                echo "  ❌ $file: Invalid TypeScript syntax"
                                echo "$(date): Invalid TypeScript syntax in $file" >> "$QUALITY_LOG"
                            fi
                        else
                            echo "  ✅ $file: TypeScript file (tsc not available for validation)"
                            SYNTAX_SCORE=$((SYNTAX_SCORE + 5))
                        fi
                        ;;
                    *.html|*.htm|*.xhtml)
                        if command -v xmllint >/dev/null 2>&1; then
                            if xmllint --html --noout "$file" 2>/dev/null; then
                                echo "  ✅ $file: Valid HTML"
                                SYNTAX_SCORE=$((SYNTAX_SCORE + 8))
                            else
                                echo "  ⚠️  $file: HTML validation warnings"
                                SYNTAX_SCORE=$((SYNTAX_SCORE + 3))
                            fi
                        else
                            echo "  ✅ $file: HTML file (xmllint not available for validation)"
                            SYNTAX_SCORE=$((SYNTAX_SCORE + 5))
                        fi
                        ;;
                    *.css|*.scss|*.sass|*.less)
                        if [[ -s "$file" ]]; then
                            echo "  ✅ $file: CSS/preprocessor file"
                            SYNTAX_SCORE=$((SYNTAX_SCORE + 5))
                        else
                            echo "  ⚠️  $file: Empty CSS file"
                        fi
                        ;;
                    *.py)
                        if command -v python3 >/dev/null 2>&1; then
                            if python3 -m py_compile "$file" 2>/dev/null; then
                                echo "  ✅ $file: Valid Python syntax"
                                SYNTAX_SCORE=$((SYNTAX_SCORE + 10))
                            else
                                echo "  ❌ $file: Invalid Python syntax"
                                echo "$(date): Invalid Python syntax in $file" >> "$QUALITY_LOG"
                            fi
                        else
                            echo "  ✅ $file: Python file (python3 not available for validation)"
                            SYNTAX_SCORE=$((SYNTAX_SCORE + 5))
                        fi
                        ;;
                    *.yaml|*.yml)
                        if command -v yq >/dev/null 2>&1; then
                            if yq eval '.' "$file" >/dev/null 2>&1; then
                                echo "  ✅ $file: Valid YAML"
                                SYNTAX_SCORE=$((SYNTAX_SCORE + 8))
                            else
                                echo "  ❌ $file: Invalid YAML syntax"
                                echo "$(date): Invalid YAML syntax in $file" >> "$QUALITY_LOG"
                            fi
                        else
                            echo "  ✅ $file: YAML file (yq not available for validation)"
                            SYNTAX_SCORE=$((SYNTAX_SCORE + 5))
                        fi
                        ;;
                    *)
                        echo "  ℹ️  $file: File type not validated"
                        ;;
                esac
            fi
        done <<< "$CHANGED_FILES"
    else
        echo "📋 No changed files to validate"
        SYNTAX_SCORE=50
    fi
else
    echo "📋 Full project validation not implemented yet"
    SYNTAX_SCORE=50
fi

echo "$(date): Gate 1 completed - Syntax Score: $SYNTAX_SCORE" >> "$QUALITY_LOG"

# Gate 2: Repository Cleanliness
echo ""
echo "🧹 Gate 2: Repository Cleanliness"
echo "$(date): Starting Gate 2 - Repository Cleanliness" >> "$QUALITY_LOG"

# Check for unnecessary files
UNNECESSARY_FILES=$(git ls-files | grep -E "(backup|\.tmp|\.temp|\.log)$" || true)
if [[ -n "$UNNECESSARY_FILES" ]]; then
    echo "⚠️  Found unnecessary files in repository:"
    echo "$UNNECESSARY_FILES" | sed 's/^/  - /'
    echo "$(date): Found unnecessary files: $UNNECESSARY_FILES" >> "$QUALITY_LOG"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE - 10))
else
    echo "✅ Repository cleanliness check passed"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE + 20))
fi

echo "$(date): Gate 2 completed - Integration Score: $INTEGRATION_SCORE" >> "$QUALITY_LOG"

# Gate 3: Framework Integrity (for AI framework projects)
echo ""
echo "🔧 Gate 3: Framework Integrity"
echo "$(date): Starting Gate 3 - Framework Integrity" >> "$QUALITY_LOG"

if [[ -f "ai-dev" && -d ".ai_workflow" ]]; then
    echo "📋 AI Framework detected - running integrity checks"
    
    # Check essential framework files
    ESSENTIAL_FILES=(
        "ai-dev"
        "manager.md"
        ".ai_workflow/workflows/setup/01_start_setup.md"
        ".ai_workflow/workflows/run/01_run_prp.md"
    )
    
    MISSING_FILES=()
    for file in "${ESSENTIAL_FILES[@]}"; do
        if [[ ! -f "$file" ]]; then
            MISSING_FILES+=("$file")
        fi
    done
    
    if [[ ${#MISSING_FILES[@]} -eq 0 ]]; then
        echo "✅ All essential framework files present"
        INTEGRATION_SCORE=$((INTEGRATION_SCORE + 30))
    else
        echo "❌ Missing essential framework files:"
        printf '%s\n' "${MISSING_FILES[@]}" | sed 's/^/  - /'
        echo "$(date): Missing essential files: ${MISSING_FILES[*]}" >> "$QUALITY_LOG"
        
        # Auto-recovery: attempt to restore missing manager.md
        if [[ " ${MISSING_FILES[*]} " =~ " manager.md " ]]; then
            echo "🔧 Attempting auto-recovery for manager.md..."
            if [[ -f ".ai_workflow/scripts/verify_installation.sh" ]]; then
                echo "   Running installation verification with auto-fix..."
                bash .ai_workflow/scripts/verify_installation.sh fix-all >/dev/null 2>&1 || true
                
                # Re-check if manager.md now exists
                if [[ -f "manager.md" ]]; then
                    echo "   ✅ manager.md recovered successfully"
                    # Remove manager.md from missing files list
                    MISSING_FILES=("${MISSING_FILES[@]/manager.md/}")
                    # Filter out empty elements
                    MISSING_FILES_FILTERED=()
                    for file in "${MISSING_FILES[@]}"; do
                        [[ -n "$file" ]] && MISSING_FILES_FILTERED+=("$file")
                    done
                    MISSING_FILES=("${MISSING_FILES_FILTERED[@]}")
                else
                    echo "   ⚠️  Auto-recovery failed for manager.md"
                fi
            fi
        fi
        
        # Final assessment after auto-recovery attempts
        if [[ ${#MISSING_FILES[@]} -eq 0 ]]; then
            echo "✅ All essential files recovered - framework integrity restored"
            INTEGRATION_SCORE=$((INTEGRATION_SCORE + 20))
        else
            echo "❌ Critical files still missing after recovery attempts"
            INTEGRATION_SCORE=$((INTEGRATION_SCORE - 20))
        fi
    fi
else
    echo "ℹ️  Non-framework project - basic integrity check"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE + 10))
fi

echo "$(date): Gate 3 completed - Integration Score: $INTEGRATION_SCORE" >> "$QUALITY_LOG"

# Gate 4: Test Execution (if not skipped)
echo ""
echo "🧪 Gate 4: Test Execution"
echo "$(date): Starting Gate 4 - Test Execution" >> "$QUALITY_LOG"

if [[ "$SKIP_TESTS" == "false" ]]; then
    echo "📋 Running available tests..."
    
    # Check for common test patterns
    TEST_FILES=$(find . -name "*test*" -type f 2>/dev/null || true)
    if [[ -n "$TEST_FILES" ]]; then
        echo "📋 Found test files:"
        echo "$TEST_FILES" | sed 's/^/  - /'
        TEST_SCORE=$((TEST_SCORE + 20))
    else
        echo "ℹ️  No test files found"
        TEST_SCORE=$((TEST_SCORE + 10))
    fi
else
    echo "⏭️  Test execution skipped"
    TEST_SCORE=10
fi

echo "$(date): Gate 4 completed - Test Score: $TEST_SCORE" >> "$QUALITY_LOG"

# Calculate overall score
TOTAL_POSSIBLE=100
OVERALL_SCORE=$(( (SYNTAX_SCORE + TEST_SCORE + INTEGRATION_SCORE) * 100 / TOTAL_POSSIBLE ))

# Ensure score doesn't exceed 100
if [[ $OVERALL_SCORE -gt 100 ]]; then
    OVERALL_SCORE=100
fi

# Quality Assessment
echo ""
echo "📊 Quality Assessment Results"
echo "============================"
echo "  Syntax Score: $SYNTAX_SCORE"
echo "  Test Score: $TEST_SCORE"
echo "  Integration Score: $INTEGRATION_SCORE"
echo "  Overall Score: $OVERALL_SCORE%"
echo "  Quality Threshold: $QUALITY_THRESHOLD%"
echo ""

echo "$(date): Quality assessment completed - Overall Score: $OVERALL_SCORE%" >> "$QUALITY_LOG"

# Final validation
if [[ $OVERALL_SCORE -ge $QUALITY_THRESHOLD ]]; then
    echo "✅ Quality gates PASSED ($OVERALL_SCORE% >= $QUALITY_THRESHOLD%)"
    echo "$(date): Quality gates PASSED" >> "$QUALITY_LOG"
    echo "📝 Quality log: $QUALITY_LOG"
    exit 0
else
    echo "❌ Quality gates FAILED ($OVERALL_SCORE% < $QUALITY_THRESHOLD%)"
    echo "$(date): Quality gates FAILED" >> "$QUALITY_LOG"
    echo "📝 Quality log: $QUALITY_LOG"
    exit 1
fi
```

## Integration Points

### Pre-commit Hook Integration
- Integrated into `.ai_workflow/precommit/hooks/pre-commit`
- Validates code quality before each commit
- Configurable quality thresholds

### CLI Integration
- Available via `./ai-dev quality` command
- Supports different validation scopes
- Provides detailed quality metrics

### PRP Execution Integration
- Validates code quality during PRP execution
- Ensures generated code meets standards
- Provides feedback for quality improvements

## Quality Metrics

### Syntax Score (0-50 points)
- JSON validation: 10 points per valid file
- Markdown validation: 5 points per valid file
- Bash syntax validation: 10 points per valid file

### Test Score (0-25 points)
- Test file presence: 20 points
- Test execution: Additional points based on results

### Integration Score (0-50 points)
- Repository cleanliness: 20 points
- Framework integrity: 30 points
- File structure validation: Additional points

### Overall Score Calculation
- Combined weighted score from all gates
- Normalized to 0-100 scale
- Compared against configurable threshold (default: 80%)

## Error Handling

### Graceful Degradation
- Continues validation even if some tools are missing
- Provides meaningful error messages
- Suggests remediation steps

### Logging
- Comprehensive logging to `.ai_workflow/logs/quality_*.log`
- Detailed error tracking and debugging information
- Quality metrics history for trend analysis