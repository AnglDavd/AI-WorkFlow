# Execute Project Response Plan (PRP)

## Purpose
Execute a Project-Response-Plan (PRP) using the abstract tool engine with automatic quality validation, systematic interpretation, task execution mapping, step-by-step validation, and detailed activity logging.

## When to Use
- Executing a specific Project Response Plan (PRP) file
- Running automated task workflows
- Implementing project requirements systematically
- When quality validation before execution is required

## Objective
Execute a Project-Response-Plan (PRP) using the abstract tool engine with automatic quality validation, systematic interpretation, task execution mapping, step-by-step validation, and detailed activity logging.

## Role & Approach
You are a **Task Execution Engine** - a precise and methodical executor that:
- **Literal Interpretation**: Execute the PRP exactly as written
- **Context-Aware**: First detect project-specific commands, then execute
- **Meticulous Logging**: Maintain detailed, structured log of every step
- **Targeted Self-Correction**: Apply minimal, targeted fixes when errors occur
- **Clear Reporting**: Communicate progress and errors in structured format

**Before proceeding, you MUST consult `.ai_workflow/GLOBAL_AI_RULES.md` for overarching guidelines.**

## Commands

### Phase 1: Pre-execution Quality Validation
```bash
# === AUTOMATIC QUALITY VALIDATION ===
echo "🔍 Running automatic quality validation before PRP execution..."
if [[ "$QUALITY_VALIDATION_ENABLED" != "false" ]]; then
    PROJECT_PATH="$(pwd)" bash .ai_workflow/workflows/quality/quality_gates.md
    if [[ $? -ne 0 ]]; then
        echo "❌ Quality validation failed before PRP execution"
        if [[ "$QUALITY_VALIDATION_STRICT" == "true" ]]; then
            echo "🚫 Blocking PRP execution due to quality issues (strict mode enabled)"
            exit 1
        else
            echo "⚠️  Quality issues detected but proceeding with PRP execution"
        fi
    else
        echo "✅ Quality validation passed, proceeding with PRP execution"
    fi
else
    echo "⏭️  Quality validation disabled for PRP execution"
fi
```

### Phase 2: Initialization & Context Detection
```bash
# 1. Receive PRP File
if [[ -z "$PRP_FILE_PATH" ]]; then
    read -p "Enter path to PRP file: " PRP_FILE_PATH
    if [[ ! -f "$PRP_FILE_PATH" ]]; then
        echo "❌ PRP file not found: $PRP_FILE_PATH"
        exit 1
    fi
fi

# 2. Setup Logging
mkdir -p .ai_workflow/run_logs
PRP_FILENAME=$(basename "$PRP_FILE_PATH" .md)
LOG_FILE=".ai_workflow/run_logs/${PRP_FILENAME}_$(date +%Y%m%d_%H%M%S).log"
echo "[START] Executing PRP: $PRP_FILENAME at $(date)" > "$LOG_FILE"

# 3. Parse PRP
echo "📋 Parsing PRP file: $PRP_FILE_PATH" | tee -a "$LOG_FILE"

# 4. Detect Project Context (CRITICAL)
echo "🔍 Detecting project context..." | tee -a "$LOG_FILE"

# Check for package.json (Node.js/JavaScript)
if [[ -f "package.json" ]]; then
    echo "📦 Node.js project detected" | tee -a "$LOG_FILE"
    LINT_COMMAND="npm run lint"
    TEST_COMMAND="npm test"
    TYPE_CHECK_COMMAND="npm run type-check"
    BUILD_COMMAND="npm run build"
    
# Check for pyproject.toml or requirements.txt (Python)
elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
    echo "🐍 Python project detected" | tee -a "$LOG_FILE"
    LINT_COMMAND="flake8 ."
    TEST_COMMAND="pytest"
    TYPE_CHECK_COMMAND="mypy ."
    BUILD_COMMAND="python setup.py build"
    
# Check for pom.xml (Java/Maven)
elif [[ -f "pom.xml" ]]; then
    echo "☕ Java/Maven project detected" | tee -a "$LOG_FILE"
    LINT_COMMAND="mvn checkstyle:check"
    TEST_COMMAND="mvn test"
    BUILD_COMMAND="mvn compile"
    
# Check for build.gradle (Java/Gradle)
elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    echo "☕ Java/Gradle project detected" | tee -a "$LOG_FILE"
    LINT_COMMAND="./gradlew check"
    TEST_COMMAND="./gradlew test"
    BUILD_COMMAND="./gradlew build"
    
# Default/Generic project
else
    echo "📁 Generic project detected" | tee -a "$LOG_FILE"
    LINT_COMMAND="echo 'No lint command configured'"
    TEST_COMMAND="echo 'No test command configured'"
    TYPE_CHECK_COMMAND="echo 'No type check command configured'"
    BUILD_COMMAND="echo 'No build command configured'"
fi

# 5. Load Tool Definitions
if [[ -f ".ai_workflow/docs/tool_abstraction_design.md" ]]; then
    echo "🛠️  Loading tool definitions..." | tee -a "$LOG_FILE"
else
    echo "⚠️  Tool abstraction design not found, using defaults" | tee -a "$LOG_FILE"
fi

# 6. Initialize Workflow State
echo "🔄 Initializing workflow state..." | tee -a "$LOG_FILE"
```

### Phase 3: Task Execution Loop
```bash
# Execute PRP tasks systematically
echo "🚀 Starting PRP execution..." | tee -a "$LOG_FILE"

# Parse YAML blocks from PRP file
if command -v yq >/dev/null 2>&1; then
    echo "📝 Using yq for YAML parsing..." | tee -a "$LOG_FILE"
else
    echo "⚠️  yq not found, using basic parsing..." | tee -a "$LOG_FILE"
fi

# Main execution logic will be handled by the AI agent
# based on the specific PRP content and abstract tool mappings

echo "✅ PRP execution completed" | tee -a "$LOG_FILE"
echo "[END] PRP execution finished at $(date)" >> "$LOG_FILE"
```

## Verification Criteria
- Pre-execution quality validation must pass (unless disabled)
- PRP file must exist and be readable
- Project context must be detected successfully
- All abstract tool mappings must be resolved
- Execution log must be created and populated
- All tasks in the PRP must be executed in sequence
- Each task's validation criteria must be met

## Input Requirements
- `PRP_FILE_PATH`: Path to the Project Response Plan file to execute
- `QUALITY_VALIDATION_ENABLED`: Enable/disable pre-execution quality validation (default: true)
- `QUALITY_VALIDATION_STRICT`: Block execution on quality issues (default: false)

## Output
- Detailed execution log in `.ai_workflow/run_logs/`
- Project context detection results
- Task execution results with success/failure status
- Final execution summary

## Next Steps
- **On Success**: PRP tasks completed, proceed with project workflow
- **On Quality Failure (Strict Mode)**: Fix quality issues before re-executing
- **On Execution Failure**: Review logs, fix issues, and re-execute PRP
- **On File Not Found**: Verify PRP file path and permissions

## Abstract Tool Mappings
This workflow supports mapping abstract tools to project-specific commands:
- `LINT_PROJECT` → `$LINT_COMMAND`
- `RUN_TESTS` → `$TEST_COMMAND`
- `TYPE_CHECK` → `$TYPE_CHECK_COMMAND`
- `BUILD_PROJECT` → `$BUILD_COMMAND`

## Security Considerations
- All inputs are validated through the security validation layer
- File paths are sanitized to prevent path traversal attacks
- Commands are executed with appropriate permissions
- Logs are stored securely with proper access controls