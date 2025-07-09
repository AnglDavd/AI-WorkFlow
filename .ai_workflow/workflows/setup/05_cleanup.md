## Objective
This node performs the final cleanup by removing the original framework directory.

## Pre-conditions
- The new project has been fully created and initialized.
- The `OLD_DIR_NAME` is stored in `temp_state.vars`.
- The current working directory is the new project directory.

## Commands
```bash
# The script that created the project is one level up
cd ..

source ./.ai_workflow/temp_state.vars

if [ -n "$OLD_DIR_NAME" ]; then
    rm -rf "$OLD_DIR_NAME"
else
    echo "Error: Could not determine the original directory to remove. Skipping cleanup."
    ./.ai_workflow/workflows/common/error.md "Cleanup failed: Could not determine the original directory to remove."
    exit 1
fi

# Clean up the temporary state file
rm ./.ai_workflow/temp_state.vars
```

## Verification Criteria
The original project directory should no longer exist.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
