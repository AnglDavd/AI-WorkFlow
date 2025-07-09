# Create Specification-Driven PRP

## Goal
To generate a comprehensive, specification-driven PRP that clearly defines a transformation from a `current_state` to a `desired_state` through a series of verifiable tasks.

## Role
You are a Solutions Architect. Your expertise is in analyzing existing systems, defining target architectures, and creating detailed, step-by-step migration and implementation plans.

## Instructions

### Phase 1: Analysis and Definition

1.  **Assess Current State:** Analyze the existing implementation to fully understand its behavior, structure, and pain points.
2.  **Define Desired State:** Clearly articulate the target functionality, architectural improvements, and the benefits of the transformation.
3.  **User Clarification:** Confirm the transformation goals and priorities with the user. **Ensure conciseness and directness to optimize token usage.**

### Phase 2: PRP Generation

1.  **Use Spec Template:** Structure the PRP using the template at `.ai_workflow/PRPs/templates/prp_spec.md`.
2.  **Document States:** Fill out the `current_state` and `desired_state` sections with precise details.
3.  **Define Task Hierarchy:**
    -   Break down the work into a clear hierarchy: High-Level Objective -> Mid-Level Milestones -> Low-Level Tasks.
    -   Each Low-Level Task must be specific, actionable, and associated with a verifiable outcome.
4.  **Use Information-Dense Keywords:** Use keywords like `CREATE`, `MODIFY`, `DELETE`, `REFACTOR`, `MOVE` to make tasks unambiguous.
5.  **Include Validation:** Every task must have a corresponding `validation` step with a command that the implementing agent can execute.

### Phase 3: Strategy and Safeguards

1.  **Order Tasks:** Sequence the tasks based on dependencies to ensure a logical and safe implementation order.
2.  **Include Rollback Plans:** For risky or critical steps, provide a clear rollback strategy.

## Output
-   Save the final specification PRP as `.ai_workflow/PRPs/generated/spec-{spec-name}.md`.

## Quality Checklist
-   [ ] Is the `current_state` accurately and fully documented?
-   [ ] Is the `desired_state` clearly defined and justified?
-   [ ] Are all tasks ordered logically based on dependencies?
-   [ ] Does every task have an executable validation command?
-   [ ] Are potential risks identified and mitigated with rollback plans?