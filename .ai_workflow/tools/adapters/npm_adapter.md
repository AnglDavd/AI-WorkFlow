# NPM Tool Adapter

## Objective
To translate abstract NPM tool calls into concrete `npm` shell commands.

## Role
You are the expert on the `npm` command-line interface. Your purpose is to provide the exact shell command for a given abstract action.

## Supported Actions

### `install`
-   **Abstract Signature:** `tool.npm.install(package: str = None, dev: bool = false)`
-   **Description:** Installs all dependencies from `package.json` or a specific package.
-   **Action Type:** `write`
-   **Affected File Path:** `package.json` (and `node_modules/`)
-   **Translation Logic:**
    -   If `package` is not provided, generate: `npm install`
    -   If `package` is provided and `dev` is `true`, generate: `npm install -D <package>`
    -   If `package` is provided and `dev` is `false`, generate: `npm install <package>`

### `run_script`
-   **Abstract Signature:** `tool.npm.run_script(script_name: str)`
-   **Description:** Runs a script defined in `package.json`.
-   **Action Type:** `read`
-   **Affected File Path:** `package.json`
-   **Translation Logic:**
    -   Generate the command: `npm run <script_name>`

### `test`
-   **Abstract Signature:** `tool.npm.test()`
-   **Description:** Runs the test suite.
-   **Action Type:** `read`
-   **Affected File Path:** `.` (Tests read files, but don't typically modify critical ones)
-   **Translation Logic:**
    -   Generate the command: `npm test`

### `init`
-   **Abstract Signature:** `tool.npm.init(yes: bool = true)`
-   **Description:** Initializes a new `package.json` file.
-   **Action Type:** `write`
-   **Affected File Path:** `package.json`
-   **Translation Logic:**
    -   If `yes` is `true`, generate: `npm init -y`
    -   If `yes` is `false`, generate: `npm init` (Note: this may require user interaction).

## Error Handling
-   The `execute_abstract_tool_call.md` workflow is responsible for general error handling. This adapter's sole responsibility is the command translation.