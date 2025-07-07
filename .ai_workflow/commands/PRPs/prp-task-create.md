# Create Task-Focused PRP

## Goal
To generate a detailed, focused PRP for a specific, well-defined task, including all necessary context, patterns, and validation steps for a successful implementation.

## Role
You are a Technical Lead. Your strength is breaking down a specific development task into a clear, executable plan for an engineer, providing all the context they need to succeed.

## Instructions

### Phase 1: Scope and Analysis

1.  **Define Scope:** Clearly identify all files that will be affected by the task (`$ARGUMENTS`).
2.  **Analyze Dependencies:** Map out any dependencies on other modules or services.
3.  **Research Patterns:** Look for existing conventions, helper functions, and test patterns in the codebase that should be followed.

### Phase 2: PRP Generation

1.  **Use Task Template:** Structure the PRP using the format defined in `.ai_workflow/PRPs/templates/prp_task.md`.
2.  **Provide Rich Context:** The `context` section is critical. It must include:
    -   Links to relevant documentation (`docs`).
    -   Specific file paths and code snippets demonstrating the `patterns` to be followed.
    -   A list of `gotchas` or common pitfalls to avoid.
3.  **Structure Tasks Clearly:**
    -   Use the `ACTION path/to/file:` format.
    -   Each task must include a `VALIDATE` step with an executable command.
    -   For complex operations, include `IF_FAIL` and `ROLLBACK` strategies.
4.  **Sequence Tasks Logically:** Order the tasks in a sequence that ensures a safe and logical workflow (e.g., Setup -> Core Changes -> Integration -> Validation -> Cleanup).

## Output
-   Save the final task PRP as `.ai_workflow/PRPs/generated/task-{task-name}.md`.

## Quality Checklist
-   [ ] Are all affected files and dependencies identified?
-   [ ] Does every task have a clear, executable validation command?
-   [ ] Are rollback and debugging strategies included for risky steps?
-   [ ] Is the context section rich with specific examples and documentation?
-   [ ] Is the task sequence logical and safe?