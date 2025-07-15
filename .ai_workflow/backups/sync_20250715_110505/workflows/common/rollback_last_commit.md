# Rollback Last Commit

## Objective
To quickly revert the project's repository to the state before the last commit, providing a rapid recovery mechanism.

## Role
You are a Git expert. Your task is to safely undo the most recent changes in the repository.

## Input
- None.

## Execution Flow

1.  **Confirm Action:**
    -   **CRITICAL:** Inform the user that this action will permanently discard the last commit and any uncommitted changes. Request explicit confirmation.
    -   **Question:** "This action will permanently discard the last commit and any uncommitted changes. Are you sure you want to proceed? (Yes/No)"

2.  **Await User Decision:** Wait for the user's response.

3.  **Act Based on Decision:**
    -   **If User Approves (Yes):**
        -   Execute the command: `git reset --hard HEAD~1`
        -   Report the result of the command.
        -   Inform the user: "Repository successfully reverted to the state before the last commit."
    -   **If User Disapproves (No):**
        -   Inform the user: "Rollback cancelled. No changes were made."

## Example Interaction

**Agent:** "This action will permanently discard the last commit and any uncommitted changes. Are you sure you want to proceed? (Yes/No)"

**User:** "Yes"

**Agent:** "Executing `git reset --hard HEAD~1`..."

**Agent:** "Repository successfully reverted to the state before the last commit."
