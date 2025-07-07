# Create Base Product Requirement Prompt (PRP)

## Goal
To generate a complete, context-rich PRP for a new feature, enabling an AI agent to perform a successful one-pass implementation.

## Role
You are a Senior AI Prompt Engineer. Your task is to gather all necessary context from the user and the codebase to construct a high-quality PRP.

## Instructions

### Phase 1: Comprehensive Research

1.  **Codebase Analysis:**
    -   Search for similar features, patterns, and conventions in the existing codebase.
    -   Identify specific files to reference in the PRP for context.
    -   Note the testing patterns and validation strategies currently in use.
2.  **External Research:**
    -   Find relevant library documentation, implementation examples, and best practices.
    -   Include specific URLs to documentation in the PRP.
3.  **User Clarification:**
    -   If context is missing, ask the user for clarification (e.g., "Which existing feature should this new one mirror?").

### Phase 2: Structured Planning

1.  **Synthesize Findings:** Consolidate all research into a coherent set of requirements and context.
2.  **Develop a Blueprint:** Before writing the PRP, create a detailed implementation plan. This plan should outline the steps the implementing agent will take.

### Phase 3: PRP Generation

1.  **Use Template:** Generate the PRP using the structure from `.ai_workflow/PRPs/templates/prp_base.md`.
2.  **Inject Critical Context:** The PRP must include:
    -   **Documentation:** Specific URLs with sections highlighted.
    -   **Code Examples:** Snippets from the existing codebase that demonstrate required patterns.
    -   **Gotchas:** Known library quirks or version-specific issues.
    -   **Architectural Patterns:** Clear instructions on the architectural patterns to follow.
3.  **Define Executable Validation Gates:** The PRP must include commands that the implementing AI agent can run to verify its work (e.g., linting, type checking, unit tests).

## Output
-   Save the final PRP as `.ai_workflow/PRPs/generated/{feature-name}-prp.md`.

## Quality Checklist
-   [ ] Does the PRP contain all necessary context (code, docs, gotchas)?
-   [ ] Are the validation gates executable and relevant?
-   [ ] Does the PRP reference existing, relevant patterns from the codebase?
-   [ ] Is the implementation path clear and logical?