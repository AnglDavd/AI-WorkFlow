# Tool Abstraction Layer Design Document

## 1. Introduction

This document outlines the design for a conceptual Tool Abstraction Layer within the Dynamic Project Manager (DPM) framework. Currently, workflow nodes (`.md` files) directly embed shell commands. While transparent, this approach can be brittle, less portable, and harder for AI agents to interpret semantically.

This abstraction layer aims to introduce a more robust and intelligent way for prompts to request actions from underlying command-line tools.

## 2. Goals of the Abstraction Layer

-   **Improve Prompt Portability:** Allow prompts to function correctly across different operating systems, shell environments, or tool versions without modification.
-   **Reduce Reliance on Specific Bash Syntax:** Abstract away complex shell piping, quoting, and conditional logic from the prompts.
-   **Enable Semantic Requests:** Allow prompts to request actions in a more human-readable and semantic way (e.g., "add all files to git" instead of `git add .`).
-   **Facilitate Adaptation:** Make it easier to adapt to new versions of tools or swap out underlying tools (e.g., `npm` for `yarn`) by only updating the adapter.
-   **Enhance Agent Understanding:** Provide the agent with a higher-level understanding of the intended action, rather than just a raw command string.

## 3. Core Concepts

-   **Abstract Tool Call:** A standardized, semantic representation of an action to be performed by a tool. This is what would be written in the `.md` files.
-   **Tool Adapter:** A conceptual component (executed by the agent's internal logic) responsible for translating an Abstract Tool Call into one or more concrete shell commands that can be executed by `run_shell_command`.
-   **Tool Registry:** An internal mapping within the agent that associates abstract tool names/actions with their corresponding Tool Adapters.

## 4. Proposed Syntax in `.md` Files

To differentiate abstract tool calls from direct shell commands, a new Markdown code block type or a special comment syntax could be used. For this proposal, we'll use a `tool_call` block:

```tool_call
tool.git.add_all()
tool.npm.install(package="react", dev=true)
tool.fs.read_file(path="./src/index.js")
```

## 5. Agent's Interpretation and Execution Flow

1.  **Agent Reads `.md`:** The agent parses the workflow node (`.md` file).
2.  **Identify `tool_call` Blocks:** The agent recognizes blocks marked with `tool_call`.
3.  **Parse Abstract Tool Call:** For each line within the `tool_call` block, the agent parses the abstract call (e.g., `tool.git.add_all()`).
4.  **Lookup Adapter:** The agent consults its internal Tool Registry to find the appropriate Tool Adapter (e.g., the `git` adapter for `tool.git`).
5.  **Generate Concrete Command:** The Tool Adapter's method (e.g., `add_all()`) generates the concrete, environment-specific shell command (e.g., `git add .`).
6.  **Execute Command:** The agent executes the concrete shell command using the `run_shell_command` tool.
7.  **Handle Output/Errors:** The agent processes the output and exit code, and handles errors as per the framework's error handling protocol.

## 6. Example Tool Adapters (Conceptual)

### Git Adapter
-   `tool.git.add_all()` -> `git add .`
-   `tool.git.commit(message="...")` -> `git commit -m "..."`
-   `tool.git.checkout_branch(name="...")` -> `git checkout -b "..."`
-   `tool.git.pull(remote="origin", branch="main")` -> `git pull origin main`

### NPM Adapter
-   `tool.npm.install(package="...", dev=false)` -> `npm install <package>` or `npm install -D <package>`
-   `tool.npm.run_script(script_name="...")` -> `npm run <script_name>`
-   `tool.npm.test(coverage=true)` -> `npm test -- --coverage`

### FS (Filesystem) Adapter
-   `tool.fs.read_file(path="...")` -> `cat <path>` (or use `read_file` tool directly)
-   `tool.fs.write_file(path="...", content="...")` -> `echo "..." > <path>` (or use `write_file` tool directly)
-   `tool.fs.create_directory(path="...")` -> `mkdir -p <path>`

## 7. Benefits

-   **Enhanced Portability:** Changes in underlying tool syntax only require updating the adapter, not every `.md` file.
-   **Improved Readability:** Prompts become more semantic and easier for humans to understand at a glance.
-   **Centralized Error Handling:** Adapters can encapsulate tool-specific error patterns, leading to more robust error reporting.
-   **Increased Flexibility:** Easier to swap out tools (e.g., `npm` for `yarn`, `git` for `hg`) with minimal impact on prompts.
-   **Reduced Prompt Complexity:** Prompts can focus on *what* to do, not *how* to do it in specific shell syntax.

## 8. Challenges/Considerations

-   **Initial Development Effort:** Building a comprehensive set of adapters requires significant upfront work.
-   **Argument Mapping:** Designing a flexible way to map abstract arguments to concrete command-line flags and options.
-   **Performance Overhead:** While likely minimal, there's a slight overhead in the interpretation layer.
-   **Maintaining Registry:** The agent's internal Tool Registry needs to be kept up-to-date.

## 9. Future Work

-   Implement a prototype of a few key adapters (e.g., for Git and NPM).
-   Integrate the parsing of `tool_call` blocks into the agent's core workflow execution logic.
-   Define a formal schema (e.g., JSON Schema) for abstract tool calls to ensure consistency.
