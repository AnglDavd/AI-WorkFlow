## Objective
This node asks the user to confirm the configuration before proceeding with the project creation.

## Pre-conditions
The file `/.ai_workflow/temp_state.vars` must exist and contain the `PROJECT_NAME`.

## Commands
```bash
source ./.ai_workflow/temp_state.vars

read -p "Use current directory for the project? (y/n): " USE_CURRENT_DIR

if [[ "$USE_CURRENT_DIR" == "y" ]]; then
    PROJECT_DIR="."
else
    read -p "Enter new directory name [default: $PROJECT_NAME]: " NEW_DIR_NAME
    PROJECT_DIR=${NEW_DIR_NAME:-$PROJECT_NAME}
fi

echo "export PROJECT_DIR=\"$PROJECT_DIR\"" >> ./.ai_workflow/temp_state.vars

echo ""
echo "Configuration Summary:"
echo "- Project Name: $PROJECT_NAME"
echo "- Project Directory: $PROJECT_DIR"
echo ""

read -p "Proceed with this configuration? (y/n): " CONFIRMATION
if [[ "$CONFIRMATION" != "y" ]]; then
    echo "User aborted setup."
    call_workflow "common/abort.md" "Setup aborted by user."
    exit 1 # Exit with a non-zero code to signify abortion
fi
```

## Verification Criteria
The command should exit with 0 if the user confirms.

## Next Steps
- **On Success (user confirms 'y'):** Proceed to [Create Project Structure](./03_create_structure.md).
- **On Failure (user enters 'n' or anything else):** Proceed to [Abort Workflow](../../common/abort.md).
