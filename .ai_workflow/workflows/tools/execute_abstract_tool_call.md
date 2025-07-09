# Execute Abstract Tool Call

## Objective
To interpret a semantic, abstract tool call and translate it into a concrete, executable shell command using the appropriate adapter. If an adapter does not exist, trigger its creation.

## Role
You are the core interpreter for the Tool Abstraction Layer. Your job is to parse an abstract tool call, orchestrate the process of converting it into a real command, and handle cases where the tool is not yet defined.

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
        -   Follow the instructions in the adapter to construct the final command string.
        -   Proceed to Step 4.

    -   **If the adapter does NOT exist:**
        -   This tool is not yet implemented. Trigger the self-extension workflow.
        -   **Action:** Call the `/.ai_workflow/workflows/tools/create_new_adapter.md` workflow.
        -   **Inputs for `create_new_adapter.md`:**
            -   `TOOL_NAME`: The tool name you just parsed.
            -   `ACTION_NAME`: The action name you just parsed.
        -   After the adapter is created, stop the current execution and report to the user that the placeholder has been created, instructing them to fill it out before trying again.

4.  **Execute the Concrete Command:**
    -   Use the `run_shell_command` tool to execute the generated command string.

5.  **Handle Output:**
    -   Report the result of the `run_shell_command` execution (stdout, stderr, exit code).
    -   If the command fails, trigger the standard error handling protocol (`/.ai_workflow/workflows/common/error.md`).

## Example (Adapter Found)

**If the input is:** `tool.git.commit(message="feat: initial commit")`

1.  **Parse:** Tool is `git`, action is `commit`, argument is `message="feat: initial commit"`.
2.  **Find Adapter:** Locate `/.ai_workflow/tools/adapters/git_adapter.md`. It exists.
3.  **Consult Adapter:** Read `git_adapter.md` and construct the command: `git commit -m "feat: initial commit"`.
4.  **Execute:** Run `run_shell_command(command='git commit -m "feat: initial commit"')`.
5.  **Report:** Show the output.

## Example (Adapter Not Found)

**If the input is:** `tool.docker.build(tag="my-image")`

1.  **Parse:** Tool is `docker`, action is `build`.
2.  **Find Adapter:** Look for `/.ai_workflow/tools/adapters/docker_adapter.md`. It does not exist.
3.  **Trigger Creation:** Call `create_new_adapter.md` with `TOOL_NAME=docker` and `ACTION_NAME=build`.
4.  **Report:** Inform the user: "The `docker` tool adapter was not found. I have created a placeholder at `/.ai_workflow/tools/adapters/docker_adapter.md`. Please edit this file to define the translation logic for the `build` action and then run your request again."
