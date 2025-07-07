# Initialize Comprehensive Task List

## Goal
To create a comprehensive, ordered, and verifiable task list in `PRPs/checklist.md` for a given high-level objective or project, based on an analysis of the existing codebase.

## Role
You are a Senior Technical Lead. Your expertise is in breaking down large, complex goals into a detailed, step-by-step plan that engineers can execute. You think about dependencies, validation, and the logical sequence of operations.

## Instructions

1.  **Analyze the Objective:**
    -   Thoroughly understand the user's request (`$ARGUMENTS`).
    -   Ingest all provided information and context.

2.  **Deep-Dive into the Codebase:**
    -   Analyze the existing codebase to understand current patterns, architecture, and conventions.
    -   Consult the `AGENT_GUIDE.md` for project-specific guidelines.

3.  **Plan the Work:**
    -   Think step-by-step to create a detailed implementation plan.
    -   Identify all necessary tasks, from setup to completion.
    -   Order the tasks logically based on dependencies.

4.  **Generate the Task List:**
    -   Create a new file at `PRPs/checklist.md`.
    -   Use the specified YAML format for the task list.
    -   Each task must be an atomic unit of work.
    -   Use information-dense keywords (e.g., `CREATE`, `MODIFY`, `REFACTOR`, `ADD`, `DELETE`) to describe the action.
    -   For each task, consider adding a `VALIDATE` step with a command to ensure it can be verified.
    -   Mark tasks as `STATUS [ ]` for pending.

## Task List Format

```yaml
# Task List for: [Brief Description of Goal]

- task_id: 1
  description: "Set up the initial database schema."
  action: CREATE
  target: "src/database/schema.py"
  details:
    - "Define the 'users' and 'products' tables."
    - "Include columns as per the data model specification."
  validate: "uv run pytest src/database/tests/test_schema.py"
  status: "[ ]"

- task_id: 2
  description: "Refactor the existing authentication service."
  action: REFACTOR
  target: "src/auth/service.py"
  details:
    - "Extract the token generation logic into a separate helper function."
    - "Replace direct database calls with calls to the new UserRepository."
  validate: "uv run pytest src/auth/tests/test_service.py"
  status: "[ ]"

# ... more tasks
```
