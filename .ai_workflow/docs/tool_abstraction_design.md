# Tool Abstraction Design

## 1. Purpose

This document defines the set of **abstract tools** that the AI agent will use to execute tasks described in Project-Response-Plans (PRPs). The goal is to decouple the agent from the user's specific environment (shell, language versions, etc.), allowing it to operate autonomously and predictably.

The **PRP Execution Engine** (`01_run_prp.md`) will be responsible for interpreting these abstract tools and translating them into calls to the agent's real, underlying tools (e.g., `write_file`, `run_shell_command`).

## 2. Design Principles

*   **Atomicity:** Each tool performs a single, well-defined action.
*   **Agnosticism:** The tools do not depend on a specific language or framework.
*   **Verifiability:** Actions (e.g., `WRITE_FILE`) should be verifiable by other tools (e.g., `LINT_FILE`).

---

## 3. Abstract Tool Catalog

The following details each tool, its parameters, and its expected mapping.

### Action Tools (Modify State)

---

#### **`WRITE_FILE`**

*   **Description:** Creates a new file or completely overwrites an existing one with the provided content. It is the fundamental tool for generating or updating code and other artifacts.
*   **Parameters:**
    *   `path` (string, required): The absolute or project-root-relative path where the file will be written.
    *   `content` (string, required): The full content to be written to the file.
*   **Mapping to Real Tools:** `write_file(file_path=path, content=content)`
*   **Example Usage (in a PRP):**
    ```yaml
    - tool: "WRITE_FILE"
      path: "src/components/Button.js"
      content: "export default function Button() { return <button>Click Me</button>; }"
    ```

---

#### **`REPLACE_IN_FILE`**

*   **Description:** Searches for a specific block of text (`old_string`) within a file and replaces it with a new block (`new_string`). Ideal for making precise, targeted modifications without rewriting the entire file.
*   **Parameters:**
    *   `path` (string, required): The path to the file to be modified.
    *   `old_string` (string, required): The exact block of text to be replaced (including indentation and newlines).
    *   `new_string` (string, required): The new block of text that will replace the old one.
*   **Mapping to Real Tools:** `replace(file_path=path, old_string=old_string, new_string=new_string)`
*   **Example Usage (in a PRP):**
    ```yaml
    - tool: "REPLACE_IN_FILE"
      path: "config/settings.py"
      old_string: "FEATURE_FLAG_A = False"
      new_string: "FEATURE_FLAG_A = True"
    ```

---

#### **`DELETE_FILE`**

*   **Description:** Permanently deletes a file from the filesystem.
*   **Parameters:**
    *   `path` (string, required): The path to the file to be deleted.
*   **Mapping to Real Tools:** `run_shell_command(command=f"rm {path}")`
*   **Example Usage (in a PRP):**
    ```yaml
    - tool: "DELETE_FILE"
      path: "docs/old_feature.md"
    ```

---

### Validation Tools (Verify State)

**Important Note:** The following validation tools (LINT, TEST, TYPE_CHECK) depend on the Execution Engine having the project-specific commands pre-configured. The engine must detect the project type and use the appropriate commands (e.g., `npm run lint`, `pytest`, `mypy .`, etc.).

---

#### **`FILE_EXISTS`**

*   **Description:** Verifies that a file exists at the specified path. Useful for confirming that a `WRITE_FILE` action was successful.
*   **Parameters:**
    *   `path` (string, required): The path to the file to check.
*   **Mapping to Real Tools:** `run_shell_command(command=f"test -f {path}")`. Success is determined by a 0 exit code.
*   **Example Usage (in a PRP):**
    ```yaml
    validations:
      - tool: "FILE_EXISTS"
        path: "src/components/Button.js"
    ```

---

#### **`LINT_FILE` / `LINT_PROJECT`**

*   **Description:** Runs the project's configured linter on a specific file or the entire project. The tool should only succeed if the linter reports no errors.
*   **Parameters:**
    *   `path` (string, optional): The path to the file to lint. If omitted, it runs on the whole project (`LINT_PROJECT`).
*   **Mapping to Real Tools:** `run_shell_command(command=LINT_COMMAND)` where `LINT_COMMAND` is a pre-configured variable in the engine (e.g., `ruff check .` or `eslint . --fix`).
*   **Example Usage (in a PRP):**
    ```yaml
    validations:
      - tool: "LINT_FILE"
        path: "src/app.js"
    ```

---

#### **`RUN_TESTS` / `RUN_ALL_TESTS`**

*   **Description:** Runs the test suite on a specific test file or the entire project. The tool should only succeed if all tests pass.
*   **Parameters:**
    *   `path` (string, optional): The path to the test file to run. If omitted, all tests are run (`RUN_ALL_TESTS`).
*   **Mapping to Real Tools:** `run_shell_command(command=TEST_COMMAND)` where `TEST_COMMAND` is a pre-configured variable in the engine (e.g., `pytest` or `npm test`).
*   **Example Usage (in a PRP):**
    ```yaml
    validations:
      - tool: "RUN_TESTS"
        path: "tests/test_logic.py"
    ```

---

#### **`RUN_TYPE_CHECK`**

*   **Description:** Runs the project's static type checker (e.g., Mypy, TypeScript Compiler). The tool should only succeed if there are no type errors.
*   **Parameters:**
    *   `path` (string, optional): The path to check. If omitted, the entire project is checked.
*   **Mapping to Real Tools:** `run_shell_command(command=TYPE_CHECK_COMMAND)` where `TYPE_CHECK_COMMAND` is a pre-configured variable (e.g., `mypy .` or `tsc --noEmit`).
*   **Example Usage (in a PRP):**
    ```yaml
    validations:
      - tool: "RUN_TYPE_CHECK"
        path: "src/services/api.ts"
    ```

---

#### **`HTTP_REQUEST`**

*   **Description:** Performs an HTTP request. This is an advanced tool, useful for integration tests or for interacting with external APIs as part of a task.
*   **Parameters:**
    *   `method` (string, required): The HTTP method (e.g., `GET`, `POST`, `PUT`).
    *   `url` (string, required): The URL to which the request will be made.
    *   `headers` (dict, optional): A dictionary of HTTP headers.
    *   `body` (string/dict, optional): The body of the request.
*   **Mapping to Real Tools:** `run_shell_command` using `curl`. The engine must build the `curl` command from the parameters.
*   **Example Usage (in a PRP):**
    ```yaml
    validations:
      - tool: "HTTP_REQUEST"
        method: "POST"
        url: "http://localhost:8080/api/users"
        body:
          username: "testuser"
    ```
