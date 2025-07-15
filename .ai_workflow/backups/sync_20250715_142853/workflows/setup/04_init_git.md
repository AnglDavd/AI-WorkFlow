## Objective
This node initializes a new Git repository IF the user chose to create a new project.

## Pre-conditions
- The setup mode (`SETUP_MODE`) is defined in `temp_state.vars`.
- The current working directory is the parent of the project directory.

## Commands
```bash
source ./.ai_workflow/temp_state.vars

# Only run git init if we are in 'new project' mode.
# In 'inject' mode, we MUST NOT touch the user's existing repository.
if [ "$SETUP_MODE" == "new" ]; then
    echo "Initializing a new Git repository for the project..."
    
    # The previous step already removed the old .git directory.
    # We just need to init, add, and commit.
    cd "$PROJECT_DIR"
    
    git init > /dev/null 2>&1
    git add . > /dev/null 2>&1
    git commit -m "Initial commit: Set up AI development framework" > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        handle_workflow_error "Git initialization failed. Check if Git is installed or if the directory is empty."
        exit 1
    fi
    echo "New Git repository initialized successfully."
else
    echo "Skipping Git initialization for existing project."
fi
```

## Verification Criteria
- If `SETUP_MODE` was 'new', a new `.git` directory should exist in the project folder.
- If `SETUP_MODE` was 'inject', no changes should have been made.

## Next Steps
- **On Success:** Proceed to [Final Cleanup](./05_cleanup.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).