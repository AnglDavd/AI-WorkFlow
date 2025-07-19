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

# Use robust interactive input system
if [ -f ".ai_workflow/scripts/interactive_input.sh" ]; then
    echo "📋 Getting project name..."
    PROJECT_NAME=$(bash .ai_workflow/scripts/interactive_input.sh project-name)
    echo "Project name set: $PROJECT_NAME"
else
    # Fallback to simple input for compatibility
    if [ -n "${PROJECT_NAME:-}" ]; then
        echo "Using PROJECT_NAME from environment: $PROJECT_NAME"
    elif [ "${AUTO_CONFIRM:-}" = "true" ]; then
        PROJECT_NAME="my-awesome-app"
        echo "Auto-confirmation enabled, using default project name: $PROJECT_NAME"
    else
        echo -n 'Enter your new project name (e.g., my-awesome-app): '
        read PROJECT_NAME || PROJECT_NAME="my-awesome-app"
        
        if [ -z "$PROJECT_NAME" ]; then
            PROJECT_NAME=$(basename "$(pwd)" 2>/dev/null || echo "my-awesome-app")
            echo "Using directory-based project name: $PROJECT_NAME"
        else
            echo "Project name entered: $PROJECT_NAME"
        fi
    fi
fi

# Validate project name
if [ -z "$PROJECT_NAME" ]; then
    echo "❌ PROJECT_NAME is empty. Aborting."
    ./.ai_workflow/workflows/common/error.md "Project name cannot be empty."
    exit 1
fi

# Clean project name (remove/replace invalid characters)
PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/[^a-zA-Z0-9._-]/-/g' | tr '[:upper:]' '[:lower:]')
echo "export PROJECT_NAME=\"$PROJECT_NAME\"" > ./.ai_workflow/temp_state.vars
```


## Verification Criteria
The command should exit with 0, and the `temp_state.vars` file should contain the project name.

## Next Steps
- **On Success:** Proceed to [Confirm Setup Configuration](./02_confirm_setup.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
