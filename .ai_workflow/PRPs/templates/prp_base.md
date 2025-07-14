name: "Base PRP Template v3.3 - Agnostic with Full Context"
description: |
  Template optimized for AI agents to implement features using an abstract, tool-based engine.
  This version combines abstract execution with comprehensive guidelines and context points from previous versions to ensure high-quality, integrated results.

## Core Principles

1.  **Abstraction**: Define tasks using a universal, tool-based language.
2.  **Atomicity**: Each task should be a small, verifiable unit of work.
3.  **Self-Correction**: Each action is followed by a validation, enabling a robust fix-and-retry loop.
4.  **Holistic Context**: Provide all necessary context, from high-level goals to specific integration points.

---

## Goal

[What needs to be built - be specific about the end state and desires]

## Why

- [Business value and user impact]
- [Integration with existing features]
- [Problems this solves and for whom]

## What

[User-visible behavior and technical requirements]

### Success Criteria

- [ ] [Specific measurable outcomes]

## Context & References

### Documentation & Code Examples

```yaml
# Provide all necessary context for the agent to understand the task.
references:
  - type: url
    path: [Official API docs URL]
    comment: [Specific sections/methods the agent will need]
  - type: file
    path: [path/to/existing_similar_feature.ext]
    comment: [Use this file as a structural and stylistic pattern]
  - type: doc
    content: |
      CRITICAL: Note any important project conventions or library quirks here.
      Example: All public functions must be documented using JSDoc style.
      Example: The project uses dependency injection for all services.
```

### Target File Structure

```yaml
# Describe the desired state of the file system after the PRP is executed.
files:
  - path: "src/models/user.model.ext"
    description: "Contains the data structure for a user."
    status: "new" # or "modified"
  - path: "src/services/user.service.ext"
    description: "Contains the business logic for user management."
    status: "new"
```

## Implementation Guidelines & Quality Checks

**As you generate code, you MUST adhere to these principles:**

-   **Follow Existing Patterns**: Do not invent new coding patterns or styles if a clear precedent exists in the codebase.
-   **Handle Errors Gracefully**: Implement robust error handling. Do not assume the "happy path". Anticipate potential failures.
-   **Be Specific with Errors**: Do not catch generic exceptions. Catch specific errors and handle them appropriately.
-   **Keep Logs Informative**: Logs should be helpful for debugging but not excessively verbose in production.
-   **Manage Configuration**: Do not hardcode values that should be configurable (e.g., API keys, timeouts, feature flags).
-   **Update Documentation**: If your changes affect how a user or developer interacts with the system, ensure relevant documentation is also updated.

**Anti-Patterns to AVOID:**
-   ❌ **Ignoring Tests**: Never ignore or bypass a failing test. Understand the root cause, fix the code, and re-run.
-   ❌ **Skipping Validation**: Do not skip validation steps because you assume the input will be correct.

## Integration Points

```yaml
# Describe necessary changes in other parts of the system.
# This ensures that the new feature is correctly integrated.
integrations:
  - type: "DATABASE"
    description: "Add a 'feature_enabled' boolean column to the 'users' table."
  - type: "CONFIG"
    description: "Add a 'FEATURE_TIMEOUT' variable to the main configuration file, defaulting to 30 seconds."
  - type: "API_ROUTES"
    description: "Register a new '/feature' endpoint in the main API router."
```

## Implementation Plan

### Task List

```yaml
# A sequence of tasks to be executed. The agent will interpret the 'content'
# description and write the appropriate code in the project's language,
# following all the guidelines above.

tasks:
  - name: "Create User Data Model"
    actions:
      - tool: "WRITE_FILE"
        path: "src/models/user.model.ext" # '.ext' should be replaced with the correct extension
        content: |
          Define a 'User' data structure or class.
          It must include the following fields:
          - 'id': An integer, serving as the unique identifier.
          - 'username': A string.
          - 'email': A string, which must be a valid email format.
    validations:
      - tool: "FILE_EXISTS"
        path: "src/models/user.model.ext"
      - tool: "LINT_FILE"
        path: "src/models/user.model.ext"

  # ... other tasks follow the same pattern ...

```

## Final Validation

### Automated Checks

```yaml
# A final, holistic validation checklist to run after all tasks are completed.
validations:
  - tool: "LINT_PROJECT"
  - tool: "RUN_ALL_TESTS"
```

### Manual & Qualitative Checks
- [ ] **Manual Test**: [Describe a simple, manual E2E test. Example: "Send a POST request to the /feature endpoint with a valid payload and expect a 200 OK response."]
- [ ] **Error Case Review**: Have the most likely error cases been handled gracefully?
- [ ] **Logging Review**: Are the logs produced by the new feature informative but not noisy?

---
