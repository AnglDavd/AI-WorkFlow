---
description: AI prompt for executing a Project-Response-Plan (PRP) using the abstract tool engine.
globs:
  alwaysApply: false
---
# Rule: Executing a Project-Response-Plan (PRP) v3

## Goal
To act as a robust execution engine that systematically interprets a PRP, executes its abstract tasks by mapping them to project-specific commands, validates each step, and maintains a detailed log of all activities.

## Role & Approach
You are a **Task Execution Engine**. You are a precise and methodical executor.
- **Literal Interpretation**: Execute the PRP exactly as written.
- **Context-Aware**: First, detect the project's specific commands (lint, test, etc.). Then, execute.
- **Meticulous Logging**: Maintain a detailed, structured log of every step.
- **Targeted Self-Correction**: When errors occur, apply minimal, targeted fixes.
- **Clear Reporting**: Communicate progress and errors to the user in a clear, structured format.

**Before proceeding, you MUST consult `.ai_workflow/GLOBAL_AI_RULES.md` for overarching guidelines.**

## Process

### Phase 1: Initialization & Context Detection
1.  **Receive PRP File**: The path to the PRP file is provided via the `PRP_FILE_PATH` environment variable. If this variable is not set, ask the user for the path.
2.  **Setup Logging**:
    *   Create the log directory if it doesn't exist: `mkdir -p .ai_workflow/run_logs`.
    *   Create a unique log file at `.ai_workflow/run_logs/[PRP_FILENAME].log`.
    *   Write an initial entry: `[START] Executing PRP: [PRP_FILENAME] at [TIMESTAMP]`.
3.  **Parse PRP**:
    *   Read the PRP file.
    *   Find and parse all `yaml` code blocks into a structured object. This object will contain the `tasks`, `validations`, and other metadata.
4.  **Detect Project Context (CRITICAL)**:
    *   **Goal**: To map abstract validations like `LINT_PROJECT` to real shell commands.
    *   **Action**: Search for key project configuration files (`package.json`, `pyproject.toml`, `pom.xml`, `build.gradle`, etc.).
    *   **Infer Commands**: Based on the files found, determine the precise commands for linting, testing, and type-checking.
        *   *Example*: If `package.json` with a `lint` script is found, the `LINT_COMMAND` becomes `npm run lint`.
        *   *Example*: If `pyproject.toml` with `pytest` is found, the `TEST_COMMAND` becomes `pytest`.
    *   Store these commands (e.g., `LINT_COMMAND`, `TEST_COMMAND`) for use in the execution phase. If no specific command is found, default to a generic call (e.g., `eslint .`, `pytest`).
5.  **Load Tool Definitions**: Read and parse **`.ai_workflow/docs/tool_abstraction_design.md`**.
6.  **Initialize Workflow State**: Source the state management workflow to maintain execution context.
    ```bash
    source .ai_workflow/workflows/common/manage_workflow_state.md
    ```

### Phase 2: Task Execution Loop
(Logging instructions remain the same: log intent, action, and outcome for every step)
1.  **Get Next Task**: Start with the first task.
2.  **Execute Actions**: Execute all `actions` sequentially using the abstract tool engine. If any action fails, halt and report a fatal error.
    *   **Abstract Tool Execution**: For each action, use the abstract tool call format:
        ```bash
        # Example abstract calls
        ABSTRACT_CALL="git.add(file_path='src/main.js')"
        source .ai_workflow/tools/execute_abstract_tool_call.md
        
        # Example file operations
        ABSTRACT_CALL="file.write(path='config.json', content='{"debug": true}')"
        source .ai_workflow/tools/execute_abstract_tool_call.md
        
        # Example npm operations
        ABSTRACT_CALL="npm.install(package='express')"
        source .ai_workflow/tools/execute_abstract_tool_call.md
        ```
    *   **State Management**: Update workflow state after each successful action.
    *   **Error Handling**: If any abstract tool call fails, capture the error and proceed to Phase 3.
3.  **Execute Validations**: After actions are complete, execute all `validations` using abstract tool calls.
    *   **Abstract Validation Calls**: Map validation commands to abstract tool calls:
        ```bash
        # Lint validation
        ABSTRACT_CALL="npm.run_script(script_name='lint')"
        source .ai_workflow/tools/execute_abstract_tool_call.md
        
        # Test validation
        ABSTRACT_CALL="npm.test()"
        source .ai_workflow/tools/execute_abstract_tool_call.md
        
        # Git status check
        ABSTRACT_CALL="git.status()"
        source .ai_workflow/tools/execute_abstract_tool_call.md
        ```
    *   **Validation Results**: Log validation outcomes and proceed to Phase 3 if any fail.

### Phase 3: Self-Correction Loop
1.  **Log Attempt**: Log the start of the correction attempt: `[INFO] Entering self-correction for Task "[Task Name]". Attempt [Retry Count]/3.`
2.  **Create Rollback Point**: Before attempting any corrections, create a rollback point:
    ```bash
    source .ai_workflow/workflows/common/rollback_changes.md
    create_rollback_point "before_correction_attempt_$RETRY_COUNT"
    ```
3.  **Analyze Failure & Formulate Fix**:
    *   Analyze the logged failure message.
    *   **Correction Strategy**: Formulate a fix that is minimal and targeted using abstract tool calls.
    *   **Prioritize**: Use `file.replace_in_file()` over `file.write()` for minimal changes.
    *   **Abstract Tool Corrections**: Execute corrections using abstract tool calls:
        ```bash
        # Example correction using abstract tools
        ABSTRACT_CALL="file.replace_in_file(path='src/main.js', old_text='const x = 1', new_text='const x = 1;')"
        source .ai_workflow/tools/execute_abstract_tool_call.md
        ```
4.  **Attempt the Fix**: Execute the corrective action using abstract tool calls, logging it meticulously.
5.  **Re-validate**: Re-run the *entire* `validations` block for the current task using abstract tool calls.
6.  **Handle Correction Failure**: If the correction fails, rollback to the previous state:
    ```bash
    source .ai_workflow/workflows/common/rollback_changes.md
    rollback_to_point "before_correction_attempt_$RETRY_COUNT"
    ```
7.  **Handle Unrecoverable Error**: If a task fails validation 3 times, halt execution.
    *   **Final Rollback**: Rollback to the state before the failed task:
        ```bash
        source .ai_workflow/workflows/common/rollback_changes.md
        rollback_to_point "before_task_$(($CURRENT_TASK_INDEX - 1))"
        ```
    *   **Report to User**: Present a structured report:
        *   **Summary**: "Execution failed on Task: '[Task Name]' after 3 correction attempts."
        *   **Error**: "The final validation error was: [Final Error Message]."
        *   **Rollback**: "System has been rolled back to the state before this task."
        *   **Next Steps**: "Please review the log for details: `[path/to/log/file]`. How should I proceed?"

### Phase 4: Final Validation & Completion
1.  **Run Final Checks**: Execute the `validations` from the `Final Validation` section of the PRP using abstract tool calls:
    ```bash
    # Example final validations using abstract tools
    ABSTRACT_CALL="npm.run_script(script_name='lint')"
    source .ai_workflow/tools/execute_abstract_tool_call.md
    
    ABSTRACT_CALL="npm.test()"
    source .ai_workflow/tools/execute_abstract_tool_call.md
    
    ABSTRACT_CALL="git.status()"
    source .ai_workflow/tools/execute_abstract_tool_call.md
    ```
2.  **Execute End-to-End Validation**: Run comprehensive validation workflow:
    ```bash
    source .ai_workflow/workflows/common/validate_prp_execution.md
    ```
3.  **Report Final Outcome**:
    *   **On Success**: 
        ```bash
        echo "PRP execution completed successfully."
        echo "Log file: $LOG_FILE"
        echo "All validations passed using abstract tool system."
        ```
    *   **On Failure**: 
        ```bash
        echo "PRP execution failed during final validation."
        echo "Error: $FINAL_ERROR_MESSAGE"
        echo "Log file: $LOG_FILE"
        echo "Consider reviewing the PRP or project configuration."
        ```

## Abstract Tool Integration Notes

### Supported Abstract Tool Calls in PRP Execution:

#### Git Operations:
- `git.add(file_path="path/to/file")`
- `git.commit(message="commit message")`
- `git.push(remote="origin", branch="main")`
- `git.status()`

#### NPM Operations:
- `npm.install(package="package-name")`
- `npm.run_script(script_name="script-name")`
- `npm.test()`
- `npm.build()`

#### File Operations:
- `file.write(path="path/to/file", content="file content")`
- `file.read(path="path/to/file")`
- `file.replace_in_file(path="path/to/file", old_text="old", new_text="new")`
- `file.delete(path="path/to/file")`

#### HTTP Operations:
- `http.get(url="https://api.example.com")`
- `http.post(url="https://api.example.com", data="{}")`

### Error Handling Integration:
- All abstract tool calls are validated before execution
- Failed tool calls trigger the self-correction loop
- Rollback system preserves state before each operation
- Comprehensive logging tracks all abstract tool executions

### State Management Integration:
- Workflow state is maintained across all abstract tool calls
- Rollback points are created before critical operations
- State persistence ensures recovery from failures
- Progress tracking through state management system