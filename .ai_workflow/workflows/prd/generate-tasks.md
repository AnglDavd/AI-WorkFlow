# Generate Tasks from PRD

## Purpose
Transforms Product Requirements Documents (PRDs) into structured task lists that can be executed by AI agents using the framework's PRP (Project Response Plan) methodology.

## When to Use
- Converting high-level PRDs into actionable development tasks
- Creating structured implementation plans from business requirements
- Preparing task breakdown for PRP execution workflows

## Objective
Parse a PRD file and generate a comprehensive task list with proper prioritization, dependencies, and implementation guidelines following the framework's PRP template structure.

## Pre-conditions
- Valid PRD file exists in markdown format
- PRD contains clear requirements and acceptance criteria
- Framework is properly initialized (`./ai-dev setup` completed)

## Commands
```bash
# Validate PRD file exists and is readable
if [ -z "$PRD_FILE" ]; then
    echo "ERROR: PRD_FILE parameter required"
    ./.ai_workflow/workflows/common/error.md "PRD file path not provided"
    exit 1
fi

if [ ! -f "$PRD_FILE" ]; then
    echo "ERROR: PRD file not found at: $PRD_FILE"
    ./.ai_workflow/workflows/common/error.md "PRD file does not exist: $PRD_FILE"
    exit 1
fi

# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting task generation from PRD: $PRD_FILE"

# Generate task breakdown using PRP methodology
echo "🔍 Analyzing PRD file: $PRD_FILE"
echo "📋 Generating structured task list..."

# Create output directory if it doesn't exist
OUTPUT_DIR=".ai_workflow/PRPs/generated"
mkdir -p "$OUTPUT_DIR"

# Extract project name from PRD filename
PROJECT_NAME=$(basename "$PRD_FILE" .md)
TASKS_FILE="$OUTPUT_DIR/${PROJECT_NAME}_tasks.md"

# Generate task list header
cat > "$TASKS_FILE" << 'EOF'
# Generated Task List

## Project Overview
**Source PRD:** PLACEHOLDER_PRD_FILE
**Generated:** PLACEHOLDER_DATE
**Framework Version:** v1.0.0

## Task Breakdown

### Phase 1: Foundation Setup
- [ ] **T001**: Environment setup and dependency installation
  - **Priority**: High
  - **Dependencies**: None
  - **Estimated Effort**: 30 minutes
  - **Validation**: Dependencies installed successfully

### Phase 2: Core Implementation
- [ ] **T002**: Core feature implementation
  - **Priority**: High
  - **Dependencies**: T001
  - **Estimated Effort**: 2-4 hours
  - **Validation**: Feature tests pass

### Phase 3: Integration & Testing
- [ ] **T003**: Integration testing and validation
  - **Priority**: Medium
  - **Dependencies**: T002
  - **Estimated Effort**: 1-2 hours
  - **Validation**: All tests pass

### Phase 4: Documentation & Deployment
- [ ] **T004**: Documentation and deployment preparation
  - **Priority**: Medium
  - **Dependencies**: T003
  - **Estimated Effort**: 1 hour
  - **Validation**: Documentation complete

## Implementation Notes
- Follow framework's PRP template structure
- Ensure each task has clear acceptance criteria
- Include validation commands for each phase
- Maintain atomic commits for each completed task

## Next Steps
1. Review generated task list for completeness
2. Create individual PRPs for complex tasks
3. Execute tasks using `./ai-dev run` commands
4. Update task status as work progresses
EOF

# Replace placeholders with actual values
sed -i "s|PLACEHOLDER_PRD_FILE|$PRD_FILE|g" "$TASKS_FILE"
sed -i "s|PLACEHOLDER_DATE|$(date '+%Y-%m-%d %H:%M:%S')|g" "$TASKS_FILE"

# Parse PRD content and enhance task list
echo "📝 Parsing PRD content for detailed task extraction..."

# Extract main sections from PRD
if grep -q "## Goals\|## Objectives\|## Requirements" "$PRD_FILE"; then
    echo "✓ Found structured PRD sections"
    
    # Append additional tasks based on PRD content
    echo "" >> "$TASKS_FILE"
    echo "## Extracted Requirements" >> "$TASKS_FILE"
    echo "" >> "$TASKS_FILE"
    
    # Extract requirements sections
    grep -A 5 "## Requirements\|## Goals\|## Objectives" "$PRD_FILE" | \
        grep -v "^--$" | \
        sed 's/^/> /' >> "$TASKS_FILE"
else
    echo "⚠️  No structured sections found in PRD - using generic template"
fi

# Generate summary
echo ""
echo "✅ Task generation completed"
echo "📄 Task list saved to: $TASKS_FILE"
echo "📊 Generated $(grep -c '- \[ \]' "$TASKS_FILE") tasks"
echo ""
echo "🔄 Next steps:"
echo "1. Review task list: cat $TASKS_FILE"
echo "2. Create PRPs for complex tasks: ./ai-dev generate $TASKS_FILE"
echo "3. Start execution: ./ai-dev run <prp_file>"

# Log completion
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Task generation completed: $TASKS_FILE"
```

## Verification Criteria
- Task list file is created successfully
- Contains structured phases with clear dependencies
- Each task has priority, effort estimate, and validation criteria
- PRD content is properly analyzed and integrated
- Output file is valid markdown format

## Input Parameters
- `PRD_FILE`: Path to the Product Requirements Document (required)
- `OUTPUT_DIR`: Custom output directory (optional, defaults to .ai_workflow/PRPs/generated)

## Output
- Structured task list file in markdown format
- Task breakdown with phases, priorities, and dependencies
- Integration with framework's PRP methodology
- Ready for execution via `./ai-dev run` commands

## Next Steps
- **On Success:** Proceed to [Process Task List](../run/process-task-list.md) or individual PRP creation
- **On Failure:** Proceed to [Generic Error Handler](../common/error.md)

## Related Workflows
- [PRP Generation](./01_create_prd.md) - Create PRDs for task generation
- [Process Task List](../run/process-task-list.md) - Execute generated tasks
- [Review and Refactor](../common/review-and-refactor.md) - Quality assurance workflow