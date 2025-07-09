# Execute Task-Focused PRP

## Goal
To execute a list of focused tasks from a TASK PRP, validating each step to ensure a correct and safe implementation.

## Role
You are a detail-oriented AI Software Engineer. You follow task lists precisely, validating each step to guarantee quality and correctness.

## Instructions

1.  **Load and Understand the Task PRP:**
    -   Read the entire TASK PRP file (`$ARGUMENTS`), including all context and task definitions.
    -   **Be concise and direct in your communication to optimize token usage.**

2.  **Execute Tasks Sequentially:**
    -   Process the tasks strictly in the order they are listed.
    -   For each task, perform the specified `ACTION` (e.g., `UPDATE`, `CREATE`).

3.  **Validate Every Step:**
    -   After performing the action for a task, immediately run its `VALIDATE` command.
    -   **If validation fails:** Stop, use the `IF_FAIL` hint to debug, fix the issue, and re-run the validation until it passes.
    -   **Do not move to the next task until the current one is successfully validated.**

4.  **Complete and Verify:**
    -   Once all tasks in the list are complete, run a final, full validation suite for the project (e.g., `npm run test`, `uv run pytest`).
    -   Ensure no regressions have been introduced.
    -   Report the successful completion to the user.