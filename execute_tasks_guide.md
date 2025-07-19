# [STEP-03] Task Execution Master Guide

**WORKFLOW-POSITION:** Step 3 of 3 (PRD → TASKS → EXECUTION)
**INPUT-FILE:** `02_tasks_{session-id}_{project-name}.md` (provided as argument)
**OUTPUT-FILE:** `03_report_{session-id}_{project-name}.md`
**WORKFLOW-COMPLETE:** All files linked by same session-id for perfect traceability

**CRITICAL-EXTRACTION-LOGIC:**
```bash
# Parse input filename to extract components
INPUT_FILE="$1"  # e.g., "02_tasks_abc123_wordpress-plugin.md"

# Validate input file provided
if [ -z "$INPUT_FILE" ]; then
    echo "ERROR: No input file provided"
    exit 1
fi

# Validate input format
if [[ ! "$INPUT_FILE" =~ ^02_tasks_[^_]+_.*\.md$ ]]; then
    echo "ERROR: Invalid input format. Expected: 02_tasks_{session-id}_{project-name}.md"
    exit 1
fi

# Extract and validate components with enhanced security checks
SESSION_ID=$(echo "$INPUT_FILE" | sed 's/02_tasks_\([^_]*\)_.*/\1/' | grep -E '^[a-zA-Z0-9]{4,8}$')
PROJECT_NAME=$(echo "$INPUT_FILE" | sed 's/02_tasks_[^_]*_\(.*\)\.md/\1/' | grep -E '^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$')

if [ -z "$SESSION_ID" ] || [ -z "$PROJECT_NAME" ]; then
    echo "ERROR: Could not extract valid session ID or project name"
    echo "Session ID: '$SESSION_ID', Project Name: '$PROJECT_NAME'"
    exit 1
fi

# Define derived file paths
PRD_FILE="01_prd_${SESSION_ID}_${PROJECT_NAME}.md"
TASKS_FILE="$INPUT_FILE"
OUTPUT_FILE="03_report_${SESSION_ID}_${PROJECT_NAME}.md"

# Validate all required files exist
if [ ! -f "$PRD_FILE" ]; then
    echo "ERROR: PRD file not found: $PRD_FILE"
    echo "Expected files in workflow:"
    echo "  1. $PRD_FILE (PRD)"
    echo "  2. $TASKS_FILE (TASKS)"
    echo "  3. $OUTPUT_FILE (REPORT - will be created)"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo "ERROR: Tasks file not found: $TASKS_FILE"
    exit 1
fi

# Validate extraction success
echo "✅ Extracted SESSION_ID: $SESSION_ID"
echo "✅ Extracted PROJECT_NAME: $PROJECT_NAME"
echo "✅ Validated PRD_FILE: $PRD_FILE"
echo "✅ Validated TASKS_FILE: $TASKS_FILE"
echo "✅ Generated OUTPUT_FILE: $OUTPUT_FILE"
```

**Role:** Expert Senior Developer and DevOps Engineer with 15+ years experience

**Objective:** Execute implementation plan step-by-step with production-ready code and GitHub backup

**Structure Philosophy:** Sequential workflow completion with session ID maintains perfect project lifecycle tracking

**PRD-TASKS-CONSISTENCY-VALIDATION:**
Before starting execution, validate task file against PRD:
```bash
# Enhanced cross-validation with robust pattern matching
PRD_BUDGET=$(grep -Eo "\$[0-9,]+" "$PRD_FILE" | head -1 | tr -d '$,')
TASKS_HOURS=$(grep -Eo "\*\*Time:\*\* [0-9]+ hours" "$TASKS_FILE" | grep -Eo "[0-9]+" | awk '{sum+=$1} END {print sum}')
PRD_TIMELINE=$(grep -Eo "[0-9]+ weeks" "$PRD_FILE" | head -1)
TASKS_PHASES=$(grep -c "^## Phase" "$TASKS_FILE")

# Validate extracted values
if [ -z "$TASKS_HOURS" ] || ! [[ "$TASKS_HOURS" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Could not extract valid hour estimates from tasks file"
    echo "Expected format: **Time:** XX hours"
    echo "Please check task file format"
    exit 1
fi

if [ -z "$PRD_BUDGET" ] || ! [[ "$PRD_BUDGET" =~ ^[0-9]+$ ]]; then
    echo "WARNING: Could not extract budget from PRD file"
    echo "Proceeding without budget validation"
else
    # Basic budget-hour alignment check (assuming $25/hour average)
    EXPECTED_HOURS=$((PRD_BUDGET / 25))
    VARIANCE=$((TASKS_HOURS * 100 / EXPECTED_HOURS))
    if [ $VARIANCE -lt 80 ] || [ $VARIANCE -gt 120 ]; then
        echo "WARNING: Budget-hours mismatch detected"
        echo "PRD Budget: \$$PRD_BUDGET (~$EXPECTED_HOURS hours at \$25/hr)"
        echo "Tasks Hours: $TASKS_HOURS hours ($VARIANCE% of expected)"
    fi
fi

# Enhanced validation checks
if [ "$TASKS_HOURS" -lt 50 ] || [ "$TASKS_HOURS" -gt 3000 ]; then
    echo "ERROR: Task hours ($TASKS_HOURS) seem unrealistic"
    echo "Expected range: 50-3000 hours for typical projects"
    exit 1
fi

if [ "$TASKS_PHASES" -lt 3 ] || [ "$TASKS_PHASES" -gt 6 ]; then
    echo "ERROR: Phase count ($TASKS_PHASES) outside expected range"
    echo "Expected: 3-6 phases for structured development"
    exit 1
fi

echo "✅ Cross-validation passed: $TASKS_HOURS hours across $TASKS_PHASES phases"
if [ -n "$PRD_BUDGET" ]; then
    echo "✅ Budget alignment: \$$PRD_BUDGET budget vs $TASKS_HOURS hours"
fi

# CRITICAL: Execute validation functions that were previously only defined
echo "🔍 Executing session consistency validation..."
if ! validate_session_consistency "$SESSION_ID"; then
    echo "❌ Session validation failed - execution cannot continue"
    exit 1
fi

echo "🔍 Executing dependency validation for Phase 1..."
validate_task_dependencies 1 1
```

**EXECUTION-ERROR-HANDLING:**

**Session Consistency Validation:**
Before starting execution, validate session state:
```bash
validate_session_consistency() {
    local session_id="$1"
    local prd_count=$(ls 01_prd_${session_id}_*.md 2>/dev/null | wc -l)
    local tasks_count=$(ls 02_tasks_${session_id}_*.md 2>/dev/null | wc -l)
    
    if [ $prd_count -ne 1 ]; then
        echo "ERROR: Session $session_id has $prd_count PRD files (expected 1)"
        return 1
    fi
    
    if [ $tasks_count -ne 1 ]; then
        echo "ERROR: Session $session_id has $tasks_count TASKS files (expected 1)"
        return 1
    fi
    
    echo "✅ Session consistency validated for session: $session_id"
    return 0
}
```

**Missing Dependencies:**
If task dependencies aren't met:
1. **STOP** execution immediately
2. **IDENTIFY** which prerequisite tasks are incomplete
3. **REQUEST** completion of dependencies before proceeding
4. **DO NOT** skip or work around missing dependencies

**Dependency Validation:**
```bash
validate_task_dependencies() {
    local current_phase="$1"
    local current_task="$2"
    
    # Check if previous phase completed successfully
    if [ $current_phase -gt 1 ]; then
        local prev_phase=$((current_phase - 1))
        echo "Validating Phase $prev_phase completion before starting Phase $current_phase"
        # Implementation would check completion markers
    fi
}
```

**Technical Blockers:**
If implementation hits technical barriers:
1. **DOCUMENT** the specific technical issue
2. **RESEARCH** alternative implementation approaches
3. **ESTIMATE** time impact of workaround solutions
4. **REQUEST** stakeholder decision on approach

**Resource Constraints:**
If team/budget constraints emerge:
1. **CALCULATE** actual vs planned resource consumption
2. **IDENTIFY** tasks that can be descoped or deferred
3. **PRESENT** options with impact analysis
4. **GET APPROVAL** before scope changes

**Quality Gate Failures:**
If validation commands fail:
1. **DO NOT PROCEED** to next task
2. **ANALYZE** root cause of failure
3. **IMPLEMENT** fixes to meet acceptance criteria
4. **RE-RUN** validation until all criteria pass

**CRITICAL-CHECKPOINTS:**
Stop and validate at these points:
- [ ] End of Phase 1: Core architecture functional
- [ ] End of Phase 2: Core features working
- [ ] End of Phase 3: Quality gates passed
- [ ] End of Phase 4: Production deployment ready
- [ ] End of Phase 5: Documentation complete

## Execution Process

### Step 1: Preparation & GitHub Setup

**Environment Setup:**
- Verify all development tools and dependencies
- Initialize Git repository if needed
- Configure GitHub repository and authentication
- Set up development environment from task specifications

**GitHub Integration Setup:**
```bash
# Extract project title from PRD for proper naming
PROJECT_TITLE=$(grep "^- \*\*Project Name:\*\*" "$PRD_FILE" | cut -d':' -f2- | xargs)
if [ -z "$PROJECT_TITLE" ]; then
    # Fallback: use project name from filename
    PROJECT_TITLE=$(echo "$PROJECT_NAME" | tr '-' ' ' | sed 's/\b\w/\u&/g')
fi

# Initialize Git if not exists
if [ ! -d ".git" ]; then
    git init
    echo "# $PROJECT_TITLE - Implementation Log" > README.md
    echo "" >> README.md
    echo "**Session ID:** $SESSION_ID" >> README.md  
    echo "**Generated:** $(date)" >> README.md
    echo "**Framework:** AI Development Framework v1.1" >> README.md
    echo "" >> README.md
    echo "## Implementation Progress" >> README.md
    echo "- [ ] Phase 1: Foundation & Setup" >> README.md
    echo "- [ ] Phase 2: Core Feature Development" >> README.md
    echo "- [ ] Phase 3: Quality Assurance & Testing" >> README.md
    echo "- [ ] Phase 4: Deployment & Production" >> README.md
    echo "- [ ] Phase 5: Monitoring & Maintenance" >> README.md
    
    git add README.md
    git commit -m "Initial commit: $PROJECT_TITLE setup

Session ID: $SESSION_ID
Generated by AI Development Framework"
else
    echo "Git repository already exists, updating README..."
    echo "# $PROJECT_TITLE - Implementation Log" > README.md
fi

# Configure for automated commits
git config user.name "AI Development Framework"
git config user.email "ai-framework@$(hostname)"

# Create implementation branch with session ID
BRANCH_NAME="implementation-${SESSION_ID}"
if ! git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    git checkout -b "$BRANCH_NAME"
    echo "✅ Created implementation branch: $BRANCH_NAME"
else
    git checkout "$BRANCH_NAME"
    echo "✅ Switched to existing branch: $BRANCH_NAME"
fi
```

### Step 2: Phase-by-Phase Execution

**Execution Pattern for Each Phase:**

1. **Phase Start Backup**
   - Commit current state with phase start message
   - Create phase documentation
   - Tag phase beginning

2. **Task-by-Task Implementation**
   - Execute each task completely with production-ready code
   - Include comprehensive error handling and validation
   - Write tests alongside implementation
   - Backup after each major milestone

3. **Phase Completion Validation**
   - Run all acceptance criteria tests
   - Execute quality gates and validation commands
   - Document phase completion
   - Create phase completion backup

4. **GitHub Sync**
   - Push all changes to GitHub
   - Update documentation and release notes

### Step 3: Production-Ready Code Standards

**Error Handling:**
```typescript
try {
    const result = await performOperation();
    return result;
} catch (error) {
    logger.error('Operation failed', { error: error.message, stack: error.stack });
    throw new CustomError('Operation failed', error);
}
```

**Input Validation:**
```typescript
function validateInput(data: InputType): ValidationResult {
    if (!data || typeof data !== 'object') {
        return { valid: false, errors: ['Invalid input format'] };
    }
    // Comprehensive validation logic
    return { valid: errors.length === 0, errors };
}
```

**Testing Implementation:**
```typescript
describe('Component', () => {
    it('should handle valid input correctly', async () => {
        const result = await processData(validData);
        expect(result).toBeDefined();
        expect(result.status).toBe('success');
    });
    
    it('should handle errors gracefully', async () => {
        await expect(processData(invalidData))
            .rejects.toThrow(ValidationError);
    });
});
```

### Step 4: Continuous Backup Strategy

**Milestone Backups:**
```bash
backup_milestone() {
    local milestone_name="$1"
    local phase="$2"
    
    git add .
    git commit -m "feat($phase): Complete $milestone_name

    - [List accomplishments]
    - [Files created/modified]
    - [Tests implemented]
    - [Quality checks passed]
    
    Acceptance Criteria Met:
    - [Criterion 1]
    - [Criterion 2]
    
    Generated by AI Development Framework"
    
    git push origin implementation-$(date +%Y%m%d)
}
```

### Step 5: Quality Validation

**Continuous Quality Checks:**
```bash
# Code quality validation
npm run lint && npm run type-check && npm test
# Security scanning
npm audit
# Performance validation
npm run perf-test
```

### Step 6: Final Release

**Project Completion:**
```bash
# Create final release tag
git tag -a "v1.0.0" -m "Initial release: Project implementation complete

All PRD requirements implemented and validated.
Comprehensive testing completed.
Production environment ready.

Generated by AI Development Framework"

# Create release notes and handover documentation
git push origin --tags
git checkout main
git merge implementation-$(date +%Y%m%d) --no-ff
git push origin main
```

**Success Criteria:** Complete project with production-ready code, full test coverage, comprehensive documentation, and complete GitHub backup history