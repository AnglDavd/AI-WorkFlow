# AI Project Knowledge Base

This file serves as a persistent memory for the AI agent within this project. It stores common patterns, recurring decisions, solutions to previously encountered problems, and any specific preferences or insights relevant to the project's development.

## How the AI Uses This File:
- **Consultation:** Before making a decision or implementing a common pattern, the AI will consult this file.
- **Learning:** The AI will update this file with new patterns, solutions, or project-specific best practices it discovers.
- **Consistency:** Ensures consistent application of solutions and adherence to project-specific conventions.

## Contents:

### Data Sources and Logs

-   **Token Usage Log:**
    -   **Location:** `/.ai_workflow/work_journal/token_usage.log`
    -   **Purpose:** This file is the historical record of all LLM token consumption for the project.
    -   **Format:** Each line is a separate JSON object representing a single API call.
    -   **Instruction:** When the user asks about token usage or costs, you MUST read and analyze this file to provide a data-driven answer. When asked to optimize for token economy, this file is your primary data source for identifying high-consumption workflows.

### Common Patterns & Solutions:
- [AI to add common code patterns, architectural decisions, or recurring solutions here]

### Project-Specific Conventions:
- **completed_parent_tasks_count:** 0 (AI must increment this after each parent task completion and reset after a review-and-refactor cycle)
- [AI to add project-specific naming conventions, file structures, or coding styles here]

### Recurring Issues & Resolutions:
- [AI to add details about issues encountered and how they were resolved]

### User Preferences:
- [AI to add any specific user preferences or instructions that should be remembered for this project]
