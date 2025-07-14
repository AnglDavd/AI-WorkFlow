## Objective
This node performs the final cleanup actions based on the setup mode used.

## Pre-conditions
- The setup process is complete.
- The `SETUP_MODE` is defined in `temp_state.vars`.

## Commands
```bash
source ./.ai_workflow/temp_state.vars

# CASE 1: We injected the framework into an existing project.
if [ "$SETUP_MODE" == "inject" ]; then
    echo "--------------------------------------------------"
    echo "Framework injection complete."
    echo "This installer directory has served its purpose."
    echo "You can now safely delete this directory."
    echo "--------------------------------------------------"

# CASE 2: We created a new project from the installer.
elif [ "$SETUP_MODE" == "new" ]; then
    # The logic to handle directory cleanup if a new one was created
    # was complex and brittle. A simpler approach is to instruct the user.
    echo "--------------------------------------------------"
    echo "New project '$PROJECT_NAME' created successfully."
    echo "This installer directory is no longer needed."
    echo "You can now safely delete it."
    echo "--------------------------------------------------"
fi

# Clean up the temporary state file in the final project directory
if [ -n "$PROJECT_DIR" ] && [ "$PROJECT_DIR" != "." ]; then
    rm "$PROJECT_DIR/.ai_workflow/temp_state.vars"
else
    rm ./.ai_workflow/temp_state.vars
fi

```

## Verification Criteria
The `temp_state.vars` file should be removed from the final project directory.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).