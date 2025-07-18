# Start Project Setup

## Purpose
This node starts the project setup process by gathering the new project's name from the user.

## When to Use
- Starting a new project setup workflow
- Initializing project configuration
- Beginning the framework setup process

## Objective
This node starts the project setup process by gathering the new project's name from the user.

## Commands
```bash
# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting Project Setup workflow."

# Use environment variable or interactive prompt with auto-confirmation support
if [ -n "$PROJECT_NAME" ]; then
    echo "Using PROJECT_NAME from environment: $PROJECT_NAME"
elif [ "$AUTO_CONFIRM" = "true" ]; then
    PROJECT_NAME="my-awesome-app"
    echo "Auto-confirmation enabled, using default project name: $PROJECT_NAME"
else
    echo -n 'Enter your new project name (e.g., my-awesome-app): '
    read PROJECT_NAME
fi

if [ -z "$PROJECT_NAME" ]; then
    echo "PROJECT_NAME is empty. Aborting."
    ./.ai_workflow/workflows/common/error.md "Project name cannot be empty."
    exit 1
fi
PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/ /_/g')
echo "export PROJECT_NAME=\"$PROJECT_NAME\"" > ./.ai_workflow/temp_state.vars
```


## Verification Criteria
The command should exit with 0, and the `temp_state.vars` file should contain the project name.

## Next Steps
- **On Success:** Proceed to [Confirm Setup Configuration](./02_confirm_setup.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
