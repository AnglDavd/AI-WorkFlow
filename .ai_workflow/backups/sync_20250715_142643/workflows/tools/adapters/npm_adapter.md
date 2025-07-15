## Objective
This node acts as a conceptual adapter for NPM tool calls, translating abstract actions into concrete NPM shell commands.

## Commands
```bash
# Arguments: $1 = action, $2 = args_string (e.g., "package='react' dev=true")

ACTION="$1"
ARGS_STRING="$2"

CONCRETE_COMMAND=""

case "$ACTION" in
    "install")
        # Extract package and dev status from ARGS_STRING
        PACKAGE=$(echo "$ARGS_STRING" | sed -n 's/.*package=\'\'\([^\\]\+\)\'\'.*/\1/p')
        DEV_STATUS=$(echo "$ARGS_STRING" | sed -n 's/.*dev=\'\'\([^\\]\+\)\'\'.*/\1/p')

        if [[ "$DEV_STATUS" == "true" ]]; then
            CONCRETE_COMMAND="npm install -D ${PACKAGE}"
        else
            CONCRETE_COMMAND="npm install ${PACKAGE}"
        fi
        ;;
    "run_script")
        # Extract script_name from ARGS_STRING
        SCRIPT_NAME=$(echo "$ARGS_STRING" | sed -n 's/.*script_name=\'\'\([^\\]\+\)\'\'.*/\1/p')
        CONCRETE_COMMAND="npm run ${SCRIPT_NAME}"
        ;;
    *)
        echo "Error: Unknown NPM action: $ACTION"
        ./.ai_workflow/workflows/common/error.md "Unknown NPM action: $ACTION"
        exit 1
        ;;
esac

echo "Simulated Concrete Command: ${CONCRETE_COMMAND}"
# In a real implementation, the agent would now execute: run_shell_command "$CONCRETE_COMMAND"
```

## Verification Criteria
The command should exit with 0, and the simulated concrete NPM command should be displayed.

## Next Steps
- This is a conceptual adapter. The process is finished after displaying the command.

