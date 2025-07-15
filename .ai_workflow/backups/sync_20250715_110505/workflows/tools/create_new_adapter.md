# Create New Tool Adapter

## Objective
To dynamically create a placeholder for a new, undefined Tool Adapter, making the system self-extending.

## Role
You are a framework engineer. When a workflow tries to use a tool that doesn't have an adapter yet, your job is to create a boilerplate file for that new adapter so a developer can easily implement it.

## Input
-   `TOOL_NAME`: The name of the new tool to create an adapter for (e.g., `docker`).
-   `ACTION_NAME`: The name of the action that was attempted (e.g., `build`).

## Execution Flow

1.  **Define File Path:**
    -   Construct the path for the new adapter file: `/.ai_workflow/tools/adapters/<TOOL_NAME>_adapter.md`.

2.  **Check for Existence:**
    -   Verify that the file does not already exist to prevent accidental overwrites.

3.  **Create Boilerplate Content:**
    -   Generate the content for the new adapter file. The content should be a pre-filled template that includes a placeholder for the action that was originally attempted.

4.  **Write the New File:**
    -   Use the `write_file` tool to create the new adapter file with the boilerplate content.

5.  **Report to User:**
    -   Inform the user that the tool was not found, but a placeholder adapter has been created at the specified path.
    -   Instruct the user to edit the new file to add the correct command translation logic.

## Boilerplate Template

Use the following template for the new file's content, replacing `<TOOL_NAME>` and `<ACTION_NAME>` with the input variables:

```markdown
# <TOOL_NAME> Tool Adapter

## Objective
To translate abstract <TOOL_NAME> tool calls into concrete `<TOOL_NAME>` shell commands.

## Role
You are the expert on the `<TOOL_NAME>` command-line interface. Your purpose is to provide the exact shell command for a given abstract action.

## Supported Actions

### `<ACTION_NAME>`
-   **Abstract Signature:** `tool.<TOOL_NAME>.<ACTION_NAME>(...)`
-   **Description:** [Please add a description for this action]
-   **Translation Logic:**
    -   **[IMPLEMENTATION NEEDED]**
    -   Generate the command: `...`

## Error Handling
-   The `execute_abstract_tool_call.md` workflow is responsible for general error handling. This adapter's sole responsibility is the command translation.
```
