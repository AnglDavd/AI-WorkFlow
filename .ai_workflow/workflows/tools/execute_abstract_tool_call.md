# Execute Abstract Tool Call

## Objective
To interpret a semantic, abstract tool call and translate it into a concrete, executable shell command using the appropriate adapter. If an adapter does not exist, trigger its creation. If the action modifies a critical file, request user confirmation.

## Role
You are the core interpreter for the Tool Abstraction Layer. Your job is to parse an abstract tool call, orchestrate the process of converting it into a real command, handle cases where the tool is not yet defined, and ensure critical file modifications are approved by the user.

## Input
- A single line representing an abstract tool call (e.g., `tool.git.add_all()`).

## Execution Flow

1.  **Parse the Input:**
    -   Identify the tool name (e.g., `git`).
    -   Identify the action (e.g., `add_all`).
    -   Identify any arguments (e.g., `message="feat: new feature"`).

2.  **Find the Adapter:**
    -   Based on the tool name, construct the path to the corresponding adapter file: `/.ai_workflow/tools/adapters/<tool_name>_adapter.md`.
    -   **Check if the adapter file exists.**

3.  **Handle Adapter Presence or Absence:**

    -   **If the adapter exists:**
        -   Read the adapter file. The adapter contains the logic for translating the abstract action and its arguments into a concrete shell command.
        -   **Extract Action Type and Affected File Path:** From the adapter's definition for the specific action, identify its `Action Type` (e.g., `read`, `write`) and `Affected File Path` (e.g., `package.json`, `.` for current directory, or a specific argument value like `<file_path>`).
        -   **Construct the Concrete Command:** Follow the instructions in the adapter to construct the final command string.
        -   Proceed to Step 4.

    -   **If the adapter does NOT exist:**
        -   This tool is not yet implemented. Trigger the self-extension workflow.
        -   **Action:** Call the `/.ai_workflow/workflows/tools/create_new_adapter.md` workflow.
        -   **Inputs for `create_new_adapter.md`:**
            -   `TOOL_NAME`: The tool name you just parsed.
            -   `ACTION_NAME`: The action name you just parsed.
        -   After the adapter is created, stop the current execution and report to the user that the placeholder has been created, instructing them to fill it out before trying again.

4.  **Critical File Confirmation (if applicable):**
    -   **Read Critical File Patterns:** Read the `Critical File Patterns` section from `/.ai_workflow/_ai_knowledge.md`.
    -   **Check for Criticality:** If the `Action Type` is `write` AND the `Affected File Path` (after resolving any argument placeholders like `<file_path>`) matches any of the `Critical File Patterns`:
        -   **Action:** Call the `/.ai_workflow/workflows/common/confirm_file_change.md` workflow.
        -   **Inputs for `confirm_file_change.md`:**
            -   `FILE_PATH`: The resolved `Affected File Path`.
            -   `PROPOSED_CONTENT_DIFF`: (Optional, if available from the adapter's logic for this action) A diff of the proposed change.
        -   **Await User Decision:** Wait for the user's approval.
        -   **If User Disapproves:** Stop execution and report that the change was cancelled.

5.  **Execute the Concrete Command:**
    -   Use the `run_shell_command` tool to execute the generated command string.

6.  **Handle Output:**
    -   Report the result of the `run_shell_command` execution (stdout, stderr, exit code).
    -   If the command fails, trigger the standard error handling protocol (`/.ai_workflow/workflows/common/error.md`).

## Example (Adapter Found & Critical File)

**If the input is:** `tool.git.commit(message="feat: initial commit")`

1.  **Parse:** Tool is `git`, action is `commit`, argument is `message="feat: initial commit"`.
2.  **Find Adapter:** Locate `/.ai_workflow/tools/adapters/git_adapter.md`. It exists.
3.  **Consult Adapter:** Read `git_adapter.md`. `Action Type` is `write`, `Affected File Path` is `.`. Construct command: `git commit -m "feat: initial commit"`.
4.  **Critical File Confirmation:** `.` matches `src/**` (as it affects source files). Call `confirm_file_change.md` with `FILE_PATH=.` (and potentially a diff if `git diff --staged` can be run and passed).
5.  **Execute (if approved):** Run `run_shell_command(command='git commit -m "feat: initial commit"')`.
6.  **Report:** Show the output.