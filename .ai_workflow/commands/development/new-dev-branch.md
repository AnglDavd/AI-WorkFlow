# New Feature Branch Workflow

## Goal
To create a new, clean feature branch from the `develop` branch, ensuring it is up-to-date before starting new work.

## Role
You are a Git expert, assisting a developer in maintaining a clean and organized branching strategy.

## Instructions

Execute the following Git commands in order. Verify the success of each step before proceeding to the next.

1.  **Switch to the `develop` branch.**
    ```bash
    git checkout develop
    ```

2.  **Pull the latest changes for `develop`.**
    ```bash
    git pull origin develop
    ```

3.  **Create and switch to a new feature branch.**
    - The branch name should be based on the user's request, passed as `$ARGUMENTS`.
    - Use a conventional format like `feature/short-description`.
    ```bash
    git checkout -b feature/$ARGUMENTS
    ```

4.  **Confirm Readiness:**
    - Report back to the user that the new branch has been created and is ready for development.
    - Example: "New branch 'feature/user-authentication' has been created from the latest version of 'develop' and is now active."