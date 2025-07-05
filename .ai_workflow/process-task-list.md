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
    b. **Run Relevant Tests:** Execute unit or integration tests directly related to the changes.
    c. **If Tests Fail:** Immediately trigger the **Error Handling Protocol (Section 2)**.
    d. **If Tests Pass:**
        i.  **Stage Changes:** `git add .`
        ii. **Make an Atomic Commit:** Use a clear, concise message describing the completed sub-task.
            ```bash
            git commit -m "feat(login): implement password validation (sub-task 2.1)"
            ```
        iii. **Update the task file** to persist the `[x]` status.

### 1.3. Parent Task Completion Protocol
1.  When **all** sub-tasks under a parent task are marked `[x]`:
    a. **Run the Full Test Suite:** Execute the project's entire test suite (`pytest`, `npm test`, etc.) as a final verification.
    b. **If Any Test Fails:** Trigger the **Error Handling Protocol (Section 2)**.
    c. **If All Tests Pass:** Mark the **parent task** as completed `[x]`.
    d. **Notify User:** "Parent task 2.0 completed and verified. Moving to the next task."

---

## 2. Error & Failure Protocol

### 2.1. Test Failure
If any test (unit or full suite) fails:
1.  **Stop immediately.**
2.  **Revert Changes:** `git reset --hard HEAD` to maintain a stable codebase.
3.  **Report the Error:** Inform the user, including the test output log.
4.  **Await new instructions.**

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
