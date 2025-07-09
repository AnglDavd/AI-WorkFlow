# Tool Abstraction Layer

This directory contains the components for the framework's Tool Abstraction Layer.

## How it Works

The goal of this layer is to allow workflows to use tools like `git` and `npm` without writing raw shell commands. This makes the workflows more portable and easier to read.

The execution flow is as follows:

1.  A workflow uses a `tool_call` block to specify an abstract action (e.g., `tool.git.add_all()`).
2.  This action is passed to the main interpreter: `/.ai_workflow/workflows/tools/execute_abstract_tool_call.md`.
3.  The interpreter parses the call and identifies the tool (e.g., `git`).
4.  It then consults the appropriate adapter in the `adapters/` directory (e.g., `adapters/git_adapter.md`).
5.  The adapter provides the concrete shell command to execute.
6.  The interpreter runs the command.

## How to Add a New Adapter

1.  **Create a New Adapter File:**
    -   Create a new `.md` file in the `adapters/` directory (e.g., `my_tool_adapter.md`).

2.  **Define the Actions:**
    -   For each abstract action you want to support (e.g., `tool.my_tool.do_something()`), create a section in your adapter file.
    -   For each action, specify the `Abstract Signature` and the `Translation Logic` that generates the final shell command.

3.  **Update the Interpreter (if necessary):**
    -   The core interpreter (`execute_abstract_tool_call.md`) is designed to be generic. However, if your new tool requires very complex logic, you might need to update the interpreter's prompt.

4.  **Use it in a Workflow:**
    -   You can now use your new abstract tool calls in any workflow.
