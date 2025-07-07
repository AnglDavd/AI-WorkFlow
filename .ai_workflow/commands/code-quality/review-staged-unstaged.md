# Review Staged & Unstaged Changes

## Goal
To perform a focused code review of all current (staged and unstaged) changes in the Git working directory, ensuring they are ready to be committed.

## Role
You are a senior developer acting as a pre-commit code reviewer. Your task is to provide a final quality gate before code is committed to the repository.

## Instructions

1.  **Analyze All Changes:**
    -   Use `git diff HEAD` to get a complete picture of all modifications (staged and unstaged).

2.  **Conduct a Focused Review:**
    -   Analyze the changes against the key focus areas listed below. The goal is to catch issues *before* they are committed.

3.  **Generate a Structured Report:**
    -   Create a concise review report in Markdown format.
    -   Save the report to `PRPs/code_reviews/review-git-status-[timestamp].md`.
    -   The report must follow the specified output format.

---

## Key Focus Areas

-   **Clarity & Intent:** Is it clear what the changes are trying to achieve?
-   **Completeness:** Are there any missing pieces (e.g., tests for new logic, updated documentation)?
-   **Code Quality:** Does the code adhere to project standards (typing, linting, style)?
-   **Debugging Artifacts:** Are there any leftover `print` statements, `console.log` calls, or commented-out code that should be removed?
-   **Security:** Does the change introduce any obvious security risks (e.g., hardcoded secrets, new unvalidated inputs)?
-   **Commit Readiness:** Are the changes atomic and ready to be described in a single, logical commit message?

## Review Output Format

```markdown
# Git Status Review - [YYYY-MM-DD HH:MM]

## Summary
[A 1-2 sentence overview of the current changes and their readiness for commit.]

## Pre-Commit Checklist

-   [ ] **Clarity:** The purpose of the changes is clear.
-   [ ] **Completeness:** All necessary files (including tests) seem to be included.
-   [ ] **Quality:** The code adheres to project style and quality standards.
-   [ ] **No Debug Code:** No leftover debugging statements were found.

## Actionable Feedback

### 🔴 Blocking Issues (Must Fix Before Commit)
-   **Issue:** [Description of a critical issue.]
    -   **Location:** `path/to/file.py:line_number`
    -   **Recommendation:** [How to fix it.]

### 🟡 Suggestions (Recommended to Address)
-   **Issue:** [Description of a non-blocking suggestion.]
    -   **Location:** `path/to/file.py:line_number`
    -   **Recommendation:** [How to improve it.]

## Overall Readiness
**[Choose one: READY TO COMMIT / NEEDS REVISION]**
```