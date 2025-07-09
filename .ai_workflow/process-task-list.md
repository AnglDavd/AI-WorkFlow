# AI Agent Task Execution Guide

This document outlines the rules and protocols for an AI agent to process a Markdown-based task list, ensuring a controlled, safe, and verifiable development workflow.

## Definition of Ready
Before starting work, ensure the following conditions are met:
- [ ] A PRD file has been generated and is linked in the project file.
- [ ] A task list file has been generated from the PRD and is linked.
- [ ] The project environment is set up (dependencies installed, etc.).
- [ ] The user has confirmed which task to start with.

## Core Principles
- **One Sub-task at a Time:** Do not start the next sub-task until you receive explicit approval from the user.
- **Zero Secrets in Code (CRITICAL):** Never write secrets (API keys, passwords, tokens) directly in code. Use environment variables via a `.env` file, and ensure `.env` is listed in `.gitignore`.
- **Utilize Project Knowledge Base:** Regularly consult and update `.ai_workflow/_ai_knowledge.md` for common patterns, project-specific conventions, and recurring issues/resolutions.
- **Token Efficiency:** Be mindful of token usage. Prioritize concise communication and only include necessary context. Summarize large outputs when appropriate.
- **Adhere to Global Rules:** Always consult `.ai_workflow/GLOBAL_AI_RULES.md` for overarching guidelines on behavior and project conventions.

---

## 1. Task Implementation Workflow

### 1.1. Sub-task Execution
1.  **Identify the next pending sub-task** in the list.
2.  Implement the code or perform the necessary actions to complete it.
3.  Upon completion, **stop** and follow the completion protocol.

### 1.2. Sub-task Completion Protocol
Immediately after completing a sub-task, follow these steps in order:

1.  **Report to User:** Notify the user with a brief, clear summary of the changes.
    - **Example:** "Sub-task 2.1 completed. I have modified `auth.py` to add password validation. Shall I proceed?"
2.  **Await Approval:** Wait for the user's go-ahead.
3.  **Upon Approval:**
    a. **Mark as Completed:** Change the sub-task's status from `[ ]` to `[x]`.
    b. **Run Relevant Tests:** Execute unit or integration tests directly related to the changes. **To find the correct command, consult the project-specific stack guide (e.g., `CLAUDE-NODE.md`) identified in the PRD.**
    c. **If Tests Fail:** Immediately trigger the **Error Handling Protocol (Section 2)**.
    d. **If Tests Pass:**
        i.  **Run Relevant Tests (Pre-Commit):** Execute unit or integration tests directly related to the changes. **To find the correct command, consult the project-specific stack guide (e.g., `CLAUDE-NODE.md`) identified in the PRD.**
        ii. **If Pre-Commit Tests Fail:** Immediately trigger the **Error Handling Protocol (Section 2)**.
        iii. **If Pre-Commit Tests Pass:**
            1.  **Stage Changes:** `git add .`
            2.  **Make an Atomic Commit:** Use a clear, concise message describing the completed sub-task.
                ```bash
                git commit -m "feat(login): implement password validation (sub-task 2.1)"
                ```
            3.  **Run Relevant Tests (Post-Commit):** Execute the same tests again to confirm stability after commit.
            4.  **If Post-Commit Tests Fail:** Immediately trigger the **Error Handling Protocol (Section 2)**.
            5.  **If Post-Commit Tests Pass:**
                a. **Update the task file** to persist the `[x]` status.

### 1.3. Parent Task Completion Protocol
1.  When **all** sub-tasks under a parent task are marked `[x]`:
    a. **Run the Full Test Suite:** Execute the project's entire test suite (`pytest`, `npm test`, etc.) as a final verification.
    b. **If Any Test Fails:** Trigger the **Error Handling Protocol (Section 2)**.
    c. **If All Tests Pass:** Mark the **parent task** as completed `[x]`.
    d. **Notify User:** "Parent task 2.0 completed and verified. Moving to the next task."
    e. **Post-Completion Suggestions:**
        i. Read `_ai_knowledge.md` to get `completed_parent_tasks_count`.
        ii. Increment `completed_parent_tasks_count`.
        iii. **Automated Token Economy Review (New):**
            - **Threshold:** 5 (This is configurable. You can change this number.)
            - Check if `completed_parent_tasks_count` is a multiple of the **Threshold**.
            - If it is, automatically trigger the token economy review cycle:
                - **Notify User:** "I have completed 5 parent tasks. To ensure continued efficiency, I will now automatically run a token economy review."
                - **Execute Review:** Read and execute the workflow at `/.ai_workflow/commands/code-quality/review-token-economy.md`.
                - **Present Report:** Show the generated optimization report to the user.
                - **Reset Counter:** After the review, reset `completed_parent_tasks_count` to 0 in `_ai_knowledge.md`.
        iv. **Refactoring Cycle Suggestion:**
            - **Threshold:** 3 (This is configurable.)
            - If `completed_parent_tasks_count` is a multiple of this **Threshold**, suggest a refactoring cycle:
                > "I have completed `completed_parent_tasks_count` parent tasks. This might be a good time to run a code review and refactoring cycle using `review-and-refactor.md`. Would you like to proceed with that now, or should I continue with the next development task?"
            - If the user agrees to refactor, reset `completed_parent_tasks_count` to 0 in `_ai_knowledge.md` after the refactoring cycle is complete.
        v. **Framework Feedback Suggestion:** Regardless of the other cycles, always offer the user to provide feedback on the framework itself:
            > "Would you like to provide feedback on the framework's performance or suggest improvements? I can help generate a GitHub issue for the main repository. This issue will ONLY contain feedback related to the framework, NOT your project's code or sensitive data."
            If the user agrees, instruct the user to provide general feedback (e.g., "The prompt for task X was unclear", "The validation step was slow"). Then, generate a prompt for the `FRAMEWORK_ASSISTANT` to create the `gh issue create` command with this general feedback.

    f. **Update Progress Report:** After completing any sub-task or parent task, update the `progress_report.md` file. This includes:
        i. Reading the current task list to count total, completed, and pending tasks.
        ii. Updating the progress bar (e.g., `[▓▓▓▓▓░░░░░] 50%`).
        iii. Listing the current task in progress.
        iv. Listing all pending and completed tasks.
    g. **Check for Project Completion & Feedback Generation:**
        i. Read the `Status` from `_project.md`.
        ii. If `Status` is `Completed` and `feedback_summary.md` does not exist, then:
            - Inform the user: "Project marked as Completed. Generating final framework feedback report using `feedback_prompt.md`."
            - Execute the instructions in `feedback_prompt.md` to generate `feedback_summary.md`.

---

## 2. Error & Failure Protocol

### 2.1. Test Failure Protocol (Resilient)
If any test (unit or full suite) fails:
1.  **Diagnose the Failure:**
    -   Analyze the test output log for error messages, stack traces, and hints.
    -   Identify the type of failure (e.g., syntax error, assertion failure, dependency issue, integration problem).
2.  **Attempt Auto-Correction (Limited):**
    -   **Attempt 1 (Syntax/Linting):** If the error suggests a syntax or linting issue, try running the project's linter/formatter (`ruff check --fix`, `npm run lint --fix`) on the modified files.
    -   **Attempt 2 (Dependency/Setup):** If the error suggests a missing dependency or environment issue, try running the project's dependency installation command (`uv sync`, `npm install`).
    -   **Re-run Tests:** After each auto-correction attempt, re-run the relevant tests. If they pass, proceed to step 3.
3.  **Escalate Intelligently (If Auto-Correction Fails):**
    -   If tests still fail after auto-correction attempts, do NOT stop immediately.
    -   **Report the Error:** Inform the user about the test failure, including:
        -   The original error message and relevant parts of the log.
        -   What auto-correction attempts were made and why they failed.
        -   Your current hypothesis about the root cause.
    -   **Offer Options to User:** Present clear options for how to proceed:
        -   "a) Provide more context or a specific debugging hint to help me fix it."
        -   "b) Create a new debugging task in `PRPs/checklist.md` for this issue, revert the current changes, and proceed with the next main task."
        -   "c) Revert the current changes and stop development at this point."
    -   **Await User Decision:** Wait for the user's explicit instruction.
    -   **If User Chooses (b):**
        -   **Create Debug Task:** Generate a new task in `PRPs/checklist.md` with a clear description of the bug, its symptoms, and the failed test output.
        -   **Revert Changes:** `git reset --hard HEAD` to maintain a stable codebase.
        -   **Proceed:** Continue with the next main task in the `PRPs/checklist.md`.
    -   **If User Chooses (c):**
        -   **Revert Changes:** `git reset --hard HEAD`.
        -   **Stop.****

### 2.2. Setup & Configuration Failure
If any environment setup command fails (e.g., `npm install`, `docker-compose up`):
1.  **Stop immediately.**
2.  **Report the Failure:** Inform the user, providing the full error log from the failed command.
3.  **Suggest a Solution:** If possible, suggest a potential cause or fix (e.g., "This could be a network issue or a dependency conflict.").
4.  **Await new instructions.**

---

## 3. Blocker and Ambiguity Protocol
If you cannot complete a sub-task due to missing information, ambiguity, or a technical obstacle:

1.  **Stop.** Do not guess or make assumptions.
2.  **Request Assistance:** Clearly inform the user about the blocker.
3.  **Propose Solutions:** Offer specific alternatives or questions to resolve the issue.
    - **Example:** "I am blocked on sub-task 3.2. The external API is not responding as documented. I can: a) Implement a temporary mock to proceed and log this as technical debt, b) Spend time investigating the API documentation further, or c) I may need valid credentials from you. How should I proceed?"
4.  **Await the user's decision.**

---

## 4. Dynamic Task Management

### 4.1. Discovering New Tasks
- If you discover that a necessary task is missing from the list:
  1. **Do not implement it.**
  2. **Add it to the list** in the appropriate section with a `[proposed]` tag.
     - `[ ] [proposed] - Add error logging for the new API endpoint.`
  3. **Inform the User:** "I've identified a necessary new task and have added it to the list as a proposal for your review. I will now continue with the current task."

### 4.2. List Maintenance
- **Keep the "Relevant Files" section updated** with every file you create or modify, including a brief description of its purpose.